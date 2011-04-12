package WormBase::Test;

use strict;
use warnings;
use Carp;
use YAML qw(Dump);
use Test::More (); # isa_ok, use_ok
use Test::Builder;

use namespace::autoclean;

# generic WormBase tester
# base class for other WormBase testers

my $Test = Test::Builder->new;

################################################################################
# Constructors/accessors
################################################################################

sub new {
    my ($class, $args) = @_;
    croak 'Arguments must be in a hashref' if $args && ref $args ne 'HASH';

    my $self = bless {}, $class;

    return $self;
}

################################################################################
# Methods
################################################################################

sub dump {
    my $self = shift;
    if (@_) {
        $Test->diag(Dump(@_));
    }
    else {
        $Test->diag(Dump($self));
    }
}

################################################################################
# Tests from Test::*, wrapped around OO goodness.
################################################################################

# &method passes @_ straight to method, bypassing stack and prototyping

sub isa_ok { # from Test::More
    my $self = shift;
    return &Test::More::isa_ok;
}

sub use_ok { # from Test::More
    my $self = shift;
    return &Test::More::use_ok;
}

sub is_passing { # from Test::Builder
    return $Test->is_passing;
}

sub done_testing { # from Test::Builder
    $Test->done_testing;
}

1;
