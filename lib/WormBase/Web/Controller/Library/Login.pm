package WormBase::Web::Controller::Library::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';




=head1 NAME

WormBase::Web::Controller::Library::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched WormBase::Web::Controller::Library::Login in Library::Login.');
}


=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
