package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The name of the expression cluster',
         data        => $self->_pack_obj($object),
    };
    return $data;
}

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

sub description {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Description',
         data        =>  $object->Description, 
    };
    return $data;
}

sub remark {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'remark on teh expression cluster',
         data        =>  $object->Remark, 
    };
    return $data;
}

sub algorithm {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Algorithm',
         data        =>  $object->Algorithm, 
    };
    return $data;
}



1;