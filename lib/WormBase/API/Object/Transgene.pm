package WormBase::API::Object::Transgene;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Transgene

=head1 SYNPOSIS

Model for the Ace ?Transgene class.

=head1 URL

http://wormbase.org/species/*/transgene

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

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


=head3 synonym

This method will return a data structure containing
a brief summary of the requested transgene.

=over

=item PERL API

 $data = $model->synonym();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/synonym

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub synonym {
    my $self    = shift;
    my $object  = $self->object;
    my $synonym = $object->Synonym;
    return { description => 'a synonym for the transgene',
	     data        =>  "$synonym" || undef };
}

# sub summary { }
# Supplied by Role; POD will automatically be inserted here.
# << include summary >>


=head3 driven_by_gene

This method will return a data structure containing
the gene that drives the gene.

=over

=item PERL API

 $data = $model->driven_by_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_gene

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub driven_by_gene {
    my $self = shift;
    my $object = $self->object;
    
    my $gene   = $object->Driven_by_gene;
    $gene = ($gene) ? $self->_pack_obj($gene) : undef;
    return { description => 'gene that drives the transgene',
	     data        => $gene };
}


=head3 driven_by_construct

This method will return a data structure containing
the construct driving the transgene.

=over

=item PERL API

 $data = $model->driven_by_construct();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_construct

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub driven_by_construct {
    my $self = shift;
    my $object = $self->object;
    
    my $construct = $object->Driven_by_construct;
    return { description => 'construct that drives the transgene',
	     data        => $construct || undef };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


=head3 reporter_construct

This method will return a data structure of the 
reporter construct driven by the transgene.

=over

=item PERL API

 $data = $model->reporter_construct();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub reporter_construct {
    my $self   = shift;
    my $object = $self->object;
    my %reporters;
    foreach ($object->Reporter_product) {
	if ($_ eq 'Gene') {
	    $reporters{gene} = $self->_pack_obj($_);
	} elsif ($_ eq 'Other_reporter') {	    
	    $reporters{'other reporter'} = $_->right;
	} else {
	    $reporters{$_} = "$_";
	}
    }
    
    return { description => 'reporter construct for this transgene',
	     data        => %reporters ? \%reporters : undef };
}



#######################################
#
# The Isolation Widget
#
#######################################

=head2 Isolation

=head3 author

This method will return a data structure containing
the author that constructed the transgene.

=over

=item PERL API

 $data = $model->author();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/author

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub author {
    my $self   = shift;
    my $object = $self->object;
    my $author = $object->Author;

    my $person;  # WBPeople only; Sorry, Charlie.
    if ($author) {
	$person = $author->Possible_person;
	$person = $person ? $self->_pack_obj($person,$person->Standard_name) : undef;
    }
    
    return { description => 'the person who created the transgene',
	     data        => $person };
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 clone

This method will return a data structure containing
information about the clone of this transgene.

=over

=item PERL API

 $data = $model->clone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/clone

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub clone {
    my $self = shift;
    my $object = $self->object;
    my $clone  = $object->Clone;
    $clone = $clone ? $self->_pack_obj($clone) : undef;
    return { description => 'the clone of this transgene',
	     data        => $clone };
}


=head3 fragment

This method will return a data structure containing
information about the clone fragments contained
in this transgene.

=over

=item PERL API

 $data = $model->fragment();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/fragment

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub fragment {
    my $self   = shift;
    my $object = $self->object;
    my $frag = $object->Fragment;
    return { description => 'clone fragments contained in this transgene',
	     data        => $frag || undef };
}



=head3 injected_into_strains

This method will return a data structure containing
strains that the transgene has been injected into.

=over

=item PERL API

 $data = $model->injected_into_strains();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/injected_into_strains

B<Response example>

<div class="response-example"></div>

=back

=cut 

# -not in the schema anymore? -AC
# sub injected_into_strains {
#     my $self   = shift;
#     my $object = $self->object;
#     my @cgc_strains = $object->Injected_into_CGC_strain;
#     my @data = map { $self->_pack_obj($_) } @cgc_strains;
#     push @data,map { "$_" } $object->Injected_into;
#     return { description => 'strains that the transgene has been injected into',
# 	     data        => @data ? \@data : undef};
# }

=head3 integration_method

This method will return a data structure containing
how the transgene was integrated (if it was).

=over

=item PERL API

 $data = $model->integration_method();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_by

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub integration_method {    
    my $self   = shift;
    my $object = $self->object;
    my $method = $object->Integration_method;
    return { description => 'how the transgene was integrated (if it has been)',
	     data        => $method ? $method : undef };
}

# 
=head3 integrated_at

This method will return a data structure containing
the map position of the transgene if it has been integrated.

=over

=item PERL API

 $data = $model->integrated_at();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_at

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub integrated_at {    
    my $self   = shift;
    my $object   = $self->object;
    my $position = $object->Map;

    return { description => 'map position of the integrated transgene',
	     data        => $position ? "$position" : undef};
}

=head3 rescues

This method will return a data structure containing
information about phenotypes the transgene may rescue.

=over

=item PERL API

 $data = $model->rescues();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/rescues

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rescues {    
    my $self = shift;
    my $object = $self->object;
    my @genes  = $object->Rescue;
    @genes = map {$self->pack_obj($_) } @genes;
    return { description => 'genes that may be rescued by this transgene',
	     data        => @genes ? \@genes : undef };
}



#######################################
#
# The Phenotypes widget
#
#######################################

# sub phenotypes {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes>>

# sub phenotypes_not_observed {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes_not_observed>>


#######################################
#
# The Expression widget
#
#######################################

# sub expression_patterns { }
# Supplied by Role; POD will automatically be inserted here.
# << include expression_patterns >>

=head3 marker_for

This method will return a data structure of the 
describing what the transgene is a marker for.

=over

=item PERL API

 $data = $model->marker_for();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marker_for

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub marker_for {
    my $self   = shift;
    my $object = $self->object;
    my $marker = $object->Marker_for;
    return { description => 'string decribing what the transgene is a marker for',
	     data        =>  $marker || undef };
}


=head3 marked_rearrangement

This method will return a data structure of the
rearrangmements that the transgene can be used for.

=over

=item PERL API

 $data = $model->marked_rearrangement();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene ID (gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marked_rearrangement

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub marked_rearrangement {
    my $self   = shift;
    my $object = $self->object;
    my @rearrangements = $object->Marked_rearrangement;
    @rearrangements    = map { $self->_pack_obj($_) } @rearrangements;
    return { description => 'rearrangements that the transgene can be used as a marker for',
	     data        =>  @rearrangements ? \@rearrangements : undef };
}

__PACKAGE__->meta->make_immutable;

1;

