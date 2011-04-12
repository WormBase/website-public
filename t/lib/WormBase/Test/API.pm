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

Readonly our $API_BASE => 'WormBase::API';
sub API_BASE () { return $API_BASE; }

# WormBase API tester

################################################################################
# Constructor & Accessors
################################################################################

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
