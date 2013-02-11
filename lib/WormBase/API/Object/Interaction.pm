package WormBase::API::Object::Interaction;
use Moose;

with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Interaction';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Interaction

=head1 SYNPOSIS

Model for the Ace ?Interaction class.

=head1 URL

http://wormbase.org/species/*/interaction

=cut

has '_interactors' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__interactors',
);

#######################################
#
# CLASS METHODS
#
#######################################

sub _build__interactors {
    my $self = shift;
    my $object = $self->object;

    my %interactors;
    foreach my $type ($object->Interactor) {
		my $count = 0;
        next unless $type =~ /Molecule_regulator|Other_regulator|Other_regulated|Rearrangement|Interactor_overlapping_gene/;
		foreach my $interactor ($type->col) {
			my $name = eval {$interactor->Public_name} || "$interactor";
			foreach my $tag ($type->right->down($count++)->col) {
			@{$interactors{$type}{"$name"}{"$tag"}} = map {
									  if ($_->isTag) {"$_"}
									  else { $self->_pack_obj($_) }
								  } $tag->col;
			}
			$interactors{$type}{"$name"}{object} = $self->_pack_obj($interactor);
		}
    }
    return %interactors ? \%interactors : undef;
}

#######################################
#
# INSTANCE METHODS
#
#######################################


#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# Override Role to give a better label for name.
sub _build_name { 
    my $self = shift;
    my $object = $self->object;
    my @list;
    map {push @list, sort keys %{$self->_interactors->{$_}}} sort keys %{$self->_interactors};

    my $label = join(' : ', @list);
    return {
        description => "The name and WormBase internal ID of $object",
        data        =>  $self->_pack_obj($object,$label),
    };
}

# remarks {}
# Supplied by Role

# interaction_summary { }
# This method will return a data structure with the summary.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interaction_summary

sub interaction_summary {
    my $self   = shift;
    my $object = $self->object;

    my @data = map {
	my $evidence = $self->_get_evidence($_);
	$evidence ? { text => $_ && "$_", evidence => $evidence } : $_ && "$_"
    } $object->Interaction_summary;

    # Check if this interaction is valid. If not, add a warning to the description.
    # This can be removed when these invalid interactions are cleared from the database
    # See _ignored_interactions in the Interactions Role
    push @data, '<b>Warning!</b> This Interaction object was <b>incorrectly</b> generated!' if $self->_ignored_interactions($object); 
    
    return { description => 'Summary of this interaction',
	     data        => @data ? \@data : undef,
    };
}

# regulation_level { }
# This method will return a data structure with the regulation_level.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/regulation_level

sub regulation_level {
    my $self   = shift;
    my $object = $self->object;

    my @level = map {"$_"} $object->Regulation_level;

    return { description => 'Regulation level for this interaction',
	     data        => @level ? \@level : undef,
    };
}

# regulation_result { }
# This method will return a data structure with the regulation_result.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/regulation_result

sub regulation_result {
    my $self   = shift;
    my $object = $self->object;

    my @data;

    foreach my $result ($object->Regulation_result) {
	my @life_stages = map {$self->_pack_obj($_)} $result->Life_stage;
	my @anatomy_terms = map {$self->_pack_obj($_)} $result->Anatomy_term;
	my @subcellular = map {"$_"} $result->Subcellular_localization;

	push @data, {
	    type	=> "$result" || undef,
	    life_stage	=> @life_stages ? \@life_stages : undef,
	    anatomy_term=> @anatomy_terms ? \@anatomy_terms : undef,
	    subcellular_localization => @subcellular ? \@subcellular : undef,
	}
    }

    return { description => 'Regulation results for this interaction',
	     data        => @data ? \@data : undef,
    };
}

# interactor { }
# This method will return a data structure with the interactors.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interactor

sub interactor {
    my $self   = shift;
    my $interactors = $self->_interactors;
    my @data;

    foreach my $type (sort keys %{$interactors}) {
	foreach my $interactor (sort keys %{$interactors->{$type}}) {
	    my $info = $interactors->{$type}->{$interactor};
	    my $type_tag = $type;
	    $type_tag =~ s/_/ /g;
	    push @data, {
		interactor_type => $type_tag || undef,
		interactor	=> $info->{object},
		role		=> $info->{Interactor_type} || undef,
		variation	=> $info->{Variation} || undef,
		transgene	=> $info->{Transgene} || undef,
	    }
	}
    }
    return { description => 'interactors in this interaction',
	     data        => @data ? \@data : undef,
    };
}

# interaction_type { }
# This method will return a string containing the Interaction_type.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interaction_type

sub interaction_type {
    my $self = shift;
    my $object = $self->object;
    my $interaction_type = $object->Interaction_type;

    my $type_str = "$interaction_type";
    $type_str .= ': ' . $interaction_type->right if $interaction_type->right;
    $type_str =~ s/_/ /g;

    return {
        data => "$type_str" || undef,
        description => 'Type of the interaction'
    };
}

# detection_method { }
# This method will return a string containing the Detection_method.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/detection_method

sub detection_method {
    my $self = shift;
    my $object = $self->object;

    my @data;

    foreach my $method ($object->Detection_method) {
	my $method_str = "$method";
	$method_str .= ': ' . $method->right if $method->right;
	$method_str =~ s/_/ /g;
	push @data, "$method_str";
    }

    return {
        data => @data ? \@data : undef,
        description => 'Method(s) by which the interaction was detected',
    };
}

sub _build_laboratory {
    my $self = shift;
    my $object = $self->object;

    my $tag = 'From_laboratory';
    my @data;

    if ($object->$tag) {
	foreach my $lab ($object->$tag) {
	    my $label = $lab->Mail || "$lab";
	    my $representative = $lab->Representative;
	    my $name           = $representative->Standard_name if $representative;
	    push @data, {
		laboratory => $self->_pack_obj($lab, "$label"),
		representative => $self->_pack_obj($representative, "$name"),
	    };
	}
    }
    return {
        description => "the laboratory where the interaction was discovered",
        data        => @data ? \@data : undef,
    };
}

# libraries_screened { }
# This method will return a data structure containing the libraries screened.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/libraries_screened

sub libraries_screened {
    my $self = shift;
    my $object = $self->object;
    
    my @data;
    foreach my $library ($object->Library_screened){
	my $library_str = "$library";
	$library_str .= ' (' . $library->right . ')' if $library->right;
	push @data, "$library_str" || undef;
    }

    return {
        description => 'Libraries screened for the interaction',
        data => @data ? \@data : undef,
    };
}

# confidence { }
# This method will return a data structure containing the confidence.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/confidence

sub confidence {
    my $self = shift;
    my $object = $self->object;

    my %data;
    my $conf = $object->Confidence;
    my $info = $object->$conf if $conf;
    $data{"$conf"} = "$info" if $conf;

    return {
        description => 'Confidence details for the interaction',
        data => %data ? \%data : undef,
    };
}

# interaction_phenotype { }
# This method will return a data structure containing the phenotypes.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/phenotypes

sub interaction_phenotype {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Interaction_phenotype;

    return {
        description => 'Phenotype details for the interaction',
        data => @data ? \@data : undef,
    };
}

# rnai { }
# This method will return a data structure containing the rnai.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/rnai

sub rnai {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Interaction_RNAi;

    return {
        description => 'RNAi details for the interaction',
        data => @data ? \@data : undef,
    };
}

# process { }
# This method will return a data structure containing the WBProcess.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/process

sub process {
    my $self = shift;
    my $object = $self->object;

    return {
        description => 'WBProcess for the interaction',
        data => $self->_pack_obj($object->WBProcess),
    };
}

###########################
#
# The Interactors Widget
#
###########################


#######################################
#
# The External Links widget
#
#######################################

# xrefs {}
# Supplied by Role

#######################################
#
# The References Widget
#
#######################################

# references {}
# Supplied by Role


#######################################
#
# Internal Methods
#
#######################################


__PACKAGE__->meta->make_immutable;

1;

