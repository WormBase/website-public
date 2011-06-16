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

sub index :Path('/about') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{template} = 'about/index.tt2';
}

sub about_documentation :Path('/about') :Args(1)   {
    my ($self,$c,$page) = @_;
    $c->stash->{template} = "about/$page.tt2";
}



1;
