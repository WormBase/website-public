package WormBase::Model::Antibody;

use strict;
use warnings;
use base 'WormBase::Model';

###########################################
# Components of the General Information widget
###########################################
sub location {
  my $self     = shift;
  my $object = $self->current_object;
  my @location = sort {$a cmp $b} $object->Location;
  my @stash;
  foreach (@location) {
    my $rep     = $_->Representative->Standard_name;
    my $address = $_->Mail; 
    push @stash,[$_,$rep,$address]
  }
  return \@stash;
}

sub generated_against_locus {
  my $self     = shift;
  my $object = $self->current_object;
  return [ $object->Gene ];
}

sub corresponding_gene {
  my $self     = shift;
  my $object = $self->current_object;
  my $gene   = $object->Gene;
  my @stash = $object->CDS;
  @stash      = $gene->Corresponding_CDS if ($gene && !@stash);
  return \@stash;
}

sub antigen {
  my $self     = shift;
  my $object = $self->current_object;
  my ($type,$comment) = eval { $object->Antigen->row };  
  return ([$type,$comment]);
}

###########################################
# Components of the Expression Pattern widget
###########################################
sub expression_patterns {
  my $self     = shift;
  my $object = $self->current_object;
  my @stash;
  
  my @expr_patterns = $object->Expr_pattern;
  foreach (@expr_patterns) {
    my $date = $_->Date || '';
    ($date) = $date =~ /(\d+) \d+:\d+:\d+$/;
    my $author = $_->Author || '';
    my $ref    = $author ? "$author $date" : $_;
    my $pattern = $_->Pattern || $_->Subcellular_localization || $_->Remark;
    push @stash,[$_,$ref,$pattern];
  }
  return \@stash;
}


# This is the original get_object.
# It will form the basis of search()
#sub _search_antibody {
#  my ($self,$c,$name) = @_;
#
##  if (my $object = $self->is_stashed('antibody',$c)) {
##	return $object;
##	}
#
## Use the stashed object to save on lengthy database queries
## between requests for widgets
#if ($c->stash->{current_object}) {
#  $c->log->debug("Using pre-stashed object: " . $c->stash->{current_object});
#  return $c->stash->{current_object};
#} else {
#  $c->log->debug("The requested object $name does not exist in the stash: We have to fetch it again.");
#}

# my $dbh = $self->dbh_ace;
#  # The most common request: by antibody ID
#  my @ab = $dbh->fetch('Antibody' => $name);
#
#  # Allow users to search by
#  #  -- three-letter gene names
#  #  -- CDSes
#  #  -- lab IDs
#  #  -- Antibody Other_names
#
#	unless (@ab) {
#  # Sometimes CDSes are not attached to the antibody - fetch from the locus
#  my @queries = ("find Gene where Public_name=*$name*; follow Antibody",
#			     "find Antibody where Other_name=*$name*",
#			     "find Antibody where Gene=*$name*,",  # This will not work
#			     "find Antibody where CDS=*$name*",
#			     "find Antibody where Location=$name*");
#  foreach (@queries) {
#	 @ab = $dbh->fetch(-query=>$_) unless (@ab);
#	 last if @ab;
#}
#}
#
#  $c->stash->{object} = $ab[0];
#  return $ab[0];
#}


=head1 NAME

WormBase::Model::Antibody - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

- The original script had a more detailed get_object.
  This will form the basis of search.

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
