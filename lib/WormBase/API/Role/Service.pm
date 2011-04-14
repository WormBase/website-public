package WormBase::API::Role::Service;

use Moose::Role;
use Fcntl qw(:flock O_RDWR O_CREAT);
use DB_File::Lock;
use File::Path 'mkpath';

# Every service should provide a:
requires 'dbh';    # a database handel for the service
requires 'connect';    # a database connection for the service
requires 'ping';

has conf => ( # the other attributes can probably be built from this
    is       => 'ro',
    required => 1,
);

has symbolic_name => (
    is            => 'rw',
    isa           => 'Str',
    required      => 1,
    documentation => 'A simple symbolic name for the service, typically a single word, e.g. "acedb"',
);

has function => (
    is            => 'rw',
    isa           => 'Str',
    documentation => 'A brief description of the service',
    lazy          => 1,
    builder       => '_build_function',
);

sub _build_function {
    return 'unknown';
}

has version => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $dbh = $self->dbh || return "?";
        return $dbh->version;
    },
);

has 'tmp_base' => (
    is       => 'ro',
    required => 1,
    default  => '/tmp/',
);

has 'hosts' => (
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    lazy_build => 1,
);

sub _build_hosts {
    my $self = shift;
    return [split /\s+/o , $self->conf->{host}];
}

has log => (
    is => 'ro',
);

has 'host' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => 0,
);

has 'port' => (
    is         => 'rw',
    isa        => 'Str', # does not allow undef -- necessary? 
    lazy_build => 1,
    #     default => '2005',
);

sub _build_port {
    my ($self) = @_;
    return $self->conf->{port} // ''; # satisfy type constraint
}

has 'user' => (
    is         => 'rw',
    isa        => 'Str', # does not allow undef
    lazy_build => 1,
);

sub _build_user {
    my ($self) = @_;
    return $self->conf->{user} // ''; # satisfy type constraint
}

has 'pass' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

sub _build_pass {
    my ($self) = @_;
    return $self->conf->{pass};
}

has 'source' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
    default  => 'c_elegans',
);

around 'dbh' => sub {
    my $orig = shift;
    my $self = shift;

    if (my $dbh = $self->$orig(@_)) {
        $self->ping($dbh) and return $dbh;
    }

    my $source = $self->source;
    $self->log->debug( $self->symbolic_name." dbh for source $source doesn't exist or is not alive; trying to connect");
    return $self->reconnect;
};

sub reconnect {
    my $self  = shift;

    my $tries = 0;
    my $dbh;
    foreach my $host ($self->select_hosts) {
        $tries++;

        $self->host($host);

        $self->log->info("try #$tries: Connecting to ".$self->symbolic_name. " ".$self->source);
        $self->log->debug('     using the following parameters:');
        $self->log->debug('       ' . $self->host . ':' . (defined $self->port?$self->port:''));

        if ($dbh = eval {$self->connect}) {
            $self->log->info("   --> succesfully established connection to  ".$self->symbolic_name." on " . $self->host);
            # Cache my handle
            $self->set_dbh($dbh);
            return $dbh;
        }

        $self->mark_down_host($self->host);
        $self->log->fatal($self->host." is down!");
        $self->log->fatal($@) if $@;
        $self->host(0);

        last if $tries > $self->conf->{reconnect};
    }

    $self->log->fatal("Tried $tries times but still could not connect to the  ".$self->symbolic_name." !");
    return 0;
}

# get hosts to try to connect to
sub select_hosts {
    my ($self) = @_;
    my $get_downed_hosts = $self->get_downed_hosts(1);
    my @live_hosts;
    foreach my $host ( @{$self->hosts} ) {
        if ( my $pack = $get_downed_hosts->{$host}) {
            next if time - unpack('L', $pack) < $self->conf->{delay};
            $get_downed_hosts->{$host} = undef;
        }
        push @live_hosts, $host;
        $self->log->debug("push host $host in the queue for connection");
    }
    return @live_hosts;
}

# sub select_hosts {
#     my ($self,$current)   = @_;
#     my $ua = LWP::UserAgent->new(protocols_allowed => ['http'], timeout=>5 );
#     # if the current connected host is not too busy then continue using it
#     # number 40 is arbitrary and needs to be adjusted in future!
#     if(defined $current) {
# 	return 0 if($self->check_cpu_load($ua,$self->host)<40) ;
# 	return 1;
#     }
#     # open berkeley db(which stores the db hosts status:on/off information)
#     my $get_downed_hosts     = $self->get_downed_hosts(1);
#     my $host_loads;
#     foreach my $host ( @{$self->hosts} ) {
# 	my ($status,$last_checked)=(0,0);
# 	if( my $pack = $get_downed_hosts->{$host}) {
# 	  if( (time() - unpack('L',$pack)) >= INITIAL_DELAY ) {
# 		  undef $get_downed_hosts->{$host};
#   # 		$self->mark_host($host,1,$get_downed_hosts);
# 	  }
# 	  else {next;}

# 	}
# 	$host_loads->{$host} = $self->check_cpu_load($ua,$host);
# 	$self->log->debug("host $host CPU Load: ".$host_loads->{$host}."%");
#     }
#     defined $host_loads or return;
#     return sort {$host_loads->{$a}<=>$host_loads->{$b}} keys %{$host_loads};
# }

# sub check_cpu_load {
#     my ($self,$ua,$host) = @_;
#     my $response = $ua->get("http://".$host."/server-status");
#     my $load = -1;  # this is set temporarily since the server-status module is not enabled on hosts now
#     if($response->is_success) {
# 	($load)=$response->content =~ /CPU Usage.*- (.*) CPU load/i;
# 	$load =~ s/%// if(defined $load);
#     }
#     else {
# # 	$self->log->debug("not able to retrieve host $host status through http!");
#     }
#     return $load;
# }

sub mark_down_host {
    my $self   = shift;
    my $host   = shift || return;
    my $get_downed_hosts = shift || $self->get_downed_hosts(1) || return;

    $self->log->info("marking $host down");
    $get_downed_hosts->{$host} = pack('L',time());
}

# returns hashref of HOST => TIME SINCE DOWN
sub get_downed_hosts {
    my $self  = shift;
    my $write = shift;

    my $locking    = $write ? 'write' : 'read';
    my $mode       = $write ? O_CREAT|O_RDWR : O_RDONLY;
    my $perms      = 0666;

    mkpath($self->tmp_base,0,0777) unless -d $self->tmp_base;

    my $path	   = $self->tmp_base.'/WormBase_'.$self->symbolic_name;
    my %h;
    tie (%h,'DB_File::Lock',$path,$mode,$perms,$DB_HASH,$locking);
    return \%h;
}



1;
