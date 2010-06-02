package WormBase::API;

use Moose;                       # Moosey goodness

use namespace::clean -except => 'meta';
use WormBase::API::Factory;      # Our object factory
use Config::General;
use WormBase::API::Service::Search;

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
# This is the configuration object/hashref for databases info e.g. connection hosts password...
has database => (
    is       => 'ro',
    required => 1,
    lazy_build => 1,
    );


has tmp_base => (
    is       => 'rw',
    );

has search => (
    is     => 'rw',
    isa    => 'WormBase::API::Service::Search',
    lazy_build      => 1,
    );

# this is here just for the testing script to load database configuration
# may be removed or changed in furutre! 
sub _build_database {
    my $self = shift;
    my $root  = $self->conf_dir;
    my $conf = new Config::General(
				  -ConfigFile      => "$root/../wormbase.conf",
				  -InterPolateVars => 1
    );
    $self->tmp_base($conf->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{tmp_base});
    return   $conf->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{database} ;
}

# builds a search object with the default datasource
sub _build_search {
  my $self = shift;
  my $service_instance = $self->_services->{$self->default_datasource}; 
  return WormBase::API::Service::Search->new({ dbh => $service_instance}); 
}
 

# Version should be provided by the default datasource or set explicitly.
sub version {
    my $self = shift;
    # Fetch the dbh for the default datasource
    my $service = $self->_services->{$self->default_datasource};
    return $service->version;
}

 
# Build a hashref of services, including things like the 
# default datasource, GFF databases, etc.
# Note the double underscores...
sub _build__services {
    my ($self) = @_;
    my %services;
    for my $dbn (sort keys %{$self->database}) {
      next if($dbn eq 'tmp');
      my $class = __PACKAGE__ . "::Service::$dbn" ;	
      Class::MOP::load_class($class);
      # Instantiate the service providing it with
      # access to some of our configuration variables
      my @species = sort keys %{$self->database->{$dbn}->{data_sources}}; 
      push @species, '' unless @species;
        
      foreach my $sp (@species) {
	  my $new = $class->new({	conf => $self->database->{$dbn},
					log      => $self->log,
					species	 => $sp,
					symbolic_name => $dbn,
					path => $self->database->{tmp},
				      });
	  my $type=$sp? $dbn.'_'.$sp:$dbn;
	  $services{$type} = $new; 
	  $self->log->debug( "service $type registered but not connected yet");
      }
    }
    return \%services;
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
	$class = $object->class;
    }
    else {
	# Try fetching an object (from the default data source)
	my $service_instance = $self->_services->{$self->default_datasource}; 
	$object = $service_instance->fetch(-class=>$class,-name=>$name);
        if($class eq 'Sequence') {
	    $object ||= $service_instance->fetch(-class=>'CDS',-name=>$name);
	}
    }
    return WormBase::API::Factory->create($class,
					      { object   => $object,
						log => $self->log,
						dsn	 => $self->_services,
						tmp_base  => $self->tmp_base,
					      });
    
}


1;

