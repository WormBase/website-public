package WormBase::Test::API::Object;

use strict;
use warnings;
use Carp;
use Test::Builder;
use Readonly;
use Class::MOP;

use namespace::autoclean;

use WormBase::Test::API;
use base 'WormBase::Test::API';

my $Test = Test::Builder->new;

# WormBase API model object tester

=head1 NAME

WormBase::Test::API::Object - WormBase API object tester

=head1 SYNOPSIS

    my $tester = WormBase::Test::API::Object->new({
        conf_file => $conf_file,
        class     => $class, # e.g. 'Paper' or 'WormBase::API::Object::Paper'
    });

    my @test_object_names = qw(a b c d);

    # automatic testing
    my %test_objects = $tester->run_common_tests(@test_object_names);

    # finer autotesting
    $tester->run_common_tests({
        names                   => \@test_object_names,
        # check only the methods specific to the class
        exclude_parents_methods => 1,
        exclude_roles_methods   => 1,
    });

    $tester->run_common_tests({
        names           => \@test_object_names,
        # check only these methods
        include_methods => ['method1', 'method2'],
    });

    $tester->run_common_tets({
        names           => \@test_object_names,
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

Any tests or methods requiring a class in either WormBase::Test or
WormBase::Test::API are overridden here to make use of the class set for
the tester.

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
        croak "Class must be a string!" if ref $param;
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

=item B<fully_qualified_class_name($class)>

    my $full_class = WormBase::Test::API::Object->fully_qualified_class_name('Paper');
    # WormBase::API::Object::Paper

Takes a class name and fully qualifies it with the OBJECT_BASE constant as a
prefix if not already done. Useful for dynamically creating objects.

=cut

sub fully_qualified_class_name { # invocant-independent
    my ($invocant, $name) = @_;
    return $invocant->_fully_qualified_class_name($OBJECT_BASE, $name);
}

=item B<fetch_object($objname|$arghash)>

    $obj = $tester->fetch_object($obj_name); #  if class is set
    $obj = $tester->fetch_object({class => $class, name => $obj_name});

See L<WormBase::Test::API/fetch_object>.

=cut

sub fetch_object {
    my ($self, $args) = @_;

    my $class = $self->class;
    if (ref $args eq 'HASH') {
        $args->{class} ||= $class;
        return $self->SUPER::fetch_object($args);
    }

    croak "Must provide set tester's class" unless $class;
    return $self->SUPER::fetch_object({name => $args, class => $class});
}

=item B<get_parents_methods([$class])>

    $parents_methods = $tester->get_parents_methods; # if class is set
    $parents_methods = $tester->get_parents_methods($class);

See L<WormBase::Test/get_parents_methods>.

=cut

sub get_parents_methods {
    my ($self, $class) = @_;
    $class ||= $self->class;
    $class = $self->fully_qualified_class_name($class);

    return $self->SUPER::get_parents_methods($class);
}

=item B<get_roles_methods([$class])>

    $roles_methods = $tester->get_roles_methods; # if class is set
    $roles_methods = $tester->get_roles_methods($class);

See L<WormBase::Test/get_roles_methods>.

=cut

sub get_roles_methods {
    my ($self, $class) = @_;
    $class ||= $self->class;
    $class = $self->fully_qualified_class_name($class);

    return $self->SUPER::get_roles_methods($class);
}

=item B<get_class_specific_methods([$class])>

    $roles_methods = $tester->get_class_specific_methods; # if class is set
    $roles_methods = $tester->get_class_specific_methods($class);

See L<WormBase::Test/get_class_specific_methods>.

=cut

sub get_class_specific_methods {
    my ($self, $class) = @_;
    $class ||= $self->class;
    $class = $self->fully_qualified_class_name($class);

    return $self->SUPER::get_class_specific_methods($class);
}

################################################################################
# Test methods
################################################################################

=back

=head2 Test methods

These methods facilitate testing and emit TAP. They all return the success
status of the test in scalar context and will also do so in list context unless
otherwise specified.

=over

=item B<run_common_tests($argshash)>

Run tests common to model objects. The names of test objects must be provided
as arguments:

    @test_object_names = ('Object 1', 'Object 2'); # names of objects
    $tester->run_common_tests(@test_object_names);

or in the "names" entry of an arguments hashref ("argshash"):

    $tester->run_common_tests({names => \@test_object_names});

This method will attempt to fetch each object and run L<compliant_methods_ok>
on them. Specific methods to test may be specified by providing an arrayref
of method names or metaobjects like so:

    $tester->run_common_tests({
        names           => \@test_object_names,
        include_methods => $methods, # arrayref
    });

Similarly, methods can be excluded from testing i.e. test all methods of the
class except the ones specified:

    $tester->run_common_tests({
        names           => \@test_object_names,
        exclude_methods => $methods, # all except these
    });

Note that if methods are specified to test using include_methods, any exclusions
are ignored.

    $tester->run_common_tests({
        names           => \@test_object_names,
        include_methods => $methods1, # only test these
        exclude_methods => $methods2, # no effect
    });

In addition to the specific exclusions, the methods belonging to the class'
parents or roles can be excluded automatically like so:

    $tester->run_common_tests({
        names                   => \@test_object_names,
        exclude_parents_methods => 1,
        exclude_roles_methods   => 1,
    });

Note that large exclusions such as excluding parents' methods and roles' methods
will ignore any inclusions specified such that the above run is the same as

    $tester->run_common_tests({
        names                   => \@test_object_names,
        include_methods         => $methods,
        exclude_parents_methods => 1,
        exclude_roles_methods   => 1,
    });

In such a case, more methods to be excluded may be specified:

    $tester->run_common_tests({
        names                   => \@test_object_names,
        exclude_parents_methods => 1,         # exclude parents' methods
        exclude_roles_methods   => 1,         # exclude roles' methods
        exclude_methods         => $methods,  # exclude these too!
    });

Thus, in general: B<DO NOT USE BOTH EXCLUSION AND INCLUSION TOGETHER>.

If the fetched objects are desired, run_common_tests will return a hash in list
context with the object name as the key and object as the value:

    my %object_hash = $tester->run_common_tests(@test_object_names);

It is possible that some of the objects are not fetched so do not assume that
C<values %object_hash> will be the same as @test_object_names (even after
rearrangement).

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

    my $object_names;
    my $method_args; # for method compliance test
    if (ref $_[0] eq 'HASH') {
        my $args = shift;
        # $args->{objects} deprecated!
        $object_names = $args->{name} || $args->{names} || $args->{objects}
            or croak 'Need object names in hash';

        my @excludes;
        if ($args->{exclude_methods}) {
            croak 'exclude_methods must be an arrayref!'
                unless ref $args->{exclude_methods} eq 'ARRAY';
            @excludes = @{$args->{exclude_methods}}; # ensure non-destructiveness
        }

        my $large_exclusions; # will warn & disable inclusions
        foreach my $type (qw(parents roles)) {
            next unless $args->{"exclude_${type}_methods"};
            $large_exclusions ||= 1;
            my $m = "get_${type}_methods";
            push @excludes, map {$_->name} $self->$m($class);
        }

        # we must check for large exclusions because inclusions
        # override all exclusions in the compliant_methods_ok method
        if ($args->{include_methods}) {
            if ($large_exclusions) {
                carp 'Common tests were specified to exclude many methods and ',
                     'also include methods. Ignoring specified inclusions.';
            }
            else {
                $method_args->{include} = $args->{include_methods};
            }
        }

        $method_args->{exclude} = \@excludes if @excludes;
    }
    else {
        $object_names = [@_];
    }

    my $ok = 1;
    my %objects;
    foreach my $obj_name (@$object_names) {
        my $obj = $self->fetch_object_ok($obj_name);
		$method_args->{name} = $obj if $method_args;
        my $meth_ok = $self->compliant_methods_ok($method_args || $obj);
        $ok &&= $meth_ok;
        $objects{$obj_name} = $obj if $obj;
    }

    return wantarray ? %objects : $ok;
}

# deprecated. here for current testing code but will be removed soon.
sub test_object_methods {
    my $self = shift;
    $self->run_common_tests({objects => $_[0], include_methods => $_[1]});
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

=item B<compliant_methods_ok($object, $argshash)>

    $tester->compliant_methods_ok($object);

Tests all methods of an object by calling them and checking that their data
are standards compliant as determined by WormBase::API::Role::Object::_check_data().
The test passes if the method is called without error and the returned data
is standards compliant.

The option to test only certain methods is provided:

    $tester->compliant_methods_ok({
        name    => $object,
        include => $methods_array,
    });

Where $methods_array is an arrayref of methods metaobjects or the names of methods.
The option to test all methods except a few is also provided:

    $tester->compliant_methods_ok({
        name    => $object,
        exclude => $methods_array,
    });

Inclusions and exclusions cannot be mixed. If inclusions are specified, only those
included metehods are tested, even if exclusions are specified.

=cut

sub compliant_methods_ok {
    my ($self, $args) = @_;
    croak 'Need to provide object as an argument or an argument hash'
        unless $args; # quick check to do less work

    my ($wb_obj, $class);

    my %methods; # METHOD_NAME => METHOD_NAME/METHOD_METAOBJECT

    if (ref $args eq 'HASH') {
        $wb_obj = $args->{name} || $args->{object}; # $args->{object} deprecated!
        croak 'Need to provide an object as an argument'
            unless eval {$wb_obj->isa($OBJECT_BASE)};
        $class = ref $wb_obj;

        if ($args->{include} and $args->{exclude}) {
            carp 'Include and exclude options specified; only include will be used';
        }

        # deal with inclusion-exclusion options. inclusions override exclusions
        if ($args->{include}) { # test only these methods
            croak 'Include option must be arrayref!'
                unless ref $args->{include} eq 'ARRAY';
            %methods = map { (ref $_ ? $_->name : $_) => $_ } @{$args->{include}};
        }
        else { # test all public methods
            my $meta = $class->meta or die "Couldn't get metaclass for class $class";
            %methods = map { $_->name => $_ }
                       $self->_grep_public_methods($meta->get_all_methods);

            if ($args->{exclude}) { # don't test these methods
                croak 'Exclude option must be arrayref!'
                    unless ref $args->{exclude} eq 'ARRAY';
                map { delete $methods{ref $_ ? $_->name : $_ } }
                    @{$args->{exclude}};
            }
        }
    }
    else {
        $wb_obj = $args;
    }

    my $test_name = $wb_obj->object . " of class $class has compliant methods";

    unless (%methods) {
        $Test->ok(0, $test_name);
        $Test->diag('No public methods found');
        $Test->diag('Include: ', join(', ', @{$args->{include}})) if $args->{include};
        $Test->diag('Exclude: ', join(', ', @{$args->{exclude}})) if $args->{exclude};
        return;
    }

    return $Test->subtest($test_name => sub {
        while (my ($method_name, $method_meta) = each %methods) {
            my $data = $self->call_method_ok($wb_obj, $method_name);
            $self->compliant_data_ok($data, $method_name);
        }
    }); # end of subtest
}

# deprecated. here for current testing code but will be removed soon.
sub listed_methods_ok {
    my ($self, $args) = @_;
    $self->compliant_methods_ok($args);
}

=item B<compliant_data_ok($data, $testname)>

    $ok = $tester->compliant_data_ok($data, $testname);

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

=item B<fetch_object_ok>

    $obj = $tester->fetch_object_ok($obj_name); # if class is set
    $obj = $tester->fetch_object_ok({class => $class, name => $name})
    $obj = $tester->fetch_object_ok({aceclass => $ace, name => $name});

See L<WormBase::Test::API/fetch_object_ok>.

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

L<WormBase::Test>, L<WormBase::Test::API>

=head1 COPYRIGHT

=cut

1;
