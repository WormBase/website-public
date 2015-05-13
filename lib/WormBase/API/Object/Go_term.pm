package WormBase::API::Object::Go_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::GO_term

=head1 SYNPOSIS

Model for the Ace ?GO_Term class.

=head1 URL

http://wormbase.org/species/go_term

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

# term { }
# This method will return a data structure with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/term

sub term {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Term;
    return {
        'data'        => $self->_pack_obj($object, $tag_object && "$tag_object"),
        'description' => 'GO term'
    };
}

# definition { }
# This method will return a data structure with the definition of the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/definition

sub definition {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Definition;
    return {
        'data'        => $data_pack && "$data_pack",
        'description' => 'term definition'
    };
}

# type { }
# This method will return a data structure with the type of go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/type
sub type {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Type;
    $data_pack =~ s/\_/\ /;
    return {
        'data'        => $data_pack,
        'description' => 'type for this term'
    };
}

#######################################
#
# The Associations Widget
#
#######################################

# genes { }
# This method will return a data structure with the genes annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/genes

sub genes {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my $objTag = 'Gene';

    foreach my $anno ($object->GO_annotation) {
        my $gene = $anno->$objTag;
        my $desc = $gene->Concise_description || $gene->Provisional_description || undef;
        my $species = $gene->Species || undef;
            push @data, {
                gene          => $self->_pack_obj($gene),
                species       => $self->_pack_obj($species),
                evidence_code => $self->_get_GO_evidence($anno),
                description	  => $desc && "$desc",
            };

    }

    return {
        'data'        => @data ? \@data : undef,
        'description' => 'genes annotated with this term'
    };
}

# cds { }
# This method will return a data structure with the cds annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/cds

sub cds {
    my $self   = shift;
    my $object = $self->object;
    my @data;

    foreach my $cds ($object->CDS) {
        push @data, {
            cds           => $self->_pack_obj($cds),
            species       => $self->_pack_obj($cds->Species || undef),
            evidence_code => $self->_get_GO_evidence( $object, $cds ),
        };
    }
    return {
        'data'        => @data ? \@data : undef,
        'description' => 'CDS annotated with this term'
    };
}

# phenotype { }
# This method will return a data structure with the phenotypes annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/phenotype

sub phenotype {
    my $self = shift;
    my $object = $self->object;
    my @data;

    foreach my $phenotype ($object->Phenotype) {
        my $desc = $phenotype->Description;
        push @data, {
            phenotype_info   => $self->_pack_obj($phenotype),
            description      => $desc && "$desc",
        };
    }
    return {
        'data'        => @data ? \@data : undef,
        'description' => 'phenotypes annotated with this term'
    };
}

# motif { }
# This method will return a data structure with the motifs annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/motif

sub motif {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Motif;

    return {
        'data'        => @data ? \@data : undef,
        'description' => 'motifs annotated with this term'
    };
}

# sequence { }
# This method will return a data structure with the sequences annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/sequence

sub sequence {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Sequence');
    return {
        data        => $data_pack,
        description => 'sequences annotated with this term'
    };
}

# transcript { }
# This method will return a data structure with the transcripts annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/transcript

sub transcript {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Transcript');
    return {
        data        => $data_pack,
        description => 'transcripts annotated with this term'
    };
}

# anatomy_term { }
# This method will return a data structure with the anatomy_terms annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/anatomy_term

sub anatomy_term {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Anatomy_term');
    return {
        data        => $data_pack,
        description => 'anatomy terms annotated with this term'
    };
}

# homology_group { }
# This method will return a data structure with the homology_groups annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/homology_group

sub homology_group {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Homology_group');
    return {
        data        => $data_pack,
        description => 'homology groups annotated with this term'
    };
}

# expr_pattern { }
# This method will return a data structure with the expr_patterns annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/expr_pattern

#sub expr_pattern {
#    my $self      = shift;
#    my $data_pack = $self->_get_tag_data('Expr_pattern');
#    return {
#        data        => $data_pack,
#        description => ' annotated with this term'
#    };
#}

# cell { }
# This method will return a data structure with the cells annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/cell

sub cell {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Cell');
    return {
        data        => $data_pack,
        description => 'cells annotated with this term'
    };
}

#################################
#
# Internal Methods
#
#################################

sub _get_tag_data {
    my ($self, $tag) = @_;
    my $object = $self->object;
    my @data_pack;
    my @motifs;

    foreach ($object->$tag) {
        my $desc = eval {$_->Description};

        push @data_pack,
          {
            'term'             => $self->_pack_obj($_),
            'description'      => $desc && "$desc",
            'class'            => $tag && "$tag",
            'evidence_code'    => $self->_get_GO_evidence( $object, $_ ),
          };
    }
    return @data_pack ? \@data_pack : undef;
}


sub _get_GO_evidence {
    my ($self, $annotation) = @_;
    my $code = $annotation->GO_code;
    my $reference = $self->_pack_obj($annotation->Reference);

    return {text => $code && "$code",
            evidence => {
                Paper_evidence => $reference
            }
    };
    # my $association = $gene->fetch()->get('GO_term')->at("$term");
    # my $code = $association->right if $association;
    # return {text => $code && "$code", evidence => $self->_get_evidence($code)};
}



__PACKAGE__->meta->make_immutable;

1;
