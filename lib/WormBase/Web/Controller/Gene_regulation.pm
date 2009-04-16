package WormBase::Web::Controller::Gene_regulation;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Gene_regulation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub get_params : Chained('/') PathPart("gene_regulation") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
#  my $ace = $c->model('AceDB');
}


#sub get_object : Chained("/") PathPart("gene_regulation") CaptureArgs(1) {
#  my ($self,$c,$name) = @_;
#  $c->model("WormBase::Web::Model::AceDB")->get_object($c,'Gene_regulation',$name);
#}

=head1 AUTHOR

Todd W. Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
