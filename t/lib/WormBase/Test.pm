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

=head1 NAME

WormBase::Test - a generic object-oriented WormBase tester

=head1 SYNOPSIS

   my $tester = WormBase::Test->new;

   $tester->dump($wb_obj, [1,2,3], 'string');

   $tester->isa_ok([1,2,3], 'ARRAY'); # ok
   $tester->done_testing;

=head1 DESCRIPTION

This provides a base class for WormBase tester objects and provides
introspective tools compatible TAP output.

=head1 METHODS

=head2 Construction

=over

=cut

################################################################################
# Constructors/accessors
################################################################################

=item B<new>

    my $tester = WormBase::Test->new;

Creates a new tester object.

=cut

sub new {
    my ($class, $args) = @_;
    croak 'Arguments must be in a hashref' if $args && ref $args ne 'HASH';

    my $self = bless {}, $class;

    return $self;
}

=back

=head2 Introspection

=over

=cut

################################################################################
# Methods
################################################################################

=item B<dump([@objects])>

    $tester->dump; # dump of $tester

    WormBase::Test->dump(@objs);
    $tester->dump(@objs);

Produces a YAML dump of the arguments. If no arguments are provided and this is
called as an instance method, produces a YAML dump of the tester object itself.

=cut

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

=back

=head2 Wrapped test methods from Test::*

The following are test methods from various Test:: modules wrapped in this class
and behave identically to their corresponding subroutines in their original
module. In general, they are used like so:

    WormBase::Test->method(@args);
    $tester->method(@args);

They are intended to be used by subclasses of WormBase::Test which do not wish
to use some of the Test:: modules directly.

=over

=cut

# &method passes @_ straight to method, bypassing stack and prototyping

=pod

From L<Test::More>

=item B<isa_ok>

=cut

sub isa_ok { # from Test::More
    my $self = shift;
    return &Test::More::isa_ok;
}

=item B<use_ok>

=cut

sub use_ok { # from Test::More
    my $self = shift;
    return &Test::More::use_ok;
}

=back

=cut


1;
