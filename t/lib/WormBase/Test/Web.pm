package WormBase::Test::Web;

use strict;
use warnings;
use Carp;
use Readonly;
use URI::URL;
use WormBase::Util::URI;
use Test::WWW::Mechanize::Catalyst;

use namespace::autoclean;

use WormBase::Test;
use base 'WormBase::Test';

Readonly our $APP_BASE => 'WormBase::Web';
sub APP_BASE () { return $APP_BASE; }

my %Mech_options = (allow_external => 1); # allow external requests by default
my $Mech = server() ? Test::WWW::Mechanize::Catalyst->new({%Mech_options})
         : Test::WWW::Mechanize::Catalyst->new({catalyst_app => $APP_BASE,
                                               %Mech_options});

sub new {
    my $class = shift;
    my $args  = shift;

    my $self = $class->SUPER::new($args);

    return bless $self, $class;
}

sub mech {
    return $Mech;
}

sub api_tester {
    my ($self) = @_;

    return $self->{api_tester} if $self->{api_tester};

    my $api = eval { $self->api };
    if (!$api) {
        if ($@) {
            croak "Could not get API tester: $@";
        }
        # this could be an error in here or outside
        confess "Could not get API tester: API could not be fetched.";
    }

    require WormBase::Test::API;
    return $self->{api_tester} = WormBase::Test::API->new({api => $api});
}

sub server {
    return $ENV{CATALYST_SERVER} || undef;
}

sub base_url {
    my $self = shift;
    return URI::URL->new($self->server // 'http://localhost');
}

sub is_external_url {
    my ($self, $url) = @_;
    return WormBase::Util::URI::is_same_domain($self->base_url, $url);
}

*is_external_server = \&server;

sub is_local_server {
    my $self = shift;
    return ! $self->is_external_server;
}

sub context {
    my $self = shift;

    $self->_local_only_error('Context') if $self->is_external_server;

    return $self->{context} if $self->{context};
    # otherwise lazyload it

    # this is basically use pragma without BEGIN block...
    # Catalyst::Test::ctx_request is created upon import only
    require Catalyst::Test;
    Catalyst::Test->import($APP_BASE);

    my ($res, $c) = ctx_request('/');
    return $self->{context} = $c;
}

sub api {
    my $self = shift;

    $self->_local_only_error('API') if $self->is_external_server;

    return $self->{api} if $self->{api};
    # otherwise lazyload it

    my $c = $self->context;
    return $self->{api} = $c->model('WormBaseAPI');
}

sub _local_only_error {
    my ($self, $name) = @_;

    croak $name || 'Method', ' can only be used on a local server';
}

1;
