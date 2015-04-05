package WormBase::Web::ThirdParty::Google;

use Moose;
use JSON::Any;
use URI::Escape;
use HTTP::Request;
use HTTP::Request::Common;
use LWP::UserAgent;
use Encode;



# our $_base_url = 'https://www.googleapis.com';
# #use constant 'application/json';
# has 'base_url' => (
#     is => 'ro',
#     isa => 'Str',
#     default => sub { return $_base_url} );
use constant BASE_URL => 'https://www.googleapis.com';

has 'provider_name' => (
    is => 'ro',
    required => 1,
    lazy     => 1,
    builder  => '_build_provider_name',
);

has 'credentials' => (
    is => 'ro',
    lazy_build => 1,
    builder => '_build_credentials');


use Data::Dumper;


#################################################
#
#
#   Public Methods (2Leg OAuth)
#
#
#################################################


sub get_user {
    my ($self, %args) = @_;
    my $resp = $self->call_api("/plus/v1/people/me", undef, %args);

    my $name = $resp->{name};
    my $email = $resp->{emails}->[0];
    my $profile = {
        first_name  => $name && $name->{givenName},
        last_name   => $name && $name->{familyName},
        email => $email && $email->{value},
        id => $resp->{id}   # google's People id
    };

    return $profile;
}

sub call_api {
    my ($self,$url, $url_params, %args) = @_;

    my ($access_token,
        $refresh_token,
        $method) = @args{qw /access_token refresh_token method/};
    return unless $access_token;

    my $uri     = URI->new(BASE_URL);
    $uri->path("$url");
    $uri->query_form($url_params);

    $method = $method || 'GET';
    my $req = HTTP::Request->new( $method => $uri);

    $req->header(
        'Authorization' => 'Bearer ' . $access_token,
        'Content-Type' => 'application/json'
    );

    my $response;
    eval {
        $response = $self->_send_request($req);
        1;
    } || do {
        my $error_code = $@;
        if ($error_code eq '401' && $refresh_token){
            # not ideal, user has to refresh the page to use the updatedd token
            # keep simple for now
            my $token_response = $self->request_token({ grant_type => 'refresh_token' });
        }
    };

    return $response;
}

sub _send_request {
    my ($self, $request) = @_;

    my $lwp       = LWP::UserAgent->new;
    my $response  = $lwp->request($request);

    unless ($response->is_success){
        my $response_code = $response->code;
 #       print "Error code: $response_code " . $response->message;
        die "$response_code";

    }

    my $json = new JSON;
    return $json->allow_nonref->utf8->relaxed->decode($response->content);
}


sub request_token {
    my ($self, $args) = @_;
    my $uri     =  URI->new(BASE_URL);
    $uri->path('/oauth2/v3/token');

#    my ($grant_type, $authorization_code, $refresh_token) = %args{qw 'grant_type code refresh_token'};
    # my $req_content = {
    #     grant_type = $grant_type || 'authorization_code',
    # };
    # $req_content->{code} = $authorization_code if $authorization_code;
    # $req_content->{refresh_token} =

    $args->{grant_type} ||= 'authorization_code';
    $args->{client_id} = $self->credentials->{'client_id'};
    $args->{client_secret} = $self->credentials->{'client_secret'};

    my $req = POST($uri,
                   Content_Type => 'application/x-www-form-urlencoded',
                   Content => [ %$args ]
               );

    # $req->authorization_basic($self->credentials->{'client_id'},
    #                           $self->credentials->{'client_secret'});
    my $response = $self->_send_request($req);
    return $response;
}

sub get_authorization_url {
    my ($self, %args) = @_;
    my %args_new = (
        redirect_uri => '/',
        state => '',
        scope => '',
        response_type => 'code',
        access_type => 'offline',
        client_id => $self->credentials->{'client_id'},
        %args);
    return $self->_build_uri('https://accounts.google.com', '/o/oauth2/auth', \%args_new);
}

sub _build_uri {
    my ($self, $base_url, $rel_url, $url_params) =  @_;
    my $uri = URI->new($base_url || BASE_URL);
    $uri->path("$rel_url");
    $uri->query_form($url_params);
    return $uri->as_string;
}

sub _build_credentials {
    my ($self) = @_;
    my $path = WormBase::Web->path_to('/') . '/credentials/' . $self->provider_name ;

    my $client_id = `cat $path/client_id.txt`;
    chomp $client_id;
    my $client_secret = `cat $path/client_secret.txt`;
    chomp $client_secret;

    die 'Missing credentials' unless $client_id && $client_secret;

    return {
        client_id => $client_id,
        client_secret => $client_secret
    };
}

sub _build_provider_name {
    my ($self) = @_;
    my ($pname) = __PACKAGE__ =~ /::(\w+)$/;
    return lc($pname);
}

1;
