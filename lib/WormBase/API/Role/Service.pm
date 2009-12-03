package WormBase::API::Role::Service;

use Moose::Role;

# Every service should provide a:
requires 'connect';    # a method for connecting to the service

# A connect method
has symbolic_name => (
    is => 'ro',
    isa => 'Str',
    documentation => 'A simple symbolic name for the service, typically a single word, e.g. "acedb"',
    );

has function => (
    is  => 'ro',
    isa => 'Str',
    required => 1,
    documentation => 'A brief description of the service',
    );

has version => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->dbh->version;
    },
    );

has dbh => (
    is => 'rw',
    );

#has conf_dir => (
#    is => 'ro',
#    );

has log => (
    is => 'ro',
    );

1;
