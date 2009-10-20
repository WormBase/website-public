package WormBase::API::Object::Transcript;

use Moose;

with 'WormBase::API::Role::Object';

sub name {
    my $self = shift;
    my $ace  = $self->object;
#    $self->log->debug("here we are " . $self->ace_object);
    return $ace->name;
}

sub common_name {
    my $self = shift;
    my $object = $self->object;
    my $name = $object->Public_name;
    return $name;
}

1;
