package WormBase::Model::Structure_data;

use strict;
use warnings;
use base 'WormBase::Model';

# No longer available!
#__PACKAGE__->mk_accessors(qw/similarity_display_cutoff/);
# Should just be autoload.

sub database {
  my ($self) = @_;
  my $object = $self->current_object;
  my $db_info = $object->Db_info;
  my @db_rows = $db_info->row if $db_info;
  my $database  = $db_rows[1];
  my $native_id = $db_rows[3];

  my $formatted_native_id = $native_id;
  if ($database eq 'PDB') { $formatted_native_id =~ s/_.+$//; }
  
  my $formatted_database = $database;
  $formatted_database =~ s/^Northeast Structural Genomics Consortium$/NESGC/;
  $formatted_database =~ s/^NYSGXRC$/NYSGRC/;
  $formatted_database =~ s/^OPPF: Oxford Protein Production Facility$/NON-OPPF/;
  $formatted_database =~ s/^RSGI$/NON-RSGI/;
  return $formatted_database;
}

sub target_id {
  my ($self) = @_;
  my $object = $self->current_object;
  my $db_info = $object->Db_info;
  my @db_rows = $db_info->row if $db_info;
  my $database  = $db_rows[1];
  my $native_id = $db_rows[3];
  return $native_id;
  
  # This belongs in the template
  #my $external_link = $formatted_database eq 'PDB' ? a({-href=>sprintf(Configuration->Protein_links->{PDB},$formatted_native_id), -target=>'_blank'}, $native_id)
#                                                   : a({-href=>sprintf(Configuration->Protein_links->{TARGETDB},$formatted_native_id, $formatted_database), -target=>'_blank'}, $native_id);
}


sub sequence {
  my ($self) = @_;
  my $object = $self->current_object;
  
  my $protein = $object->Protein;
  my $peptide = $protein->Peptide if $protein;
  my $sequence = $peptide->asPeptide if $peptide;
  
  # Format sequence
  $sequence =~ s/^>[^\n]*\n+//;
  $sequence =~ s/\n+//g;
  $sequence =~ s/(.{40})/$1<BR>/g;
  return $sequence;
}


sub status {
  my ($self) = @_;
  my $object = $self->current_object;
  my @status = map {s/_/ /g; $_;} $object->Status;
  return \@status;

  # Belongs in template
  # push (@status, '', a({-href => '/etc/structure_status_tags.html'}, '[click here for a list of all tags]'));
}


# Returns a table with rows of: homol protein, similarity
sub homology {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = {};
  my @homols = $object->Pep_homol;

  $data->{wormpep_release}  = $object->Wormpep_release;
  $data->{display_cutoff}   = $self->similarity_display_cutoff;

  foreach my $homol (@homols){
    # Pep_homol	WP:CE01784	blat_structure	95.16	2	62	154	214
    my @homol_rows       = $homol->row;
    my $homol_protein      = $homol_rows[0];
    my $percent_similarity = $homol_rows[2];

    next unless ($percent_similarity >= $data->{display_cutoff});
    
    # Template
    # my $formatted_homol_protein = a({-href => Object2URL($homol_protein)}, $homol_protein);
    push @{$data->{table}},[$homol_protein, $percent_similarity]; 
  }
  return $data;
}

=head1 NAME

WormBase::Model::Structure_data - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION 

     database: Move names of external resources to configuration
     target_id: Remove external URLs to configuration
     Reconcile redundancy between database and target_id
     status: Move Status markup to template

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
