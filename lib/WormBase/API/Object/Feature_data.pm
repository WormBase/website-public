package WormBase::API::Object::Feature_data;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Feature_data

=head1 SYNPOSIS

Model for the Ace ?Feature_data class.

=head1 URL

http://wormbase.org/species/(feature_data

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


#########################
#
# The Overview widget
#
#########################

# name {}
# Supplied by Role

# method {}
# Supplied by Role

# feature {}
# This method will return a data structure with the feature associated
# with the object.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/feature

sub feature {
    my $self      = shift;
    my $object    = $self->object;

    return { data        => $self->_pack_obj($object->Feature),
	     description => 'the sequence feature', };
}

# intron { }
# This method will return a data structure with introns associated with the feature_data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/intron

sub intron {
    my $self    = shift;
    my $object  = $self->object;
    return { data        => $self->_pack_obj($object->Confirmed_intron),
	     description => 'introns associated with this object', };
}

# predicted_five_prime { }
# This method will return a data structure 
# containing objects 5' of the curent feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_five_prime

sub predicted_five_prime {
    my $self   = shift;
    my $object = $self->object;
    return { data        => $self->_pack_obj($object->Predicted_5),
	     description => 'predicted 5\' related object of the requested object' };
}

# predicted_three_prime { }
# This method will return a data structure
# containing objects 3' of the requested object.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_three_prime

sub predicted_three_prime {
    my $self    = shift;
    my $object  = $self->object;

    return { data        => $self->_pack_obj($object->Predicted_3),
	     description => 'predicted 3\' related object of requested feature', };
}

__PACKAGE__->meta->make_immutable;

1;

