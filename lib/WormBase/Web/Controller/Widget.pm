package WormBase::Web::Controller::Widget;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

sub add : Local {
    my ( $self, $c, $class, $widget_name ) = @_;
    $c->session->{$class}->{$widget_name} = 1;
}

sub remove : Local {
    my ( $self, $c, $class, $widget_name ) = @_;
    $c->session->{$class}->{$widget_name} = 0;
}

sub toggle :Path('/widget/toggle')  {
    my ( $self, $c, $class, $widget_name) = @_;
    $c->session->{$class}->{$widget_name} = (($c->session->{$class}->{$widget_name} || 0) + 1) % 2;
}

1;