package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expression_cluster

=head1 SYNPOSIS

Model for the Ace ?Expression_cluster class.

=head1 URL

http://wormbase.org/species/expresssion_cluster

=head1 METHODS/URIs

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



sub gene {
    my $self = shift;
    my $object = $self->object;
    my %ret;
    map { {$ret{"$_"} = $self->_pack_obj($_, $_->Public_name)}} $object->Gene;
    my $data = { description => 'The corresponding gene',
         data        =>  \%ret, 
    };
    return $data;
}

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

sub algorithm {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Algorithm',
         data        =>  $object->Algorithm, 
    };
    return $data;
}



1;
