package WormBase::API::Object::Antibody;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Antibody

=head1 SYNPOSIS

Model for the Ace ?Antibody class.

=head1 URL

http://wormbase.org/species/antibody

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

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>

=head3 summary

This method will return a data structure 
containing a summary of the requested antibody.

=head4 PERL API

 $data = $model->summary();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/summary

=head5 Response example

<div class="response-example"></div>

=cut 

sub summary {
    my $self = shift;
    my $object = $self->object;
    my $summary = $object->Summary;
    return { description => 'summary of the antibody',
	     data        => "$summary" or undef };
}








=head3 corresponding_gene

This method will return a data structure containing
the corresponding gene for this antibody.

=head4 PERL API

 $data = $model->corresponding_gene();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/corresponding_gene

=head5 Response example

<div class="response-example"></div>

=cut

sub corresponding_gene {
    my $self   = shift;
    my $object = $self->object;
    my $gene   = $object->Gene;
    return { description => 'the corresponding gene the antibody was generated against',
	     data        => $gene ? $self->_pack_obj($gene,$gene->Public_name) : undef };
}

=head3 antigen

This method will return a data structure 
containing the antigen that this antibody
was generated against.

=head4 PERL API

 $data = $model->antigen();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/antigen

=head5 Response example

<div class="response-example"></div>

=cut

sub antigen {
    my $self   = shift;
    my $object = $self->object;
    my ($type,$comment) = $object->Antigen->row if $object->Antigen;
    $type =~ s/_/ /g;
    return { description => 'the type and decsription of antigen this antibody was generated against',
	     data        => { type    => "$type" || undef,
			      comment => "$comment" || undef },
    };
}

=head3 animal

This method will return a data structure containing
the animal the antibody was generated.

=head4 PERL API

 $data = $model->animal();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/animal

=head5 Response example

<div class="response-example"></div>

=cut

sub animal {    
    my $self = shift;
    my $object = $self->object;
    my $animal = $object->Animal;

    if ($animal eq 'Other_animal') {
	my $data = $animal->right;
	$animal  = $data if $data;
    }
    return { description => 'the animal the antibody was generated in',
	     data        => "$animal" or undef };
}

=head3 clonality

This method will return a data structure containing
the clonality of this antibody.

=head4 PERL API

 $data = $model->clonality();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/clonality

=head5 Response example

<div class="response-example"></div>

=cut

sub clonality {
    my $self      = shift;
    my $object    = $self->object;
    my $clonality = $object->Clonality;
    return { description => 'the clonality of the antibody',
	     data        => "$clonality" || undef };
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>


=head3 constructed_by

This method will return a data structure containing
the person who isolated the antibody.

=head4 PERL API

 $data = $model->constructed_by();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/constructed_by

=head5 Response example

<div class="response-example"></div>

=cut

sub constructed_by {
    my $self      = shift;
    my $object    = $self->object;
    my $person    = $object->Person
    return { description => 'the person who constructed the antibody',
	     data        => $person ? $self->_pack_obj($person,$person->Standard_name) : undef };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>



#######################################
#
# The Expression widget
#
#######################################

=head3 expression_patterns

This method will return a data structure containing
information on expression patterns generated by this antibody.

=head4 PERL API

 $data = $model->expression_patterns();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

An Antibody ID (eg [cgc2018]:mec-7)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/expression_patterns

=head5 Response example

<div class="response-example"></div>

=cut

sub expression_patterns {
    my $self = shift;
    my $antibody = $self->object;
    my @data;
    my @expr_patterns = $antibody->Expr_pattern;
    
    foreach ($antibody->Expr_pattern) {	
	my $author  = $_->Author || ''; ## data for link to be added(?)
	my $pattern = $_->Pattern || $_->Subcellular_localization || $_->Remark;

	
	push @data, {
	    expression_pattern => $self->_pack_obj($_),
	    description        => "$pattern" or undef,
	    author             => "$author" or undef,
	};
    }
    return { description => 'expression patterns using the antibody',
	     data        => @data ? \@data : undef };
}

1;
