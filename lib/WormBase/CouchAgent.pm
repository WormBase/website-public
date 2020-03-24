package WormBase::CouchAgent;

use Moose;

use JSON qw(encode_json decode_json);
use LWP::UserAgent;
use HTTP::Status qw(:constants);
use Carp qw(croak cluck confess);
use URI::Escape::XS qw(uri_escape);
use Data::Dumper;
use namespace::autoclean -except => 'meta';

# TODO: POD

has 'host' => (
    is      => 'rw',
    isa     => 'Str',
    default => '127.0.0.1',
);

has 'port' => (
    is      => 'rw',
    isa     => 'Int',
    default => 5984,
);

has 'database' => ( # name of database, e.g. ws227
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has '_ua' => (
    is      => 'ro',
    isa     => 'LWP::UserAgent',
    builder => '_build__ua',
);

sub BUILD {
    my ($self) = @_;
    my ($req, $res);

    # check if the database exists
    $req = $self->_prepare_request('GET');
    $res = $self->_request($req);
    return if $res->is_success; # database exists

    return $self->create_database if $res->code == HTTP_NOT_FOUND; # database missing
    return $self->_handle_http_error($res);
}

sub _build__ua {
    my ($self) = @_;

    my $default_header = HTTP::Headers->new(
        Content_Type => 'application/json',
        Accept       => 'application/json',
    );

    return LWP::UserAgent->new(
        agent           => 'WormBase/2.0 (Cache)',
        keep_alive      => 10,
        timeout         => 10,
        default_headers => $default_header,
    );
}

# this module should allow the client to form the document in whatever
# way necessary (whatever structure they wish)

sub update_document {
    my ($self, $params) = @_;
    my $document = $params->{doc} // $params->{document};

    my $id = $document->{_id} //= $params->{id} // $params->{key}
                              // croak 'Require id/key';
    $document->{_rev} //= $params->{rev}
                      // do {
                          my $doc = $self->get_document({ id => $id });
                          $doc->{_rev};
                      };

    if ( ! $document->{_rev} ) { # no revision so create?
        if ($params->{create}) { # create the document
            delete $document->{_rev};
            return $self->create_document($params);
        }
        return; # document doesn't exist ERROR?
    }

    my $req = $params->{delete}
            ? $self->_prepare_request(DELETE => uri_escape($id)
                                      . "?rev=$document->{_rev}")
            : $self->_prepare_request(PUT => uri_escape($id),
                                      { content => $document });

    my $res = $self->_request($req);

    return decode_json($res->content) if $res->is_success;

    if ($res->code == HTTP_CONFLICT) {
        # conflict in code
        return; # TODO: error?
    }

    return $self->_handle_http_error($res); # may just die
}

sub fetch_document {
    my ($self, $params) = @_;

    my $id = $params->{id} // $params->{key} // croak 'Require id/key';

    my $req = $self->_prepare_request(GET => uri_escape($id));
    my $res = $self->_request($req);

    return decode_json($res->content) if $res->is_success;

    if ($res->code == HTTP_NOT_FOUND) {
        return; # TODO: error?
    }

    return $self->_handle_http_error($res); # may just die
}

# NOTE: DOES NOT RETURN THE DATA; USE fetch_document FOR THAT
sub get_document {
    my ($self, $params) = @_;

    my $id = $params->{id} // $params->{key} // croak 'Require id/key';
    my $req = $self->_prepare_request(HEAD => uri_escape($id));
    my $res = $self->_request($req);

    if ($res->is_success) {
        my $rev = $res->header('Etag');
        $rev = substr $rev, 1, -1;
        return { _rev => $rev, _id => $id };
    }

    if ($res->code == HTTP_NOT_FOUND) {
        # document not found
        return; # TODO: error?
    }

    return $self->_handle_http_error($res);
}

sub create_document {
    my ($self, $params) = @_;

    my $document = $params->{doc} // $params->{document};
    my $id = $document->{_id} // $params->{id} // $params->{key}
          // croak 'Require id/key';

    my $req = $self->_prepare_request(PUT => uri_escape($id),
                                      { content => $document });
    my $res = $self->_request($req);

    return decode_json($res->content) if $res->is_success;

    if ($res->code == HTTP_CONFLICT) {
        # document already exists!
        return; # TODO: error
    }

    return $self->_handle_http_error($res);
}

sub delete_document {
    my ($self, $params) = @_;

    my $id = $params->{id} // $params->{key} // croak 'Require id/key';
    return $self->update_document({
        delete => 1,
        id     => $id
    });
}

sub bulk_get_documents {
    my ($self, $params) = @_;
    $params->{revonly} = 1;
    return $self->bulk_fetch_documents($params);
}

sub bulk_fetch_documents {
    my ($self, $params) = @_;

    my $docs = $params->{keys};
    croak 'Keys must be in an arrayref' if $docs && ref $docs ne 'ARRAY';

    my $path = '_all_docs';
    $path .= '?include_docs=true' unless $params->{revonly};

    my $req = $docs # bulk fetch specific or all?
            ? $self->_prepare_request(POST => $path,
                                      { content => { keys => $docs } })
            : $self->_prepare_request(GET => $path);

    my $res = $self->_request($req);
    if ($res->is_success) {
        my $data = decode_json($res->content);
        if ($docs) { # specific documents
            return [ map { $_->{value}{rev} } @{$data->{rows}} ] if $params->{revonly};
            return [ map { $_->{doc} }        @{$data->{rows}} ];
        }
        else { # want everything
            return [ map { id => $_->{id}, rev => $_->{value}{rev} }, @{$data->{rows}} ]
                if $params->{revonly};
            return [ map { $_->{doc} } @{$data->{rows}} ];
        }
    }

    return $self->_handle_http_error($res); # may just die
}

sub bulk_update_documents {
    my ($self, $params) = @_;

    my $documents = $params->{docs} // $params->{documents} // croak 'Require documents';
    unless ($params->{nocheck}) {
        croak 'Documents must be in arrayref' unless ref $documents eq 'ARRAY';
        foreach (@$documents) {
            croak 'Documents must be hashrefs' unless ref $_ eq 'HASH';
            croak 'Documents must have _id' unless defined $_->{_id};
        }
    }

    my $req = $self->_prepare_request(POST => '_bulk_docs',
                                      { content => { docs => $documents } });
    my $res = $self->_request($req);
    return decode_json($res->content) if $res->is_success;

    return $self->_handle_http_error($res); # may just die
}

sub list_databases {
    my ($self) = @_;
    my $res = $self->_request(HTTP::Request->new(
        GET => 'http://' . $self->host . ':' . $self->port. '/_all_dbs',
    ));

    return decode_json($res->content) if $res->is_success;

    return $self->_handle_http_error($res); # may just die
}

sub create_database {
    my ($self, $params) = @_;

    my $req = $self->_prepare_request('PUT');
    my $res = $self->_request($req);

    return decode_json($res->content) if $res->is_success;

    if ($res->code == HTTP_PRECONDITION_FAILED) {
        # database already exists
        return; # TODO: error?
    }

    return $self->_handle_http_error($res); # may just die
}

sub delete_database {
    my ($self, $params) = @_;

    my $req = $self->_prepare_request('DELETE');
    my $res = $self->_request($req);

    return decode_json($res->content) if $res->is_success;

    if ($res->code == HTTP_NOT_FOUND) {
        # database doesn't exist
        return;
    }

    return $self->_handle_http_error($res); # may just die
}

############################################################
#
# Private stuff
#
############################################################

sub _request {
    shift->_ua->request(@_);
}

sub _prepare_request {
    my ($self, $method, $path, $args) = @_;
    my $uri = 'http://' . $self->host . ':' . $self->port . '/'
            . $self->database;
    $uri   .= "/$path" if defined $path;

    my $req = HTTP::Request->new($method, $uri, $self->_ua->default_headers);
    $req->content(encode_json($args->{content})) if defined $args->{content};

    return $req;
}

sub _handle_http_error {
    my ($self, $res) = @_;
    my $err = 'HTTP ERROR: ', $res->status_line;
    $err .= "\n" . $res->content if $res->content;
    $err .= "\n" . Dumper($res->request);
    confess $err;
}

__PACKAGE__->meta->make_immutable;

1;
