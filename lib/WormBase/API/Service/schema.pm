package WormBase::API::Service::schema;

use Moose;

with 'WormBase::API::Role::Object';

use namespace::autoclean -except => 'meta';

sub index {
    my ($self) = @_;
    my $data = {};
    return $data;
}

1;
