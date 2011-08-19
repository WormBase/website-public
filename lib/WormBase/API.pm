package WormBase::API;

use Moose;                       # Moosey goodness

use namespace::clean -except => 'meta';
use WormBase::API::Factory;      # Our object factory
use Config::General;
use WormBase::API::Service::Xapian;
use Search::Xapian qw/:all/;
use WormBase::API::ModelMap;
use Class::MOP;

with 'WormBase::API::Role::Logger'; # A basic Log::Log4perl screen appender

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
    #    lazy_build => 1,
);

has tmp_base => (
    is       => 'rw',
);

has xapian => (
    is     => 'rw',
    isa    => 'WormBase::API::Service::Xapian',
    lazy_build      => 1,
);

# this is for the view (see /template/config/main)
# it's a nasty hack. it simply reveals WormBase::API::ModelMap to the view
# so that the maps can be accessed from there. this is heavily coupled
# with the internals of ModelMap.
has modelmap => (
    is => 'ro',
    lazy => 1,
    required => 1,
    default => sub {
        return WormBase::API::ModelMap->new; # just a blessed scalar ref
    },
);

has _tools => (
    is       => 'ro',
    lazy_build      => 1,
);

has tool => (
    is       => 'rw',
);

# builds a search object with the default datasource
sub _build_xapian {
  my $self = shift;
  my $service_instance = $self->_services->{$self->default_datasource}; 
  my $root  = $self->conf_dir;
  my $config = new Config::General(
				  -ConfigFile      => "$root/../wormbase.conf",
				  -InterPolateVars => 1
    );
  my $db = Search::Xapian::Database->new($config->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{pre_compile}->{base} . $self->version() . "/search/main");
  my $syn_db = Search::Xapian::Database->new($config->{'DefaultConfig'}->{'Model::WormBaseAPI'}->{args}->{pre_compile}->{base} . $self->version() . "/search/syn");
  my $qp = Search::Xapian::QueryParser->new($db);
  my $auto_qp = Search::Xapian::QueryParser->new($db);
  my $syn_qp = Search::Xapian::QueryParser->new($db);
  $qp->set_database($db);
  $syn_qp->set_database($syn_db);
  $qp->set_default_op(OP_OR);
 
  my $type_svrp = Search::Xapian::StringValueRangeProcessor->new(2);
  my $species_svrp = Search::Xapian::NumberValueRangeProcessor->new(3, "species:");
  $qp->add_valuerangeprocessor($species_svrp);
  $qp->add_valuerangeprocessor($type_svrp);


  my $svrp = Search::Xapian::StringValueRangeProcessor->new(2);
  $syn_qp->add_valuerangeprocessor($svrp);

  return WormBase::API::Service::Xapian->new({db => $db, qp => $qp, c => $config, api => $self, syn_db => $syn_db, syn_qp => $syn_qp}); 
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
sub _build__services {
    my ($self) = @_;

    my %services;

    my $db_confs = $self->database;
    foreach my $db_type (sort keys %$db_confs) {
        next if $db_type eq 'tmp';
        my $service_class = __PACKAGE__ . "::Service::$db_type";
        Class::MOP::load_class($service_class);

        my $conf = $db_confs->{$db_type};
        my @sources = sort keys %{$conf->{data_sources}}; # usually species
        # some of the DBs may not have specific data sources but
        # we'd still like to set them up below
        @sources = '' unless @sources;

        foreach my $source (@sources) {
            my $service = $service_class->new({
                conf          => $conf,
                log           => $self->log,
                source        => $source,
                symbolic_name => $db_type,
                tmp_base      => $db_confs->{tmp},
            });

            my $full_name = $source ? "${db_type}_${source}" : $db_type;
            $services{$full_name} = $service;
            $self->log->debug("service $full_name registered but not yet connected");
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
#      $hash->{search} = $self->search if ($tool eq 'aligner');    # TODO: Needs to be updated for Xapian.
      $tools{$tool}  = $class->new($hash);
      $self->log->debug( "service $tool registered");
    }
    return \%tools;
}

# Fetches a WormBase object corresponding to an Ace object.
# TODO: Standardize return values. Currently returns object if fetched,
#       0 if can't get DB handle, and -1 if can't seem to fetch object.
#       Consider throwing an exception and return;, respectively. Will
#       Require modifying places where $api->fetch is called.
sub fetch {
    my ($self,$args) = @_;

    my ($object, $class, $aceclass, $name)
        = @{$args}{qw(object class aceclass name)};

    if ($object) {
        $class = $self->modelmap->ACE2WB_MAP->{fullclass}->{$object->class};
    }
    else {
        my $service_dbh = $self->_services->{$self->default_datasource}->dbh || return 0;

        # resolve classes to properly retrieve object
        if ($class) { # WB class was provided
            $aceclass = $self->modelmap->WB2ACE_MAP->{class}->{$class}
                     || $self->modelmap->WB2ACE_MAP->{fullclass}->{$class}
                     || return 0; # don't know which aceclass
        }
        else { # aceclass provided (assumption), WB class not
            $class = $self->modelmap->ACE2WB_MAP->{fullclass}->{$aceclass}
                or return 0; # an aceclass we don't handle [yet]?
        }

        # HACK for variation -- resolve variation name first
        if ($aceclass eq 'Variation' and $name !~ /^WBVar/ and
            my $var_name = $service_dbh->fetch(-class => 'Variation_name', -name => $name)) {
            $name = $var_name->Public_name_for || $var_name->Other_name_for || $name;
        }

        # Try fetching an object (from the default data source)
		if (ref $aceclass eq 'ARRAY') { # multiple Ace classes
			foreach my $ace (@$aceclass) {
				last if $object = $service_dbh->fetch(-class => $ace, -name => $name);
			}
		}
		else { # assume a single Ace class
			$object = $service_dbh->fetch(-class => $aceclass, -name => $name);
		}
    }

    return -1 unless(defined $object); #&& ($name eq 'all' || $name eq '*'));
    return WormBase::API::Factory->create($class, {
		object      => $object,
		log         => $self->log,
		dsn			=> $self->_services,
		tmp_base    => $self->tmp_base,
		pre_compile => $self->pre_compile,
	});
}

# Instantiate but without fetching an ace object
sub instantiate_empty {
    my ($self,$args) = @_;
    my $class   = $args->{class};
    return WormBase::API::Factory->create($class, {
        log         => $self->log,
        dsn         => $self->_services,
        tmp_base    => $self->tmp_base,
        pre_compile => $self->pre_compile,
    });
}

1;

