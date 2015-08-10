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

has 'genes' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_annotated_genes',
);

sub _build_annotated_genes {
    my $self   = shift;
    my $object = $self->object;

    my $counts = $self->_get_count($object, 'GO_annotation');
    my @annotations = $counts <= 500 ? $object->GO_annotation : ();

    my $comment_too_many = "$counts GO annotations found. Too many to display. Please use our <a href=\"ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release\">FTP site</a> to download.";

    my @data;
    foreach my $anno (@annotations) {

        my $gene = $anno->Gene;
        my $go_code = $anno->GO_code;
        my $ev_names = ['Reference', 'Contributed_by', 'Date_last_updated'];
        my $evidence = $self->_get_evidence($anno->fetch(), $ev_names);
        my $species = $gene->Species || undef;

        my @entities = map {
            $self->_pack_list([$_->col()]);
        } $anno->Annotation_made_with;

        my @entities = map {
            my @ent;
            if ("$_" eq 'Database'){
                @ent = $self->_pack_xrefs($anno);
            }else{
                @ent = $self->_pack_list([$_->col()]);
            }
            @ent;
        } $anno->Annotation_made_with;

        my @go_refs = map {
            $_->{label} = $_->{id};
            $_;
        }  $self->_pack_xrefs($anno, 'GO_reference');
        $evidence->{GO_reference} = \@go_refs if @go_refs;


        my %extensions = map {
            my ($ext_type, $ext_name, $ext_value) = $_->row();
           "$ext_name" => $self->_pack_obj($ext_value)
        } $anno->Annotation_extension;

        my $anno_data = {
            gene => $self->_pack_obj($gene),
            species => $self->_pack_obj($species),
            with => @entities ? \@entities : undef,
            extensions => %extensions ? { evidence => \%extensions} : undef,
            evidence_code => $evidence ? { evidence => $evidence, text => "$go_code" } : "$go_code",
            anno_id => "$anno",
        };

        push @data, $anno_data;
    }

    return {
        'data'        => @data ? \@data : $counts ? $comment_too_many : undef,
        'description' => 'genes annotated with this term'
    };
}


sub genes_summary {
    my ($self)   = @_;

    my $ref_type = ref($self->genes->{data});
    my @data = $ref_type ? @{$self->genes->{data}}: ();

    sub _get_gene_id {
        my ($item) = @_;
        return $item->{gene}->{label};
    }

    my $summary_by_gene = $self->_group_and_combine(\@data, \&_get_gene_id, \&_summarize_gene);

    return {
        description => 'genes annotated with this term',
        data        => %$summary_by_gene ? [values %$summary_by_gene] : undef,
    };
}


sub _summarize_gene {
    my ($anno_data_all) = @_;

    my @exts_all = ();
    foreach my $anno_data (@$anno_data_all){
        #extensions within a single annotation
        my $exts = $anno_data->{extensions};
        push @exts_all, $exts if $exts;
    }
    return {
        gene => $anno_data_all->[0]->{gene},
        species => $anno_data_all->[0]->{species},
        extensions => @exts_all ? \@exts_all : undef,
    };
}

# genes { }
# This method will return a data structure with the genes annotated with the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/genes

# sub genes {
#     my $self   = shift;
#     my $object = $self->object;
#     my %data;
#     my $objTag = 'Gene';

#     my $counts = $self->_get_count($object, 'GO_annotation');
#     my @annotations = $counts <= 500 ? $object->GO_annotation : ();
#     my $comment_too_many = "$counts GO annotations found. Too many to display. Please use our <a href=\"ftp://ftp.wormbase.org/pub/wormbase/releases/current-production-release\">FTP site</a> to download.";

#     foreach my $anno (@annotations) {
#         my $gene = $anno->$objTag;
#         my $evidence_code = $self->_get_GO_evidence($anno);

#         if ($data{$gene}){
#             push @{ $data{$gene}{evidence_code} }, $evidence_code;
#         } else {

#             my $desc = $gene->Concise_description || $gene->Provisional_description || undef;
#             my $species = $gene->Species || undef;
#             %{$data{$gene}} = (
#                 gene          => $self->_pack_obj($gene),
#                 species       => $self->_pack_obj($species),
#                 evidence_code => [$self->_get_GO_evidence($anno)],
#                 description	  => $desc && "$desc",
#             );
#         }

#     }

#     foreach (values %data) {
#         $_->{evidence_code} = [sort {$a->{text} cmp $b->{text}} @{ $_->{evidence_code} }];
#     }

#     return {
#         'data'        => %data ? [values %data] : $counts ? $comment_too_many : undef,
#         'description' => 'genes annotated with this term'
#     };
# }

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
    my $ev_names = ['Reference', 'Contributed_by', 'Date_last_updated'];
    my $evidence = $self->_get_evidence($annotation->fetch(), $ev_names);

    return {text => $code && "$code",
            evidence => $evidence,
    };
    # my $association = $gene->fetch()->get('GO_term')->at("$term");
    # my $code = $association->right if $association;
    # return {text => $code && "$code", evidence => $self->_get_evidence($code)};
}



__PACKAGE__->meta->make_immutable;

1;
