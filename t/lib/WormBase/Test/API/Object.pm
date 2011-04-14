package WormBase::Test::API::Object;

use strict;
use warnings;
use Carp;
use Test::Builder;
use Readonly;
use Class::MOP;

use namespace::autoclean;

use base 'WormBase::Test::API';

my $Test = Test::Builder->new;

# WormBase API model object tester

=head1 NAME

WormBase::Test::API::Object - WormBase API object tester

=head1 SYNOPSIS

    my $tester = WormBase::Test::API::Object->new({
        conf_file => $conf_file, # e.g. 'Paper' or 'WormBase::API::Object::Paper'
        class     => $class,
    });

    my @test_object_names = qw(a b c d);

    # automatic testing
    my %test_objects = $tester->run_common_tests(@test_object_names);

    # finer autotesting
    $tester->run_common_tests({
        objects                 => \@test_object_names,
        # check only the methods specific to the class
        exclude_parents_methods => 1,
        exclude_roles_methods   => 1,
    });

    $tester->run_common_tests({
        objects         => \@test_object_names,
        # check only these methods
        include_methods => ['method1', 'method2'],
    });

    $tester->run_common_tets({
        objects         => \@test_object_names,
        # check all methods except
        exclude_methods => ['badmethod', 'manually_test_this'],
    });

    # manual testing
    $tester->class('Variation');
    my $obj = $tester->fetch_object_ok('WBVar00249542');
    my $data = $tester->call_method_ok($var, 'name');
    $tester->compliant_data_ok($data);



    # more advanced manual testing
    my ($fixed_data, @problems) = $tester->compliant_data_ok($data);
    ... # some manual inspection of problems or battery of tests using Test::More

    my @methods = map{$_->name} $tester->get_class_specific_methods;
    $tester->call_method_ok($obj, $_) foreach grep {...} @methods;

=head1 DESCRIPTION

Tester class for testing WormBase models and their objects. Fundamentally,
the model is tested by fetching instances of the model and exercising the code
through calls and standards compliance. The tester is designed to help
facilitate these tests anywhere from automating the "common" tests to calling
specific methods and capturing their error. This class, like the WormBase::Test
class that it inherits from will emit TAP compatible output for use with
Test::Harness (and its prove command).

=head1 CONSTANTS

Constants related to testing objects. These can be accessed either as
interpolable variables or subroutines/methods:

    $WormBase::Test::API::Object::CONSTANT
    WormBase::Test::API::Object::CONSTANT

=over

=item B<OBJECT_BASE>

The namespace/prefix/base of all WormBase model objects.

=cut

Readonly our $OBJECT_BASE => $WormBase::Test::API::API_BASE . '::Object';
sub OBJECT_BASE () { return $OBJECT_BASE; }

=back

=head1 METHODS

=head2 Constructor and accessors

=over

=cut

################################################################################
# Constructor & Accessors
################################################################################

# yes, rolling my own class. may replace with Moose or something later

=item B<new($argshash)>

    my $tester = WormBase::Test::API::Object->new({
        class     => $class, # optional
        conf_file => $file,  # or api => $api
    });

Creates an object tester with an underlying L<WormBase::API> object. See
L<WormBase::Test::API> for more details on the API object construction.

The tester may optionally be associated with a particular class to test, which
alleviates the need to specify a class in some of the class-specific tests.

If a class is provided, the class module will be loaded (if not already) and
the following class-specific tests will be run: test that the class is in fact
a WormBase model object class; test that the class is immutable for Moose
optimizations.

If a class is not provided, these tests can be run after constructing the
tester object. The class can also be explicitly re/set later with L<class>.

=cut

sub new {
    my ($class, $args) = @_;

    my $self = $class->SUPER::new($args);
    if ($args->{class}) { # run class tests automatically
        my $class = $self->class($args->{class});

        # attempt to load class if not already
        unless (Class::MOP::is_class_loaded($class)) {
            $self->use_ok($class);
        }

        $self->class_hierarchy_ok($args->{class});
        $self->class_immutable_ok($args->{class});
    }
    return $self;
}

=item B<class([$class])>

    $tester->class($class); # e.g. 'Paper'
    my $class = $tester->class;

=cut

sub class { # accessor/mutator
    my ($self, $param) = @_;
    if ($param) {
        croak "Not a string!" if ref $param;
        return $self->{class} = $self->fully_qualified_class_name($param);
    }
    return $self->{class};
}

=back

=head2 Utility methods

These methods are used to help with testing model objects but not
necessarily test methods themselves. See the L<"Test methods"> for those.

=over

=cut

################################################################################
# Methods
################################################################################

=item B<fetch_object($argshash)>

    my $obj = $tester->fetch_object({
        name     => $name,
        class    => $class, # optional unless set earlier
        aceclass => $aceclass, # for fetching WB objects using an Ace class
    })

Fetches a L<WormBase::API::Object> object of a given class. This uses (and reveals)
the underlying WormBase::API object's interface to fetch.

C<name> is required. C<class> or C<aceclass> is required unless the class of
the tester object has been set beforehand.

=cut

sub fetch_object {
    my ($self, $args) = @_;
    croak 'Must provide object details in arguments!' unless $args;
    my ($name, $class, $aceclass);
    if (ref $args eq 'HASH') {
        croak 'Must provide name of object in arguments' unless $args->{name};
        $name     = $args->{name};
        $class    = $args->{class};
        $aceclass = $args->{aceclass};
    }
    else {
        $name = $args;
    }

    $class ||= $self->class;
    croak 'Must specify class of object to fetch, either through',
        '$tester->class or using a hashref as arguments'
        unless $class;

    my $api = $self->api or die "Can't get $WormBase::Test::API::API_BASE object";

    return $api->fetch({class => $class, name => $name, aceclass => $aceclass});
}

=item B<fully_qualified_class_name($class)>

    my $full_class = WormBase::Test::API::Object->fully_qualified_class_name('Paper');
    # $full_class is now 'WormBase::API::Object::Paper'

    $tester->fully_qualified_class_name('Paper'); # can be called as instance method
    $full_class = $tester->fully_qualified_class_name($full_clas); # unchanged

Takes a class name and fully qualifies it with the OBJECT_BASE constant as a
prefix if not already done.

=cut

sub fully_qualified_class_name { # invocant-independent
    my ($invocant, $name) = @_;

    return $name =~ /^$OBJECT_BASE/o ? $name : "${OBJECT_BASE}::${name}";
}

=item B<get_parents_methods([$class])>

    my @parents_methods = $tester->get_parents_methods($class);

Get the methods present in all parent classes of the given class. The class
must be provided unless previously set for the tester object. The methods
will be L<Moose::Meta::Method> objects. Often, it is useful to get the
unqualified method names like so:

    @method_names = map { $_->name } @parents_methods;

=cut

# these are nice utilities; perhaps it should be put in WormBase::Test
sub get_parents_methods { # of WormBase class.
    my ($self, $class) = @_;
    $class ||= $self->class or croak 'Must provide class as an argument';
    $class = $self->fully_qualified_class_name($class);

    my @parents = $class->meta->superclasses;
    return map { eval {$_->meta->get_all_methods} } @parents;
}

=item B<get_roles_methods([$class])>

    my @roles_methods = $tester->get_roles_methods($class);

Get the methods provided in all the roles of a given class. The class
must be provided unless previously set for the tester object.

=cut

sub get_roles_methods {
    my ($self, $class) = @_;
    $class ||= $self->class;
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

=item B<get_class_specific_methods([$class])>

    my @my_methods = $tester->get_class_specific_methods($class);

Get the methods declared in the given class. This excludes methods originally
defined in a parent class or a consumed role. The class must be provided
unless previously set for the tester object.

=cut

sub get_class_specific_methods {
    my ($self, $class) = @_;
    $class ||= $self->class;
    $class = $self->fully_qualified_class_name($class);

    my %roles_methods = map {$_->name => 1} $self->get_roles_methods($class);
    my %parents_methods = map {$_->name => 1} $self->get_parents_methods($class);

    return grep {!$roles_methods{$_->name} && !$parents_methods{$_->name}}
        $self->get_all_methods;
}

=back

=head2 Test methods

These methods facilitate testing and emit TAP. They all return the success
status of the test in scalar context and will also do so in list context unless
otherwise specified.

=over

=cut

################################################################################
# Test methods
################################################################################

=item B<run_common_tests($argshash)>

Run tests common to model objects. The names of test objects must be provided
as arguments:

    my @test_objects = ('Object 1', 'Object 2'); # names of objects
    $tester->run_common_tests(@test_objects);

or in the "objects" entry of an arguments hashref ("argshash"):

    $tester->run_common_tests({objects => \@test_objects});

This method will attempt to fetch each object and run L<compliant_methods_ok>
on them. If the parents' or roles' methods should not be tested for each
object, specify that in the argshash:

    $tester->run_common_tests({
        objects                 => \@test_objects,
        exclude_parents_methods => 1,
        exclude_roles_methods   => 1,
    });

If the fetched objects are desired, run_common_tests will return a hash in list
context with the object name as the key and object as the value:

    my %object_hash = $tester->run_common_tests(@test_objects);

It is possible that some of the objects are not fetched so do not assume that
C<values %object_hash> will be the same as @test_objects (even after rearrangement).

In scalar context, run_common_tests will return the test success.

CAVEAT: The tester object B<must> have an associated class to run the common tests.

=cut

sub run_common_tests {
    my $self = shift;
    croak 'No arguments given. Call with name of objects to fetch, ',
          'or hash with name of objects and additional options'
          unless @_;
    my $class = $self->class
        or croak 'Need to provide tester with test class via class accessor';

    my @object_names;
    my $method_args; # for method compliance test
    if (ref $_[0] eq 'HASH') {
        my $args = shift;
        croak 'Need objects in hash' unless $args->{objects};
        @object_names = @{$args->{objects}};

        $method_args->{exclude} = $args->{exclude_methods} if $args->{exclude_methods};

        my $large_exclusions; # will disable inclusions
        foreach my $type (qw(parents roles)) {
            next unless $args->{"exclude_${type}_methods"};
            $large_exclusions ||= 1;
            my $m = "get_${type}_methods";
            push @{$method_args->{exclude}}, map {$_->name} $self->$m($class);
        }

        # we must check for large exclusions because inclusions
        # override all exclusions in the compliant_methods_ok method
        $method_args->{include} = $args->{include_methods}
            if !$large_exclusions && $args->{include_methods};
    }
    else {
        @object_names = @_;
    }

    my $ok;
    my %objects;
    foreach my $obj_name (@object_names) {
        my $obj = $self->fetch_object_ok({name => $obj_name});
        my $meth_ok = $self->compliant_methods_ok($obj, $method_args || ());
        $ok &&= $meth_ok;
        $objects{$obj_name} = $obj if $obj;
    }

    return wantarray ? %objects : $ok;
}

=item B<class_hierarchy_ok([$class])>

    $tester->class_hierarchy_ok($class);

Tests that the class is a WormBase model object and consumes the model object
role. A class must be provided unless previously set for the tester object.

=cut

sub class_hierarchy_ok { # checks that the class has the right hierarchy
    my ($self, $class) = @_;
    $class ||= $self->class;
    croak 'Must provide a class as an argument!' unless $class;

    $class = $self->fully_qualified_class_name($class);

    return $Test->subtest("Class $class hierarchy ok" => sub {
        # check that it's a WormBase Object descendent
        $self->isa_ok($class, $OBJECT_BASE, $class);

        # implements Object role
        my $role = "${WormBase::Test::API::API_BASE}::Role::Object";
        $Test->ok($class->does($role), "$class does role $role");
    }); # end of subtest
}

=item B<class_immutable_ok([$class])>

    $tester->class_immutable_ok($class);

Tests that the class is immutable, which causes Moose to optimize certain
metaclass features and improve construction of objects.
See L<Moose::Manual::BestPractices/"namespace::autoclean and immutabilize">
for details.

=cut

sub class_immutable_ok {
    my ($self, $class) = @_;
    $class ||= $self->class or croak 'Must provide a class as an argument!';

    $class = $self->fully_qualified_class_name($class);

    return $Test->ok($class->meta->is_immutable, "Class $class is immutable");
}

=item B<fetch_object_ok($argshash)>

    my $obj = $tester->fetch_object_ok($args)

Tests fetching a model object. Identical interface to L<fetch_object>.

=cut

sub fetch_object_ok {
    my ($self, $args) = @_;

    my $name = ref $args eq 'HASH' ? $args->{name} : $args;
    $Test->ok(my $obj = $self->fetch_object($args), 'Fetch object ' . $name);
    return $obj;
}

=item B<compliant_methods_ok($object, $argshash)>

    $tester->compliant_methods_ok($object);

Tests all methods of an object by calling them and checking that their data
are standards compliant as determined by WormBase::API::Role::Object::_check_data().
The test passes if the method is called without error and the returned data
is standards compliant.

=cut

sub compliant_methods_ok {
    my $self = shift;
    my ($wb_obj, $args) = @_;
    croak 'A WormBase object must be an argument!'
        unless ref $wb_obj && $wb_obj->isa($OBJECT_BASE);
    croak 'Options must be a hashref!' if $args && ref $args ne 'HASH';

    my $meta  = $wb_obj->meta;
    my $class = $meta->name;    # same as ref $wb_obj;
    my @methods = $self->_grep_public_methods($meta->get_all_methods);

    # deal with inclusion-exclusion options. inclusions override exclusions
    my (%include, %exclude);
    if ($args->{include}) { # test only these methods (if public)
        croak 'Include option must be arrayref!'
            unless ref $args->{include} eq 'ARRAY';
        %include = map {$_ => 1} @{$args->{include}} if $args->{include};
        @methods = grep { $include{$_->name} } @methods;
    }
    elsif ($args->{exclude}) { # test all public methods except these
        croak 'Exclude option must be arrayref!'
            unless ref $args->{exclude} eq 'ARRAY';
        %exclude = map {$_ => 1} @{$args->{exclude}} if $args->{exclude};
        @methods = grep { !$exclude{$_->name} } @methods;
    }

    my $test_name = $wb_obj->object . " of class $class has compliant methods";

    unless (@methods) {
        $Test->ok(0, $test_name);
        $Test->diag('No public methods found');
        $Test->diag('Include: ', join(', ', @{$args->{include}})) if %include;
        $Test->diag('Exclude: ', join(', ', @{$args->{exclude}})) if %exclude;
        return;
    }

    return $Test->subtest($test_name, => sub {
        foreach my $method (@methods) {
            my $m = $method->name;
            my $data = $self->call_method_ok($wb_obj, $m);
            $self->compliant_data_ok($data, $m);
        }
    }); # end of subtest
}

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


=item B<compliant_data_ok($data, $testname)>

    my $ok = $tester->compliant_data_ok($data, $testname);

Tests whether the given datum is standards compliant as determined by
WormBase::API::Role::Object::_check_data. The test passes if the datum
is standards compliant.

In list context, return data fixed by _check_data followed by a list of problems
found by _check_data. An empty list is returned if there were no problems.

=cut

sub compliant_data_ok {
    my ($self, $data, $name) = @_; # unpacking data; _check_data will not mangle it
    my $test_name = (defined $name ? "$name d" : 'D') . 'ata is standards compliant';

    my $ok;

    if (my ($fixed_data, @problems) = WormBase::API::Role::Object->_check_data($data)) {
        $ok = $Test->ok(0, $test_name);
        $Test->diag(join("\n", @problems));
        return wantarray ? ($fixed_data, @problems)  : $ok;
    }

    return wantarray ? () : $Test->ok(1, $test_name);
}

=back

=cut


################################################################################
# Private methods
################################################################################

{ # block for _grep_public_methods
# private but nothing we can do to rename them with _
# add to this list as necessary
my %private_methods = map { $_ => 1 }
    qw(new DESTROY);

# given a list of methods (not method names), filter out the "private" methods.
sub _grep_public_methods {
    my ($self, @methods) = @_;

    my @public;
    foreach (@methods) {
        next unless $_->name =~ /^[A-Za-z]/; # must begin with letter (not _)
        next if $_->package_name =~ /^Moose/; # no Moosey business!
        next if $private_methods{$_->name};

        push @public, $_;
    }

    return @public;
}
} # end of block for _grep_public_methods

# note a Class::MOP::Method object for debugging purposes
sub _note_method {
    my ($self, $method) = @_;
    my $type = ref $method;

    my ($name, $original_package, $package_name) =
        map {(my $a = $_) =~ s/^${WormBase::Test::API::API_BASE}::/W::A::/o; $a}
        map {$method->$_} qw(name original_package_name package_name);

    $Test->note("$name; OPKG: $original_package; PKG: $package_name; TYPE: $type");
}

=head1 AUTHOR

=head1 BUGS

=head1 SEE ALSO

L<WormBase::API>, L<WormBase::API::Object>, L<WormBase::API::Role::Object>,
L<WormBase::Test>, L<WormBase::Test::API>

=head1 COPYRIGHT

=cut

1;
