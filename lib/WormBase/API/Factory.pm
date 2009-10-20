package WormBase::API::Factory;
use MooseX::AbstractFactory;

# Roles that the factory should implement:
implementation_does qw/WormBase::API::Role::Object/;
implementation_class_via sub { 'WormBase::API::Object::' . shift };



1;
