package WormBase::API::Role::Phenotype;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################

has 'features' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_features',
);

#######################################
#
# The Phenotype Widget
#   template: classes/gene/phenotype.tt2
#
#######################################

use Data::Dumper;

sub _build__phenotypes_with {
    my ($self, $phenotype_tag) = @_;
    my $object = $self->object;

    my @allele_phenotypes = map {
        my $allele = $_;
        my $experimental_info = $self->_get_allele_info($allele);
        map {
            $_->{experimental_info} = $experimental_info;
            $_;
        } $self->_get_phenotypes_by_experiment($allele, $phenotype_tag);
    } $object->Allele;

    my @rnai_phenotypes = map {
        my $rnai = $_;
        my $experimental_info = $self->_get_rnai_info($rnai);
        map {
            $_->{experimental_info} = $experimental_info;
            $_;
        } $self->_get_phenotypes_by_experiment($rnai, $phenotype_tag);
    } $object->RNAi_result;

    my @construct_phenotypes = map {
        my $transgene = $_;
        my $experimental_info = $self->_get_construct_info($transgene);
        map {
            $_->{experimental_info} = $experimental_info;
            # Only include those transgenes where the Caused_by in #Phenotype_info
            # is the current gene.
            $_->{evidence}->{Caused_by_gene}->[0]->{id} eq "$object" ? ($_) : ();
        } $self->_get_phenotypes_by_experiment($transgene, $phenotype_tag);
    } map { $_->Transgene_construct } $object->Construct_product;

    # Don't look into Drives_construct for phenotypes - source Karen Y

    my @all_phenotypes = map {
        my $phenotype_evidence = $_->{evidence} || {};
        my $experimental_evidence = $_->{experimental_info}->{evidence} || {};
        my $experimental_object = $_->{experimental_info}->{object};
        my %evidence = (%$phenotype_evidence, %$experimental_evidence);
        {
            phenotype => $_->{phenotype},
            entity => @{$_->{pato}} ? $_->{pato} : undef,
            evidence => %evidence ? { text=>$experimental_object, evidence=>\%evidence } : $experimental_object,
        };
    } (@allele_phenotypes, @rnai_phenotypes,  @construct_phenotypes);

    print Dumper \@all_phenotypes;
    #{ text=>$packed_obj, evidence=>$evidence } if $evidence && %$evidence;


    return @all_phenotypes ? \@all_phenotypes : undef;
}




#######################################
#
# helper functions
#
#######################################

sub _get_phenotypes_by_experiment {
    my ($self, $experimental_obj, $phenotype_tag) = @_;

    my @phenotype_infos = map {
        my $evidence = $self->_get_evidence($_, undef, ['EQ_annotations']);
        my @patos = $self->_get_pato($_, 'EQ_annotations');
        {
            phenotype => $self->_pack_obj($_),
            evidence => $evidence,
            pato => \@patos
        };
    } $experimental_obj->$phenotype_tag;
    return @phenotype_infos;
}


sub _get_pato {
    my ($self, $phenotype_info_obj, $pato_tag) = @_;
    my @entities = $phenotype_info_obj->at($pato_tag);

    my @patos = map {
        my ($entity_type, $entity_term, $pato_term) = $_->row();
        return {
            pato_evidence => {
                entity_term => $self->_pack_obj($entity_term),
                pato_term => $pato_term->Name ? "$pato_term->Name" : 'abnormal',
            }
        };
    } @entities;

    return @patos;
}


sub _get_rnai_info {
   my ($self, $rnai_obj) = @_;

   my $label = $rnai_obj =~ /WBRNAi0{0,3}(.*)/ ? $1 : undef;
   my @papers = $self->_pack_obj($rnai_obj->Reference);
   my $genotype = $rnai_obj->Genotype;
   my $strain = $rnai_obj->Strain;

   return {
       object => $self->_pack_obj($rnai_obj, $label),
       type => 'RNAi',
       evidence => {
           paper => @papers ? \@papers : undef,
           genotype => $genotype ? "$genotype" : undef,
           strain => $strain ? "$strain" : undef
       }
   };
}


sub _get_construct_info {
   my ($self, $construct_obj) = @_;

   return {
       object => $self->_pack_obj($construct_obj),
       type => 'Transgene'
   };
}


sub _get_allele_info {
   my ($self, $allele_obj) = @_;

   my $is_sequenced = $allele_obj->SeqStatus =~ /sequenced/i;
   my $packed_obj = $self->_pack_obj($allele_obj, undef, style => $is_sequenced ? 'font-weight:bold': 0,);

   return {
       object => $packed_obj,
       type => 'Allele'
   };
}


1;
