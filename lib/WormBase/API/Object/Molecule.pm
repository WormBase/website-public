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
        'description' => 'Other common names for the molecule'
    };
}


# gene_regulation { }
# This method will return a data structure with gene regulation processes involving the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/gene_regulation

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
        'description' => 'Reported uses/affects of the molecule with regards to nematode species biology'
    };
}

# biofunction_role { }
# This method will return a data structure with information on specific role of molecule in nematode biology, with particular regards to biological pathways
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00005495/biofunction_role
sub biofunction_role {
    my $self = shift;
    my $object = $self->object;

    my @bf_roles = map {text=>"$_", evidence=>$self->_get_evidence($_)}, $object->Biofunction_role;

    return {
        'data'        => @bf_roles ? \@bf_roles : undef,
        'description' => 'Controlled vocabulary for specific role of molecule in nematode biology, with particular regards to biological pathways'
    };
}

# detection_status { }
# This method will return a data structure with information on whether the molecule is predicted to be present in the animal or was shown to be present in the organism through a direct detection method
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00005495/detection_status
sub detection_status {
    my $self = shift;
    my $object = $self->object;

    my $status_ace = $object->Status;
    my $evidence = $self->_get_evidence($status_ace);
    my $status = $status_ace ? $evidence ? {
        text => "$status_ace",
        evidence => $evidence
    } : "$status_ace" : undef;

    return {
        'data'        => $status,
        'description' => 'Signifies if the molecule is predicted to be present in the animal or was shown to be present in the organism through a direct detection method'
    };
}

# detection_method { }
# This method will return a data structure with information on the experimental tool used to detect molecule
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00005495/detection_method
sub detection_method {
    my $self = shift;
    my $object = $self->object;

    my @methods = map {text=>"$_", evidence=>$self->_get_evidence($_)}, $object->Detection_method;

    return {
        'data'        => @methods ? \@methods : undef,
        'description' => 'Experimental tool used to detect molecule'
    };
}


# extraction_method { }
# This method will return a data structure with information on the method used to extract the molecule during detection.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00005495/extraction_method
sub extraction_method {
    my $self = shift;
    my $object = $self->object;

    my @methods = map {text=>"$_", evidence=>$self->_get_evidence($_)}, $object->Extraction_method;

    return {
        'data'        => @methods ? \@methods : undef,
        'description' => 'Method used to extract the molecule during detection'
    };
}


# biofunction_role { }
# This method will return a data structure with information on specific role of molecule in nematode biology, with particular regards to biological pathways
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00005495/biofunction_role
sub biological_role {
    my $self = shift;
    my $object = $self->object;

    my $data = {};
    my $papers = {};
    foreach my $tag ('Biofunction_role', 'Status', 'Detection_method', 'Extraction_method') {
        my @items = map { "$_" } $object->$tag;
        $data->{lc $tag} = @items ? \@items : undef;

        if (@items) {
            # keep track of paper evidence seen
            my $paper = $self->_pack_obj($object->$tag->at('Paper_evidence'));
            $papers->{$paper->{id}} = $paper if $paper;
        }
    }
    $data->{paper_evidence} = [values %$papers] if %$papers;

    return {
        'data'        => %$data ? $data : undef,
        'description' => 'Controlled vocabulary for specific role of molecule in nematode biology, with particular regards to biological pathways'
    };
}


# nonspecies_source { }
# This method will return a data structure with information on the source of molecule when not generated by the organism being studied.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/nonspecies_source
sub nonspecies_source {
    my $self = shift;
    my $object = $self->object;

    my $source =  $object->Nonspecies_source;

    return {
        'data'        => $source && "$source",
        'description' => 'Source of molecule when not generated by the organism being studied'
    };
}


# inchi { }
# This method will return a data structure with information on the InChi structure.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/inchi
sub inchi {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->InChi;

    return {
        'data'        => $value && "$value",
        'description' => 'InChi structure'
    };
}

# inchi_key { }
# This method will return a data structure with information on the InChi structure key.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/inchi_Key
sub inchi_key {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->InChiKey;

    return {
        'data'        => $value && "$value",
        'description' => 'InChi structure key'
    };
}

# smiles { }
# This method will return a data structure with information on the SMILES structure.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/smiles
sub smiles {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->SMILES;

    return {
        'data'        => $value && "$value",
        'description' => 'SMILES structure'
    };
}

# formula { }
# This method will return a data structure with information on the Molecular formula from ChEBI
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/formula
sub formula {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->Formula;

    return {
        'data'        => $value && "$value",
        'description' => 'Molecular formula from ChEBI'
    };
}

# iupac { }
# This method will return a data structure with information on the IUPAC name.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/iupac
sub iupac {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->IUPAC;

    return {
        'data'        => $value && "$value",
        'description' => 'IUPAC name'
    };
}

# monoisotopic_mass { }
# This method will return a data structure with information on the monoisotopic mass calculated from the chemical formula of the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/WBMol:00004910/monoisotopic_mass
sub monoisotopic_mass {
    my $self = shift;
    my $object = $self->object;

    my $value =  $object->Monoisotopic_mass;

    return {
        'data'        => $value && "$value",
        'description' => 'Monoisotopic mass calculated from the chemical formula of the molecule'
    };
}

# chebi { }
# This method will return a data structure of ChEBI ID of the molecule
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/chebi

sub chebi_id {
    my $self = shift;
    my $object = $self->object;

    my ($chebi_id) = map {
        my ($db, $namespace, $id) = $_->row();
        "$db" eq 'ChEBI' && "$namespace" eq 'CHEBI_ID' ? "$id" : ();
    } $object->Database;

    return {
        'data'        => $chebi_id,
        'description' => 'ChEBI id of the molecule'
    };
}

############################
#
# The Phenotype Widget
#
############################


sub affected_genes {
    my ($self) = @_;

    my $genes_by_variations = $self->affected_variations->{data} || [];
    my $genes_by_transgenes = $self->affected_transgenes->{data} || [];
    my $genes_by_rnai = $self->affected_rnai->{data} || [];

    my @genes = ();
    push @genes, @$genes_by_transgenes;
    push @genes, @$genes_by_rnai;
    push @genes, @$genes_by_variations;

    return {
        'data' => @genes ? \@genes : undef,
        'description' => 'genes affected by the molecule'
    };
}

# affected_variations { }
# This method will return a data structure with variations affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_variations

sub affected_variations {
    my $self      = shift;

    sub get_affected_gene {
        my ($variation, $phenotype, $phenotype_tag_name) = @_;

        my ($phenotype_info) = grep {
            "$_" eq "$phenotype" ? ($_) : ();
        } ($variation->$phenotype_tag_name);

        my @affected_gene = $variation->Gene;

        return ($phenotype_info, @affected_gene);
    }

    my $data_pack = $self->_affects('Variation', \&get_affected_gene);

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
    my $object = $self->object;

    my @data;
    foreach my $affected ($object->Strain){
        my $phenotype = $affected->right;
        my $evidence = {text => $self->_pack_obj($phenotype), evidence => $self->_get_evidence($phenotype)} if $affected->right(2);
        push @data, {
            affected  => $self->_pack_obj($affected),
            phenotype => $evidence ? $evidence : $self->_pack_obj($phenotype),
        };
    }

    return {
        data        => @data ? \@data : undef,
        description => 'strain affected by molecule'
    };
}

# affected_transgenes { }
# This method will return a data structure with transgenes affected by the molecule.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_transgenes

sub affected_transgenes {
    my $self      = shift;
    my $that_self = $self; # some closure issue and name collision

    sub get_caused_by_gene {
        my ($transgene, $phenotype, $phenotype_tag_name) = @_;

        my ($phenotype_info) = grep {
            "$_" eq "$phenotype" ? ($_) : ();
        } ($transgene->$phenotype_tag_name);

        my @genes;
        if ($phenotype_info) {
            @genes = $phenotype_info->at('Caused_by');  #worm genes
            @genes = $phenotype_info->at('Caused_by_other') if !@genes;  #other genes
        }
        return ($phenotype_info, @genes);
    }

    my $data_pack = $self->_affects('Transgene', \&get_caused_by_gene);

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

    sub get_primary_targets {
        my ($rnai, $phenotype, $phenotype_tag_name) = @_;

        my ($phenotype_info) = grep {
            "$_" eq "$phenotype" ? ($_) : ();
        } ($rnai->$phenotype_tag_name);

        my @affected_gene = grep { $_->get('Inferred_automatically',1) eq 'RNAi_primary'; } $rnai->Gene;

        return ($phenotype_info, @affected_gene);
    }

    my $data_pack = $self->_affects('RNAi', \&get_primary_targets);

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
    my ($self, $tag, $affected_gene_function) = @_;
    my $object = $self->object;

    my @data;
    foreach my $affected ($object->$tag){

        my $phenotype = $affected->right;
        my $phenotype_info;
        my $phenotype_tag;

        if ($affected_gene_function) {
            my ($phenotype_info, @affected_genes) = $affected_gene_function->($affected, $phenotype, 'Phenotype');
            if (@affected_genes) {
                $phenotype_tag = 'phenotype';
            }else{
                ($phenotype_info, @affected_genes) = $affected_gene_function->($affected, $phenotype, 'Phenotype_not_observed');
                $phenotype_tag = 'phenotype_not' if @affected_genes;
            }

            my ($remark) = $phenotype_info->at('Remark') if $phenotype_info;
            my $affected_packed = $self->_pack_obj($affected);
            $affected_packed->{label} = $affected_packed->{label} .
                ' [' . $tag . ']';

            my $evidence = {text => [$affected_packed, $remark ? "$remark" : ''],
                            evidence => $self->_get_evidence($phenotype)} if $affected->right(2);

            # create a row for every affected gene
            foreach my $gene (@affected_genes) {
                my $data_per_phenotype =  {
                    affected  =>  $evidence ? $evidence : $affected_packed,
                    affected_gene => $self->_pack_obj($gene),
                    $phenotype_tag => $self->_pack_obj($phenotype)
                };
                push @data, $data_per_phenotype;
            }
        }
    }
    return @data ? \@data : undef;
}

__PACKAGE__->meta->make_immutable;

1;
