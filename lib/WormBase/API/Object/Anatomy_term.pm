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

http://wormbase.org/species/*/anatomy_term

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

sub term {
	my ($self) = @_;

    my $data = $self->_pack_obj($self ~~ 'Term');
    $data->{class} = 'Anatomy_term' if $data; # important or no?

	return {
		data        => $data,
		description => 'Term in the Anatomy ontology',
    };
}


=head3 definition

This method will return a data structure containing a prose
definition of this term.

=over

=item PERL API

 $data = $model->definition();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term ID (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/definition

B<Response example>

<div class="response-example"></div>

=back

=cut

sub definition {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $object->Definition;
    return {
        data        => $data ? "$data" : undef,
        description => 'definition of the anatomy term',
    };
}

=head3 synonyms

This method will return a data structure containing the 
synonyms of this anatomy term object.

=over

=item PERL API

 $data = $model->synonyms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Anatomy_term ID (eg WBbt:0005175)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/synonyms

B<Response example>

<div class="response-example"></div>

=back

=cut

sub synonyms {
    my $self     = shift;
    my $object   = $self->object;
    my @synonyms = $object->Synonym;
	my @data;

    foreach my $synonym (@synonyms) {
        #my $synonym;
        #$synonym = eval{$entry->Primary_name->right;};
        # my $tag_info = $self->_pack_obj($synonym);
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

=over

=item PERL API

 $data = $model->transgenes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Anatomy_term ID WBbt:0005175

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/transgenes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub transgenes {
    my $self   = shift;
    my $term = $self->object;
    my @transgenes;
    eval {
        @transgenes =
          map { $_->Transgene }
          grep { /marker/i && defined $_->Transgene } $term->Expr_pattern;
    };
    my @data_pack = map { $_ = $self->_pack_obj($_) } @transgenes;
    return {
        'data'        => @data_pack ? \@data_pack : undef,
        'description' => 'transgenes annotated with this anatomy_term'
    };
}


#######################################
#
# The Expression patterns
#
#######################################

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
            'description' => "$ec_description"
          };
    }
    return {
        'data'        => @data_pack ? \@data_pack : undef,
        'description' => 'expression_clusters associated with this anatomy_term'
    };
}

# sub expression_patterns {}
# Supplied by Role; POD will automatically be inserted here.
# << include expression_patterns >>


#####################
## browser
#####################

#####################
## term diagram
#####################

#####################
## associations
####################




=head3 gene_ontology

This method will return a data structure containing go terms for this anatomy_term.

=over

=item PERL API

 $data = $model->gene_ontology();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/gene_ontology

<div class="response-example"></div>

=back

=cut 

sub gene_ontology {
    my $self     = shift;
    my $object   = $self->object;
    my @go_terms = $object->GO_term;

    my @data = map {
        term    => $self->_pack_obj($_), # will this be needed?
        ao_code => $self->_pack_obj($_->right), # or does View expect text?
    }, @{$self ~~ '@GO_term'}; # array of hashes -- note the comma

    return {
        data        => @data ? \@data : undef,
        description => 'go_terms associated with this anatomy_term',
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

=back

=cut 

sub anatomy_functions {
    my ($self) = @_;

    return {
        data        => $self->_anatomy_function('Anatomy_function'),
        description => 'anatomy_functions associatated with this anatomy_term',
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



#######################################
#
# The External Links widget
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xreffs >>

## sub anatomy {}  figure out image displaying functions

## sub worm_atlas {} put under external resources

#######################################
#
# Internal Methods
#
#######################################

sub _anatomy_function {
    my ($self, $tag) = @_;

	my @data_pack = map {
            af_data   => $self->_pack_obj($_),
            phenotype => $self->_pack_obj(scalar $_->Phenotype),
            gene      => $self->_pack_obj(scalar $_->Gene),
    }, $self->object->$tag; # array of hashes -- note the comma

    return @data_pack ? \@data_pack : undef;
}

__PACKAGE__->meta->make_immutable;

1;


