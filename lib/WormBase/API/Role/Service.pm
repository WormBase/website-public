package WormBase::API::Role::Service;

use Moose::Role;
use Fcntl qw(:flock O_RDWR O_CREAT);
use DB_File::Lock;

use constant INITIAL_DELAY => 600;

# Every service should provide a:
requires 'dbh';    # a database handel for the service
requires 'connect';    # a database connection for the service

has symbolic_name => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    documentation => 'A simple symbolic name for the service, typically a single word, e.g. "acedb"',
    );

has function => (
    is  => 'rw',
    isa => 'Str',
    documentation => 'A brief description of the service',
    );

has version => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->dbh->version;
    },
    );

has path => (
    is => 'ro',
    required => 1,
    default => '/tmp/',
    );

has conf => (
    is => 'ro',
    required => 1,
    );

has log => (
    is => 'ro',
    );

has 'hosts' => (
    is  => 'rw',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
	my $self = shift;
	return [split(/\s+|\t/,$self->conf->{host})];
    }
#     default => [qw/aceserver.cshl.edu/],
    );

has 'host' => (
    is  => 'rw',
    isa => 'Str',
    default    => 0,
    );

has 'port' => (
    is  => 'rw',
    isa => 'Str',
#     default => '2005',
    );

has 'user' => (
    is  => 'rw',
    isa => 'Str',
    );

has 'pass' => (
    is  => 'rw',
    isa => 'Str',
    );

has 'species' => (
    is  => 'rw',
    isa => 'Str',
    required => 1,
    default => 'c_elegans',
    );


around 'dbh' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $species = $self->species;
    my $dbh = $self->$orig;
 
# Do we already have a dbh? HOW TO TEST THIS WITH HASH REF? Dose undef mean timeout or disconnected?
    if (!$self->select_host && $self->has_dbh && defined $dbh && $self->ping($dbh) ) {   
      $self->log->debug( $self->symbolic_name." dbh for species $species exists and is alive!");
      return $dbh;
    } 
    $self->log->debug( $self->symbolic_name." dbh for species $species doesn't exist or is not alive; trying to connect");
    return $self->reconnect();
     
};

sub reconnect {
    my $self = shift;
    my $ReconnectMaxTries=$self->conf->{reconnect}; # get this from configuration file!
    my $tries=0;
    my $dbh;

    do {
	$tries++;
	$dbh = eval {$self->connect() };
	$self->log->info("trytime $tries: Connecting to  ".$self->symbolic_name);
	if ($self->log->is_debug()) {
	    $self->log->debug('     using the following parameters:');
	    $self->log->debug('       ' . $self->host . ':' . (defined $self->port?$self->port:''));
	}
	if(defined $dbh && $dbh) {
	    $self->log->info("   --> succesfully established connection to  ".$self->symbolic_name." on " . $self->host);
	    # Cache my handle
	    $self->set_dbh($dbh);
	    return $dbh;
	} 
	else { 
	    $self->log->fatal($self->host." is down!");
	    $self->mark_host($self->host,'down');
	    $self->host(0);
	}
    }while($tries < $ReconnectMaxTries && $self->select_host);

    $self->log->fatal("Tried $tries times but still could not connect to the  ".$self->symbolic_name." !");
}

sub select_host {
    my $self   = shift;
    # open berkeley db(which stores the db hosts status information) handle once   
    # in order to prevent multiple reopenings of the database
    my $dbfile     = $self->dbfile(1);
    my $host_status;
    my $host;
    foreach my $host ( @{$self->hosts} ) {
# 	$self->log->debug('scan host: '.$host);
	my ($status,$last_checked)=(0,0);
	if( my $pack = $dbfile->{$host}) {
	  ($status,$last_checked) = unpack('lL',$pack); 
	   if($status < 0) {
		if( (time() - $last_checked) >= INITIAL_DELAY ) {$status=0;}
		else {next;}
	    }
	}   
	$host_status->{$status}->{$host}=$last_checked ;
    }
    defined $host_status or return;
    my @rank = sort {$a<=>$b} keys %{$host_status};
    
    if($self->host){
	unless(exists $host_status->{0}->{$self->host}) { 
	  if($rank[$#rank]- $rank[0] >= 2 && exists $host_status->{$rank[$#rank]}->{$self->host}) {
	    $self->mark_host($self->host,'up',-1,$dbfile) or return; 
	    $self->log->debug("give up current host  ".$self->host);
	    $self->host(0);
	  }
	  else {return ;}
	}
    }
    my @up = keys %{$host_status->{$rank[0]}};
    $host = $up[rand @up];
    $self->mark_host($host,'up',+1,$dbfile) or return;
    $self->log->debug("chose host:$host for connecting, it current has ".$rank[0]." connections");
    $self->host($host);
    return $host;
}

sub mark_host {
    my $self   = shift;
    my $host	= shift || return;
    my $mode	= shift;
    my $connection = shift;
    my $dbfile	= shift || $self->dbfile(1) || return ;
    
    $self->log->info("marking $host $mode");  
  
    if($mode eq 'down') {
	$dbfile->{$host} = pack('lL',-1,time(),INITIAL_DELAY);
    }
    else {
	 my ($status,$last_checked)=(0,0);
	if(my $pack = $dbfile->{$host}) {
	     ($status,$last_checked) = unpack('lL',$pack); 
	}
	$status+=$connection;
	$status = 0 if($status<0);
	$dbfile->{$host} = pack('lL',$status,time());
    }
}

sub dbfile {
    my $self  = shift;
    my $write = shift;

    my $locking    = $write ? 'write' : 'read';
    my $mode       = $write ? O_CREAT|O_RDWR : O_RDONLY;
    my $perms      = 0666;
    my $path	   = $self->path.'/WormBase_'.$self->symbolic_name;
    my %h;
    tie (%h,'DB_File::Lock',$path,$mode,$perms,$DB_HASH,$locking);
    return \%h;
}


1;
