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

has log => (
    is => 'ro',
    );


sub gff_dsn {
    my $self    = shift;
    my $species = shift || $self->parsed_species;
    return $self->dsn->{"gff_".$species}; 
}

sub ace_dsn{
    my $self    = shift;
    return $self->dsn->{"acedb"}; 
}


1;
