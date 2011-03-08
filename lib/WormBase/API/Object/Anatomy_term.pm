package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Anatomy_term

=head1 SYNPOSIS

Model for the Ace ?Anatomy_term class.

=head1 URL

http://wormbase.org/species/anatomy_term

=head1 METHODS/URIs

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

=head3 definition

This method will return a data structure re: definition of this anatomy_term.

=head4 PERL API

 $data = $model->definition();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Anatomy_term ID (eg WBbt:0005175)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/definition

=head5 Response example

<div class="response-example"></div>

=cut

sub definition {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $object->Definition;
    return {
        data => $data ? "$data" : undef,
        description => 'definition of the anatomy term',
    };
}

=head3 synonyms

This method will return a data structure containing the 
synonyms of this anatomy term object.

=head4 PERL API

 $data = $model->synonyms();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Anatomy_term ID (eg WBbt:0005175)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/synonyms

=head5 Response example

<div class="response-example"></div>

=cut

sub synonyms {
    my $self     = shift;
    my $object   = $self->object;
    my @synonyms = $object->Synonym;

    foreach my $entry (@synonyms) {
        my $synonym = $entry->Primary_name->right if $entry->Primary_name;
        my $tag_info = $self->_pack_obj($synonym);
        push @data, $self->_pack_obj($synonym);
    }
    return {
        description =>
          'synonyms that have been used to describe the anatomy term',
        data => @data ? \@data : undef
    };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 transgenes

This method will return a data structure of 
transgenes annotated with this anatomy term.

=head4 PERL API

 $data = $model->transgenes();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Anatomy_term ID WBbt:0005175

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/transgenes

=head5 Response example

<div class="response-example"></div>

=cut

sub transgenes {
    my $self   = shift;
    my $object = $self->object;
    my @transgenes;
    eval {
        @transgenes =
          map { $_->Transgene }
          grep { /marker/i && defined $_->Transgene } $term->Expr_pattern;
    };
    my @data_pack = map { $_ = $self->_pack_obj($_) } @transgenes;
    return {
        'data'        => \@data_pack,
        'description' => 'transgenes annotated with this anatomy_term'
    };
}

#####################
## browser
#####################

#####################
## term diagram
#####################

#####################
## associations
####################

# TH: There is a shared expression_patterns method in Role. We should use/expand that one and template.

=head3 expr_patterns

This method will return a data structure expression patterns associated with this anatomy_term.

=over

=item PERL API

 $data = $model->expr_patterns();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term id (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/expr_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expr_patterns {
    my $self          = shift;
    my $object        = $self->object;
    my @expr_patterns = $object->Expr_pattern;

    foreach my $expr_pattern (@expr_patterns) {
        my $ep_data = {
            'id'    => "$expr_pattern",
            'label' => "$expr_pattern",
            'Class' => 'Expr_pattern'
        };

        my $ep_gene    = $expr_pattern->Gene      if $expr_pattern->Gene;
        my $ep_pattern = $expr_pattern->Pattern   if $expr_pattern->Pattern;
        my $ep_xgene   = $expr_pattern->Transgene if $expr_pattern->Transgene;

        my $gene_data         = $self->_pack_obj($ep_gene)    if $ep_gene;
        my $ep_pattern_data   = $self->_pack_obj($ep_pattern) if $ep_pattern;
        my $ep_transgene_data = $self->_pack_obj($ep_xgene)   if $ep_xgene;

        push @data_pack,
          {
            'ep_data'    => $ep_data,
            'gene'       => $gene_data,
            'pattern'    => ep_pattern_data,
            'trans_gene' => $ep_transgene_data
          };
    }
    return {
        'data'        => \@data_pack,
        'description' => 'expr_patterns annotated with this anatomy_term'
    };
}

=head3 go_terms

This method will return a data structure containing go terms for this anatomy_term.

=over

=item PERL API

 $data = $model->go_terms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term id (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/go_terms

<div class="response-example"></div>

=back

=cut 

sub go_terms {
    my $self     = shift;
    my $object   = $self->object;
    my @go_terms = $object->GO_term;

    foreach my $go_term (@go_terms) {
        my $term    = $go_term->Term;
        my $ao_code = $go_term->right;
        my $gt_data = {
            'id'    => "$go_term",
            'label' => "$term",
            'Class' => 'GO_term'
        };
        push @data_pack,
          {
            'term'    => $gt_data,
            'ao_code' => "$ao_code"
          };
    }
    return {
        'data'        => \@data_pack,
        'description' => 'go_terms associated with this anatomy_term'
    };
}

=head3 anatomy_functions

This method will return a data structure anatomy_functions associated with this anatomy_term.

=over

=item PERL API

 $data = $model->anatomy_functions();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term id (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/anatomy_functions
B<Response example>

<div class="response-example"></div>

=back

=cut 

sub anatomy_functions {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_anatomy_function('Anatomy_function');
    return {
        'data'        => $data_pack,
        'description' => 'anatomy_functions associatated with this anatomy_term'
    };
}

=head3 anatomy_function_nots

This method will return a data structure ... of this anatomy_term.

=over

=item PERL API

 $data = $model->anatomy_function_nots();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term id (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/anatomy_function_nots

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub anatomy_function_nots {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_anatomy_function('Anatomy_function_not');
    return {
        'data'        => $data_pack,
        'description' => 'anatomy_functions associatated with this anatomy_term'
    };
}

=head3 expression_clusters

This method will return a data structure expression_clusters associated with this anatomy_term.

=over

=item PERL API

 $data = $model->expression_clusters();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term id (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/expression_clusters

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expression_clusters {
    my $self   = shift;
    my $object = $self->object;
    my $desc   = 'notes';
    my @data_pack;
    my @expression_clusters = $object->Expression_cluster;
    foreach my $expression_cluster (@expression_clusters) {
        my $ec_description = $expression_cluster->Description;
        my $ec_data        = $self->_pack_obj($expression_cluster);

        push @data_pack,
          {
            'ec_data'     => $ec_data,
            'description' => $ec_description
          };
    }
    return {
        'data'        => \@data_pack,
        'description' => 'expression_clusters associated with this anatomy_term'
    };
}

#######################################
#
# The External Links widget
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

## sub anatomy {}  figure out image displaying functions

## sub worm_atlas {} put under external resources

#######################################
#
# Internal Methods
#
#######################################

sub _anatomy_function {
    my $self              = shift;
    my $tag               = shift my $object = $self->object;
    my @anatomy_functions = $object->$tag;

    foreach my $anatomy_function (@anatomy_functions) {
        my $phenotype      = $anatomy_function->Phenotype;
        my $phenotype_name = $phenotype->Primary_name;
        my $gene_data      = $self->_pack_obj( $af->Gene ) if $af->Gene;

        push @data_pack,
          {
            'af_data' => {
                'id'    => "$anatomy_function",
                'label' => "$anatomy_function",
                'Class' => 'Anatomy_function'
            },
            'phenotype' => {
                'id'    => $phenotype,
                'label' => $phenotype_name,
                'class' => 'phenotype'
            },
            'gene' => $gene_data
          };
    }
    return \@data_pack;
}

1;

