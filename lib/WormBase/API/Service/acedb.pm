package WormBase::API::Service::acedb;

use Moose;
use Ace;

use namespace::clean -except => 'meta';

{
    # the following stops Ace from caching in memory and default to
    # file cache or fetch directly from AceDB.
    no warnings 'redefine';
    *Ace::memory_cache_store = sub {};
}


has 'dbh'     => (
    is        => 'rw',
    isa       => 'Ace',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/fetch raw_query find fetch_many/],
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

    my %cache_args         =  (
        cache_root         => $conf->{cache_root},
        max_size           => $conf->{cache_size},
	    default_expires_in => $conf->{cache_expires},
    ) if $conf->{cache_root};

    if ($conf->{cache_auto_purge_interval} ne '') {
        $cache_args{cache_auto_purge_interval} = 
            $conf->{cache_auto_purge_interval};
    }

    my %options =  ( # will always have this...
        -user   => $self->user,
        -pass   => $self->pass,
    );

    if (my $prog                      = $self->program and my $path = $self->path) {
        @options{'-program', '-path'} = ($prog, $path);
    }
    else {
        @options{'-host', '-port'} = ($self->host, $self->port);
    }

    $options{-cache} = \%cache_args if %cache_args;

    return Ace->connect(%options) || die Ace->error;
}

sub ping {
  my ($self,$dbh)=@_;
  return $dbh->ping;

}

1;
