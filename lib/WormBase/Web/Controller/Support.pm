package WormBase::Web::Controller::Support;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub support :Path('/support') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{section} = 'support';
    $c->stash->{template} = 'support/report.tt2';
    $self->_setup_page($c);
}

# Allow anything under /support to have an arbitrary number of path parts
sub support_documentation :Path('/support') :Args {
    my ($self, $c, @path_parts) = @_;
    $self->_setup_page($c);
    $c->stash->{section} = 'support';
    $c->stash->{path_parts} = \@path_parts;
    $c->stash->{template} = 'support/report.tt2';
}

1;
