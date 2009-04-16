package WormBase::Web::Controller::Variation;

use strict;
use warnings;
use base 'WormBase::Web::Controller';
#use base 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Variation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub get_params : Chained('/') PathPart("variation") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
#  my $ace = $c->model('AceDB');
}

#sub get_object : Chained("/") PathPart("variation") CaptureArgs(1) {
#  my ($self,$c,$name) = @_;
#  $c->model("WormBase::Web::Model::AceDB")->get_object($c,'Variation',$name);
#}


=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
