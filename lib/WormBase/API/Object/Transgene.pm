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

=cut

#######################################
#
# The Overview widget 
#
#######################################

=head2 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head4 Response example

<div class="response-example"></div>

=cut 

sub name {
    my $self   = shift;
    my $object = $self->object;
    my $data = { description => 'the name and internal ID of a transgene',
		 data        =>  $self->_pack_obj($object) };
    return $data;
}

=head2 synonym

This method will return a data structure containing
a brief summary of the requested transgene.

=head3 PERL API

 $data = $model->synonym();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/synonym

=head4 Response example

<div class="response-example"></div>

=cut 

sub synonym {
    my $self    = shift;
    my $object  = $self->object;
    my $synonym = $object->Synonym;
    my $data = { description => 'a synonym for the transgene',
		 data        =>  "$synonym" || undef };
    return $data;
}

=head2 summary

This method will return a data structure containing
a brief summary of the requested transgene.

=head3 PERL API

 $data = $model->summary();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/summary

=head4 Response example

<div class="response-example"></div>

=cut 

sub summary {
    my $self   = shift;
    my $object = $self->object;
    my $summary = $object->Summary;
    my $data = { description => 'a brief summary of the transgene',
		 data        => "$summary" || undef };
    return $data;
}

=head2 driven_by_gene

This method will return a data structure containing
information about how the transgene is expressed.

=head3 PERL API

 $data = $model->driven_by_gene();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_gene

=head4 Response example

<div class="response-example"></div>

=cut 

sub driven_by_gene {
    my $self = shift;
    my $object = $self->object;
    
    my $gene   = $object->Driven_by_gene;
    $gene = ($gene) ? $self->_pack_obj($gene,$gene->Public_name) : undef;
    my $data = { description => 'gene that drives the transgene',
		 data        => $gene };
}



=head2 driven_by_construct

This method will return a data structure containing
information about how the transgene is expressed.

=head3 PERL API

 $data = $model->driven_by_construct();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_construct

=head4 Response example

<div class="response-example"></div>

=cut 

sub driven_by_construct {
    my $self = shift;
    my $object = $self->object;
    
    my $construct = $object->Driven_by_construct;
    my $data = { description => 'construct that drives the transgene',
		 data        => $construct || undef };
    return $data;
}

# Provided by Object.pm, pod retained for documentation

=head2 remarks

This method will return a data structure containing
curator remarks about the transgene.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene (eg gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }

=head2 reporter_construct

This method will return a data structure of the 
reporter construct driven by the transgene.

=head3 PERL API

 $data = $model->reporter_construct();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

=head4 Response example

<div class="response-example"></div>

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
    } else { }
      
    my $data = { description => 'reporter construct for this transgene',
		 data        => \%reporters };
    return $data;
}



#######################################
#
# The Isolation Widget
#
#######################################

=head2 author

This method will return a data structure of the 
reporter construct driven by the transgene.

=head3 PERL API

 $data = $model->author();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

=head4 Response example

<div class="response-example"></div>

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

# laboratory() is provided by Object.pm. Documentation
# duplicated here for completeness of API

=head2 laboratory

This method will return a data structure containing
information on the laboratory where the transgene was isolated.

=head3 PERL API

 $data = $model->laboratory();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/laboratory

=head4 Response example

<div class="response-example"></div>

=cut 


=head2 clone

This method will return a data structure containing
information about the clone of this transgene.

=head3 PERL API

 $data = $model->clone();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/clone

=head4 Response example

<div class="response-example"></div>

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


=head2 fragment

This method will return a data structure containing
information about the clone fragments contained
in this transgene.

=head3 PERL API

 $data = $model->fragment();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/fragment

=head4 Response example

<div class="response-example"></div>

=cut 

sub fragment {
    my $self   = shift;
    my $object = $self->object;
    my $frag = $object->Fragment;
    my $data = { description => 'clone fragments contained in this transgene',
		 data        => $frag || undef };
}



=head2 injected_into_strains

This method will return a data structure containing
strains that the transgene has been injected into.

=head3 PERL API

 $data = $model->injected_into_strains();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/injected_into_strains

=head4 Response example

<div class="response-example"></div>

=cut 

sub injected_into_strains {
    my $self   = shift;
    my $object = $self->object;
    my @strains = $object->Injected_into_CGC_strain;
    @strains    = map { $self->_pack_obj($_) } @strains;
    push @strains,$object->Injected_into;
    my $data    = { description => 'strains that the transgene has been injected into',
		    data        => @strains ? \@strains : undef};
    return $data;
}

=head2 integrated_by

This method will return a data structure containing
how the transgene was integrated (if it was).

=head3 PERL API

 $data = $model->integrated_by();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_by

=head4 Response example

<div class="response-example"></div>

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


=head2 integrated_by

This method will return a data structure containing
the map position of the transgene if it has been integrated.

=head3 PERL API

 $data = $model->integrated_by();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_at

=head4 Response example

<div class="response-example"></div>

=cut 

sub integrated_at {    
    my $self   = shift;
    my $object   = $self->object;
    my $position = $object->Map;

    my $data = { description => 'map position of the integrated transgene',
		 data        => "$position" };
    return $data;
}

=head2 rescues

This method will return a data structure containing
information about phenotypes the transgene may rescue.

=head3 PERL API

 $data = $model->rescues();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/rescues

=head4 Response example

<div class="response-example"></div>

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

=head2 phenotypes_observed

This method will return a data structure of the 
phenotypes associated with the transgene.

=head3 PERL API

 $data = $model->phenotypes_observed();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/phenotypes_observed

=head4 Response example

<div class="response-example"></div>

=cut 

sub phenotypes_observed {
    my $self   = shift;
    my $object = $self->object;
    my $phenes = $self->_get_phenotype_data($object, 0);
    my $data   = { description => 'phenotypes associated with the transgene',
		   data        =>  $phenes };
    return $data;
}

=head2 phenotypes_not_observed

This method will return a data structure of the 
phenotypes NOT OBSERVED with the transgene.

=head3 PERL API

 $data = $model->phenotypes_not_observed();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/phenotypes_not_observed

=head4 Response example

<div class="response-example"></div>

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

=head2 expression_patterns

This method will return a data structure of the 
expression patterns assocaited with the transgene.

=head3 PERL API

 $data = $model->expression_patterns();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/expression_patterns

=head4 Response example

<div class="response-example"></div>

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

=head2 marker_for

This method will return a data structure of the 
describing what the transgene is a marker for.

=head3 PERL API

 $data = $model->marker_for();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marker_for

=head4 Response example

<div class="response-example"></div>

=cut 

sub marker_for {
    my $self   = shift;
    my $object = $self->object;
    my $marker = $object->Marker_for;
    my $data   = { description => 'stringing decribing what the transgene is a marker for',
		   data        =>  $marker || undef };
    return $data;
}


=head2 marked_rearrangement

This method will return a data structure of the
rearrangmements that the transgene can be used for.

=head3 PERL API

 $data = $model->marked_rearrangement();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marked_rearrangement

=head4 Response example

<div class="response-example"></div>

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
