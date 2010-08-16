package WormBase::API::Object::Microarray_results;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The name of the Microarray result',
         data        => $self->_pack_obj($object),
    };
    return $data;
}

sub gene {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The corresponding gene',
         data        =>  $self->_pack_obj($object->Gene, $object->Gene->Public_name), 
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



1;