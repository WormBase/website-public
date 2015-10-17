package WormBase::API::ModelMap;

use strict;
use warnings;
use Module::Pluggable::Object;
use Class::MOP;

use constant OBJ_BASE => 'WormBase::API::Object';

BEGIN {
    # load all the object classes
    Class::MOP::load_class($_)
      foreach Module::Pluggable::Object->new(search_path => [OBJ_BASE])->plugins;
}

# If we want to make this more object-oriented, we would add a class attribute
# (e.g. _ACE_MODEL) to WormBase::API::Object. That attribute would default to
# the model name and would be overridden for the special cases, e.g. Pcr_oligo,
# which maps to PCR_product, Oligo_set, Oligo. This class would then initialize
# the maps by accessing the _ACE_MODEL attributes of each model.

# In this more procedural approach, the special cases (e.g. Pcr_oligo) are hard-
# coded into the maps. The maps are then populated with defaults. This class was
# coded with speed in mind.

{ # limit the scope of the lexical variables to prevent tampering

    # NOTE: all entries use the short WB names (without the package base) unless
    #  specified.
    # NOTE: the maps will NOT provide default values unless otherwise noted i.e.
    #  any code using the maps should not rely on the presence of a value

    my $WB2ACE_MAP_DONE = 0;
    my %WB2ACE_MAP = ( # WB models -> Ace models (values are Ace tags/values)
        class => {     # HAS DEFAULT
            Pcr_oligo => [qw(PCR_product Oligo_set Oligo)],
            Person    => [qw(Person Author)],
            Cds       => 'CDS',
            Rnai      => 'RNAi',
            Disease   => 'DO_term',
            Go_term   => 'GO_term',
            Wbprocess => 'WBProcess',
            Model     => 'Model', #for schema display to work
        },
        # the following are the tags for extracting a "common" or "public" name
        # for objects automatically. when adding a new one, please consider
        # writing a corresponding "raw" version in WormBase::Ace
        common_name => {
            Person       => 'Standard_name',
            Gene         => [qw(Public_name CGC_name Molecular_name)],
            # for gene, still missing $gene->Corresponding_CDS->Corresponding_protein
            Feature      => ['Public_name', 'Other_name'],
            Variation    => 'Public_name',
            Phenotype    => 'Primary_name',
            Gene_class   => 'Main_name',
            DO_term      => 'Name',
            Gene_name    => 'Public_name_for',
            Species      => 'Common_name',
            Molecule     => [qw(Public_name Name)],
            Anatomy_term => 'Term',
            GO_term      => 'Name',
            Motif        => 'Title',
#            Protein      => 'Gene_name',
            Rnai         => 'History_name',
            Construct    => ['Public_name', 'Other_name'],
            WBProcess	 => 'Public_name',
        },
        laboratory => {
            Gene_class  => 'Designating_laboratory',
            PCR_product => 'From_laboratory',
            Sequence    => 'From_laboratory',
            Transcript  => 'From_laboratory',
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

    # the canonical representation of Ace classes is lower case (arbitrary)
    sub _canonize_ace {
        return lc $_[0];
    }

    # Note: In fact, there is currently no (currently) observed canonical
    #       representation of WB model classes; the URL suggests lower case,
    #       the modules suggest title-case (but not always). It is recommended
    #       such a canonical representation be adopted e.g. always title-case
    #       for back-end representation and always lower-case for URLs.
    #       -AD
    sub _canonize_wb { # present for completeness
        return ucfirst lc $_[0];
    }

    sub _map_wb2ace {
        # map the classes (with short name)

		$WB2ACE_MAP{class}     ||= {};
		$WB2ACE_MAP{fullclass} ||= {};
		my ($classmap, $fullclassmap) = @WB2ACE_MAP{qw(class fullclass)};

        my @classes = Module::Pluggable::Object->new(search_path => [OBJ_BASE])->plugins;
        foreach my $fullwbclass (@classes) {
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
			my $fullwb = join('::', OBJ_BASE, $wb);
            my $canonical_ace_class;

            foreach my $ace_class (ref $ace eq 'ARRAY' ? @$ace:($ace)) {
                    $canonical_ace_class = _canonize_ace($ace_class);
                    $classmap->{$ace_class}		          ||= $wb;
                    $classmap->{$canonical_ace_class}     ||= $wb;
					$fullclassmap->{$ace_class}           ||= $fullwb;
                    $fullclassmap->{$canonical_ace_class} ||= $fullwb;
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
