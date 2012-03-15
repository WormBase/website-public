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
    return {
        'data'        => $self->_pack_obj($object, $tag_object && "$tag_object"),
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
        'data'        => $data_pack && "$data_pack",
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

#######################################
#
# The Associations Widget
#
#######################################

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
    my @data;

    foreach my $gene ($object->Gene) {
	my $desc = $gene->Concise_description || $gene->Provisional_description || undef;
	push @data, {
	    gene          => $self->_pack_obj($gene),
	    evidence_code => $self->_get_GO_evidence( $object, $gene ),
	    description	  => $desc && "$desc",
	};
    }
    return {
        'data'        => @data ? \@data : undef,
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
    my @data;

    foreach my $cds ($object->CDS) {
	push @data, {
	    cds           => $self->_pack_obj($cds),
	    evidence_code => $self->_get_GO_evidence( $object, $cds ),
	};
    }
    return {
        'data'        => @data ? \@data : undef,
        'description' => 'CDS annotated with this term'
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
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Motif;

    return {
        'data'        => @data ? \@data : undef,
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
        description => 'anatomy terms annotated with this term'
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
    my $data_pack = $self->_get_tag_data('Homology_group');
    return {
        data        => $data_pack,
        description => 'homology groups annotated with this term'
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
    my ( $self,$term, $gene ) = @_;
    my $code;

    foreach my $go_term ($gene->GO_Term) {
        if ( $go_term eq $term ) {
            $code = $go_term->right;
        }
    }
    return {text => $code && "$code", evidence => $self->_get_evidence($code)};
}



__PACKAGE__->meta->make_immutable;

1;


