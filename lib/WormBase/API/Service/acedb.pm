package WormBase::API::Service::acedb;

use Moose;
use WormBase::Ace;

use namespace::clean -except => 'meta';

has 'dbh'     => (
    is        => 'rw',
    isa       => 'Ace',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/fetch raw_query find fetch_many raw_fetch/],
);

# Roles to consume.
with 'WormBase::API::Role::Service';

has 'timeout' => (
    is        => 'ro',
    isa       => 'Str'
);

has 'query_timeout' => (
    is              => 'ro',
    isa             => 'Str'
);

has 'program'  => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_program {
    my $self = shift;
    return $self->conf->{program};
}

has 'path'     => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_path {
    my $self = shift;
    return $self->conf->{path};
}

around 'reconnect' => sub {
    my $orig       =  shift;
    my $self       =  shift;

    my $dbh;
    if (my $prog = $self->program and my $path = $self->path) {
        # go straight to connecting
        $self->log->debug("try #0: Connecting to ", $self->symbolic_name,
                          " locally at $path using $prog");
        $dbh     = $self->connect;
    }

    # use the fallback reconnect if program is not available
    $dbh ||= $self->$orig(@_);

    return $dbh;
};

sub connect {
    my $self = shift;
    my $conf = $self->conf;

    my %options =  ( # will always have this...
        -user   => $self->user,
        -pass   => $self->pass,
    );

    if (my $prog = $self->program and my $path = $self->path) {
        @options{'-program', '-path'} = ($prog, $path);
    }
    else {
        @options{'-host', '-port'} = ($ENV{'ACEDB_HOST'} || $self->host, $self->port);
    }

    if ($conf->{cache_root}) { # cache root indicates need file cache
        $options{-cache} = {
            cache_root         => $conf->{cache_root},
            max_size           => $conf->{cache_size},
            default_expires_in => $conf->{cache_expires},
        };

        # ace requires the following to have a value if present
        $options{-cache}->{cache_auto_purge_interval} = $conf->{cache_auto_purge_interval}
            if $conf->{cache_auto_purge_interval};
    }

    my $dbh = WormBase::Ace->connect(%options)
        or $self->log->error(WormBase::Ace->error);
    return $dbh;
}

sub ping {
  my ($self,$dbh)=@_;
  return $dbh->ping;

}

1;
