package WormBase::Model::Motif;

use strict;
use warnings;
use base 'WormBase::Model';
  
sub source_database {
  my ($self) = @_;
  my $object = $self->current_object;
  my ($database,$accession1,$accession2) = $object->Database('@')->row;

  # TEMPLATE TODO: Need to fetch the correct URL for the database
  # SubSection('Source database',a({-href=>$database_urls->{$database}},$database));
  return $database;
}
  
sub accession_number {
  my ($self) = @_;
  my $object = $self->current_object;

  my ($database,$accession1,$accession2) = $object->Database('@')->row;
  my $accession = $accession2 || $accession1;
  
  # TEMPLATE TODO: 
  #SubSection('Name/Accession Number',
  #a({-href=>$motif_urls->{$database}.$accession},"$accession (details)"))
  return $accession;
}

sub dna_homology {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data = $object->DNA_homol;
  
  # This all belongs in the template
  #    foreach (@homol) {
  #      my $url; 
  #      if ($_ =~ /.*RepeatMasker/g) {
  #	$_ =~ /(.*):.*/;
  #	my $clone = $1;
  #	$url = "$_: ";
  #	$url .= a({-href=>"/db/seq/clone?name=$clone;class=Clone"},"[Clone report] ");
  #	$url .= a({-href=>"/db/seq/gbrowse/wormbase?name=$clone;class=Clone"},"[Genome View]");
  #      } else {
  #	$url = ObjectLink($_);
  #      }
  #    }
  return \@data;
}



sub peptide_homology {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data = $object->Pep_homol;
  return \@data;
}

sub motif_homology {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data = $object->Motif_homol;
  return \@data;
}

sub homol_homology {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data = $object->Homol_homol;
  return \@data;
}

sub gene_ontology {
  my ($self) = @_;
  my $object = $self->current_object;

  my @data;
  # In order to display evidence, I actually need to visit each gene or CDS object,
  # fetch all GO_terms and find the one which corresponds to the current one
  my $evidence;
  foreach my $go ($object->GO_term) {
    ($evidence) = $go->right;
    
    # THIS NEEDS TO BE HANDLED IN THE TEMAPLTE
#      (($go->right) ?
#       ': '. join(br,GetEvidenceNew(-object=>$go->right,-format => 'inline'))
#       : '');
    
    push @data,[ $go, $go->Definition, $go->right, $evidence ];
  }
  
  # TEMPALTE TODO
  #SubSection('Gene Ontology term associations',
  #i('This motif has been associated with the following Gene Ontology Terms'),
  # 	     $text);
}


=head1 NAME

WormBase::Model::Motif - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

To migrate
Configuration->database_urls
Configuration->Motif_urls

The various *homol methods all have formatting logic decisions that need to be migrated into the tempaltes

GENe ontology has formatting that needs to migrate to a template

I renamed "Gene Ontology assocaitions" into a widget called "associations" with a field called "gene_ontology".


GetEvidence needs to be handled

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
