package WormBase::API::Service::acedb;

use Moose;
use Ace;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Ace',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/fetch/],
    );

# Roles to consume.
with 'WormBase::API::Role::Service';
#with 'WormBase::API::Role::Logger';

has 'cache_root' => (
    is => 'ro',
    isa => 'Str',
    );

has 'cache_expires' => (
    is => 'ro',
    isa => 'Str',
    default => '1 day',
    );

has 'cache_size' => (
    is => 'ro',
    isa => 'Str',
    );

has 'cache_auto_purge_interval' => (
    is  => 'ro',
    isa => 'Str',
    default => '6 hours',
    );

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
    my ($host,$port,$user,$pass)=@_;
    my @cache = (-cache => {
	cache_root => $self->cache_root,
	max_size   => $self->cache_size
	    || $Cache::SizeAwareCache::NO_MAX_SIZE
	    || -1,  # hardcoded $NO_MAX_SIZE constant
	    default_expires_in  => $self->cache_expires,
	    auto_purge_interval => $self->cache_auto_purge_interval,
		 } 
	) if $self->cache_root;
    
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
    $self->species('');
    # record all the info from Conf file $self->conf_dir
    $self->hosts([qw/aceserver.cshl.edu/]);
    $self->port(2005);

}

1;
