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

=head3 name

This method will return a data structure of the 
name and ID of the requested life stage.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/name

=head5 Response example

<div class="response-example"></div>

=cut 

# Provided by Object.pm; retain pod for complete documentation of the API
# sub name { }

=head3 substages

This method will return a data structure containing
substages of the requested life stage.

=head4 PERL API

 $data = $model->substages();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/substages

=head5 Response example

<div class="response-example"></div>

=cut 

sub substages {
    my $self = shift;
    my $object = $self->object;
    my @substages = map { $self->_pack_obj($_) } $object->Sub_stage;
    return { data        => \@substages,
	     description => 'sublife stage' };
}

=head3 definition

This method will return a data structure containing
a definition of the requested life stage.

=head4 PERL API

 $data = $model->definition();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/definition

=head5 Response example

<div class="response-example"></div>

=cut 

sub definition {
    my $self = shift;
    my $object = $self->object;
    my $definition = $object->Definition;
    return { data        => "$definition" || undef,
	     description => 'brief definition  of the life stage', };
}

=head3 other_names

This method will return a data structure containing
a synonyms -- if any -- of the requested life stage.

=head4 PERL API

 $data = $model->other_names();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/other_names

=head5 Response example

<div class="response-example"></div>

=cut 

# Provided by Object.pm; retain POD for completeness of documentation.
# sub other_names {} 


=head3 remarks

This method will return a data structure containing
curator remarks about the requested life stage.

=head4 PERL API

 $data = $model->remarks();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/remarks

=head5 Response example

<div class="response-example"></div>

=cut 

# Provided by Object.pm, pod retained for completeness
# sub remarks { }

#######################################
#
# Expression Patterns (needs work)
#
#######################################

=head3 expression_patterns

This method will return a data structure containing
expression patterns linked to the requested life stage.

=head4 PERL API

 $data = $model->expression_patterns();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/expression_patterns

=head5 Response example

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

=head3 cells

This method will return a data structure containing
cells linked to the requested life stage.

=head4 PERL API

 $data = $model->cells();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cells

=head5 Response example

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

=head3 cell_group

This method will return a data structure containing
cell groups linked to the requested life stage.

=head4 PERL API

 $data = $model->cell_group();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cell_group

=head5 Response example

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

=head3 contained_in_life_stage

This method will return a data structure containing
the life stages that contain the requested life stage.

=head4 PERL API

 $data = $model->contained_in_life_stage();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/contained_in_life_stage

=head5 Response example

<div class="response-example"></div>

=cut 

sub contained_in_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Contained_in;
    return { description => 'contained in life stage',
	     data        => \@stages };
}

=head3 preceded_by_life_stage

This method will return a data structure containing
the life stages that precede the requested life stage.

=head4 PERL API

 $data = $model->preceded_by_life_stage();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/preceded_by_life_stage

=head5 Response example

<div class="response-example"></div>

=cut 


sub preceded_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Preceded_by;
    return { description => 'preceded by life stage',
	     data        => \@stages  };
}

=head3 followed_by_life_stage

This method will return a data structure containing
the life stages that follow the requested life stage.

=head4 PERL API

 $data = $model->followed_by_life_stage();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

Life stage (eg embryo)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/followed_by_life_stage

=head5 Response example

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
