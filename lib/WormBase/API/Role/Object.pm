package WormBase::API::Role::Object;

use Moose::Role;

has 'ace_object' => (
    is  => 'ro',
    isa => 'Ace::Object',
    required => 1,
    );

1;
