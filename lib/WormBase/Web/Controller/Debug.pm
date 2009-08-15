package WormBase::Web::Controller::Debug;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Debug - Catalyst Controller

=head1 DESCRIPTION

Simple controller actions to assist in development and debugging.

=head1 METHODS

=cut


=head2 index

The debug index patch simply lists all available classes.

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched WormBase::Web::Controller::Debug in Debug.');
}

=head1 classes

Show a simple list of all available classes (pages) and their widgets

=cut

sub classes :Local :Args(0) {
    my ( $self, $c ) = @_;
    $c->response->body('Matched WormBase::Web::Controller::Debug in Debug.');
#    $c->stash->{template} = 'debug/models.tt2';
}

=head1 class

Display a detail page for a given class (page) including
demonstration links to each widget and field.

=cut


sub class :Chained : Path("classes") :Args(1) {
    my ($self,$c,$class) = @_;
    $c->stash->{page} = $class;
}    



=head1 AUTHOR

Todd Harris,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
