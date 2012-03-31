package WormBase::Web::Controller::ClassicCompatibility;

use parent 'WormBase::Web::Controller';

use strict;
use warnings;

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


# Capture other old URLs like /db/misc, /db/gene, etc
sub misc : LocalRegex('*') CaptureArgs(2) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'shared/legacy.tt2';

    $c->stash->{original_uri} = $c->req->uri;

    my $requested_class = $c->req->param('class');
    my $name            = $c->req->param('name');

    my $api    = $c->model('WormBaseAPI');
    my $ACE2WB = $api->modelmap->ACE2WB_MAP->{class};

    # hack for locus (legacy):
    $requested_class = 'Gene' if lc $requested_class eq 'locus';

    # there may be input (perhaps external, hand-typed input or even automated
    # input from a non-WB tool) which specifies a class in the incorrect casing
    # but is otherwise legitimate (e.g. Go_term, which should be GO_term). this
    # could be a problem in those kinds of input.
    my $class = $ACE2WB->{$requested_class}
             || $ACE2WB->{lc $requested_class} # canonical Ace class
             or $c->detach('/soft_404');

    my $normed_class = lc $class;

    my $url;
    if (exists $c->config->{sections}->{species}->{$normed_class}) { # /species
        # Fetch our external model
        my $api = $c->model('WormBaseAPI');

        my $object;

        # Fetch a WormBase::API::Object::* object
        if ($name eq '*' || $name eq 'all') {
            $object = $api->instantiate_empty($class);
        }
        else {
            $object = $api->fetch({
                class => $class,
                name  => $name,
				  }) or die "Couldn't fetch an object: $!"; 
        }
	
        my $species = eval { $object->{object}->Species } || 'any';
	my ($g, $s) = $species =~ /(.).*[ _](.+)/o;
	if ($g && $s) { $species = join('_',lc($g),$s); }
	$c->stash->{request_object} = { id    => $name,
					class => $requested_class,
					label => $c->uri_for('/species', $species, $normed_class, $name),
					taxonomy => $species };
	$c->stash->{new_uri} = $c->uri_for('/species', $species, $normed_class, $name);
#        $url = $c->uri_for('/species', $species, $normed_class, $name);
    }
    else {                      # /report
	$c->stash->{new_uri} = $c->uri_for('/resources', $normed_class, $name);
#        $url = $c->uri_for('/resources', $normed_class, $name);
    }
    $c->forward('WormBase::Web::View::TT');

    # $c->res->redirect($url);
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
