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
sub misc :Path('/db') :Args(2)  {
    my ($self, $c, $type, $cls) = @_;
    $c->stash->{template} = 'shared/legacy.tt2';

    my $class = lc ($cls || $c->req->param('class'));
    my $name            = $c->req->param('name');

    #hack for anatomy term objects
    $class = $class . "_term" if ($class == 'anatomy');

    my $api    = $c->model('WormBaseAPI');
    my $object = $api->fetch({ class => ucfirst $class, name => $name });
    my $url;

    if ( !$object || $object == -1 ){
      my ($it,$res)= $api->xapian->search_exact($c, $name, $class);
      if($name && ($it->{pager}->{total_entries} > 1 ) && ($name ne '*') && ($name ne 'all')){
        my $o = @{$it->{struct}}[0];
        $url = $self->_get_url($c, $o->get_document->get_value(2), $o->get_document->get_value(1), $o->get_document->get_value(5));
        unless($name=~m/$o->get_document->get_value(1)/){ $url = $url;}
      }
      $url ||= $c->uri_for('/search',$class,"$name");
    }else{
      my $object_name = $object->name; #to fetch species, correct class name, etc...
      $url = $self->_get_url($c, lc $object_name->{data}->{class}, $object_name->{data}->{id}, $object_name->{data}->{taxonomy});
    }
    my $old_url = $c->req->uri->as_string;
    unless($c->req->param('redirect') || '' eq 'no'){
      $c->res->status(301);
      $c->res->redirect($url."?from=$old_url");
    }
    $c->stash->{url} = $url;
    $c->stash->{old_url} = $old_url;
    return;
}

sub _get_url {
  my ($self, $c, $class, $id, $species) = @_;
  my $url =  (defined $c->config->{sections}{species}{$class}) ? $c->uri_for('/species',$species || 'all' ,$class,$id) : $c->uri_for('/resources',$class,$id);
  return "$url";
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
