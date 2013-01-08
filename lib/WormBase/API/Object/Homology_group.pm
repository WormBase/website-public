package WormBase::API::Object::Homology_group;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Homology_group

=head1 SYNPOSIS

Model for the Ace ?Homology_group class.

=head1 URL

http://wormbase.org/species/*/homology_group

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

# remarks {}
# Supplied by Role

# title { }
# This method will return a data structure with the title for the homology_group.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/title

sub title {
    my $self   = shift;
    my $object = $self->object;
    my $title  = $object->Title;
    return {data        => "$title" || undef,
	    description => 'title for this homology group'
    };
}

# type { }
# This method will return a data structure with the type of the homology_group.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/type

sub type {
    my $self           = shift;
    my $object         = $self->object;
    my $group = $object->Group_type;
    my $code = $group =~ /COG/ ? $object->COG_code : undef;
    return {data        => { homology_group => $group && "$group",
			     code       => $code && "$code" },
	    description => 'type of homology group' };
}
# gene_ontology_terms { }
# This method will return a data structure containing 
# the gene ontology terms associated with the homology group.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/gene_ontology_terms

sub gene_ontology_terms {
    my $self      = shift;
    my $object    = $self->object;
    my @data;
    foreach  ($object->GO_term) {
    	my $definition = $_->Definition;
    	push @data, {
	    go_term   => $self->_pack_obj($_),
	    definition => $definition && "$definition",
    	}
    } 	

    return { data => @data ? \@data : undef,
	     description => 'gene ontology terms associated to this homology group' };
}

# proteins { }
# This method will return a data structure containing
# the proteins listed in the homology_group.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/proteins

sub proteins {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->Protein) {
    	my $description = $_->Description;
    	push @data, {
	    protein => $self->_pack_obj($_, "$_"),
	    species => $self->_pack_obj($_->Species),
	    description => $description && "$description",
    	}
    }
    return { data        => @data ? \@data : undef,
	     description => 'proteins related to this homology_group'
    };
}

#######################################
#
# The External Links widget
#   template: shared/widgets/xrefs.tt2
#
#######################################

# xrefs {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;

