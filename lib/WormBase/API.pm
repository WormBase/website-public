package WormBase::API;

use Moose;
use Module::Pluggable::Object;

use namespace::clean -except => 'meta';
use WormBase::API::Factory;

# Roles to consume.
with 'WormBase::API::Role::Logger';           # A basic Log::Log4perl screen appender

# We assume that there is a single primary datasource.
# For now this is AceDB.
has 'primary_datasource' => (
    is       => 'ro',
#    isa      => 'Str',
#    required => 1,
    default  => 'acedb',
    );

# Dynamically establish a list of available data services.
# This includes the primary_datasource and other singletons.

# Then, during BUILD, we will connect to them.
has '_services' => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
    );

#has '_gff_datasources' => (
#    is     => 'ro',
#    isa    => 'HashRef',
#    lazy_build => 1,
#    );


# Version should either be provided by the default datasource
# or set explicitly.

# THERE SHOULD BE AN ACCESSOR FOR THE DBH OF THE DEFAULT DATASOURCE
sub version {
    my $self = shift;

    # Fetch the dbh for the primary datasource
    my $service = $self->_services->{$self->primary_datasource};
    return $service->version;
}

# Fetch a service by name
sub service {
    my $self = shift;
    my $name = shift;
    return $self->_services->{$name};
}

# This is really just a convenience accessor
# as all the gff databases are also stored under services.
# Perhaps services should be a deeper data structure, 
# for example, keyed by species...
sub gff_dsn {
    my $self    = shift;
    my $species = shift;
    return $self->_services->{"gff_$species"};
}

# Build a hashref of services, including things like the 
# default datasource, GFF databases, etc.
# Note the double underscores...
sub _build__services {
    my ($self) = @_;
    my $base = __PACKAGE__;

    my $mp = Module::Pluggable::Object->new( search_path => [ $base . "::Service" ] );
    
    my %services;
    my @classes = $mp->plugins;
    foreach my $class (@classes) {
	Class::MOP::load_class($class);
	
	# Fetch the base name of the class. Could possibly be nested
#	(my $name = $class) =~ s/\Q${base}::\E//;
	$class =~ /.*::?(.*)/;	
	$services{$1} = $class->new;
    }
    return \%services;
} 




# Call the connect method of the appropriate datasource.
sub connect {
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

# During BUILD, connect to all available services.
# This might be overkill.
sub BUILD {
    my $self = shift;
    my $services = $self->_services;
    for my $service  (keys %$services) {
	$self->connect($service);
    }
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
    my $class  = $args->{class};
    my $name   = $args->{name};

    # We may have already fetched an object (ie by following an XREF).
    # This is an ugly, ugly hack
    my $object = $args->{object};

    if ($object) {
	my $class = $object->class;
	return WormBase::API::Factory->create($class,
					      { object => $object });
    } else {
	
	# Try fetching an object (from the primary data source)
	my $service_symbolic  = $self->primary_datasource;

	my $service_instance = $self->_services->{$service_symbolic};

#	my $driver = $self->service($service);
	print STDERR "CALLING CONNECT? $service_instance\n";
	
	my $dbh = $service_instance->dbh;
	print STDERR "FETCH DBH - DID IT CALL CONNECT $dbh?\n";

	my $object = $service_instance->fetch(-class=>$class,-name=>$name);
#	my $object = $dbh->fetch(-class=>$class,-name=>$name);
	print STDERR "SEARCH - DID IT CALL CONNECT\n";

	# For some reason, this ends up calling the connect method of ALL services...
	return WormBase::API::Factory->create($class,
					      { object => $object });
    }
}




1;

