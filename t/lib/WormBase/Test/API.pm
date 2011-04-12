package WormBase::Test::API;

use strict;
use warnings;
use Carp;
use Readonly;
use Config::General;
use File::Basename;
use Test::Builder;
use Catalyst::Utils; # merge_hash: can reimplement in this class if needed
use WormBase::API;

use namespace::autoclean;

use base 'WormBase::Test';

my $Test = Test::Builder->new;

# WormBase API tester

=head1 NAME

WormBase::Test::API - a generic WormBase API testing object

=head1 SYNOPSIS

my $tester = WormBase::Test::API->new({conf_file => 'data/test.conf'});

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

Creates a new API tester object wrapping a L<WormBase::API> object.

A config file, parsable by L<Config::General>, can be passed in; it will be
loaded to create a new API object. A local version of the config file will
be searched for and loaded if present, i.e. if the config file is 'test.conf'
and if 'test_local.conf' is also present, then it will be loaded as well,
overwriting any config values from 'test.conf'.

Alternatively, an API object can be passed in and used as the underlying object.

=cut

sub new {
    my ($class, $args) = @_;

    my $self = $class->SUPER::new($args);
    if ($args->{api}) {
        $self->api($args->{api});
    }
    elsif ($args->{conf_file}) { # make the API object using conf file
        my $conf_file = $args->{conf_file};
        croak "$conf_file does not exist" unless -e $conf_file;

        my %conf = Config::General->new(-ConfigFile      => $conf_file,
                                        -InterPolateVars => 1)->getall;

        # try to find _local version of $conf_file
        my ($conf_filename, $dir, $suffix) = fileparse($conf_file, qr/\.[^.]+/);
        my $local_conf_file = $dir . $conf_filename . '_local' . $suffix;

        if (-e $local_conf_file) {
            my %newconfig = Config::General->new(-ConfigFile      => $local_conf_file,
                                                 -InterPolateVars => 1)->getall;

            %conf = %{Catalyst::Utils::merge_hashes(\%conf, \%newconfig)};
        }

        croak "$conf_file does not contain Model::WormBaseAPI stanza."
            unless exists $conf{'Model::WormBaseAPI'}; # indicates something amiss...
        my $api = WormBase::API->new($conf{'Model::WormBaseAPI'}->{args});
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

################################################################################
# Methods
################################################################################



################################################################################
# Test Methods
################################################################################

1;
