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
    my $page = $c->model('Schema::Page')->find({url=>"/about"});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);

}

sub about_documentation :Path('/about') :Args(1)   {
    my ($self,$c,$page) = @_;
    my $p = $c->model('Schema::Page')->find({url=>"/about/" . $page});
    my @widgets = $p->static_widgets if $p;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
#     $c->stash->{template} = "about/$page.tt2";
    $c->stash->{section} = 'resources';
    $c->stash->{title} = $page;
    $c->stash->{template} = 'about/report.tt2';
}



1;
