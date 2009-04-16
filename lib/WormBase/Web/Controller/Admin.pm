package WormBase::Web::Controller::Admin;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

WormBase::Web::Admin - Catalyst Controller for administrative
functions at WormBase.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched WormBase::Web::Controller::Admin in Admin.');
}


=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
