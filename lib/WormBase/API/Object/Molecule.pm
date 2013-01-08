package WormBase::API::Object::Molecule;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Molecule

=head1 SYNPOSIS

Model for the Ace ?Molecule class.

=head1 URL

http://wormbase.org/species/*/molecule

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

# synonyms { }
# This method will return a data structure with synonyms for the molecule name.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/synonyms

sub synonyms {
    my $self    = shift;
    my $object  = $self->object;
    my @data    = map {"$_"} $object->Synonym;
    return {
        'data'        => @data ? \@data : undef,
        'description' => 'synonyms for the molecule name'
    };
}


# gene_regulation { }
# This method will return a data structure with gene regulation processes involving the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/gene_regulation

sub gene_regulation {
    my $self     = shift;
    my $gene_reg = $self->_pack_objects($self ~~ '@Gene_regulator');
    return {
        'data'        => %$gene_reg ? $gene_reg : undef,
        'description' => 'gene regulation involving the molecule'
    };
}

# molecule_use { }
# This method will return a data structure with information on how the molecule is used.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/molecule_use

sub molecule_use {
    my $self = shift;
    my $object = $self->object;
    # TODO: deal with evidence
    my @uses = map {text=>"$_", evidence=>$self->_get_evidence($_)}, $object->Molecule_use;
    # (use, evidence type, evidence)
    return {
        'data'        => @uses ? \@uses : undef,
        'description' => 'uses for the molecule'
    };
}

############################
#
# The Phenotype Widget
#
############################

# affected_variations { }
# This method will return a data structure with variations affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_variations

sub affected_variations {
    my $self      = shift;
    my $data_pack = $self->_affects('Variation');

    return {
        data        => $data_pack,
        description => 'variations affected by molecule'

    };
}

# affected_strains { }
# This method will return a data structure with strains affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_strains

sub affected_strains {
    my $self      = shift;
    my $data_pack = $self->_affects('Strain');

    return {
        data        => $data_pack,
        description => 'strain affected by molecule'
    };
}

# affected_transgenes { }
# This method will return a data structure with transgenes affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_transgenes

sub affected_transgenes {
    my $self      = shift;
    my $data_pack = $self->_affects('Transgene');

    return {
        data        => $data_pack,
        description => 'transgenes affected by molecule'
    };
}

# affected_rnai { }
# This method will return a data structure with rnais affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_rnai

sub affected_rnai {
    my $self      = shift;
    my $data_pack = $self->_affects('RNAi');

    return {
        data        => $data_pack,
        description => 'rnai affected by molecule'
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

##########################
#
# Internal methods
#
##########################

sub _affects {
    my ($self, $tag) = @_;
    my $object = $self->object;

    my @data;
    foreach my $affected ($object->$tag){
	my $phenotype = $affected->right;
	my $evidence = {text => $self->_pack_obj($phenotype), evidence => $self->_get_evidence($phenotype)} if $affected->right(2);
	push @data, {
	    affected  => $self->_pack_obj($affected),
	    phenotype => $evidence ? $evidence : $self->_pack_obj($phenotype),
	};
    }
    return @data ? \@data : undef;
}

__PACKAGE__->meta->make_immutable;

1;

