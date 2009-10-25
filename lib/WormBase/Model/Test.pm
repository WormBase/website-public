package WormBase::Model::Test;

use Moose;
#use strict;
#use warnings;
use namespace::clean -except => 'meta';
#use base 'WormBase::Model';

extends 'WormBase::Model';


# THIS SHOULD BE GENERIC.
# Is it an evidence hash under the Evidence tag?
sub evidence {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Evidence;
  return $data; ## returns Object;
}

sub driven_by_sequence {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Driven_by_CDS_promoter;
  return $data;
}

sub reporter_product {
  my ($self) = @_;
  my $object = $self->current_object;
  my %data;
  my @reporter_products = $object->Reporter_product;
  foreach my $reporter_product (@reporter_products){
    if($reporter_product =~ m/Other\_reporter/){
      next;
    }
    else{
      $data{$reporter_product} = $reporter_product;
    }
  }

  $data{other_product} = $object->Other_reporter;
  $data{ce_gene}       = $object->Gene;
  $data{ce_sequence}   = $object->CDS;
  
  return \%data;
}

sub injected_into_cgc_strain {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Injected_into_CGC_strain;
  return $data;
}

sub integrated_by {
  my ($self) = @_;
  my $object = $self->current_object;
  my $other = $object->Injected_into;
  
  my $data;
  if ($other eq 'Other_integration_method') {
    $data = $object->Integrated_by->right;
  } else {
    $data = $object->Integrated_by;
  }
  
  return $data;
}

sub location {
  my ($self) = @_;
  my $object = $self->current_object;
  my @location_objects = $object->Location;
  my @data;
  foreach my $location_object (@location_objects){
    my %data;
    $data{object}         = $location_object;
    $data{representative} = $location_object->Representative->Standard_name;
    $data{address}        = $location_object->Address(2);
    
    push @data, \%data;
  }  
  return \@data;
}

sub two_point {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data = $object->get('2_point');
  return \@data;
}


# map() is a perl built-in.  We probably shouldn't use it as a section/action since it's confusing.
#sub map {
sub map_position {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Map;
  return $data;
}


=pod

takes the $c and transgene object and returns a Phenotype object

=cut

sub phenotype {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Phenotype;
  return $data;
}

=pod

takes the $c and transgene object and returns an Expr_pattern object

=cut


# TH: I've changed this to expression_pattern.  Method names correspond to section names.
# These should be human readable.

#sub expr_pattern {
sub expression_pattern {
  my ($self) = @_;
  my $object = $self->current_object;
  my $data = $object->Expr_pattern;
  return $data;
}


=head1 NAME

WormBase::Model::Transgene - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

might want to return additional details for, say, the mapping experiments - two_point()
instead of dumping this onto the template

=head1 AUTHOR

Norie de la Cruz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

=pod

takes the $c and transgene object and returns an Evidence object (?)

=cut

1;
