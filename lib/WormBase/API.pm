package WormBase::API;

use Moose;                       # Moosey goodness
use Module::Pluggable::Object;   # Support for pluggable services

use namespace::clean -except => 'meta';
use WormBase::API::Factory;      # Our object factory

with 'WormBase::API::Role::Logger';           # A basic Log::Log4perl screen appender


# We assume that there is a single default data source.
# For now this is AceDB.
has 'default_datasource' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'acedb',
    );

# Dynamically establish a list of available data services.
# This includes the default_datasource and other singletons.
# During BUILD we will establish data handles to each.
has '_services' => (
    is         => 'ro',
    isa        => 'HashRef',
    lazy_build => 1,
    );

has 'stringified_responses' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 1,
    );

# This is just the configuration directory
# for instantiating Log::Log4perl object. Janky.
has conf_dir => (
    is       => 'ro',
    required => 1,
    );


# Version should be provided by the default datasource or set explicitly.
sub version {
    my $self = shift;
    
    # Fetch the dbh for the default datasource
    my $service = $self->_services->{$self->default_datasource};
    return $service->version;
}

# Fetch a service object by its symbolic name
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

	# Instantiate the service providing it with
	# access to some of our configuration variables
	$services{$1} = $class->new({conf_dir => $self->conf_dir,
				     log      => $self->log,
				    });
    }
    return \%services;
} 




# Call the connect method of the appropriate datasource.
sub connect {
    my ($self,$service) = @_;
    $self->_services->{$service}->connect();
}

# During BUILD, connect to all available services.
# This might be overkill.
sub BUILD {
    my $self = shift;
    my $services = $self->_services;
    for my $service  (keys %$services) {
	$self->connect($service);
    }
}

# Provide a wrapper around the driver's fetch method
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
	
	# Try fetching an object (from the default data source)
	my $service_symbolic = $self->default_datasource;
	
	my $service_instance = $self->_services->{$service_symbolic};
	
#	my $driver = $self->service($service);
	my $dbh = $service_instance->dbh;
	
	my $object = $service_instance->fetch(-class=>$class,-name=>$name);
#	my $object = $dbh->fetch(-class=>$class,-name=>$name);
	
	# TODO!!
	# Calling my factory causes instantiation of new Service::* objects
	# (ie new ddatabase connections).  This is bad.
	# - It also *requires* that we pass the conf_dir
	#   which is only used for setting up the log object
	
	# To get around this (for now) I'm passing the conf_dir
	# but this is SERIOUSLY NOT OPTIMAL
	return WormBase::API::Factory->create($class,
					      { object   => $object,
						conf_dir => $self->conf_dir,
					      });
    }
}




1;

