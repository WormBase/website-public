package WormBase::Web::Controller::About;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
#use FindBin qw/$Bin/;

#__PACKAGE__->config->{libroot} = "$Bin/../../lib/WormBase/API";

##############################################################
#
#   Simple abut pages.
# 
##############################################################

sub about :Path('/about') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section} = 'resources';
    $c->stash->{template} = 'about/report.tt2';
    $self->_setup_page($c);
}

# Allow anything under /about to have an arbitrary number of path parts.
# Helpful for organizing things like documentation.
sub about_documentation :Path('/about') :Args   {
    my ($self,$c,@path_parts) = @_;
    $self->_setup_page($c);
    $c->stash->{section} = 'resources';
    $c->stash->{path_parts} = \@path_parts;
    $c->stash->{template} = 'about/report.tt2';
}


1;
