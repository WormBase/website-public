package WormBase::API::Service::aql_wql;

use Moose;

use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';

sub index {}

sub run {}

__PACKAGE__->meta->make_immutable;

1;
