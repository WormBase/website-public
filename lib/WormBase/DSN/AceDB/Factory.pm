package WormBase::DSN::AceDB::Factory;

# A Factory for WormBase::DSN::AceDB::Object::*

use Moose;

has 'SUBCLASS' => (
    is => 'ro',
    required => 1
    );

has 'MSG' => (
    is => 'ro',
    required => 1,
    );

has 'acedbh' => (
    is  => 'ro',
#    isa => 'WormBase::DSN::AceDB'
    );


sub BUILD {
    my $self = shift;
#    $self->log->debug("instantiating a new ...");
    my $class = "WormBase::DSN::AceDB::Object::" . $self->SUBCLASS;
    Class::MOP::load_class($class);
    return $class->new(acedb => $self->acedbh);
#    return $self->package->new(acedbh => $self->acedbh);

}

1;
