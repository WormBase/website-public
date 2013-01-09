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

#######################################
#
# INSTANCE METHODS
#
#######################################

#######################################
#
# The Overview widget 
#
#######################################

# name { }
# Supplied by Role

# substages { }
# This method will return a data structure containing
# substages of the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/substages

sub substages {
    my $self   = shift;
    my $object = $self->object;
    my @substages = map { $self->_pack_obj($_) } $object->Sub_stage;
    return { data        => @substages ? \@substages : undef,
	     description => 'life substage' };
}

# definition { }
# This method will return a data structure containing
# a definition of the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/definition

sub definition {
    my $self = shift;
    my $object = $self->object;
    my $definition = $object->Definition;
    return { data        => "$definition" || undef,
	     description => 'brief definition  of the life stage', };
}

# other_names { }
# Supplied by Role

# remarks {}
# Supplied by Role

# contained_in_life_stage { }
# This method will return a data structure containing
# the life stages that contain the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/contained_in_life_stage

sub contained_in_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Contained_in;
    return { description => 'contained in life stage',
	     data        => @stages ? \@stages : undef };
}

# preceded_by_life_stage { }
# This method will return a data structure containing
# the life stages that precede the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/preceded_by_life_stage

sub preceded_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Preceded_by;
    return { description => 'preceded by life stage',
	     data        => @stages ? \@stages : undef };
}

# followed_by_life_stage { }
# This method will return a data structure containing
# the life stages that follow the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/followed_by_life_stage

sub followed_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Followed_by;
    return { description => 'next life stage after this',
	     data        => @stages ? \@stages : undef };
}


#######################################
#
# Expression Patterns
#
#######################################

# expression_patterns {}
# Supplied by Role


#######################################
#
# Cells
#
#  Cell/Cell_group not used on the site.
#
#######################################

# cells { }
# This method will return a data structure containing
# cells linked to the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cells

sub cells {
    my $self = shift;
    my $object = $self->object;

    my @cells = map { "$_" } $object->Cell;
    return { description => 'cells at this lifestage',
	     data        => @cells ? \@cells : undef };
}

# cell_group { }
# This method will return a data structure containing
# cell groups linked to the requested life stage.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/life_stage/embryo/cell_group

sub cell_group {
    my $self   = shift;
    my $object = $self->object;
    my @cell_group = map { "$_" } $object->Cell_group;
    return { description => 'The prominent cell group for this life stage',
	     data        => @cell_group ? \@cell_group : undef };
}


__PACKAGE__->meta->make_immutable;

1;

