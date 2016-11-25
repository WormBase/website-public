package WormBase::CHI::Driver::Couch;

use Moose; # strict, warnings

use Log::Any qw($log);
use WormBase::CouchAgent;
use URI::Escape::XS qw(uri_escape uri_unescape);
use namespace::autoclean -except => 'meta';

extends 'CHI::Driver';

has 'host' => (
    is      => 'ro',
    isa     => 'Str',
    default => '127.0.0.1',
);

has 'port' => (
    is      => 'ro',
    isa     => 'Int',
    default => 5984,
);

# for some reason +namespace doesn't let me make is => 'rw' work
has 'namespace' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Default',
);

has '_couchagent' => (
    is      => 'ro',
    isa     => 'WormBase::CouchAgent',
    lazy    => 1,
    builder => '_build__couchagent',
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my %params = @_ == 1 && ref $_[0] eq 'HASH'
               ? %{$_[0]} : @_;

    if ($params{server}) {
        my ($host, $port) = split /:/, $params{server};
        delete $params{server};
        $params{host} = $host;
        $params{port} = $port;
    }

    return $class->$orig(%params);
};

sub _build__couchagent {
    my ($self) = @_;
    return WormBase::CouchAgent->new({
        host     => $self->host,
        port     => $self->port,
        database => $self->escape_namespace($self->namespace),
    });
}

sub fetch {
    my ($self, $key) = @_;

    my $doc = $self->_couchagent->fetch_document({ id => $self->escape_key($key) });
    return $doc->{data};
}

sub has_document {
    my ($self, $key) = @_;

    return $self->_couchagent->get_document({ id => $self->escape_key($key) });
}

sub fetch_multi_hashref {
    my ($self, $keys) = @_;

    my $data = $self->_couchagent->bulk_fetch_documents({
        keys => [ map { $self->escape_key($_) } @$keys ]
    });
    return {
        map { $self->unescape_key($_->{_id}) => $_->{data} }
            grep(defined, @$data)
    };
}

sub store {
    my ($self, $key, $data) = @_;

    $self->_couchagent->update_document({
        create   => 1,
        document => {
            _id    => $self->escape_key($key),
            data   => $data,
        },
    });
}

# UNTESTED AND UNUSED BY CHI RIGHT NOW
sub store_multi {
    my ($self, $key_data, $options) = @_;

    my @documents = map { _id => $self->escape_key($_), data => $key_data->{$_} },
                        keys %$key_data;

    $self->_couchagent->bulk_update_documents({
        documents => \@documents,
        # nocheck   => 1,
    });
}

sub clear {
    my ($self) = @_;
    $self->_couchagent->delete_database;
    $self->_couchagent->create_database;
}

sub remove {
    my ($self, $key) = @_;

    $self->_couchagent->delete_document({ id => $self->escape_key($key) });
}

sub get_namespaces {
    my ($self) = @_;
    return map { $self->unescape_namespace($_) }
               @{$self->_couchagent->list_databases};
}

sub get_keys {
    my ($self) = @_;
    return map { $self->unescape_key($_->{id}) }
               @{$self->_couchagent->bulk_get_documents};
}

sub escape_namespace {
    my (undef, $ns) = @_;
    $ns =~ s/([A-Z_])/_\L$1/g;
    $ns =~ s/^([^a-wyz])/x$1/g;
    return uri_escape($ns);
}

sub unescape_namespace {
    my (undef, $ns) = @_;
    $ns = uri_unescape($ns);
    $ns =~ s/^x(.)/$1/;
    $ns =~ s/_(.)/\U$1/g;
    return $ns;
}

sub escape_key {
    my (undef, $key) = @_;
    return uri_escape($key);
}

sub unescape_key {
    my (undef, $key) = @_;
    return uri_unescape($key);
}

__PACKAGE__->meta->make_immutable;

1;
