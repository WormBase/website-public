package WormBase::Web::Controller::REST::Gene;

use strict;
use warnings;
use base 'Catalyst::Controller::REST';

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
sub get_params : Chained('/') PathPart("rest/gene") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
  $c->log->debug("WormBase::Web::Controller::REST::Gene $name");
  # my $ace = $c->model('AceDB');
}

#sub genetic_position : Chained('get_params') PathPart('gene/genetic_position') CaptureArgs(1) ActionClass('REST') {}


#sub genetic_position : Path('genetic_position') CaptureArgs(1) ActionClass('REST') {}
#sub genetic_position : Chained('get_params') PathPart('genetic_position') ActionClass('REST') {}

#sub genetic_position_GET {
#  my ($self,$c) = @_;
#
#  # Instantiate the Model
#  my $model = $c->model(ucfirst('Gene'));
#
#  $c->stash->{genetic_position} = $model->genetic_position($c);
#  $c->log->debug($c->stash->{genetic_position});
#  $self->status_ok( $c, entity => $c->stash->{genetic_position} );
#}

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
