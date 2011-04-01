package WormBase::Test;

use strict;
use warnings;
use Carp;

use YAML qw(Dump);
use Test::More;

use namespace::autoclean;

# generic WormBase tester
# base class for other WormBase testers

sub new {
    my ($class, $args) = @_;
    croak 'Arguments must be in a hashref' if $args && ref $args ne 'HASH';

    my $self = bless {}, $class;

    return $self;
}

sub dump {
    my $self = shift;
    if (@_) {
        diag(Dump(@_));
    }
    else {
        diag(Dump($self));
    }
}

1;
