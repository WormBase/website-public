package WormBase::API::Object::Microarray_results;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod 

=head1 NAME

WormBase::API::Object::Microarray_results

=head1 SYNPOSIS

Model for the Ace ?Microarray_results class.

=head1 URL

http://wormbase.org/species/microarray_results

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


sub gene {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The corresponding gene',
         data        =>  $self->_pack_obj($object->Gene), 
    };
    return $data;
}

sub cds {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The corresponding cds',
         data        => $self->_pack_obj($object->CDS),
    };
    return $data;
}



__PACKAGE__->meta->make_immutable;

1;

