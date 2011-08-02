package WormBase::Web::Model::Mendeley;

use strict;
use warnings;
use parent 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class => 'WormBase::Web::ThirdParty::Mendeley',
    );
    

sub mangle_arguments {
    my ($self,$args) = @_;
    return %$args;
}

1;
