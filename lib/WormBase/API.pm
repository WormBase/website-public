package WormBase::API;

use Moose;

# What roles should we consume?
with 
    'WormBase::API::Role::Logger',           # A basic Log::Log4perl screen appender
    'WormBase::API::Role::Service::AceDB';   # The AceDB service


use WormBase::API::Factory;
#extends 'WormBase::Factory';

has 'name' => (
    is => 'ro',
    isa => 'Str',
    );
has 'class' => (
    is => 'ro',
    isa => 'Str',
    );

# During instantiation, create a new database handle
# or refresh an old one.
sub BUILD {
    my $self = shift;
    # Refresh the acedb connection (if we have been
    # passed an WormBase::API object)
    if ($self->has_acedb_dbh) {       
	$self->acedb_dbh();
    
    # Otherwise, connect and stash.
    } else {
	$self->connect();
    }

    # HACK! If provided with a name and class, trying to instantiate an object
    if ($self->name) {
	my $object = $self->test_get($self->class,$self->name);

	return $object;
    } else {
	return $self;
    }
}



sub test_get {
    my $self = shift;
    my ($class,$name) = @_;
    $self->log->debug("$class $name");
    my $object = $self->fetch(-class=>$class,-name=>$name);
    $self->log->debug("$object");
    return WormBase::API::Factory->create('Gene',
					  { ace_object => $object });
}


1;

