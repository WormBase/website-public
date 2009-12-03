package WormBase;

use Log::Log4perl;
use FindBin qw/$Bin/;
#use Ace;
#use Bio::DB::GFF;
use Moose;

#
#=head1 ATTRIBUTES
#
#=head2 log
#
#Status : optional
#Type   : A Log::Log4perl object
#
#If not specified, a default Log::Log4Perl object will
#be created that appends STDOUT to the screen.
#
#=cut
#
#has 'log' => (
#	      is   => 'ro',
#	      lazy => 1,
#	      builder => '_build_log'
#	     );
#
#sub _build_log {
#  my $self = shift;
#  
#  # Use the default log4perl that is supplied with the webapp
#  Log::Log4perl::init("../conf/log4perl-screen.conf");
#  my $log = Log::Log4perl::get_logger();
#  return $log;
#}

=head1

#####################################################
#
#   OPTIONAL: AceDB attributes
#
#   If not specified, a connection to the saceserver
#   on localhost:2005 will be established.
#
#####################################################
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

has 'acedb_dbh' => (
    is        => 'rw',
#    isa       => 'Ace',
    lazy      => 1,
    builder   => '_build_acedb_dbh',
    predicate => 'has_acedb_dbh',
    writer    => 'set_acedb_dbh',
    );

around 'acedb_dbh' => sub {
    my $orig = shift;
    my $self = shift;

    # Do we already have a dbh?
    if ($self->has_acedb_dbh) {
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
    $self->connect_to_acedb();
    return $self;
};
    
# Version ocorresponds to version of the current AceDB
has 'version' => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->acedb_dbh->version;
    },
    );

#####################################################
#
#   OPTIONAL: GFFDB attributes
#
#   If not specified, NO database handles will be
#   established.
#
#####################################################

has 'mysql_user' => (
    is => 'ro',
    isa => 'Str',
    );

has 'mysql_pass' => (
    is => 'ro',
    isa => 'Str',
    );
    
has 'mysql_host' => (
    is => 'ro',
    isa => 'Str',
    default => 'localhost'
    );

has 'data_sources' => (
    is => 'ro',
    isa => 'HashRef'
    );

has 'gff_dbh' => (
    is        => 'rw',
    isa       => 'HashRef',
    lazy      => 1,
    builder   => '_build_gff_dbh',
    predicate => 'has_gff_dbh',
    writer    => 'set_gff_dbh',
    );

around 'gff_dbh' => sub {
    my $orig = shift;
    my $self = shift;

    # Do we already have a dbh?
    # This SHOULD be parameterized to accept the species.
    # Maybe I need an attribute helper?
    if ($self->has_gff_dbh) {
	return $self->$orig;
    } else {
	$self->log->debug("     gff-handles are missing; trying to resurrect");
	# For some reason, dbh() is not yet set. Call connect().
	$self->connect_to_gff();
    }
    
    return $self;
};



#####################################################
#
#    METHODS
#
#####################################################

# Create appropriate database handles (if necessary)
# during object instantiation
sub BUILD {
    my $self = shift;
    $self->connect_to_acedb();
    $self->connect_to_gff();
}


# TODO: Should be able to select from a number of available acedb hosts
#  my @available_hosts = $self->acedb_hosts;
#  my $host = $available_hosts[int(rnd())];
sub connect_to_acedb {
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
	? $self->log->info("   --> succesfully established connection to acedb on "
			   . $self->acedb_host)
	: $self->log->fatal("Could not connect to the aceserver at "
			    . $self->acedb_host);

    # Cache the acedb database handle
    $self->set_acedb_dbh($dbh);
    return $dbh;
}

sub connect_to_gff {
    my $self = shift;
    $self->log->info("Connecting to GFF databases");
    
    my %handles;
    # Connect to each GFF/Support database  
    foreach my $species (keys %{$self->data_sources}) {
	$self->log->info("Connecting to the GFF database for $species");
	my $gff_args = $self->data_sources->{$species};

	return unless ($gff_args);
  
	$gff_args->{-user} = $self->mysql_user;
	$gff_args->{-pass} = $self->mysql_pass;
	$gff_args->{-dsn}  = "dbi:mysql:database=$species;host=" . $self->mysql_host;
	
	if ($self->log->is_debug()) {
	    $self->log->debug("     using the following parameters:");
	    foreach (keys %$gff_args) {
		$self->log->debug("       $_" . " "  . $gff_args->{$_});
	    }
	}  
	
	my $dbh = Bio::DB::GFF->new(%$gff_args)
	    or $self->log->fatal("Couldn't connect to the $species GFF database!");
	
	$self->log->info("   --> succesfully established connection to $species GFF") if $dbh;
	
	$handles{$species} = $dbh;
    }

    $self->set_gff_dbh(\%handles);
}



# I wonder if this is actually necessary now with around method modifier.
#sub _build_acedb_dbh {
#    my $self = shift;
##    my $dbh = $self->dbh;
#     my $dbh;
#    # Do we have a live dbh? Just return it.
#    if ($dbh && $dbh->ping) {
#	$self->log->debug("The aceserver dbh is already established and cached");
#	return $dbh;
#    } else {
#	$self->log->debug("Acedb has gone away. Trying to reconnect...");
#	my $dbh = $self->connect_to_acedb();
#	$self->dbh($dbh);
#	return $dbh;
#    }
#}


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
    
    my $db = $self->acedb_dbh();
    my $formatted_class = ucfirst($class);
    my $object = $db->fetch(-class=>$formatted_class,-name=>$name,-fill=>1);  
    
    return $object;
}




=cut




1;



