package WormBase::API;

use Moose;
use Module::Pluggable::Object;
use namespace::clean -except => 'meta';
use WormBase::API::Factory;




# What roles should we consume?
with 
    'WormBase::API::Role::Logger';           # A basic Log::Log4perl screen appender


# We assume that there is a single primary datasource.
# For now this is AceDB.
has 'primary_datasource' => (
    is       => 'ro',
#    isa      => 'Str',
#    required => 1,
    default  => 'acedb',
    );

# Dynamically establish a list of available data services.
# This includes any database that we may need.
has '_services' => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
    );



# Version should either be provided by the default datasource

# THERE SHOULD BE AN ACCESSOR FOR THE DBH OF THE DEFAULT DATASOURCE

sub version {
    my $self = shift;
    my $service = $self->_services->{$self->primary_datasource};
    return $service->version;
}

sub dbh {
    my $self = shift;
    my $name = shift;
    return $self->_services->{$name};
}



# Build up a hashref of services, including things like the 
# default datasource, GFF databases, etc.
sub _build__services {
    my ($self) = @_;
    my $base = __PACKAGE__;

    my $mp = Module::Pluggable::Object->new( search_path => [ $base . "::Service" ] );
    my @classes = $mp->plugins;
    my %services;
    foreach my $class (@classes) {
	Class::MOP::load_class($class);

	# Fetch the base name of the class
	(my $name = $class) =~ s/\Q${base}::Service::\E//;
	$services{$name} = $class->new;
	return \%services;
    }
}


# Call the connect method of the appropriate datasource.
sub connect {
    my ($self,$service) = @_;
    $self->_services->{$service}->connect();
}


sub connect_to {
    my ($self,$service) = @_;
    $self->_services->{$service}->connect();
}




=head1

has 'name' => (
    is => 'ro',
    isa => 'Str',
    );
has 'class' => (
    is => 'ro',
    isa => 'Str',
    );


=cut

# During instantiation, connect to our primary service (AceDB).
sub BUILD {
    my $self = shift;
    $self->connect($self->primary_datasource);
}

# One approach: conditionally conecting to acedb as necessary
# Skip the process if we have been passed a database handle

=head1

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

=cut


# Wrapper around the driver's fetch method
# and MooseX::AbstractFactory to create a 
# WormBase::API::Object::*
sub fetch {
    my ($self,$args) = @_;
    my $class = $args->{class};
    my $name  = $args->{name};

    my $service = $self->primary_datasource;
    my $driver = $self->_services->{$service};
    my $object = $driver->fetch(-class=>$class,-name=>$name);
#    $self->log->debug("$driver $service $object $class $name");

    return WormBase::API::Factory->create($class,
					  { object => $object });
}




1;

