package WormBase::API::Role::Service;

use Moose::Role;

# Every service should provide a:
requires 'dbh';    # a database handel for the service
requires 'connect';    # a database connection for the service

has symbolic_name => (
    is => 'rw',
    isa => 'Str',
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
#     default => [qw/aceserver.cshl.edu/],
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
    if ($self->has_dbh && defined $dbh && $self->ping($dbh)) { 
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
    while($tries<$ReconnectMaxTries) {
	$tries++;
	my $host = $self->hosts->[ rand @{$self->hosts} ];
	$dbh = $self->connect($host);
			   
	$self->log->info("trytime $tries: Connecting to  ".$self->symbolic_name);
	if ($self->log->is_debug()) {
	    $self->log->debug('     using the following parameters:');
	    $self->log->debug('       ' . $host . ':' . (defined $self->port?$self->port:''));
	}
	if($dbh) {
	    $self->log->info("   --> succesfully established connection to  ".$self->symbolic_name." on " . $host);
	    # Cache my handle
	    $self->set_dbh($dbh);
	    return $dbh;
	} 
    }
    $self->log->fatal("Tried $ReconnectMaxTries times but still could not connect to the  ".$self->symbolic_name." !");
    return $dbh;
}










1;
