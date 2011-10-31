package WormBase::Ace;

use strict;
use warnings;

use parent 'Ace';

# Returns the Species entry of the given object.
# Undef if the object does not have a Species entry.
# ASSUMPTION: Species string is simple (does not contain \ or " in it)
sub raw_species {
    my ($self, $object) = @_;
    my $class = $object->class;
    $self->raw_query(qq(find $class "$object"));
    my ($species) = $self->raw_query('show -a Species') =~ /Species\s+"([^"]+)"/o;
    return $species;
}

1;
