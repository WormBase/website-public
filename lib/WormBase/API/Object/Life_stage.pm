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

=head3 substages

This method will return a data structure containing
substages of the requested life stage.

=over

=item PERL API

 $data = $model->substages();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/substages

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub substages {
    my $self   = shift;
    my $object = $self->object;
    my @substages = map { $self->_pack_obj($_) } $object->Sub_stage;
    return { data        => @substages ? \@substages : undef,
	     description => 'life substage' };
}

=head3 definition

This method will return a data structure containing
a definition of the requested life stage.

=over

=item PERL API

 $data = $model->definition();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/definition

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub definition {
    my $self = shift;
    my $object = $self->object;
    my $definition = $object->Definition;
    return { data        => "$definition" || undef,
	     description => 'brief definition  of the life stage', };
}

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# Timing. These used to be in their own widget.

=head3 contained_in_life_stage

This method will return a data structure containing
the life stages that contain the requested life stage.

=over

=item PERL API

 $data = $model->contained_in_life_stage();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/contained_in_life_stage

B<Response example>

<div class="response-example"></div>

=back

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

=over

=item PERL API

 $data = $model->preceded_by_life_stage();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/preceded_by_life_stage

B<Response example>

<div class="response-example"></div>

=back

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

=over

=item PERL API

 $data = $model->followed_by_life_stage();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/followed_by_life_stage

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub followed_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Followed_by;
    return { description => 'next life stage after this',
	     data        => \@stages };
}


#######################################
#
# Expression Patterns
#
#######################################

# sub expression_patterns {}
# Supplied by Role; POD will automatically be inserted here.
# << include expression_patterns >>



#######################################
#
# Cells
#
#  Cell/Cell_group not used on the site.
#
#######################################

=head3 cells

This method will return a data structure containing
cells linked to the requested life stage.

=over

=item PERL API

 $data = $model->cells();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cells

B<Response example>

<div class="response-example"></div>

=back

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

=over

=item PERL API

 $data = $model->cell_group();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

Life stage (eg embryo)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cell_group

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub cell_group {
    my $self   = shift;
    my $object = $self->shift;
    my @cell_group = map { $self->_pack_obj($_) } $object->Cell_group;
    return { description => 'The prominent cell group for this life stage',
	     data        => \@cell_group };
}


__PACKAGE__->meta->make_immutable;

1;

