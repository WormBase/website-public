package WormBase::API::Role::Service;

use Moose::Role;

# Every Service should implement a connect method
requires 'connect';

has symbolic_name => (
    is => 'ro',
    isa => 'Str',
    documentation => 'A simple symbolic name for the service, typically a single word, e.g. "acedb"',
    );

has version => (
    is => 'ro',
    isa => 'Str'
    );

has dbh => (
    is => 'rw',
    );


1;
