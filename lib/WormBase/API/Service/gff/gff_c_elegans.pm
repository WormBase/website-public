package WormBase::API::Service::gff::gff_c_elegans;

use Moose;
use Bio::DB::GFF;

with 'WormBase::API::Role::Service::gff';    # Must come first as it provides connect();
with 'WormBase::API::Role::Service';
with 'WormBase::API::Role::Logger';

has 'species' => (
    is => 'ro',
    isa => 'Str',
    default => 'c_elegans',
    );



1;
