package WormBase::Test::CHI::Driver::Couch;

use strict;
use warnings;
use CHI::Test;
use Data::Dumper;
use parent 'CHI::t::Driver';

sub new_cache_options {
    my $self = shift;

    return (
        $self->SUPER::new_cache_options,
        driver_class  => 'WormBase::CHI::Driver::Couch',
    );
}

sub testing_driver_class {
    return 'WormBase::CHI::Driver::Couch';
}

1;
