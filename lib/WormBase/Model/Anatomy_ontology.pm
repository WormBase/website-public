package WormBase::Model::Anatomy_ontology;

use strict;
use warnings;
use base 'WormBase::Model';

=head1 NAME

WormBase::Model::Anatomy_ontology - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Norie  de la Cruz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=pod

NB:
Tree display skipped
subsection: Paper unclear -- Todd sent out note about making Paper and Reference consistent
subsection: Anatomy unclear
Section: Link_diagram not added

=cut

sub synonyms {
  my $self   = shift;
  my $object = $self->current_object;
  return $object->Synonym;
}

sub url {
  my $self   = shift;
  my $object = $self->current_object;
  return $object->URL;
}

sub go_term {
  my $self   = shift;
  my $object = $self->current_object;
  return $object->GO_term;
}

# TH: This MAY be handled by Model.pm. It's pretty ubiquitous
sub expression_pattern {
  my $self = shift;
  my $object = $self->current_object;
  my @data = $object->Expr_pattern;
  return \@data;  ## returns text
}

sub anatomy_function {
  my $self = shift;
  my $object = $self->current_object;
  my @anatomy_fns = $object->Anatomy_function;
  my %data;
  foreach my $anatomy_fn (@anatomy_fns){
    my $anatomy_fn_name = $anatomy_fn->name;
    my $phenotype = $anatomy_fn->Phenotype;
    my $phenotype_name = $phenotype->Primary_name;
    my @dataset = ($anatomy_fn,$phenotype_name);
    $data{$anatomy_fn_name} = \@dataset;
    # $counter++;
  }
  return \%data;  ## returns hash of array_references
}

sub anatomy_function_not {
  my $self = shift;
  my $object = $self->current_object;
  my @anatomy_fns = $object->Anatomy_function_not;
  my %data;
  foreach my $anatomy_fn (@anatomy_fns){
    my $anatomy_fn_name = $anatomy_fn->name;
    my $phenotype = $anatomy_fn->Phenotype;
    my $phenotype_name = $phenotype->Primary_name;
    my @dataset = ($anatomy_fn,$phenotype_name);
    $data{$anatomy_fn_name} = \@dataset;
    # $counter++;
  }
  return \%data;  ## returns hash of array_references
}

1;
