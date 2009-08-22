package WormBase::API::Object::Gene;

use Moose;

with 'WormBase::API::Role::Object';

sub name {
    my $self = shift;
    my $ace  = $self->ace_object;
#    $self->log->debug("here we are " . $self->ace_object);
    return $ace->name;
}

1;
