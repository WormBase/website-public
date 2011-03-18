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

http://wormbase.org/species/transgene

=head1 TODO

=head1 METHODS/URIs

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
    my $data = { description => 'a synonym for the transgene',
		 data        =>  "$synonym" || undef };
    return $data;
}


# sub summary { }
# Supplied by Role; POD will automatically be inserted here.
# << include summary >>


=head3 driven_by_gene

This method will return a data structure containing
information about how the transgene is expressed.

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
    $gene = ($gene) ? $self->_pack_obj($gene,$gene->Public_name) : undef;
    my $data = { description => 'gene that drives the transgene',
		 data        => $gene };
}



=head3 driven_by_construct

This method will return a data structure containing
information about how the transgene is expressed.

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
    my $data = { description => 'construct that drives the transgene',
		 data        => $construct || undef };
    return $data;
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

# sub remarks { }

sub reporter_construct {
    my $self = shift;
    my $object = $self->object;
    
    my %reporters = map { $_ => $_ } $object->Reporter_product;
    
    if ($reporters{Other_reporter}) {
	my $text = $reporters{Other_reporter}->right;
	$reporters{other} = $text;
	$reporters{Other_reporter} = undef;
    } elsif ($reporters{Gene}) {
	my $gene = $reporters{Gene}->right;
	$reporters{Gene} = $self->_pack_obj($gene,$gene->Public_name); 
    } else {	
    }
    
    my $data = { description => 'reporter construct for this transgene',
		 data        => \%reporters };
    return $data;
}



#######################################
#
# The Isolation Widget
#
#######################################

=head3 author

This method will return a data structure of the 
reporter construct driven by the transgene.

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

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
    
    my $data = { description => 'the person who created the transgene',
		 data        => $person };
    return $data;
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
    my $data = { description => 'the clone of this transgene',
		 data        => $clone };
    return $data;
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
    my $data = { description => 'clone fragments contained in this transgene',
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

sub injected_into_strains {
    my $self   = shift;
    my $object = $self->object;
    my @cgc_strains = $object->Injected_into_CGC_strain;
    my @data = map { $self->_pack_obj($_) } @cgc_strains;
    push @data,map { "$_" } $object->Injected_into;
    my $data    = { description => 'strains that the transgene has been injected into',
		    data        => @strains ? \@strains : undef};
    return $data;
}

=head3 integrated_by

This method will return a data structure containing
how the transgene was integrated (if it was).

=over

=item PERL API

 $data = $model->integrated_by();

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

sub integrated_by {    
    my $self   = shift;
    my $object = $self->object;
    my %methods = map { $_ => $_ } $object->Integrated_by;
    my @methods;
    if ($methods{Other_integration_method}) {
	my $text = $methods{Other_integration_method}->right;
	push @methods,$text;
    } 
    push @methods,keys %methods;
    my $data = { description => 'how the transgene was integrated (if it has been)',
		 data        => @methods ? \@methods : undef };
    return $data;
}


=head3 integrated_by

This method will return a data structure containing
the map position of the transgene if it has been integrated.

=over

=item PERL API

 $data = $model->integrated_by();

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

    my $data = { description => 'map position of the integrated transgene',
		 data        => $position ? "$position" : undef};
    return $data;
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
    my $data = { description => 'genes that may be rescued by this transgene',
		 data        => \@genes };
    return $data;
}



#######################################
#
# The Phenotypes widget
#
#######################################

=head3 phenotypes_observed

This method will return a data structure of the 
phenotypes associated with the transgene.

=over

=item PERL API

 $data = $model->phenotypes_observed();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/phenotypes_observed

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotypes_observed {
    my $self   = shift;
    my $object = $self->object;
    my $phenes = $self->_get_phenotype_data($object, 0);
    my $data   = { description => 'phenotypes associated with the transgene',
		   data        =>  $phenes };
    return $data;
}

=head3 phenotypes_not_observed

This method will return a data structure of the 
phenotypes NOT OBSERVED with the transgene.

=over

=item PERL API

 $data = $model->phenotypes_not_observed();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/phenotypes_not_observed

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotypes_not_observed {
    my $self   = shift;
    my $object = $self->object;
    my $phenes = $self->_get_phenotype_data($object, 1);
    my $data   = { description => 'phenotypes NOT associated with the transgene',
		   data        =>  $phenes };
    return $data;
}



#######################################
#
# The Expression widget
#
#######################################

=head3 expression_patterns

This method will return a data structure of the 
expression patterns assocaited with the transgene.

=over

=item PERL API

 $data = $model->expression_patterns();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/expression_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my @expression = $object->Expr_pattern;
    @expression = map { $self->_pack_obj($_) } @expression;
    my $data   = { description => 'expression patterns associated with the transgene',
		   data        =>  @expression ? \@expression : undef};
    return $data;
}

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
    my $data   = { description => 'stringing decribing what the transgene is a marker for',
		   data        =>  $marker || undef };
    return $data;
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
    my $data   = { description => 'rearrangements that the transgene can be used as a marker for',
		   data        =>  @rearrangements ? \@rearrangements : undef };
    return $data;
}


####################
# Internal methods
####################
sub _get_phenotype_data {    
    my ($self,$object,$not) = @_;

    my $tag;    
    if ($not) {	
	$tag = 'Phenotype_not_observed';
    } else {	
	$tag = 'Phenotype';
    }
    
    my @data;
    foreach my $phenotype ($object->$tag) {		
	my $phenotype_name = $phenotype->Primary_name;
	my $remark         = $phenotype->Remark;
	# my $paper_evidence = $phenotype->; ## at('Paper_evidence')
	
	push @data,{ phenotype => $self->_pack_obj($phenotype,$phenotype_name),
		     remark    => "$remark",
	};
    }
    return \@data;
}



1;
