package WormBase::API::Object::Feature;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::Position';
with 'WormBase::API::Role::Sequence';


has 'tracks' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            description => 'tracks displayed in GBrowse',
            data        => [qw/CG RNASEQ_ASYMMETRIES RNASEQ RNASEQ_SPLICE POLYSOMES MICRO_ORF DNAseI_HYPERSENSITIVE_SITE REGULATORY_REGIONS PROMOTER_REGIONS HISTONE_BINDING_SITE_REGIONS TRANSCRIPTION_FACTOR_BINDING_REGION TRANSCRIPTION_FACTOR_BINDING_SITE CORRECTED_GENOME_SEQUENCE_ERROR PREDICTED_BINDING_SITES CURATED_BINDING_SITES BINDING_REGIONS GENOME_SEQUENCE_ERROR/],
        };
    }
);


# Some good examples: WBsf000001, WBsf027925

=pod 

=head1 NAME

WormBase::API::Object::Feature

=head1 SYNPOSIS

Model for the Ace ?Feature class.

=head1 URL

http://wormbase.org/species/*/feature

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
# The Overview widget
#
#######################################

# name { }
# Supplied by Role

# method { }
# Supplied by Role

# flanking_sequences { }
# This method will return a data structure containing sequences adjacent to the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/flanking_sequences

sub flanking_sequences {
    my $self   = shift;
    my $object = $self->object;

    my ($seq, @flanks);
    if (my ($flanking_seq) = $self->object->Flanking_sequences) {
        ($seq, @flanks) = $flanking_seq->row;
        $seq = $self->_pack_obj($seq);
        @flanks = map {"$_"} @flanks;
    }

    return {
        description => 'sequences flanking the feature',
        data        => $seq && {
            seq    => $seq,
            flanks => @flanks ? \@flanks : undef,
        },
    };
}

# description { }
# Supplied by Role

# annotation { }
# This method will return a data structure
# containing annotation info on the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/annotation

sub annotation {
    my $self   = shift;
    my $object = $self->object; 

    my $annotation;
    if ($annotation = $object->Annotation) {
        $annotation = $annotation->right;
    }
    
    return { description => 'annotation of the feature',
	     data        => $annotation && "$annotation", };
}

# remarks {}
# Supplied by Role

# taxonomy {}
# Supplied by Role

# sequence_ontology_terms { }
# This method will return a data structure
# containing sequence ontology terms on the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence_ontology_terms

sub sequence_ontology_terms {
    my $self   = shift;
    my $object = $self->object;

    my @terms = map {"$_"} $object->SO_term;
    return { description => 'sequence ontology terms describing the feature',
	     data        => @terms ? \@terms : undef, };
}

# sequence { }
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence

sub sequence {
    my ($self) = @_;

    return {
        description => 'TODO',
        data => $self->_pack_obj($self ~~ 'Sequence'),
    };
}

#######################################
#
# The Associations widget
#
#######################################

# defined_by { }
# This method returns a data structure detailing 
# how the sequence feature was defined.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/defined_by

sub defined_by {
    my $self   = shift;
    my $object = $self->object; 

    my @data;
    foreach my $definer ($object->Defined_by) {
    	foreach my $definer_object ($definer->col) {
	    (my $label = "$definer") =~ s/Defined_by_(.)/\u$1/;
	    push @data, {
		'object' 	=> $self->_pack_obj($definer_object),
		'label' 	=> $label && "$label",
	    };
    	}
    }
    
    return { description => 'how the sequence feature was defined',
	     data        => @data ? \@data : undef, };
}

# associations { }
# This method will return a data structure listing
# sequences associated with this feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/associations

sub associations {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my @association_types = $object->Associations;
    
    foreach my $assoc_type (@association_types) { # assoc_type is tag
    	foreach my $association_object ($assoc_type->col) {
	    (my $label = "$assoc_type") =~ s/Associated_with_(.)/\u$1/;
	    push @data, { association 	=> $self->_pack_obj($association_object),
			  label 	=> $label && "$label"      };
	}
    }
    return { description => 'objects that define this feature',
	     data        => @data ? \@data : undef,
    };
}


# binds_gene_product { }
# This method will return a data structure containing 
# the gene whose product binds the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/binds_gene_product

sub binds_gene_product {
    my $self   = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Bound_by_product_of;
    return { data => @data ? \@data : undef,
	     description => 'gene products that bind to the feature' };
}


# transcription_factor { }
# This method will return a data structure containing
# the transcription factors that associate with this feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/transcription_factor

sub transcription_factor {
    my $self   = shift;
    my $object = $self->object;

    return { description => 'Transcription factor of the feature',
	     data        => $self->_pack_obj($object->Transcription_factor) };
}

sub _build__segments {
    my ($self) = @_;
    my $object = $self->object;
    return [] unless $self->gff;
    return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object)];
}


__PACKAGE__->meta->make_immutable;

1;

