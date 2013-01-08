package WormBase::API::Object::Rnai;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Rnai

=head1 SYNPOSIS

Model for the Ace ?Rnai class.

=head1 URL

http://wormbase.org/species/*/rnai

=cut

#######################################
#
# CLASS METHODS
#
#######################################

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

# historical_name { }
# This method will return a data structure containing
# the historical name of the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/historical_name

sub historical_name {
    my $self = shift;
    my $object = $self->object;
    my $name   = $object->History_name;
    return { description => 'historical name of the rnai',
	     data        => "$name" || undef };
}

# taxonomy { }
# Supplied by Role

# targets { }
# This method will return a data structure with targets for the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/targets

sub targets {
    my ($self) = @_;
    my $object = $self->object;

    my %seen;    
    my @genes = $object->Gene;
    push @genes, grep { !$seen{$_}++ } $object->Predicted_gene;
    
    my @data;
    foreach my $gene (@genes) {
        my @types = $gene->col;
	
        foreach (@types) {
            my ($remark) = $_->col;
	    push @data, {target_type => $remark =~ /primary/ ? 'Primary target' : 'Secondary target',
			 gene        => $self->_pack_obj($gene)
	    };
        }
    }
    
    return { description => 'gene targets of the RNAi experiment',
	     data        => @data ? \@data : undef };
}


# movies { }
# This method will return a data structure with links to 
# movies demonstrating the phenotype observed in the RNAi
# experiment.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/movies

sub movies {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Supporting_data->col if $object->Supporting_data;
    my @data        = map { my $label = eval {$_->Remark}; $_ = $self->_pack_obj($_,"$label" || undef) } @tag_objects if @tag_objects;
    return { data        => @data ? \@data : undef,
	     description => 'movies documenting effect of rnai' };
}


# laboratory { }
# Supplied by Role;

# remarks {}
# Supplied by Role

#######################################
#
# The Details Widget
#
#######################################

# reagent { }
# This method will return a data structure with reagents used with the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/reagent

sub reagent {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    my @pcr_products = $object->PCR_product;
    # Here we include a link to the MRC GeneService.
    # This cuts against the grain of using External Links
    # but these are important reagents.
    foreach (@pcr_products) {
	my $gene_service_id = eval { $_->Clone->Database(3); };
	push @data, { reagent => $self->_pack_obj($_),
		      mrc_id  => $gene_service_id ? "$gene_service_id" : undef,
	};
    }
    return { data        => @data ? \@data : undef,
	     description => 'PCR products used to generate this RNAi'
    };
}

# sequence { }
# This method will return a data structure with the sequence of the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/sequence

sub sequence {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Sequence_info->right if $object->Sequence_info;
    my @data   = map { {sequence=>"$_",
			length=>length($_),
		      } 
		} @tag_objects;
    return { data        => @data ? \@data : undef,
	     description => 'rnai sequence'
    };
}

# assay { }
# This method will return a data structure with assay for the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/assay

sub assay {
    my $self      = shift;
    my $object    = $self->object || shift;
    my $data      = $object->PCR_product  ? 'PCR product' : 'Sequence';
    return {data        => $data ? "$data" : undef,
	    description => 'assay performed on the rnai' };
}


# genotype { }
# This method will return a data structure with the genotype background of the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/genotype

sub genotype {
    my $self   = shift;
    my $object = $self->object;
    my $genotype = $object->Genotype;
    return { description => 'genotype of rnai strain',
	     data        => "$genotype" || undef };
}

# strain { }
# This method will return a data structure with the strain containing the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/strain

sub strain {
    my $self   = shift;
    my $object = $self->object;
    return { description => 'strain of origin of rnai',
	     data        => $self->_pack_obj( $object->Strain) };
}

# interactions { }
# This method will return a data structure with interactions associated with the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/interactions

sub interactions {
    my ($self) = @_;
    my @data = map { $self->_pack_obj($_) } @{ $self ~~ '@Interaction' };
    return {
        description => 'interactions the rnai is involved in',
        data        => @data ? \@data : undef,
    };
}

# treatment { }
# This method will return a data structure with treatments involving the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/treatment

sub treatment {
    my $self   = shift;
    my $object = $self->object;
    my $treatment = $object->Treatment;
    return {
        description => 'experimental conditions for rnai analysis',
        data        => "$treatment" || undef };
}

# life_stage { }
# This method will return a data structure with the life_stage associated with the RNAi.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/life_stage

sub life_stage {
    my ($self) = @_;

    return {
        description => 'life stage in which rnai is observed',
        data        => $self->_pack_obj( $self ~~ 'Life_stage' ),
    };
}

# delivered_by { }
# This method will return a data structure desribing
# how the RNAi was delivered to the organism.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/delivered_by

sub delivered_by {
    my $self   = shift;
    my $object = $self->object;
    my $delivered = $object->Delivered_by;
    return { description => 'how the RNAi was delivered to the animal',
	     data        => "$delivered" || undef };
}

############################################################
#
# The Phenotypes widget
#
############################################################

# phenotypes {}
# Supplied by Role

# phenotypes_not_observed {}
# Supplied by Role

############################################################
#
# The External Links widget
#
############################################################

# xrefs {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;

