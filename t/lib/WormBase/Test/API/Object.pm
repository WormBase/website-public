package WormBase::Test::API::Object;

use strict;
use warnings;
use Carp;
use Test::Builder;
use Readonly;

use namespace::autoclean;

use base 'WormBase::Test::API';

my $Test = Test::Builder->new;

Readonly our $OBJECT_BASE => $WormBase::Test::API::API_BASE . '::Object';
sub OBJECT_BASE () { return $OBJECT_BASE; }

# WormBase API model object tester

################################################################################
# Constructor & Accessors
################################################################################

# yes, rolling my own class. may replace with Moose or something later

sub new {
    my ($class, $args) = @_;

    my $self = $class->SUPER::new($args);
    if ($args->{class}) { # run class tests automatically
        $self->class($args->{class});
        $self->class_hierarchy_ok($args->{class});
        $self->class_immutable_ok($args->{class});
    }
    return $self;
}

sub object {
    my ($self, $param) = @_;
    if ($param) {
        croak "Not a $OBJECT_BASE!"
            unless (ref $param and $param->isa($OBJECT_BASE));
        return $self->{wormbase_object} = $param;
    }
    return $self->{wormbase_object};
}

sub class {
    my ($self, $param) = @_;
    if ($param) {
        croak "Not a string!" if ref $param;
        return $self->{class} = $param;
    }
    return $self->{class};
}

################################################################################
# Methods
################################################################################

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
        $name  = $args;
    }

    $class ||= $self->class;
    croak 'Must specify class of object to fetch, either through',
        '$tester->class or using a hashref as arguments'
        unless $class;

    my $api = $self->api or die "Can't get $WormBase::Test::API::API_BASE object";

    return $api->fetch({class => $class, name => $name, aceclass => $aceclass});
}

# DFS to get parent methods
sub get_parents_methods { # of WormBase class.
    my ($self, $class) = @_;
    $class ||= $self->class or croak 'Must provide class as an argument';
    $class = $self->fully_qualified_class_name($class);

    my @parents = $class->meta->superclasses;
    return map { eval {$_->meta->get_all_methods} } @parents;
}

# this is a nice utility; perhaps it should be put in WormBase::Test
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

sub fully_qualified_class_name { # invocant-independent
    my ($invocant, $name) = @_;

    return $name =~ /^$OBJECT_BASE/o ? $name : "${OBJECT_BASE}::${name}";
}

################################################################################
# Test methods
################################################################################

sub run_common_tests {
    my $self = shift;
    croak 'No arguments given. Call with name of objects to fetch, ',
          'or hash with name of objects and additional options' unless @_;
    my $class = $self->class;
    croak 'Need to provide tester with test class via class accessor' unless $class;

    my @objs;
    my $method_args; # for method compliance test
    if (ref $_[0] eq 'HASH') {
        my $args = shift;
        croak 'Need objects in hash' unless $args->{objects};
        @objs = @{$args->{objects}};

        $method_args->{exclude} = $args->{exclude_methods} if $args->{exclude_methods};

        my $large_exclusions; # will disable inclusions
        foreach my $type (qw(parents roles)) {
            next unless $args->{"exclude_${type}_methods"};
            $large_exclusions ||= 1;
            my $m = "get_${type}_methods";
            push @{$method_args->{exclude}}, map {$_->name} $self->$m($class);
        }

        $method_args->{include} = $args->{include_methods}
            if !$large_exclusions && $args->{include_methods};
    }
    else {
        @objs = @_;
    }

    foreach my $obj_name (@objs) {
        my $obj = $self->fetch_object_ok({name => $obj_name});
        $self->compliant_methods_ok($obj, $method_args || ());
    }
}

sub fetch_object_ok {
    my ($self, $args) = @_;

    my $name = ref $args eq 'HASH' ? $args->{name} : $args;
    $Test->ok(my $obj = $self->fetch_object($args), 'Fetch object ' . $name);
    return $obj || ();
}

sub class_immutable_ok {
    my ($self, $class) = @_;
    $class ||= $self->class or croak 'Must provide a class as an argument!';

    $class = $self->fully_qualified_class_name($class);

    return $Test->ok($class->meta->is_immutable, 'Class immutable');
}

sub call_method_ok {
    my ($self, $object, $method) = @_;
    croak 'Must provide object and method as arguments'
        unless $object && $method;

    my $data = eval {$object->$method};
    $Test->ok(! $@, "$method called without problems")
        or $Test->diag("$object call $method: $@");
    return $data;
}

sub class_hierarchy_ok { # checks that the class has the right hierarchy
    my ($self, $class) = @_;
    $class ||= $self->class;
    croak 'Must provide a class as an argument!' unless $class;

    $class = $self->fully_qualified_class_name($class);

    $Test->subtest('Class hierarchy okay' => sub {
        # check that it's a WormBase Object descendent
        $self->isa_ok($class, $OBJECT_BASE) || $Test->diag("$class, $OBJECT_BASE") && return;

        # implements Object role
        $Test->ok($class->does($WormBase::Test::API::API_BASE . '::Role::Object')) || return;
    }); # end of subtest

    return 1;
}

sub compliant_methods_ok {
    my $self = shift;
    my ($wb_obj, $args) = @_;
    croak 'A WormBase object must be an argument!'
        unless ref $wb_obj && $wb_obj->isa($OBJECT_BASE);
    croak 'Options must be a hashref!' if $args && ref $args ne 'HASH';

    my $meta  = $wb_obj->meta;
    my $class = $meta->name;    # same as ref $wb_obj;
    my @methods = $self->_grep_public_methods($meta->get_all_methods);

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

    unless (@methods) {
        $Test->ok(0, 'Compliant methods');
        $Test->diag('No public methods found');
        $Test->diag('Include: ', join(', ', @{$args->{include}})) if %include;
        $Test->diag('Exclude: ', join(', ', @{$args->{exclude}})) if %exclude;
        return;
    }

    my $ok = 1;
    $Test->subtest('Compliant methods' => sub {
        foreach my $method (@methods) {
#            $self->_note_method($method);
            my $m = $method->name;
            my $data = $self->call_method_ok($wb_obj, $m);
            $self->compliant_data_ok($data)
                or $Test->diag($wb_obj->object . "->$m") && undef $ok;
        }
    }); # end of subtest

    return $ok || ();
}

sub compliant_data_ok {
    my $self = shift;
    $Test->ok(0, 'Too much data') if @_ > 1;

    my ($data) = @_; # unpack to avoid destructiveness of check_data()
    if (my ($fixed_data, @problems) = WormBase::API::Role::Object->_check_data($data)) {
        $Test->ok(0, 'Data has problems');
        $Test->diag(join("\n", @problems));
        return;
    }

    $Test->ok(1, 'Data is okay');
    return 1;
}


################################################################################
# Private methods
################################################################################

# private but nothing we can do to rename them with _
my %private_methods = map {$_=>1} qw(new DESTROY);

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

sub _note_method {
    my ($self, $method) = @_;
    my $type = ref $method;

    my ($name, $original_package, $package_name) =
        map {(my $a = $_) =~ s/^${WormBase::Test::API::API_BASE}::/W::A::/o; $a}
        map {$method->$_} qw(name original_package_name package_name);

    $Test->note("$name; OPKG: $original_package; PKG: $package_name; TYPE: $type");
}

1;
