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
sub misc :Path('/db') Args  {
    my ($self, $c, @args) = @_;
    my $type = shift @args;
    my $cls = shift @args;
    my $species = shift @args;
    $c->stash->{template} = 'shared/legacy.tt2';

    my $class = lc ($c->req->param('class') || $cls);
    my $name            = $c->req->param('name') || $c->req->param('query');

    #hack for anatomy term objects
    $class = $class . "_term" if ($class eq 'anatomy');
    my $url;
    if($class eq 'gbrowse'){
      $species ||= $c->req->param('source');
      $species = "c_$species" unless $species =~ m/_/;
      $url = $c->uri_for('/tools', 'genome', $class, $species, $name)->path;
    }elsif($name && ($name ne '*')){
      $url = $c->uri_for('/get', {
          class => $class,
          name => $name
      })->as_string;
    }else{
      $url = $self->_get_url($c, $class, "", 'all');
    }
    my $old_url = $c->req->uri->as_string;
    unless($c->req->param('redirect') || '' eq 'no'){
      $c->res->status(301);
      $url = $url =~ /\?/ ? $url : $url . "?from=$old_url";
      $c->res->redirect($url);
  }
    $c->stash->{url} = $url;
    $c->stash->{old_url} = $old_url;
    return;
}

sub _get_url {
  my ($self, $c, $class, $id, $species) = @_;
  my $url =  (defined $c->config->{sections}{species}{$class}) ? $c->uri_for('/species',$species || 'all' ,$class,$id) : $c->uri_for('/resources',$class,$id);
  return $url->path;
}

sub _prep_query {
  my ($self, $q, $ac) = @_;
  my $new_q = $q;
  $new_q =~ s/-/_/g;
  $new_q =~ s/\s/-/g;
  $new_q .= " $q" unless( $new_q eq $q || $ac);
  return $new_q;
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
