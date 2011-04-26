package WormBase::Test::API;

use strict;
use warnings;
use Carp;
use Readonly;
use Config::General;
use File::Basename;
use Test::Builder;
use WormBase::API;
use WormBase::Util::Hash 'merge_hashes';

use namespace::autoclean;

use base 'WormBase::Test';

my $Test = Test::Builder->new;

# WormBase API tester

=head1 NAME

WormBase::Test::API - a WormBase API testing object

=head1 SYNOPSIS

my $tester = WormBase::Test::API->new({conf_file => 'data/test.conf'});

my $obj = $tester->fetch_object_ok({class => 'Paper', name => 'WBPaper00024194'});


# manual operations
my $api = $tester->build_api('data/test.conf', 'data/test1.conf');
my $newtester = WormBase::Test::API->new({api => $api});

=head1 DESCRIPTION

This inherits from L<WormBase::Test> and provides a base class for WormBase API
tester objects i.e. objects involved in testing of the WormBase model.

=head1 CONSTANTS

Constants related to testing the API. These can be accessed either as
interpolable variables or subroutines/methods:

    $WormBase::Test::API::CONSTANT
    WormBase::Test::API::CONSTANT

=over

=item B<API_BASE>

The base WormBase API package/prefix.

=cut

Readonly our $API_BASE => 'WormBase::API';
sub API_BASE () { return $API_BASE; }

=back

=head1 METHODS

=head2 Construction and accessors

=over

=cut

################################################################################
# Constructor & Accessors
################################################################################

=item B<new($argshash)>

   my $tester = WormBase::Test::API->new({api => $wb_api});

   my $tester = WormBase::Test::API->new({conf_file => 'data/test.conf'});
   my $tester = WormBase::Test::API->new({conf_file => ['data/test.conf',
                                                        'data/more.conf']})

Creates a new API tester object wrapping a L<WormBase::API> object.

The name of config files, parsable by L<Config::General>, can be passed in;
each will be loaded in order to create a new API object. See L<build_api> for
more details in how the config files will be handled.

Alternatively, an API object can be passed in and used as the underlying object.

=cut

sub new {
    my ($class, $args) = @_;

    my $self = $class->SUPER::new($args);
    if ($args->{api}) {
        $self->api($args->{api});
    }
    elsif ($args->{conf_file}) { # make the API object using conf file
        my $api = $self->build_api($args->{conf_file});
        $Test->ok($api && $api->isa($API_BASE), 'Created WormBase API object');
        $self->api($api);
    }
    else {
        croak "Must either provide api object or conf_file";
    }

    return $self;
}

=item B<api([$api])>

    $tester->api($api);
    my $api = $tester->api;

=cut

sub api {
    my ($self, $param) = @_;
    if ($param) {
        croak "Not a $API_BASE!"
            unless (ref $param and $param->isa($API_BASE));
        return $self->{api} = $param;
    }
    return $self->{api};
}

=back

=head2 Utility Methods

=over

=cut

################################################################################
# Methods
################################################################################

=item B<build_api>

    $api = WormBase::Test::API->build_api($conf_file);
    $api = $tester->build_api($conf_file);
    $api = $tester->build_api($conf_file1, $conf_file2, ...);
    $api = $tester->build_api([$conf_file1, $conf_file2, ...]);

Creates a WormBase::API object from the name(s) of a given config file(s),
parsable by L<Config::General>. The config files will be loaded in order,
the latest one merged with the previous ones. Fields which already exist
from a previous config will be overwritten if specified in a later config,
consistent with the behaviour specified in L<Catalyst/"Cascading configuration">.
In other words, the latest config files specified have higher priority.

A local version of the config file will also loaded. For example, if

   $api = $tester->build_api('a.conf', 'b.conf', 'c');

then a.conf will be loaded first, then a_local.conf (if it exists) will be merged
with the current config, then b.conf will be merged, then b_local.conf (if
it exists), then c, and finally c_local (if it exists).

=cut

sub build_api {
    my ($self, @conf_files) = @_;
    if (@conf_files == 1 and ref $conf_files[0] eq 'ARRAY') {
        @conf_files = @{$conf_files[0]}; # deref the conf files
    }

    my ($conf, $newconf);
    foreach my $conf_file (@conf_files) {
        croak "$conf_file does not exist" unless -e $conf_file;

        # consider -MergeDuplicateBlocks and -MergeDuplicateOptions to
        # remove dependency on merge_hashes util function?
        $newconf = {Config::General->new(
            -ConfigFile      => $conf_file,
            -InterPolateVars => 1
        )->getall};

        $conf = merge_hashes($conf, $newconf);

        # try to find _local version of $conf_file
        my ($conf_filename, $dir, $suffix) = fileparse($conf_file, qr/\.[^.]+/);
        my $local_conf_file = $dir . $conf_filename . '_local' . $suffix;

        if (-e $local_conf_file) {
            $newconf = {Config::General->new(-ConfigFile      => $local_conf_file,
                                            -InterPolateVars => 1)->getall};

            $conf = merge_hashes($conf, $newconf);
        }
    }

    croak "Config does not contain Model::WormBaseAPI settings."
        unless exists $conf->{'Model::WormBaseAPI'}; # indicates something amiss...
    return WormBase::API->new($conf->{'Model::WormBaseAPI'}->{args});
}

=item B<fetch_object($argshash)>

    my $obj = $tester->fetch_object({
        name     => $name,
        class    => $class,
        aceclass => $aceclass, # for fetching WB objects using an Ace class
    })

Fetches a L<WormBase::API::Object> object of a given class. This uses (and reveals)
the underlying WormBase::API object's interface to fetch.

name is required. Either class or aceclass must be provided.

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
        croak 'Must provide class or aceclass in arguments'
            unless $class || $aceclass;
    }
    else {
        $name = $args;
    }

    my $api = $self->api or die "Can't get $WormBase::Test::API::API_BASE object";

    return $api->fetch({class => $class, name => $name, aceclass => $aceclass});
}

=item B<fully_qualified_class_name($class)>

    my $full_class = WormBase::Test::API::Object->fully_qualified_class_name('ModelMap');
    # WormBase::API::ModelMap

Takes a class name and fully qualifies it with the API_BASE constant as a
prefix if not already done. Useful for dynamically creating objects.

=cut

sub fully_qualified_class_name { # invocant-independent
    my ($invocant, $name) = @_;
    return $invocant->_fully_qualified_class_name($API_BASE, $name);
}

################################################################################
# Test Methods
################################################################################

=back

=head2 Test Methods

=over

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

=back

=cut

################################################################################
# Private Methods
################################################################################

=head1 AUTHOR

=head1 BUGS

=head1 SEE ALSO

L<WormBase::Test>, L<WormBase::API>

=head1 COPYRIGHT

=cut


1;
