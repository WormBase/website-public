package WormBase::API::Factory;
use MooseX::AbstractFactory;

# Roles that the factory should implement:
implementation_does qw/WormBase::API::Role::Object/;

# Generate the appropriate class name
implementation_class_via sub {
    my $class = shift;
    return $class =~ /^WormBase::API::Object::/ ? $class : "WormBase::API::Object::$class";
};

1;
