package WormBase::API::Service::acedb;

use Moose;
use Ace ();
#database handel
has 'dbh' => (
    is        => 'rw',
    isa       => 'Ace',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
#     handles   => [qw/fetch/],
    );

# Roles to consume.
with 'WormBase::API::Role::Service';

has 'path' => (
    is => 'ro',
    isa => 'Str'
    );

has 'timeout' => (
    is => 'ro',
    isa => 'Str'
    );

has 'query_timeout' => (
    is => 'ro',
    isa => 'Str'
    );

sub connect {
    my $self = shift;
    my ($host)=@_;
    my @cache = (-cache => {
	cache_root => $self->conf->{cache_root},
	max_size   => $self->conf->{cache_size}
	    || $Cache::SizeAwareCache::NO_MAX_SIZE
	    || -1,  # hardcoded $NO_MAX_SIZE constant
	    default_expires_in  => $self->conf->{cache_expires},
	    auto_purge_interval => $self->conf->{cache_auto_purge_interval},
		 } 
	) if $self->conf->{cache_root};
    
    return Ace->connect(-host => $host,
			      -port => $self->port,
			      -user=>$self->user,
			      -pass=>$self->pass,
			    );
    #			   @cache);
}

sub ping {
  my ($self,$dbh)=@_;
  return $dbh->ping;

}

sub BUILD {
    my $self = shift;
    $self->symbolic_name("acedb");
    $self->function("get connection to AceDB database");
    # record all the info from Conf file $self->conf_dir
    my @hosts;
#     push @hosts ,$self->conf->{acedb_host};
    $self->hosts([$self->conf->{host}]);
    $self->port($self->conf->{port});

}

sub fetch {
    my $self=shift;
    return $self->dbh->fetch(@_); 
}
1;
