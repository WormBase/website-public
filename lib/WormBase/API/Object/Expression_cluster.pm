package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expression_cluster

=head1 SYNPOSIS

Model for the Ace ?Expression_cluster class.

=head1 URL

http://wormbase.org/species/expresssion_cluster

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 gene

This method will return a data structure with genes in the expression_cluster.

=over

=item PERL API

 $data = $model->gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/gene

B<Response example>

<div class="response-example"></div>

=back

=cut

sub gene {
    my $self   = shift;
    my $object = $self->object;
    my @tag_objects = $object->Gene;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        description => 'The corresponding gene',
        data        => @data_pack    
      
	};
}	
#     my %return;
#     map {
#         { $ret{"$_"} = $self->_pack_obj( $_, $_->Public_name ) }
#     } $object->Gene;

#     };
# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 algorithm

This method will return a data structure with algorithm used to define the expression_cluster.

=over

=item PERL API

 $data = $model->algorithm();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/algorithm

B<Response example>

<div class="response-example"></div>

=back

=cut

sub algorithm {
    my $self   = shift;
    my $object = $self->object;
    my $data   = {
        description => 'Algorithm used to determine cluster',
        data        => $object->Algorithm,
    };
    return $data;
}

=head3 microarray

This method will return a data structure with microarray results from the expression_cluster.

=over

=item PERL API

 $data = $model->microarray();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/microarray

B<Response example>

<div class="response-example"></div>

=back

=cut

sub microarray {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Microarray_results;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => 'microarray results from expression cluster'
    };
}

=head3 sage_tag

This method will return a data structure with sage_tags analyzing the expression_cluster.

=over

=item PERL API

 $data = $model->sage_tag();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/sage_tag

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sage_tag {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->SAGE_tag;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => ''
    };
}

=head3 expr_pattern

This method will return a data structure with expr_patterns associated with the expression_cluster.

=over

=item PERL API

 $data = $model->expr_pattern();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/expr_pattern

B<Response example>

<div class="response-example"></div>

=back

=cut

sub expr_pattern {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Expr_pattern;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => 'expression patterns associated with this cluster'
    };
}

=head3 anatomy_term

This method will return a data structure with anatomy_terms associated with the expression_cluster.

=over

=item PERL API

 $data = $model->anatomy_term();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression_cluster id (eg [cgc5767]:cluster_88)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/anatomy_term

B<Response example>

<div class="response-example"></div>

=back

=cut

sub anatomy_term {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Anatomy_term;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => 'anatomy term annotated with this expression cluster'
    };
}

__PACKAGE__->meta->make_immutable;

1;

