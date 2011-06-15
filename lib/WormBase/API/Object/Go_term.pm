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

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 term

This method will return a data structure with the go_term.

=over

=item PERL API

 $data = $model->term();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/term

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub term {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Term;
    my $data_pack  = $self->_pack_obj($object,"$tag_object");
    return {
        'data'        => $data_pack,
        'description' => 'GO term'
    };
}

=head3 definition

This method will return a data structure with the definition of the go_term.

=over

=item PERL API

 $data = $model->definition();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/definition

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub definition {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Definition;
    return {
        'data'        => "$data_pack",
        'description' => 'term definition'
    };
}

=head3 type

This method will return a data structure with the type of go_term.

=over

=item PERL API

 $data = $model->type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/type

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

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

=head3 genes

This method will return a data structure with the genes annotated with the go_term.

=over

=item PERL API

 $data = $model->genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/genes

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub genes {
    my $self   = shift;
    my $object = $self->object;
    my @data_pack;
    my @genes = eval { $object->Genes };

    if (@genes) {
        foreach my $gene (@genes) {

            my ( $evidence_code, $evidence_details ) =
              $self->_get_GO_evidence( $object, $gene );
            my $gene_info = $self->_pack_object($gene);
            my $gene_data = {
                'gene'             => $gene_info,
                'evidence_code'    => $evidence_code,
                'evidence_details' => $evidence_details
            };
            push @data_pack, $gene_data;
        }
    }
    return {
        'data'        => @genes ? \@data_pack : undef,
        'description' => 'genes annotated with this term'
    };
}

=head3 cds

This method will return a data structure with the cds annotated with the go_term.

=over

=item PERL API

 $data = $model->cds();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/cds

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub cds {
    my $self   = shift;
    my $object = $self->object;
    my @data_pack;
    my @genes = eval { $object->CDS };

    if (@genes) {
        foreach my $gene (@genes) {

            my ( $evidence_code, $evidence_details ) =
              $self->_get_GO_evidence( $object, $gene );
            my $gene_info;
           	$gene_info = eval{$self->_pack_object($gene);};
            my $gene_data = {
                'gene'             => $gene_info,
                'evidence_code'    => $evidence_code,
                'evidence_details' => $evidence_details
            };
            push @data_pack, $gene_data;
        }
    }
    return {
        'data'        => @genes ? \@data_pack : undef,
        'description' => 'CDS annotated with this term'
    };
}

=head3 genes_n_cds

This method will return a data structure with the genes_n_cds annotated with the go_term.

=over

=item PERL API

 $data = $model->genes_n_cds();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/genes_n_cds

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub genes_n_cds {
    my $self = shift;
    my $term = $self->object;
    my %mol;
    my %cgc;
    my @data_pack;
    my $DB = $self->ace_dsn();
    my @objs;

    push( @objs, $term->Gene, $term->CDS ) unless @objs;

    foreach my $obj (@objs) {
        my ( $gene, $key );
        if ( $obj->class eq 'CDS' ) {
            $gene = $obj->Gene;
            $key  = $obj;
        }
        else {
            $gene = $obj;
            $key  = $gene;
        }
        next unless $gene;
        next if ( defined $cgc{$key} || defined $mol{$key} );

        if ( $gene->CGC_name ) {
            $cgc{$key} = [ $obj, $gene, $gene->CGC_name ];
        }
        else {
            $mol{$key} = [ $obj, $gene, $gene->Sequence_name ];
        }
    }

    my @sorted = keys %cgc;
    push @sorted, keys %mol;

    my @genes;

    foreach (@sorted) {
        my ( $obj, $gene, $junk ) = eval { @{ $cgc{$_} } };
        ( $obj, $gene, $junk ) = eval { @{ $mol{$_} } } unless $gene;

        # UGH!  Return a list of CDSs instead.
        push @genes, $obj;
        push @genes, $DB->fetch( Gene => $gene );
    }

    foreach my $gene (@genes) {
        my $cgc_name;
        $cgc_name = eval{$gene->CGC_name;};
        my $seq;
        $seq = eval{$gene->Sequence_name;};
        my $desc = $gene->Concise_description || $gene->Provisional_description;
        my ( $evidence_code, $evidence_details ) =
          $self->_get_GO_evidence( $term, $gene );
        my $gene_info = $self->_pack_obj($gene);

        my $gene_data = {
            'gene_info'        => $gene_info,
            'cgc_name'         => "$cgc_name",
            'seq'              => "$seq",
            'description'      => "$desc",
            'evidence_code'    => $evidence_code,
            'evidence_details' => $evidence_details
        };
        push @data_pack, $gene_data;
    }
    return {
        'data'        => @objs ?  \@data_pack : undef,
        'description' => 'genes and cds annoted with this term'
    };
}

=head3 phenotype

This method will return a data structure with the phenotypes annotated with the go_term.

=over

=item PERL API

 $data = $model->phenotype();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/phenotype

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub phenotype {
    my $self = shift;
    my $term = $self->object;
    my @data_pack;
    my @phenotypes = $term->Phenotype;
    foreach my $phenotype (@phenotypes) {
        my $phenotype_desc = $phenotype->Description;
        my ( $evidence_code, $evidence_details ) =
          $self->_get_GO_evidence( $term, $phenotype );
        my $phenotype_info = $self->_pack_obj($phenotype);

        my $pheno_data = {
            'phenotype_info'   => $phenotype_info,
            'description'      => "$phenotype_desc",
            'evidence_code'    => $evidence_code,
            'evidence_details' => $evidence_details
        };
        push @data_pack, $pheno_data;
    }
    return {
        'data'        => @phenotypes ? \@data_pack : undef,
        'description' => 'phenotypes annotated with this term'
    };
}

=head3 motif

This method will return a data structure with the motifs annotated with the go_term.

=over

=item PERL API

 $data = $model->motif();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/motif

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub motif {
    my $self = shift;
    my $term = $self->object;
    my @data_pack;

    my @motifs;
    eval { @motifs = $term->Motif; };

    foreach my $motif (@motifs) {
        my $motif_desc = $motif->Description;
        my ( $evidence_code, $evidence_details ) =
          get_GO_evidence( $term, $motif );
        my $motif_info = $self->_pack_obj($motif);
        my $motif_data = {
            'motif_info'       => $motif_info,
            'description'      => $motif_desc,
            'evidence_code'    => $evidence_code,
            'evidence_details' => $evidence_details
        };
        push @data_pack, $motif_data;
    }
    return {
        'data'        => @data_pack ? \@data_pack : undef,
        'description' => 'motifs annotated with this term'
    };
}

=head3 sequence

This method will return a data structure with the sequences annotated with the go_term.

=over

=item PERL API

 $data = $model->sequence();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/sequence

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub sequence {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Sequence');
    return {
        data        => $data_pack,
        description => 'sequences annotated with this term'
    };
}

=head3 transcript

This method will return a data structure with the transcripts annotated with the go_term.

=over

=item PERL API

 $data = $model->transcript();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/transcript

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub transcript {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Transcript');
    return {
        data        => $data_pack,
        description => 'transcripts annotated with this term'
    };
}

=head3 pseudogene

This method will return a data structure with the pseudogenes annotated with the go_term.

=over

=item PERL API

 $data = $model->pseudogene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/pseudogene

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub pseudogene {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Pseudogene');
    return {
        data        => $data_pack,
        description => 'pseudogenes annotated with this term'
    };
}

=head3 anatomy_term

This method will return a data structure with the anatomy_terms annotated with the go_term.

=over

=item PERL API

 $data = $model->anatomy_term();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/anatomy_term

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub anatomy_term {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Anatomy_term');
    return {
        data        => $data_pack,
        description => 'anatomy_terms annotated with this term'
    };
}

=head3 homology_group

This method will return a data structure with the homology_groups annotated with the go_term.

=over

=item PERL API

 $data = $model->homology_group();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/homology_group

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub homology_group {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data();
    return {
        data        => $data_pack,
        description => ' annotated with this term'
    };
}

=head3 expr_pattern

This method will return a data structure with the expr_patterns annotated with the go_term.

=over

=item PERL API

 $data = $model->expr_pattern();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/expr_pattern

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

#sub expr_pattern {
#    my $self      = shift;
#    my $data_pack = $self->_get_tag_data('Expr_pattern');
#    return {
#        data        => $data_pack,
#        description => ' annotated with this term'
#    };
#}

=head3 cell

This method will return a data structure with the cells annotated with the go_term.

=over

=item PERL API

 $data = $model->cell();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A GO_Term id (eg GO:0032502)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/cell

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub cell {
    my $self      = shift;
    my $data_pack = $self->_get_tag_data('Cell');
    return {
        data        => $data_pack,
        description => ' annotated with this term'
    };
}

#################################
#
# Browser widget
#
#################################


sub get_host {
	my $self = shift;
	my $host = 'norie.wormbase.org'; ## $ENV{'SERVER_NAME'}
	return $host;
}

#################################
#
# Internal Methods
#
#################################

sub _get_tag_data {
    my $self = shift;
    my $tag  = shift;
    my $term = $self->object;
    my @data_pack;
    my @motifs;
    my @tag_data;
    eval{@tag_data = $term->$tag} ;

    foreach my $tag_datum (@tag_data) {
        my $tag_datum_desc = $tag_datum->Description;
        my ( $evidence_code, $evidence_details ) =
          get_evidence( $term, $tag_datum );

        push @data_pack,
          {
            'term'             => "$tag_datum",
            'description'      => "$tag_datum_desc",
            'class'            => $tag,
            'evidence_code'    => $evidence_code,
            'evidence_details' => $evidence_details
          };
    }
    return @data_pack ? \@data_pack : undef;
}

sub _get_GO_evidence {

    my ( $term, $gene ) = @_;
    my @go_terms;
    eval { @go_terms = $gene->GO_Term; };
    my $evidence_code;
    my $evidence_detail;

    foreach my $go_term (@go_terms) {

        if ( $go_term eq $term ) {
            eval { $evidence_code = $go_term->right; };
            eval { $go_term->right->right->right; };
            $evidence_detail = last;
        }
    }
    return ( $evidence_code, $evidence_detail );
}

__PACKAGE__->meta->make_immutable;

1;


