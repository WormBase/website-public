package WormBase::Test::Web;

use strict;
use warnings;
use Carp;
use Readonly;
use URI::URL;
use WormBase::Util::URI;
use Test::WWW::Mechanize::Catalyst;

use namespace::autoclean;

use base 'WormBase::Test';

my $Test = Test::Builder->new;

# WormBase web tester

=head1 NAME

WormBase::Test::Web

=head1 SYNOPSIS

    my $tester = WormBase::Test::Web->new;
    my $mech = $tester->mech;

    if ($tester->is_local_server) {
        # tests that require more information about the internals

        my $api_tester = $tester->api_tester;
        my $obj = $api_tester->fetch_object({ class => $class, name => $name });

        my $c = $tester->context;

        $c->config->{...};
        $c->model(...);
        $c->controller(...);
    }

    my $url = $tester->root_url;

=head1 DESCRIPTION

Tester class for testing the WormBase web app. This provides convenience methods
and seamlessly allows testing against a locally run server or a "remote" server.
The locally run server is started up by Test::WWW::Mechanize::Catalyst and runs
within the context and duration of the test. Remote servers can be started up
and then tested against with a small loss of testing capabilities. Most notably,
the API and context cannot be fetched for further inspection of the server.
Note that a remote server may refer to localhost -- it is only remote in the sense
that the test cannot directly access the internals of app.

A tester object encapsulates a single shared Test::WWW::Mechanize::Catalyst object.
Due to a limitation of the mechanizer, if tests are run against a remote server,
they can only be run against that single remote server, as the mechanizer
depends on the L<CATALYST_SERVER> environment variable. It is
possible to modify the environment variable throughout runtime to test on
multiple servers in one test run if one so wishes, but the behaviour of such
tests is not well-defined.

It is likely desired to run tests against a single server and as of writing,
the tester object contains no significant state data. Therefore, it mostly
provides convenience methods to facilitate test-writing.

=head1 CONSTANTS

Constants related to testing and running the WormBase web application.
These can be accessed as either interpolated variables or
subroutines/methods.

    $WormBase::Test::Web::CONSTANT
    WormBase::Test::Web::CONSTANT

=over

=item B<APP_BASE>

The WormBase web app.

=cut

Readonly our $APP_BASE => 'WormBase::Web';
sub APP_BASE () { return $APP_BASE; }

=back

=cut

my %Mech_options = (allow_external => 1); # allow external requests by default
my $Mech = server() ? Test::WWW::Mechanize::Catalyst->new({%Mech_options})
         : Test::WWW::Mechanize::Catalyst->new({catalyst_app => $APP_BASE,
                                               %Mech_options});


=head1 METHODS

=cut

################################################################################
# Methods
################################################################################

=over

=item B<new($arghash)>

    # if set, will use the separate server at 3000
    $ENV{CATALYST_SERVER} = 'http://localhost:3000';
    $tester = WormBase::Test::Web->new;

Creates a new web tester object. The arguments are those needed to instantiate
a WormBase::Test object, i.e. none.

=cut

sub new {
    my $class = shift;
    my $args  = shift;

    my $self = $class->SUPER::new($args);

    return bless $self, $class;
}

=item B<mech>

    $mech = $tester->mech;

Returns the underlying Test::WWW::Mechanize::Catalyst object. It is useful
to make custom queries to a local server (local to the test).

=cut

sub mech {
    return $Mech;
}

=item B<server>

Returns the location of the test server or undef if the server
is locally run. Typically, the location of a remote server will be
stored in the C<CATALYST_SERVER> environment variable.

=cut

sub server {
    return $ENV{CATALYST_SERVER} || undef;
}

=item B<root_url>

    $url = $tester->root_url;

Returns the URI::URL object for the location of the test server. A locally run
server will default to localhost:80.

=cut

sub root_url {
    my $self = shift;
    return URI::URL->new($self->server // 'http://localhost');
}

=item B<is_external_url>

    $is_ext = $tester->is_external_url($ext); # true
    $is_ext = $tester->is_external_url($self->root_url); # false

Returns true if the provided URL is external relative to the testing server, i.e.
does not refer to a resoruce on the testing server.

=cut

sub is_external_url {
    my ($self, $url) = @_;
    return ! WormBase::Util::URI::is_same_domain($self->root_url, $url);
}

=item B<is_remote_server>

Convenience method that tests whether the testing server is external.

=cut

*is_remote_server = \&server;

=item B<is_local_server>

Convenience method that tests whether the testing server is local. This is always the
opposite of C<is_remote_server>.

=cut

sub is_local_server {
    my $self = shift;
    return ! $self->is_remote_server;
}

=item B<api_tester>

    $api_tester = $tester->api_tester;

This is only available for locally run servers. Returns a WormBase::Test::API object
for API-specific tests and queries.

=cut

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

=item B<context>

    $c = $tester->context;

This is only available for locally run servers.
Retrieves a context object for the application based on a request to '/'.
The context object can subsequently be used for its configuration and other
state-independent properties.

=cut

sub context {
    my $self = shift;

    $self->_local_only_error('Context') if $self->is_remote_server;

    return $self->{context} if $self->{context};
    # otherwise lazyload it

    # this is basically use pragma without BEGIN block...
    # Catalyst::Test::ctx_request is created upon import only
    require Catalyst::Test;
    Catalyst::Test->import($APP_BASE);

    my ($res, $c) = ctx_request('/');
    return $self->{context} = $c;
}

=item B<api>

   $api = $tester->api;
   # same as $self->api_tester->api;

This is only available for locally run servers.
Retrieves the API object for the application.

=cut

sub api {
    my $self = shift;

    $self->_local_only_error('API') if $self->is_remote_server;

    return $self->{api} if $self->{api};
    # otherwise lazyload it

    my $c = $self->context;
    return $self->{api} = $c->model('WormBaseAPI');
}

=back

=cut

################################################################################
# Private methods
################################################################################

sub _local_only_error {
    my ($self, $name) = @_;

    croak $name || 'Method', ' can only be used on a local server';
}


=head1 AUTHOR

=head1 BUGS

=head1 SEE ALSO

L<WormBase::Test>, L<WormBase::Test::API>,  L<Test::WWW::Mechanize>,
L<Catalyst::Test>

=head1 COPYRIGHT

=cut

1;
