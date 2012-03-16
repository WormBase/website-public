package WormBase::Web::Controller::ClassicCompatibility;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

__PACKAGE__->config->{namespace} = 'db';

=head1 NAME

WormBase::Web::Controller::ClassicCompatibility - Compatibility Controller for WormBase

=head1 DESCRIPTION

Backwards compatability for old-style WormBase URIs. These are ONLY used by OLD incoming links.

=head1 METHODS

=cut

=head2 get

  GET report pages
  URL space: /db/get
  Params: name and class

Provided with a class and name via the classic /db/get script,
redirect to the correct report page.

Caveat: currently assumes Ace class is given. Requires
name & class to correspond exactly to an object in AceDB
or the lower case Ace class

=cut

sub get :Local Args(0) {
    my ($self, $c) = @_;
    $c->detach('/get');
}

# TODO: POD

sub gbrowse_popup :Path('misc/gbrowse_popup') :Args(0) {
    my ($self, $c) = @_;
    $c->detach('/gbrowse_popup');
}

=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
