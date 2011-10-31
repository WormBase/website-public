package WormBase::Ace;

use strict;
use warnings;

use parent 'Ace';

# wishlist: list context should return a bunch
sub raw_fetch {
    my ($self, $object, $method) = @_;

    # run the optimized/correct method if possible
    my $raw_fetch_alt = "raw_fetch_\l$method";
    return $self->$raw_fetch_alt($object) if $self->can($raw_fetch_alt);

    my $class = $object->class;

    $self->raw_query(qq(find $class "$object"));
    my ($val) = $self->raw_query("show -a $method") =~ /^$method\s+"(.*?)(?<!(?<!\\)\\)"/sm;
    return $val;
}

# Returns the Species entry of the given object.
# Undef if the object does not have a Species entry.
# ASSUMPTION: Species string is simple (does not contain \ or " in it)
sub raw_fetch_species {
    my ($self, $object) = @_;
    my $class = $object->class;
    $self->raw_query(qq(find $class "$object"));
    my ($species) = $self->raw_query('show -a Species') =~ /Species\s+"([^"]+)"/o;
    return $species;
}

1;
