package WormBase::DSN::AceDB;

# Note: For now, this module only connects to saceserver instances.
# This is also a generic factory for WormBase::DSN::AceDB::* objects


use Moose;
use Ace;
use Bio::Graphics::Browser;

extends 'WormBase';

has 'acedb_host' => (
    is  => 'ro',
    isa => 'Str',
    default => 'localhost',
    );

has 'acedb_port' => (
    is  => 'ro',
    isa => 'Str',
    default => '2005',
    );

has 'acedb_user' => (
    is  => 'ro',
    isa => 'Str',
    );

has 'acedb_pass' => (
    is  => 'ro',
    isa => 'Str',
    );

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

has 'dbh' => (
    is        => 'rw',
    isa       => 'Ace',
    lazy      => 1,
    builder   => '_build_dbh',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    );

around 'dbh' => sub {
    my $orig = shift;
    my $self = shift;

    # Do we already have a dbh?
    if ($self->has_dbh) {
	my $dbh = $self->$orig();
	
	# If so, is it alive?	
	if ($dbh->ping) {
	    $self->log->debug("     ace-dbh has been set and is alive!");
	    return $self->$orig();
	} else {
	    $self->log->debug("     ace-dbh has been set but is dead; trying to resurrect it");
	    $dbh->reopen();
	    if ($dbh->ping) {
		$self->log->debug("          ...success!");
		return $self->$orig();
	    } else {
		$self->log->fatal("     FAILED TO REVIVE ACE-DBH!");
	    }
	}
    }
    
    # For some reason, dbh() is not yet set. Call connect().
    $self->connect();
    return $self;
};
    

has 'version' => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->dbh->version;
    },
    );

#  Create a new database handle (if necessary) during object instantiation
sub BUILD {
    my ($self) = @_;
    $self->connect();
}


# TODO: Should be able to select from a number of available acedb hosts
#  my @available_hosts = $self->acedb_hosts;
#  my $host = $available_hosts[int(rnd())];
sub connect {
    my $self = shift;

    # Establish authorization
    my @auth  = (-user=>$self->acedb_user,
		 -pass=>$self->acedb_pass) 
	if $self->acedb_user && $self->acedb_pass;
    
    # Establish the cache
    my @cache = (-cache => {
	cache_root => $self->cache_root,
	max_size   => $self->cache_size
	    || $Cache::SizeAwareCache::NO_MAX_SIZE
	    || -1,  # hardcoded $NO_MAX_SIZE constant
	    default_expires_in  => $self->cache_expires,
	    auto_purge_interval => $self->cache_auto_purge_interval,
		 } 
	) if $self->cache_root;
    
    my $dbh = Ace->connect(-host => $self->acedb_host,
			   -port => $self->acedb_port,
			   -timeout => 50,
			   @auth,
			   @cache);

    $self->log->info("Connecting to acedb:");
    if ($self->log->is_debug()) {
	$self->log->debug('     using the following parameters:');
	$self->log->debug('       ' . $self->acedb_host . ':' . $self->acedb_port);
    }
    $dbh 
	? $self->log->info("   --> succesfully established connection to acedb on " . $self->acedb_host)
	: $self->log->fatal("Could not connect to the aceserver at " . $self->acedb_host);

    # Cache my handle
    $self->set_dbh($dbh);
    return $dbh;
}


# I wonder if this is actually necessary now with around method modifier.
sub _build_dbh {
    my $self = shift;
#    my $dbh = $self->dbh;
     my $dbh;
    # Do we have a live dbh? Just return it.
    if ($dbh && $dbh->ping) {
	$self->log->debug("The aceserver dbh is already established and cached");
	return $dbh;
    } else {
	$self->log->debug("Acedb has gone away. Trying to reconnect...");
	my $dbh = $self->connect();
	$self->dbh($dbh);
	return $dbh;
    }
}


#sub set_dbh {
#    my ($self,$dbh) = @_;
#    $self->log->debug("setting dbh to $dbh");
#    $self->dbh($dbh);
#}



# Provided with the name of an object,
# fetch it from the database.
# NOTE: This is intended to only return
# a single object. It is NOT a search!

sub get_object {
    my ($self,$class,$name) = @_;
    
    $self->log->debug("get_object(): class:$class name:$name");
    
    my $db = $self->dbh();
    my $formatted_class = ucfirst($class);
    my $object = $db->fetch(-class=>$formatted_class,-name=>$name,-fill=>1);  
    
    return $object;
}



=head1 NAME

WormBase::Model::AceDB - AceDB Model Class

=head1 SYNOPSIS

See L<WormBase>

=head1 DESCRIPTION

AceDB Model Class

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
