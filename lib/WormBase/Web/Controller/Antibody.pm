package WormBase::Web::Controller::Antibody;

use strict;
use warnings;
use base 'Catalyst::Controller';

# This should be discoverable
#__PACKAGE__->config->{page_class} = 'Antibody';

sub get_params : Chained('/') PathPart("antibody") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
#  my $ace = $c->model('AceDB');
}

#sub get_object : Chained("/") PathPart("antibody") CaptureArgs(1) {
#  my ($self,$c,$name) = @_;
#  $c->model("WormBase::Web::Model::AceDB")->get_object($c,'Antibody',$name);
#}

=head1 AUTHOR

Todd W. Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
