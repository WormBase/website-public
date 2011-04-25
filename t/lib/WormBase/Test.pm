package WormBase::Test;

use strict;
use warnings;
use Carp;
use Data::Dumper;
use Readonly;
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

=head1 CONSTANTS

Constants related to testing WormBase. These can be accessed either as
interpolable variables or subroutines/methods:

    $WormBase::Test::CONSTANT
    WormBase::Test::CONSTANT

=over

=item B<WB_BASE>

The namespace/prefix/base of all WormBase classes.

=cut

Readonly our $WB_BASE => 'WormBase';
sub WB_BASE () { return $WB_BASE; }

=back

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

Produces a data dump of the arguments. If no arguments are
provided and this is called as an instance method, produces a dump of the
tester object itself.

=cut

sub dump {
    my $self = shift;

    # following taken from Data::Dumper::Concise
    local $Data::Dumper::Terse     = 1;
    local $Data::Dumper::Indent    = 1;
    local $Data::Dumper::Useqq     = 1;
    local $Data::Dumper::Deparse   = 1;
    local $Data::Dumper::Quotekeys = 0;
    local $Data::Dumper::Sortkeys  = 1;
    local $Data::Dumper::Deepcopy  = 1;

    if (@_) {
        $Test->diag(Dumper(@_));
    }
    else {
        $Test->diag(Dumper($self));
    }
}

=item B<get_parents_methods($class)>

    my @parents_methods = $tester->get_parents_methods($class);

Get the methods present in all parent classes of the given class.
The methods will be L<Moose::Meta::Method> objects. Often, it is useful to
get the unqualified method names like so:

    @method_names = map { $_->name } @parents_methods;

=cut

sub get_parents_methods {
    my ($self, $class) = @_;
    $class = ref $class || $class or croak 'Must provide object or class as arg';
    $class = $self->fully_qualified_class_name($class);

    my @parents = $class->meta->superclasses;
    return map { eval {$_->meta->get_all_methods} } @parents;
}

=item B<get_roles_methods($class)>

    my @roles_methods = $tester->get_roles_methods($class);

Get the methods provided in all the roles of a given class.

=cut

sub get_roles_methods {
    my ($self, $class) = @_;
    $class = ref $class || $class or croak 'Must provide object or class as arg';
    $class = $self->fully_qualified_class_name($class);

    my @roles = $class->meta->calculate_all_roles;
    # create an anonymous class['s metaclass] to compose roles into
    my $anon_meta = Moose::Meta::Class->create_anon_class;

    # get the methods before roles are applied
    my %excl = map {$_->name => 1} $anon_meta->get_all_methods;

    # apply all roles
    foreach my $role (@roles) {
        # add required [dummy] methods to anon class
        foreach ($role->get_required_method_list) {
            $excl{$_} = 1; # this required method isn't provided by the role
            $anon_meta->add_method($_, sub {});
        }
        $role->apply($anon_meta);
    }

    # return the methods which weren't there before applying roles
    return grep { !$excl{$_->name} } $anon_meta->get_all_methods;
}

=item B<get_class_specific_methods($class|$obj)>

    @my_methods = $tester->get_class_specific_methods($class);
    @my_methods = $tester->get_class_specific_methods($obj);

Get the methods declared in the given class. This excludes methods originally
defined in a parent class or a consumed role.

=cut

sub get_class_specific_methods {
    my ($self, $class) = @_;
    $class = ref $class || $class  or croak 'Must provide object or class as arg';
    $class = $self->fully_qualified_class_name($class);

    my %roles_methods = map {$_->name => 1} $self->get_roles_methods($class);
    my %parents_methods = map {$_->name => 1} $self->get_parents_methods($class);

    return grep {!$roles_methods{$_->name} && !$parents_methods{$_->name}}
        $class->meta->get_all_methods;
}

=item B<fully_qualified_class_name($class)>

    my $full_class = WormBase::Test->fully_qualified_class_name('Web');
    # WormBase::Web

Takes a class name and fully qualifies it with the WB_BASE constant a prefix
if not already done. Useful for dynamically creating objects.

=cut

sub fully_qualified_class_name { # invocant-independent
    my ($invocant, $name) = @_;
    return $invocant->_fully_qualified_class_name($WB_BASE, $name);
}


################################################################################
# Test Methods
################################################################################

=back

=head2 Test Methods

=over

=item B<call_method_ok($object, $method)>

    my $result = $tester->call_method_ok($object, $method);

Tests calling a method with an object. This method will essentially do
$object->$method and captures errors. The test passes if the method
is called without errors.

=cut

sub call_method_ok {
    my ($self, $object, $method) = @_;
    croak 'Must provide object and method as arguments'
        unless $object && $method;

    my $data = eval {$object->$method};
    $Test->ok(! $@, "$method called without problems")
        or $Test->diag("$object call $method: $@");
    return $data;
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
to import some of the Test:: modules directly.

=cut

# &method passes @_ straight to method, bypassing stack and prototyping

=pod

From L<Test::More>

=over

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

################################################################################
# Private methods
################################################################################

sub _fully_qualified_class_name { # invocant-independent
    my ($invocant, $prefix, $name) = @_;

    return $name =~ /^$prefix/o ? $name : "${prefix}::${name}";
}

=head1 AUTHOR

=head1 BUGS

=head1 SEE ALSO

=head1 COPYRIGHT

=cut

1;
