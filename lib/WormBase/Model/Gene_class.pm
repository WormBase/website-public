package WormBase::Model::Gene_class;

use strict;
use warnings;
use base qw/WormBase::Model/;

sub gene_class {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object;
}


# Test...I need an accessor for this in SUPER
#sub previous_genes {
#  my ($self) = @_;
#  my $name = $self->current_object->name;
#  my $dbh = $self->dbh_ace;
#  my @genes = $dbh->fetch(-query=>qq{find Gene where Other_name="$name*"});
#  return \@genes;
#}


=head1 NAME

WormBase::Model::Gene_class - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

The original version of this script:

- returned multiple entries
- implemented a list of the full gene_class
- prioritzed the list of genes in the display by species (handle this in template)

- the view for remarks needs to take into account evidence formatting
- the main template has some notes at the bottom that need to be placed in the template.

- Previous genes requires access to Acedb for a custom query. This is now broken.

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
