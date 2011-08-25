package WormBase::API::ModelMap;

use strict;
use warnings;
use Module::Pluggable::Object;
use Class::MOP;

# If we want to make this more object-oriented, we would add a class attribute
# (e.g. _ACE_MODEL) to WormBase::API::Object. That attribute would default to
# the model name and would be overridden for the special cases, e.g. Pcr_oligo,
# which maps to PCR_product, Oligo_set, Oligo. This class would then initialize
# the maps by accessing the _ACE_MODEL attributes of each model.

# In this more procedural approach, the special cases (e.g. Pcr_oligo) are hard-
# coded into the maps. The maps are then populated with defaults. This class was
# coded with speed in mind.

{ # limit the scope of the lexical variables to prevent tampering
    my $base = 'WormBase::API::Object';

    # NOTE: all entries use the short WB names (without the package base) unless
    #  specified.
    # NOTE: the maps will NOT provide default values unless otherwise noted i.e.
    #  any code using the maps should not rely on the presence of a value

    my $WB2ACE_MAP_DONE = 0;
    my %WB2ACE_MAP = ( # WB models -> Ace models (values are Ace tags/values)
		       class => { # HAS DEFAULT
			   Pcr_oligo => [qw(PCR_product Oligo_set Oligo)],
			   Person    => [qw(Person Author)],
			   Sequence  => [qw(Transcript Sequence CDS cds)],
			   Rnai      => 'RNAi',
			   Go_term   => 'GO_term',
		       },
		       common_name => {
			   Person       => 'Standard_name',
			   Gene         => [qw(Public_name CGC_name Molecular_name)],
			   # for gene, still missing $gene->Corresponding_CDS->Corresponding_protein
			   Feature      => ['Public_name', 'Other_name'],
			   Variation    => 'Public_name',
			   Phenotype    => 'Primary_name',
			   Gene_class   => 'Main_name',
               Gene_name    => 'Public_name_for',
			   Species      => 'Common_name',
			   Molecule     => [qw(Public_name Name)],
			   Anatomy_term => 'Term',
			   GO_term      => 'Term',
		       },
		       laboratory => {
			   Gene_class  => 'Designating_laboratory',
			   PCR_product => 'From_laboratory',
			   Sequence    => 'From_laboratory',
			   CDS         => 'From_laboratory',
			   Transgene   => 'Location',
			   Strain      => 'Location',
			   Antibody    => 'Location',
		       },
		       
    );

    my $ACE2WB_MAP_DONE = 0;
    my %ACE2WB_MAP = ( # Ace models -> WB models (values are WB attrs/values)
        # class HAS DEFAULT (and will be dynamically populated)
    );

    sub _map_wb2ace {
        # map the classes (with short name)
        my $mp = Module::Pluggable::Object->new(search_path => [$base]);

		$WB2ACE_MAP{class}     ||= {};
		$WB2ACE_MAP{fullclass} ||= {};
		my ($classmap, $fullclassmap) = @WB2ACE_MAP{qw(class fullclass)};

        foreach my $fullwbclass ($mp->plugins) {
            # it is necessary to load the classes as anything that is using
            # ModelMap likely wants to tinker with that class
            Class::MOP::load_class($fullwbclass);
			my $wbclass = (split /::/, $fullwbclass)[-1];
            # the exceptional cases have already been mapped.
            $classmap->{$wbclass} ||= $wbclass;
			$fullclassmap->{$fullwbclass} = $classmap->{$wbclass};
        }

		# create short names as well
        $WB2ACE_MAP_DONE = 1;
    }

    sub _map_ace2wb { # inverse map of WB2ACE
        # map the classes
        _map_wb2ace() unless $WB2ACE_MAP_DONE;

        my $classmap     = $ACE2WB_MAP{class}     ||= {};
		my $fullclassmap = $ACE2WB_MAP{fullclass} ||= {};

        while (my ($wb, $ace) = each %{$WB2ACE_MAP{class}}) {
			my $fullwb = "${base}::$wb";
            if (ref $ace eq 'ARRAY') { # multiple Ace to single WB
                foreach my $ace_class (@$ace) {
                    $classmap->{$ace_class}		||= $wb;
					$fullclassmap->{$ace_class} ||= $fullwb;
                }
            }
            else {              # assume scalar; 1-to-1
                $classmap->{$ace}     ||= $wb;
				$fullclassmap->{$ace} ||= $fullwb;
            }
        }

        $ACE2WB_MAP_DONE = 1;
    }

    sub ACE2WB_MAP {
        _map_ace2wb() unless $ACE2WB_MAP_DONE; # manual lazy loading
        return \%ACE2WB_MAP;
    }

    sub WB2ACE_MAP {
        _map_wb2ace() unless $WB2ACE_MAP_DONE; # manual lazy loading
        return \%WB2ACE_MAP;
    }

    sub new { # a dummy object for the view to access the class methods/attrs
        my $class = shift;
        return bless \(my $anon), $class;
    }
}

1;
