package WormBase::Web::Controller::Widget;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';


sub toggle :Path('/widget/toggle')  {
    my ( $self, $c, $class, $widget_name) = @_;
    my $curr = $c->user_session->{$class}->{$widget_name};
    $curr = -1 unless defined $curr;
    $c->user_session->{$class}->{'count'} ||= 1;
    if ($curr == -1) { 
      my $count = $c->user_session->{$class}->{'count'}++; 
      $c->user_session->{$class}->{$widget_name} = $count;
    } else { 
      delete $c->user_session->{$class}->{$widget_name};
    }
}

sub order :Path('/widget/order') {
    my ($self, $c, $class, $widget_name, $order) = @_;
    if($order){
      $c->user_session->{$class}->{$widget_name} = $order;
    } else {
      $c->user_session->{$class}->{'count'} = $widget_name;
    }
}

1;