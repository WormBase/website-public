package WormBase::API::Role::Object;

use Moose::Role;

has 'object' => (
    is  => 'ro',
    isa => 'Ace::Object',
    required => 1,
    );

has 'dsn' => (
    is  => 'ro',
    isa => 'HashRef',
    required => 1,
    );

sub gff_dsn {
    my $self    = shift;
    my $species = shift;
    return $self->dsn->{"gff_".$species}; 
}
1;
