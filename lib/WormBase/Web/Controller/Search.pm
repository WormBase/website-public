package WormBase::Web::Controller::Search;

use strict;
use warnings;
use Moose;
use JSON::XS;
use URI::Escape;
# use String::Escape qw( printable unprintable );

BEGIN { extends 'Catalyst::Controller::REST' }


__PACKAGE__->config(
    'default'          => 'text/x-yaml',
    'stash_key'        => 'rest',
    'map'              => {
    'text/x-yaml'      => 'YAML',
    'text/html'        => 'YAML::HTML',
    'text/xml'         => 'XML::Simple',
    'application/json' => 'JSON',
    }
    );

##############################################################
#
#   Search
#   URL space : /search
#   Params    : type, query, page count
#
##############################################################
sub search :Path('/search') Args {
    my ($self, $c, @args) = @_;
    my $type = shift @args;
    my $query = shift @args;
    my $page_count = shift @args || 1;

    $type = 'all' unless $query;
   
    # hack for references widget
    if($page_count =~ m/\D/){
      $type = $page_count =~ m/references/ ? 'paper' : $page_count;
      $page_count = 1;
    }

    $c->stash->{species} = $c->req->param("species");
    $c->stash->{nostar} = $c->req->param("nostar");
    $c->stash->{'search_guide'} = $query if($c->req->param("redirect"));
    $c->stash->{opt_q} = $c->req->param("q");

    $c->response->headers->expires(time);
    $c->response->header('Content-Type' => 'text/html');

    my $api = $c->model('WormBaseAPI');

    my $tmp_query = $self->_prep_query($query);
    $c->log->debug("search $tmp_query");
      
    my $search = $type unless($type=~/all/);

    if($page_count>1) {
      $c->stash->{template} = "search/result_list.tt2";
      $c->stash->{noboiler} = 1;
    }elsif($c->req->param("inline") || $c->req->param("widget")){
      $c->stash->{template} = "search/results.tt2";
      $c->stash->{noboiler} = 1;
      $c->stash->{widget} = $c->req->param("widget");
      $c->stash->{req_class} = $c->req->param("class");
    }else{
      if(( !($type=~/all/) || $c->req->param("redirect")) && !($c->req->param("all"))){
      # if it finds an exact match, redirect to the page 
        my $it = $api->xapian->search_exact($c, $tmp_query, $search);
        if($it->{mset}->size() == 1){
          my $o = @{$it->{struct}}[0];
          my $objs = $api->xapian->_pack_search_obj($c, $o->get_document);
          my $url = $self->_get_url($c, $objs->{class}, $objs->{id}, $objs->{taxonomy}, $objs->{coord}->{start});
          unless($query=~m/$o->get_document->get_value(1)/){ $url = $url . "?query=$query";}
          $c->res->redirect($url, 307);
          return;
        }
      }

      # if we're on a search page, setup the search first. Load results as ajax later.
      #   - try to redirect to exact match first
      $c->stash->{template} = "search/result-all.tt2";
      $c->stash->{page} = $page_count;
      $c->stash->{type} = $type;
      $c->stash->{query} = $query  || "*";
      $c->forward('WormBase::Web::View::TT');
      return;
    }

    # this is the actual search
    my $it= $api->xapian->search($c, $tmp_query, $page_count, $search, $c->stash->{species});

    $c->stash->{page} = $page_count;
    $c->stash->{type} = $type;
    $c->stash->{count} = $it->{pager}->{total_entries}; 
    my @ret = map { $api->xapian->_get_obj($c, $_->get_document ) } @{$it->{struct}}; #see if you can cache @ret
    $c->stash->{results} = \@ret;
    $c->stash->{querytime} = $it->{querytime};
    $c->stash->{query} = $query || "*";
    $c->forward('WormBase::Web::View::TT');
    return;
}

sub search_autocomplete :Path('/search/autocomplete') :Args(1) {
  my ($self, $c, $type) = @_;
  my $q = $c->req->param("term");
  $c->stash->{noboiler} = 1;
  $c->log->debug("autocomplete search: $q, $type");
  my $api = $c->model('WormBaseAPI');

  $q = $self->_prep_query($q, 1);
  my $it = $api->xapian->search_autocomplete($c, $q, ($type=~/all/) ? undef : $type);

  my @ret;
  foreach my $o (@{$it->{struct}}){
    my $objs = $api->xapian->_pack_search_obj($c, $o->get_document);
    $objs->{url} = $self->_get_url($c, $objs->{class}, $objs->{id}, $objs->{taxonomy}, $objs->{coord}->{start});
    push(@ret, $objs);
  }

  $c->req->header('Content-Type' => 'application/json');
  $c->response->header('Content-Type' => 'application/json');
  $self->status_ok(
      $c,
      entity =>  \@ret,
  );
  return;
}

sub search_count :Path('/search/count') :Args(3) {
  my ($self, $c, $species, $type, $q) = @_;

  $c->stash->{noboiler} = 1;
  my $api = $c->model('WormBaseAPI');

  my $tmp_query = $self->_prep_query($q);
  my $count = $api->xapian->search_count($c, $tmp_query, ($type=~/all/) ? undef : $type, $species);
  $c->response->body("$count");
  return;
}

sub _get_url {
  my ($self, $c, $class, $id, $species, $start) = @_;
  my $url;
  if($start){
    $url = $c->uri_for('/tools', 'genome', 'gbrowse', $species)->path . '?name=' . $class . ":" . $id;
  }elsif(defined $c->config->{sections}{species}{$class}){
    $url = $c->uri_for('/species',$species || 'all' ,$class,$id)->path;
  }elsif($class eq 'page'){
    $url = $id;
  }
  $url ||= $c->uri_for('/resources',$class,$id)->path;
  return "$url";
}

sub _prep_query {
  my ($self, $q, $ac) = @_;
  my $new_q = $q;
  $new_q =~ s/-/_/g;
  $new_q =~ s/\s/-/g;
  $new_q .= " $q" unless( $new_q eq $q || $ac);
  return $new_q;
}



=head1 NAME

WormBase::Web::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
