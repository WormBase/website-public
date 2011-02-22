package WormBase::API::Object::Life_stage;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Life_stage

=head1 SYNPOSIS

Model for the Ace ?Life_stage class.

=head1 URL

http://wormbase.org/species/life_stage

=head1 TODO

# The original LifeStage CGI presented a number of secondary screens

# TODO: Handling of big lists of objects
# Search and browse methods

=cut

#######################################
#
# The Overview widget 
#
#######################################

=head2 name

This method will return a data structure of the 
name and ID of the requested life stage.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/name

=head4 Response example

<div class="response-example"></div>

=cut 

sub name {
    my $self   = shift;
    my $object = $self->object;
    my $data = { description => 'A life stage in the development of C. elegans',
		 data        =>  $self->_pack_obj($object) };
    return $data;
}

=head2 substages

This method will return a data structure containing
substages of the requested life stage.

=head3 PERL API

 $data = $model->substage();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/substages

=head4 Response example

<div class="response-example"></div>

=cut 

sub substages {
    my $self = shift;
    my $object = $self->object;
    my @substages = map { $self->_pack_obj($_) } $object->Sub_stage;
    return { data        => \@substages,
	     description => 'sublife stage' };
}

=head2 definition

This method will return a data structure containing
a definition of the requested life stage.

=head3 PERL API

 $data = $model->definition();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/definition

=head4 Response example

<div class="response-example"></div>

=cut 

sub definition {
    my $self = shift;
    my $object = $self->object;
    my $definition = $object->Definition;
    return { data        => "$definition" || undef,
	     description => 'brief description  of the life stage', };
}

=head2 other_name

This method will return a data structure containing
a synonyms -- if any -- of the requested life stage.

=head3 PERL API

 $data = $model->other_name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/other_name

=head4 Response example

<div class="response-example"></div>

=cut 

sub other_name {
    my $self = shift;
    my $object = $self->object;    
    my @other_names = map { $self->_pack_obj($_) } $object->Other_name;
    my $data = { data        => \@other_names,
		 description => 'other possible names for this lifestage' };
    return $data;
}

=head2 remarks

This method will return a data structure containing
curator remarks about the requested life stage.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

sub remarks {
    my $self    = shift;
    my $object  = $self->object;
    my @remarks = $object->Remark;
    
    # TODO: handling of Evidence nodes
    my $data    = { description  => 'curatorial remarks',
		    data         => \@remarks,
    };
    return $data;
}   

#######################################
#
# Expression Patterns (needs work)
#
#######################################

=head2 expression_patterns

This method will return a data structure containing
expression patterns linked to the requested life stage.

=head3 PERL API

 $data = $model->expression_patterns();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/expression_patterns

=head4 Response example

<div class="response-example"></div>

=cut 

sub expression_patterns {
    my $self = shift;
    my $object = $self->object;

    # Oy. Really? We are just displaying a count in the UI and linking to search.
    my @patterns = map { $self->_pack_objects($_) } $object->Expr_pattern;
    return { description => 'expression patterns associated with this life stage',
	     data        => \@patterns  };

}


#######################################
#
# Cells
#
#######################################

=head2 cells

This method will return a data structure containing
cells linked to the requested life stage.

=head3 PERL API

 $data = $model->cells();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cells

=head4 Response example

<div class="response-example"></div>

=cut 

sub cells {
    my $self = shift;
    my $object = $self->object;
    my @cells = $object->Cell;
    @cells = map { $self->_pack_obj($_) } @cells;
    return { description => 'cells at this lifestage',
	     data        => \@cells };
}

=head2 cell_group

This method will return a data structure containing
cell groups linked to the requested life stage.

=head3 PERL API

 $data = $model->cell_group();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cell_group

=head4 Response example

<div class="response-example"></div>

=cut 

sub cell_group {
    my $self   = shift;
    my $object = $self->shift;
    my @cell_group = map { $self->_pack_obj($_) } $object->Cell_group;
    return { description => 'The prominent cell group for this life stage',
	     data        => \@cell_group };
}

#######################################
#
# Timing
#
#######################################

=head2 contained_in_life_stage

This method will return a data structure containing
the life stages that contain the requested life stage.

=head3 PERL API

 $data = $model->contained_in_life_stage();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/contained_in_life_stage

=head4 Response example

<div class="response-example"></div>

=cut 

sub contained_in_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Contained_in;
    return { description => 'contained in life stage',
	     data        => \@stages };
}

=head2 preceded_by_life_stage

This method will return a data structure containing
the life stages that precede the requested life stage.

=head3 PERL API

 $data = $model->preceded_by_life_stage();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/preceded_by_life_stage

=head4 Response example

<div class="response-example"></div>

=cut 


sub preceded_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Preceded_by;
    return { description => 'preceded by life stage',
	     data        => \@stages  };
}

=head2 followed_by_life_stage

This method will return a data structure containing
the life stages that follow the requested life stage.

=head3 PERL API

 $data = $model->followed_by_life_stage();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

Life stage (eg embryo)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/followed_by_life_stage

=head4 Response example

<div class="response-example"></div>

=cut 

sub followed_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Followed_by;
    return { description => 'next life stage after this',
	     data        => \@stages };
}


1;












1;
