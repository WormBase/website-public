package WormBase::Web::Controller;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#########################################
# Accessors for configuration variables #
#########################################
sub error_custom{
     my ( $self, $c, $status,$message ) = @_;
	$c->res->status($status);
	$c->error($message) ;
	$c->detach();
     
}

sub pages {
    my ( $self, $c ) = @_;
    my @pages = keys %{ $c->config->{pages} };
    return sort @pages;
}

sub widgets {
    my ( $self, $page, $c ) = @_;
    my (@widgets) = @{ $c->config->{pages}->{$page}->{widget_order} };
    return @widgets;
}

sub fields {
    my ( $self, $page, $widget, $c ) = @_;
    my @fields = eval { @{ $c->config->{pages}->{$page}->{widgets}->{$widget} }; };
#  @fields || die
#    "Check configuration for $page:$widget: all widgets specified in widget_order must exist in 'widgets'";
    return @fields;
}





1;
