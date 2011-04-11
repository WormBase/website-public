package WormBase::Test;

use strict;
use warnings;
use Carp;
use YAML qw(Dump);
use Test::More ();
use Test::Builder;

use namespace::autoclean;

# generic WormBase tester
# base class for other WormBase testers

my $Test = Test::Builder->new;

sub new {
    my ($class, $args) = @_;
    croak 'Arguments must be in a hashref' if $args && ref $args ne 'HASH';

    my $self = bless {}, $class;

    return $self;
}

sub dump {
    my $self = shift;
    if (@_) {
        $Test->diag(Dump(@_));
    }
    else {
        $Test->diag(Dump($self));
    }
}

sub isa_ok {
    my $self = shift;
    return &Test::More::isa_ok; # calls isa_ok, passing @_ straight to it
}

1;
