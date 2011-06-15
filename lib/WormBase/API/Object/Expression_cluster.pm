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

http://wormbase.org/species/*/expresssion_cluster

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
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

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
    my $algorithm =  $object->Algorithm;
    return { description => 'Algorithm used to determine cluster',
	     data        => "$algorithm" || undef,
    };
}



#######################################
#
# The Genes widget
#
#######################################

=head2 Genes

=head3 genes

This method will return a data structure 
with genes contained in the expression cluster.

=over

=item PERL API

 $data = $model->genes();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/genes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub genes {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $self->_pack_objects($object->Gene);
    return { data        => %$data ? $data : undef,
	     description => 'genes contained in this expression cluster' };

}


#######################################
#
# The Associations widget
#
#######################################

=head2 Associations

=head3 anatomy_terms

This method will return a data structure with anatomy 
ontology terms associated with the expression cluster.

=over

=item PERL API

 $data = $model->anatomy_terms();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/anatomy_terms

B<Response example>

<div class="response-example"></div>

=back

=cut

sub anatomy_terms {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->Anatomy_term) {
	my $definition   = $_->Definition;
	push @data, {
	    anatomy_term => $self->_pack_object($_),
	    definition => "$definition",
	};
    }
    return { data        => @data ? \@data : undef,
	     description => 'anatomy terms associated with this expression cluster'
    };
}

=head3 expression_patterns
    
This method will return a data structure 
with expression patterns associated with
the expression_cluster.

=over

=item PERL API

 $data = $model->expression_patterns();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/expression_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut

sub expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $self->_pack_objects($object->Expr_pattern);
    return { data        => %$data ? $data : undef,
	     description => 'expression patterns associated with this cluster'
    };
}


#######################################
#
# The Clustered Data widget
#
#######################################

=head2 Clustered Data

=head3 microarray

This method will return a data structure with 
microarray results from the expression cluster.

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

    my @data;      
    foreach ($object->Microarray_results) {
    	my $microarray_result = $self->_pack_obj($_);
    	my $experiment = $self->_pack_obj($_->Result) if $_->Result;
    	my $minimum = $_->Min;
    	my $maximum = $_->Max;
    	
	push @data, {
	    microarray => $microarray_result,
	    experiment => $experiment,
	    minimum => "$minimum",
	    maximum => "$maximum",
	};
    }
    return { data        => @data ? \@data : undef,
	     description => 'microarray results from expression cluster'
    };
}


=head3 sage_tags

This method will return a data structure with 
sage tags analyzing the expression_cluster.

=over

=item PERL API

 $data = $model->sage_tags();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression_cluster/[cgc5767]:cluster_88/sage_tags

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $self->_pack_objects($object->SAGE_tag);
    return { data        => %$data ? $data : undef,
	     description => 'Sage tags associated with this expression_cluster'
    };
}



#######################################
#
# The References widget
#
#######################################

=head2 References

=cut

# sub references {}
# Supplied by Role; POD will automatically be inserted here.
# << include references >>


__PACKAGE__->meta->make_immutable;

1;

