package WormBase::Model::Sequence;

use strict;
use warnings;
use base 'WormBase::Model';

# Was get_seq() and _get_seq(), now the generic search method
# This needs to be refactored.

=pod

sub search {
  my ($name,$class) = @_;
  my $thing = _get_seq($name,$class) or return;
  if ($thing->class eq 'Protein') {
    my $seq = $thing->Corresponding_CDS;
    param(name  => $seq);
    param(class => $seq->class);
    return $seq;
  } elsif ($thing->class eq 'Gene_name') {
    my $gene = $thing->Public_name_for || $thing->CGC_name_for || $thing->Molecular_name_for
      || $thing->Other_name_for || $thing->Sequence_name_for;
    my $seq = $gene->Corresponding_CDS || $gene->Corresponding_transcript || $gene->Corresponding_pseudogene;
    if ($gene && !$seq) {
	# Send us to Gene for the history display
	# I should just creeate a separate history page...
	exit;
	AceRedirect(gene => $gene);
    } else {
	param(name  => $seq);
	param(class => $seq->class);
    }
    return $seq;
  } elsif ($thing->class eq 'Gene') {
    # There could, of course, be multiple CDSes here.
    my $seq     = $thing->Corresponding_CDS || $thing->Corresponding_transcript || $thing->Corresponding_pseudogene;
    # Some genes have no sequence yet.  Just redirect them to the gene
    # page since there really won't be any informative information on
    # the sequence page form them
    AceRedirect(gene => $thing) unless $seq;
    param(name  => $seq);
    param(class => $seq->class);
    return $seq;
  } elsif ($thing->class eq 'Transcript') {
    # There could, of course, be multiple CDSes here.
    my $seq = $thing;
    param(name  => $seq);
    param(class => $seq->class);
    return $seq;
  }
  return $thing;
}


# Fetching an object or sequence from the DB should be optimized and
# library-ized.  GetAceObject could form the basis but it needs to be
# robustified and have configuration parameters added. - TH
sub _get_seq {
  my ($name,$class) = @_;
  $name =~ s/^cel//i;  # people sometimes add the CEL prefix

  # try Pseudogenes
  my @seq = $DB->fetch('Pseudogene' => $name);

  # CDSes
  @seq = $DB->fetch('CDS' => $name) unless (@seq);

  # HACK! HACK! HACK!
  # Rearranged this heuristic for WS130.  Is it still correct?
  # Previously, I was trying to fetch transcripts first but this was blocking retrieval
  # of genes from the in-page prompt.

  # Try transcripts first to pick up non-coding transcripts
  @seq = $DB->fetch('Transcript' => $name) unless @seq;

  # Is this a non-coding transcript?  If so, let's return
  my $flag;
  map {$flag++ if $_->Method eq 'non_coding_transcript'} @seq;
  return $seq[0] if $flag;

  # Genes
  @seq = $DB->fetch('Gene' => $name) unless @seq;

  # Gene-names
  @seq = $DB->fetch('Gene_name' => $name) unless @seq;

  # Proteins
  @seq = $DB->fetch('Protein' => $name) unless @seq

  # Next, search via Sequence for clones and such
  unless (@seq) {
    $class = 'Sequence';
    @seq = $DB->fetch($class => $name);
  }

  # Search via Locus
  # NOW DEPRECATED BUT SAVE UNTIL POLYMORPHISMS CONVERTED
  #unless (@seq) {
  #  if (my $gene = $DB->fetch(Locus => $name)) {
  #    # Is this right for CDS?
  #    @seq = $gene->CDS;
  #    unless (@seq) {
  #	AceRedirect('gene' => $gene);
  #	exit 0;
  #      }
  #    }
  #  }

  if (@seq > 1) {
    PrintTop(undef,'Sequence','Search Results');
    AceMultipleChoices($name,'',\@seq);
    exit 0;
  }

  if (@seq == 1) {
#    unless ($seq[0]->Species(0)) { # maybe a ghost
#      # Splices should ALWAYS be class CDS now.
#      my @splices = $DB->fetch('CDS'=>"${name}*");
#      @seq = @splices if @splices;
#    }
    return $seq[0];
  }
}

=cut


=head1 NAME

WormBase::Model::Sequence- Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

=head1 AUTHOR

Todd W. Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
