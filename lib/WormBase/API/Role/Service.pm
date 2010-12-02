package WormBase::API::Role::Service;

use Moose::Role;
use Fcntl qw(:flock O_RDWR O_CREAT);
use DB_File::Lock;
use File::Path 'mkpath';

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
	my $dbh = $self->dbh || return "?";
	return $dbh->version;
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
    if ($self->has_dbh && defined $dbh && $dbh && $self->ping($dbh) && !$self->select_host(1)) {   
#       $self->log->debug( $self->symbolic_name." dbh for species $species exists and is alive!");
      return $dbh;
    } 
    $self->log->debug( $self->symbolic_name." dbh for species $species doesn't exist or is not alive; trying to connect");
    undef $dbh; #release the current connection if exists
    return $self->reconnect();
     
};

sub reconnect {
    my $self = shift;
    my $tries=0;
    my $dbh;
    my @hosts = $self->select_host;
    while(@hosts && $tries < $self->conf->{reconnect} && $self->host(shift @hosts) ) {
	$tries++; 
	$self->log->info("trytime $tries: Connecting to  ".$self->symbolic_name);
	$self->log->debug('     using the following parameters:');
	$self->log->debug('       ' . $self->host . ':' . (defined $self->port?$self->port:''));
	
	$dbh = eval {$self->connect() };
	if(defined $dbh && $dbh) {
	    $self->log->info("   --> succesfully established connection to  ".$self->symbolic_name." on " . $self->host);
	    # Cache my handle
	    $self->set_dbh($dbh);
	    return $dbh;
	} 
	else { 
	    $self->mark_down($self->host);
	    $self->log->fatal($self->host." is down!");
	    $self->host(0);
	}
    } 
    $self->log->fatal("Tried $tries times but still could not connect to the  ".$self->symbolic_name." !");
    return 0;
}

sub select_host {
    my ($self,$current)   = @_;
    my $ua = LWP::UserAgent->new(protocols_allowed => ['http'], timeout=>30 );
    # if the current connected host is not too busy then continue using it
    # number 40 is arbitrary and needs to be adjusted in future!
    if(defined $current) {
	return 0 if($self->check_cpu_load($ua,$self->host)<40) ;
	return 1;
    }
    # open berkeley db(which stores the db hosts status:on/off information)  
    my $dbfile     = $self->dbfile(1);
    my $host_loads;
    foreach my $host ( @{$self->hosts} ) {
	my ($status,$last_checked)=(0,0);
	if( my $pack = $dbfile->{$host}) {  
	  if( (time() - unpack('L',$pack)) >= INITIAL_DELAY ) {
		  undef $dbfile->{$host};
  # 		$self->mark_host($host,1,$dbfile);
	  }
	  else {next;}
	   
	} 
	$host_loads->{$host} = $self->check_cpu_load($ua,$host);
	$self->log->debug("host $host CPU Load: ".$host_loads->{$host}."%");
    }
    defined $host_loads or return;
    return sort {$host_loads->{$a}<=>$host_loads->{$b}} keys %{$host_loads};
}

sub check_cpu_load {
    my ($self,$ua,$host) = @_;
    my $response = $ua->get("http://".$host."/server-status");
    my $load = -1;  # this is set temporarily since the server-status module is not enabled on hosts now
    if($response->is_success) {
	($load)=$response->content =~ /CPU Usage.*- (.*) CPU load/i;
	$load =~ s/%// if(defined $load);
    }
    else {
# 	$self->log->debug("not able to retrieve host $host status through http!");
    }
    return $load;
}

sub mark_down {
    my $self   = shift;
    my $host	= shift || return;
    my $dbfile	= shift || $self->dbfile(1) || return ;
    $self->log->info("marking $host down");  
    $dbfile->{$host} = pack('L',time());
}

sub dbfile {
    my $self  = shift;
    my $write = shift;

    my $locking    = $write ? 'write' : 'read';
    my $mode       = $write ? O_CREAT|O_RDWR : O_RDONLY;
    my $perms      = 0666;

    mkpath($self->path,0,0777) unless -d $self->path; 

    my $path	   = $self->path.'/WormBase_'.$self->symbolic_name;
    my %h;
    tie (%h,'DB_File::Lock',$path,$mode,$perms,$DB_HASH,$locking);
    return \%h;
}



1;
