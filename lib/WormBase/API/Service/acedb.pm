package WormBase::API::Service::acedb;

use Moose;
use Ace ();

has 'dbh' => (
    is        => 'rw',
    isa       => 'Ace',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/fetch raw_query find fetch_many/],
);

# Roles to consume.
with 'WormBase::API::Role::Service';

has 'timeout' => (
    is  => 'ro',
    isa => 'Str'
);

has 'query_timeout' => (
    is  => 'ro',
    isa => 'Str'
);

has 'program' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_program {
    my $self = shift;
    return $self->conf->{program};
}

has 'path' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_path {
    my $self = shift;
    return $self->conf->{path};
}

around 'reconnect' => sub {
    my $orig = shift;
    my $self = shift;

    my $dbh;
    if (my $prog = $self->program and my $path = $self->path) {
        # go straight to connecting
        $self->log->debug("try 0: Connecting to ", $self->symbolic_name,
                          " locally at $path using $prog");
        $dbh = $self->connect;
    }

    # use the fallback reconnect if program is not available
    $dbh ||= $self->$orig(@_);

    return $dbh;
};

sub connect {
    my $self = shift;

    # my @cache = (-cache => {
    #     cache_root => $self->conf->{cache_root},
    #     max_size   => $self->conf->{cache_size}
	#     || $Cache::SizeAwareCache::NO_MAX_SIZE
	#     || -1,                  # hardcoded $NO_MAX_SIZE constant
	#     default_expires_in  => $self->conf->{cache_expires},
	#     auto_purge_interval => $self->conf->{cache_auto_purge_interval},
    # })
    #     if $self->conf->{cache_root};

    my %options = ( # will always have this...
        -user => $self->user,
        -pass => $self->pass,
    );

    if (my $prog = $self->program and my $path = $self->path) {
        @options{'-program', '-path'} = ($prog, $path);
    }
    else {
        @options{'-host', '-port'} = ($self->host, $self->port);
    }

    return Ace->connect(%options);
    #			   @cache);
}

sub ping {
  my ($self,$dbh)=@_;
  return $dbh->ping;

}

1;
