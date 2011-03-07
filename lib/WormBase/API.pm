package WormBase::API;

use Moose;                       # Moosey goodness

use namespace::clean -except => 'meta';
use WormBase::API::Factory;      # Our object factory
use Config::General;
use WormBase::API::Service::Xapian;
use Search::Xapian qw/:all/;

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
has pre_compile => (
    is       => 'rw',
    );

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
    isa    => 'WormBase::API::Service::Xapian',
    lazy_build      => 1,
    );

has _tools => (
    is       => 'ro',
    lazy_build      => 1,
    );

has tool => (
    is       => 'rw',
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
    $self->pre_compile($conf->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{pre_compile});
    $self->tool($conf->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{tool});
    return   $conf->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{database} ;
}

# builds a search object with the default datasource
sub _build_search {
  my $self = shift;
  my $service_instance = $self->_services->{$self->default_datasource}; 
  my $root  = $self->conf_dir;
  my $config = new Config::General(
				  -ConfigFile      => "$root/../wormbase.conf",
				  -InterPolateVars => 1
    );
  my $db = Search::Xapian::Database->new($config->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{pre_compile}->{base} . $self->version() . "/search");
  my $qp = Search::Xapian::QueryParser->new($db);
  $qp->set_database($db);
  $qp->set_default_op(OP_OR);
  my $svrp = Search::Xapian::StringValueRangeProcessor->new(0);
  $qp->add_valuerangeprocessor($svrp);

  return WormBase::API::Service::Xapian->new({db => $db, qp => $qp, c => $config, api => $self}); 
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
					source	 => $sp,
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

sub _build__tools {
    my ($self) = @_;
     my %tools;
#register all the tools
    for my $tool (sort keys %{$self->tool}) {
      my $class = __PACKAGE__ . "::Service::$tool" ;	
      Class::MOP::load_class($class);
      # Instantiate the service providing it with
      # access to some of our configuration variables
      my $hash = {	pre_compile => $self->tool->{$tool},
					log      => $self->log,
					dsn	 => $self->_services, 
					tmp_base  => $self->tmp_base,
				      };
      $hash->{search} = $self->search, if ($tool eq 'aligner');
      $tools{$tool}  = $class->new($hash);
      $self->log->debug( "service $tool registered");
    }
    return \%tools;
}
# Provide a wrapper around the driver's fetch method
# and MooseX::AbstractFactory to create a 
# WormBase::API::Object::*
sub fetch {
    my ($self,$args) = @_;
    # We may have already fetched an object (ie by following an XREF).
    # This is an ugly, ugly hack
    my $object;
    my $class;

    if ($args->{object}) {
	$object = $args->{object};
	$class = $object->class;	
    } else {
	$class   = $args->{class};
	my $name = $args->{name};    
	# Try fetching an object (from the default data source)
	my $service_dbh = $self->_services->{$self->default_datasource}->dbh || return 0; 
	$object = $service_dbh->fetch(-class=>$class,-name=>$name);
	if ($class eq 'Sequence') {
	    $object ||= $service_dbh->fetch(-class=>'CDS',-name=>$name);
	} elsif ($class eq 'Pcr_oligo') {
	    $object ||= $service_dbh->fetch(-class=>'PCR_product', -name=>$name);
	    $object ||= $service_dbh->fetch(-class=>'Oligo_set', -name=>$name);
	    $object ||= $service_dbh->fetch(-class=>'Oligo', -name=>$name);
	}
    }
    return -1 unless(defined $object); #&& ($name eq 'all' || $name eq '*'));
    return WormBase::API::Factory->create($class,
					      { object       => $object,
						log          => $self->log,
						dsn	     => $self->_services,
						tmp_base     => $self->tmp_base,
						pre_compile  => $self->pre_compile,
					      });
    
}


# Instantiate but without fetching an ace object
sub instantiate_empty { 
    my ($self,$args) = @_; 
    my $class   = $args->{class};    
    return WormBase::API::Factory->create($class,
					  {log          => $self->log,
					   dsn	       => $self->_services,
					   tmp_base     => $self->tmp_base,
					   pre_compile  => $self->pre_compile,
					  });	
}    

 

1;

