package WormBase::Web::Controller::Expression_cluster;

use strict;
use warnings;
use parent 'Catalyst::Controller';


# This could/should be created dynamically...
# All it does is stash the current requested object so that I can
# format my URLs as I choose.
sub get_params : Chained('/') :PathPart('expression_cluster') :CaptureArgs(1) {
    my ($self,$c,$name) = @_;
    $c->stash->{request} = $name;
}



=head1 NAME

WormBase::Web::Controller::Expression_cluster - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched WormBase::Web::Controller::Expression_cluster in Expression_cluster.');
}


=head1 AUTHOR

Todd Harris,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
