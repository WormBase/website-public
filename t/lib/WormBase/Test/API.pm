package WormBase::Test::API;

use strict;
use warnings;
use Carp;
use Readonly;
use Config::General;
use Test::More;
use WormBase::API;

use namespace::autoclean;

use base 'WormBase::Test';


Readonly our $API_BASE => 'WormBase::API';
sub API_BASE { return $API_BASE; }

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
        croak "$args->{conf_file} does not exist" unless -e $args->{conf_file};
        my %conf = Config::General->new(-ConfigFile      => $args->{conf_file},
                                        -InterPolateVars => 1)->getall;

        my $api = WormBase::API->new($conf{'Model::WormBaseAPI'}->{args});
        ok($api && $api->isa($API_BASE), 'Created WormBase API object');

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
