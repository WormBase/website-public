package WormBase::Web::Model::CouchDB;

# Simple class for interacting with our CouchDB.
# Currently only supports creating databases,
# adding and fetching documents.  Document deletes
# and updates not yet supported.

use Moose;
use URI::Escape;
use JSON::Any qw/XS JSON/;
use HTTP::Request::Common;

extends qw/Catalyst::Model/;

has 'host'            => (is => 'ro', isa => 'Str',  required => 0);
has 'port'            => (is => 'ro', isa => 'Str',  required => 0);

has 'write_host'      => (is => 'ro', isa => 'Str', required => 1);
has 'write_host_port' => (is => 'ro', isa => 'Str', required => 1);

has 'read_host'      => (is => 'ro', isa => 'Str', required => 1);
has 'read_host_port' => (is => 'ro', isa => 'Str', required => 1);



has ua              => ( isa => 'Object', is => 'rw', lazy => 1, builder => '_build_ua' );
has useragent_class => ( isa => 'Str', is => 'ro', default => 'LWP::UserAgent' );
has useragent       => ( isa => 'Str', is => 'ro', default => "WormBase::Update/0.01" );
#has useragent_args  => ( isa => 'HashRef', is => 'ro', default => sub { {} } );
has _json_handler   => (
    is      => 'rw',
    default => sub { JSON::Any->new(utf8 => 1) },
    handles => { _from_json => 'from_json' },
    );
has 'version' => ( is => 'rw' );

sub _build_ua {
    my $self = shift;
    
    eval "use " . $self->useragent_class;

    croak $@ if $@;
    
#    my $ua = $self->useragent_class->new(%{$self->useragent_args});
    my $ua = $self->useragent_class->new();
    $ua->agent($self->useragent);
    $ua->env_proxy;
    return $ua;
}

# After object construction, make sure that the database exists.
#sub BUILD {
#    my $self = shift;
#    $self->create_database();
#}

sub mangle_arguments {
    my ($self,$args) = @_;
    return %$args;
}


# Not really necessary in this context.
# curl -X PUT $couchdb/$release"
sub create_database {
    my $self = shift;

    my $msg = $self->_prepare_request({method => 'PUT'});
    my $res = $self->_send_request($msg);    

    my $data =  $self->_parse_result($res);
    return $data;
}

# Create a new document with an optional attachment.
# curl -X PUT $couchdb/$release/uuid
# curl -X PUT $couchdb/$release/uuid/attachment (if adding an attachment, too)
#   curl -X PUT http://$couchdb/$version/$uuid \
#        -d @/usr/local/wormbase/databases/WS226/cache/gene/overview/WBGene00006763.html -H "Content-Type: text/html"
# Assuming here that we are ONLY stocking our couchdb, not updating it.
sub create_document {
    my $self = shift;
    my $params = shift;
    my $attachment = $params->{attachment};
    my $uuid       = $params->{uuid};
    my $database   = $params->{database};
    my $host       = $params->{host} || $self->write_host;  # PUTS are special; they'll be sent to a single server via proxy.
    my $port       = $params->{port} || $self->write_host_port;

    my ($res,$msg);

    # Attachments have a different URI target
    # and must include the attachment content.
    if ($attachment) {
	$msg  = $self->_prepare_request({method  => 'PUT',
					 path    => "$database/$uuid/attachment",
					 content => "$attachment",
					 host    => $host,
					 port    => $port,
					}
	    );
	$res = $self->_send_request($msg);
    } else {
	$msg  = $self->_prepare_request({method => 'PUT',
					 path   => $uuid });
	$res  = $self->_send_request($msg);
    }
    
    # Just return the HTTP::REsponse.
    return $res;
    
#    if ($res->is_success) {
#	my $data = $self->_parse_result($res);
#	return $data;
#    } else {
#	return $res->status;
#	return 0;
#    }
}


# Fetch a document
# curl -X PUT $couchdb/$release/uuid
# curl -X GET http://127.0.0.1:5984/ws226/gene_WBGene00006763_overview
sub get_document {
    my ($self,$params) = @_;
    my $uuid     = $params->{uuid};
    my $database = $params->{database};
    my $host     = $params->{host} || $self->read_host;
    my $port     = $params->{port} || $self->read_host_port;

    my $msg  = $self->_prepare_request({ method => 'GET',
                                         path   => "$database/$uuid",
                                         host   => $host,
                                         port   => $port,
                                       });
    my $res  = $self->_send_request($msg);
    if ($res->is_success) {
        return $res->content;
    } else {
        return 0;
    }
}


# GET couchdbhost/version/uuid/attachment
# Returns the HTML of the attachement; otherwise return false.
sub get_attachment {
    my ($self,$params) = @_;
    my $uuid     = $params->{uuid};
    my $database = $params->{database};
    my $host     = $params->{host} || $self->read_host;
    my $port     = $params->{port} || $self->read_host_port;

    my $msg  = $self->_prepare_request({ method => 'GET',
					 path   => "$database/$uuid/attachment",
					 host   => $host,					 
					 port   => $port,
				       });
    
    my $res  = $self->_send_request($msg);    
    if ($res->is_success) {
	return $res->content;
    } else {
	return 0;
    }
}
	



###########################################
#
# Private Methods 
#
###########################################

#sub _encode_args {
#    my ($self, $args) = @_;
#
#    # Values need to be utf-8 encoded.  Because of a perl bug, exposed when
#    # client code does "use utf8", keys must also be encoded.
#    # see: http://www.perlmonks.org/?node_id=668987
#    # and: http://perl5.git.perl.org/perl.git/commit/eaf7a4d2
#    return { map { utf8::upgrade($_) unless ref($_); $_ } %$args };
#}


# Override $host here to make a request against a specific server, otherwise, request is against loopback.
# Override $port here to make a request against a non-standard port, otherwise default port of 5984.
sub _prepare_request {
    my ($self,$opts) = @_;
    my $method  = $opts->{method};
    my $path    = $opts->{path};    # Path should INCLUDE server (ie database name)
    my $content = $opts->{content};
    my $host    = $opts->{host};    # Send all requests back to the original server.
    my $port    = $opts->{port};

    # ¡Muy importante!
    # CouchDB requests will go back to the original host (or the name of the proxy)
    # with the couchdb port appended.

    # Single server installations will need to have port 5984 open.
    # Proxy server installations will need to direct PUT requests to the appropriate backend server.
        
    $host =~ s/\/$//;
    my $uri  = URI->new("http://$host:$port/$path");
    my $msg  = HTTP::Request->new($method,$uri);

    # Append content to the body if it exists (this is the attachment mechanism for couchdb)
    if ($content) {
	$msg->content($content);
    }
    return $msg;    
}

sub _send_request {
    my $self    = shift;
    my $msg     = shift;
    my $content = shift;
    
    my $ua = $self->ua;
    if ($content) {
	$ua->request($msg,$content);
    } else {
	$ua->request($msg);
    }
}

sub _parse_result {
    my ($self, $res) = @_;
    
    my $content = $res->content;

#    my $obj = try { $self->_from_json($content) };
    my $obj = $self->_from_json($content);
    return $obj;
}


1;

