package WormBase::Web::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';

=head1 NAME

WormBase::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


# This could/should be created dynamically...
# All it does is stash the current requested object so that I can
# format my URLs as I choose.

# URL: 
# /rest/CLASS/NAME/REQUESTED_DATA/FORMAT
sub get_params : Chained('/') PathPart("rest") CaptureArgs(2) {

  my ($self,$c,$class,$name) = @_;
  $c->stash->{request} = $name;
  $c->stash->{class}   = $class;
  $c->log->debug("WormBase::Web::Controller::REST: $class; $name");
  # $c->log->debug($c->model(ucfirst($class)));
  # my $ace = $c->model('AceDB');
}

=head2 pages() pages_GET()

Provide a REST URI of all available pages.

 GET /rest/pages

=cut

sub pages : Path('/rest/pages') :Args(0) :ActionClass('REST') {}

sub pages_GET {
    my ($self,$c) = @_;
    my @pages = keys %{ $c->config->{pages} };
    $self->status_ok( $c, entity => \@pages );
}


=head2 widgets() widgets_GET()

Provide a REST URI of all widgets available for a given page.

 GET /rest/widgets/[PAGE]

=cut

sub widgets : Path('/rest/widgets') :Args(1) :ActionClass('REST') {}

sub widgets_GET {
    my ($self,$c,$page) = @_;
    my (@widgets) = @{ $c->config->{pages}->{$page}->{widget_order} };
    $self->status_ok( $c, entity => \@widgets );
}

=head2 widgets() widgets_GET()

Provide a REST URI of all fields for a given widget and page.

 GET /rest/fields/[WIDGET]/[PAGE]

=cut

sub fields : Path('/rest/fields') :Args(2) :ActionClass('REST') {}

sub fields_GET {
    my ($self,$c,$widget,$page) = @_;
    my @fields = eval { @{ $c->config->{pages}->{$page}->{widgets}->{$widget} }; };
    $self->status_ok( $c, entity => \@fields );
}



#sub genetic_position : Chained('get_params') PathPart('gene/genetic_position') CaptureArgs(1) ActionClass('REST') {}

=head1

sub genetic_position : Path('gene/genetic_position') CaptureArgs(1) ActionClass('REST') {}

sub genetic_position_GET {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name; 

  # Instantiate the Model
  my $model = $c->model(ucfirst('Gene'));

  $c->stash->{genetic_position} = $model->genetic_position($c);
  $c->log->debug($c->stash->{genetic_position});
  $self->status_ok( $c, entity => $c->stash->{genetic_position} );
}

=cut

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
