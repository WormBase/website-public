package WormBase::API::Role::Service;

use Moose::Role;

requires 'connect';

has symbolic_name => (
    is => 'ro',
    isa => 'Str',
    );

has version => (
    is => 'ro',
    isa => 'Str'
    );

has dbh => (
    is => 'rw',
    );


1;
