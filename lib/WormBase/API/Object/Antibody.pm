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

http://wormbase.org/species/*/antibody

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

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>

=head3 summary

This method will return a data structure 
containing a summary of the requested antibody.

=over

=item PERL API

 $data = $model->summary();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/summary

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub summary {
    my $self   = shift;
    my $object = $self->object;
    my $summary = $object->Summary;
    return { description => 'summary description of the antibody',
	     data        => "$summary" || undef };
}


=head3 corresponding_gene

This method will return a data structure containing
the corresponding gene for this antibody.

=over

=item PERL API

 $data = $model->corresponding_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/corresponding_gene

B<Response example>

<div class="response-example"></div>

=back

=cut

sub corresponding_gene {
    my $self   = shift;
    my $object = $self->object;
    my $gene   = $object->Gene;
    return { description => 'the corresponding gene the antibody was generated against',
	     data        => $gene ? $self->_pack_obj($gene) : undef };
}

=head3 antigen

This method will return a data structure 
containing the antigen that this antibody
was generated against.

=over

=item PERL API

 $data = $model->antigen();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/antigen

B<Response example>

<div class="response-example"></div>

=back

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

=over

=item PERL API

 $data = $model->animal();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/animal

B<Response example>

<div class="response-example"></div>

=back

=cut

sub animal {
    my $self = shift;
    my $animal = $self->object->Animal;

    if ($animal eq 'Other_animal') {
        $animal = $animal->right || $animal;
    }

    return {
        description => 'the animal the antibody was generated in',
        data        => $animal && "$animal",
    };
}

=head3 clonality

This method will return a data structure containing
the clonality of this antibody.

=over

=item PERL API

 $data = $model->clonality();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/clonality

B<Response example>

<div class="response-example"></div>

=back

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

=over

=item PERL API

 $data = $model->constructed_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Antibody ID (eg [cgc2018]:mec-7)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/constructed_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub constructed_by {
    my $self      = shift;
    my $object    = $self->object;
    my $person    = $object->Person;
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

# sub expression_patterns {}
# Supplied by Role; POD will automatically be inserted here.
# << include expression_patterns >>


__PACKAGE__->meta->make_immutable;

1;

