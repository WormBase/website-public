package WormBase::Model::Gene_regulation;

use strict;
use warnings;
use base 'WormBase::Model';

sub in_situ_hybridization {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->In_situ;
}

sub genes {
  my ($self) = @_;
  my $object = $self->current_object;
  my @trans_regulator = ($object->Trans_regulator_gene,$object->Trans_regulator_seq);
  return \@trans_regulator;
}

sub cis_regulator {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Cis_regulator_seq;
}

sub allele_used {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Allele;
}

sub rnai_used {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->RNAi;
}

sub condition {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Other_regulator;
}


=pod

THIS STILL NEEDS TO BE MIGRATED

# THIS BELONGS IN A TEMPLATE
# Headings for more readable descriptions
my %headings = (Positive_regulate => 'Positively regulates',
		Negative_regulate  => 'Negatively regulates',
		Does_not_regulate  => 'Does not regulate');

my @targets = ($GR->Trans_regulated_gene,$GR->Trans_regulated_seq,$GR->Other_regulated);
foreach my $target (@targets) {
  my $bestname = Bestname($target);
  foreach (qw/Positive_regulate Negative_regulate Does_not_regulate/) {
    next unless ($GR->$_ || $GR->Result eq $_);
    if (my @conditions = $GR->$_) {
      my $string = "$headings{$_} ";
      $string .= link_gene($target);
      $string .= ' in ' . join('; ',map {
	my $label = $_;
	$label =~ s/_/ /g;
	lc("$label: ") .
	  ObjectLink($_->right)} @conditions);
      SubSection('',$string);
    } else {
      my $string = "$headings{$_} ";
      $string .= link_gene($target);
      SubSection('',$string);
    }
  }
}

  SubSection('',
	     map {
	       'See ' . ObjectLink($_)
		 . ' for the expression pattern of ' 
		   . link_gene($_->Gene || $_->CDS) . ' in a wild type background.' . br
		 } $GR->Target_info(2)) if $GR->Target_info;

=cut










# Formerly fetch_GR()
# Here's the start of a search
sub search {
  my ($self,$name) = @_;
  return unless $name;
  my @obj;
  my $DB;  # How will this work exactly?
  # @obj = $DB->fetch(-class=>'Gene_regulation',-name=>$name);
  unless (@obj) {
    my %seen;
    my @temp = grep {!$seen{$_}++ } $DB->fetch(-query=>qq/Find Gene_name "$name"; follow Public_name_for; where Gene_regulation/);
    # Let's try sequences as well
    push(@temp,grep {!$seen{$_}++ } $DB->fetch(-query=>qq/Find Gene_name "$name"; follow Sequence_name_for; where Gene_regulation/)) unless @temp;
    push(@temp,grep {!$seen{$_}++ } $DB->fetch(-query=>qq/Find Gene_name "$name"; follow Molecular_name_for; where Gene_regulation/)) unless @temp;
    @obj = map {$_->Trans_target} @temp;
    push (@obj,map {$_->Trans_regulator} @temp);
  }
  return @obj;
}


=head1 NAME

WormBase::Model::Gene_regulation - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Original CGI had search, multiple results display, etc.

I've renamed the "Gene Regulation ID" field to "Name" instead.

I changed the "General Info" section to "Identification"

link_gene logic needs to be migrated to the template

The regulates section has headings that belong in a template.


=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
