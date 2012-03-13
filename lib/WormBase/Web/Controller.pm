package WormBase::Web::Controller;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub _setup_page {
    my ($self, $c) = @_;
    my ($page) = $c->model('Schema::Page')->search({url=>$c->req->uri->path}, {rows=>1})->next;
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);

    my $class = lc($c->stash->{object}{name}{data}{class});
    $class ||= lc($c->req->path);
    $class =~ s/[\/_]/-/g;

    my @layouts = keys(%{$c->user_session->{'layout'}->{$class}});
    my %l;
    map {$l{$_} = $c->user_session->{'layout'}->{$class}->{$_}->{'name'};} @layouts;
    $c->stash->{layouts} = \%l;
}


1;
