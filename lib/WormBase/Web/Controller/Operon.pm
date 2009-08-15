package WormBase::Web::Controller::Operon;

use strict;
use warnings;
#use base 'Catalyst::Controller';
use parent 'WormBase::Web::Controller';

__PACKAGE__->config( class => 'Operon');

=head1 NAME

WormBase::Web::Controller::Operon - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub get_params : Chained('/') PathPart("operon") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
}

#sub get_object : Chained("/") PathPart("operon") CaptureArgs(1) {
#  my ($self,$c,$name) = @_;
#  $c->model("WormBase::Web::Model::AceDB")->get_object($c,'Operon',$name);
#}



=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
