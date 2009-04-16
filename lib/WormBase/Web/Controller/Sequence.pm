package WormBase::Web::Controller::Sequence;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Sequence - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# This could/should be created dynamically...
# All it does is stash the current requested object so that I can
# format my URLs as I choose.
sub get_params : Chained('/') PathPart("gene") CaptureArgs(1) {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name;
}

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
