package WormBase::Web::Controller::Search;

use strict;
use warnings;
use Moose;
use JSON::XS;
use URI::Escape;
use Text::CSV;
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
    'text/csv'         => [ 'View', 'CSV' ],
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
    unless($page_count =~ m/\d|^all$/){
      $type = $page_count =~ m/references/ ? 'paper' : $page_count;
      $page_count = 1;
    }

    $c->stash->{species} = $c->req->param("species");
    $c->stash->{nostar} = $c->req->param("nostar");
    $c->stash->{'search_guide'} = $query if($c->req->param("redirect"));
    $c->stash->{opt_q} = $c->req->param("q");

    $page_count = 'all' if($c->req->param("download"));

    $c->response->headers->expires(time);
    my $headers = $c->req->headers;
    my $content_type 
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'text/html';
    $c->response->header( 'Content-Type' => $content_type );

    my $api = $c->model('WormBaseAPI');

    my $tmp_query = $self->_prep_query($query);
    $c->log->debug("search $tmp_query");
      
    my $search = $type unless($type=~/all/);

    if($page_count>1 || $page_count eq 'all' || $content_type ne 'text/html') {
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
    my ($it, $error) = $api->xapian->search($c, $tmp_query, $page_count, $search, $c->stash->{species});

    $c->stash->{page} = $page_count;
    $c->stash->{type} = $type;
    $c->stash->{count} = $api->xapian->search_count($c, $tmp_query, $search, $c->stash->{species});
    $c->stash->{error} = $error;
    my @ret = map { $api->xapian->_get_obj($c, $_->get_document ) } @{$it->{struct}}; #see if you can cache @ret
    $c->stash->{results} = \@ret;
    $c->stash->{querytime} = $it->{querytime};
    $c->stash->{query} = $query || "*";

    if ( $content_type eq 'text/html' ) {
      $c->forward('WormBase::Web::View::TT');
      return;
    }

    # Change the data structure a bit so the CSV converter can read it
    if ( $content_type eq 'text/csv' ) {
      my %seen;
      @ret = map { 
          my $ret = { id => $_->{name}->{id}, 
                      label => $_->{name}->{label},
                      class => $_->{name}->{class},
                      taxonomy => $_->{taxonomy}->{genus} . ' ' . $_->{taxonomy}->{species}};
          foreach my $key (keys %{$_}){
            if (ref($_->{$key}) eq 'ARRAY'){
              $ret->{$key} = join(', ', map { if(ref($_) eq 'HASH'){$_->{label}}else{$_ || 1}} @{$_->{$key}});
              $seen{$key} = 1;
            }
          }
          $ret;
        } @ret;

      my @columns = (('id', 'label', 'class', 'taxonomy'), keys %seen);
      # unshift(@columns, ('id', 'label', 'class', 'taxonomy'));
      $c->stash ( data => \@ret, 
                  columns => \@columns, 
                  filename => "$query\_$type\_" . $c->stash->{species} . $api->version . ".csv" 
                  );
    }

    $self->status_ok(
        $c,
        entity => {
            page  => $c->stash->{page},
            type   => $c->stash->{type},
            count   => $c->stash->{count},
            results   => $c->stash->{results},
            query   => $c->stash->{query},
            species   => $c->stash->{species},
            uri    => $c->req->path,
        }
    );
}

sub search_git :Path('/search/issue') :Args(2) {
  my ($self, $c, $query, $page_count) = @_;

    $c->response->headers->expires(time);
    my $headers = $c->req->headers;
    my $content_type 
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'text/html';
    $c->response->header( 'Content-Type' => $content_type );

    my $state = $c->req->param("state") || 'open';
    $c->stash->{state} = $state;

    $page_count ||= 1;
    if($page_count>1) {
      $c->stash->{template} = "search/result_list.tt2";
    }else{
      $c->stash->{template} = "search/results.tt2";
    }

    if($query =~/all|^\*$/){
      $query = undef;
    }

    $c->stash->{page} = $page_count;
    $c->stash->{type} = 'issue';
    $c->stash->{noboiler} = 1;

    my $url     = "https://api.github.com/" . ($query ? "legacy/issues/search/" . $c->config->{github_repo} . "/" . ($state || 'open') . "/$query" : "repos/" . $c->config->{github_repo} . "/issues");
    $url .= "?page=" . ($page_count) . ($state && !$query ? '&state=' . $state : '');
    my $path = WormBase::Web->path_to('/') . '/credentials';
    my $token = `cat $path/github_token.txt`;
    chomp $token;
    return unless $token;
    my $json         = new JSON;
    my $data = {};

    my $req = HTTP::Request->new(GET => $url);
    $req->content_type('application/json');
    $req->header('Authorization' => "token $token");

    my $request_json = $json->encode($data);
    $req->content($request_json);

    # Send request, get response.
    my $lwp       = LWP::UserAgent->new;
    my $response  = $lwp->request($req) or $c->log->debug("Couldn't POST");
    my $response_json = $response->content;
    my $parsed    = $json->allow_nonref->utf8->relaxed->decode($response_json);
    my $results = $query ? $parsed->{issues} : $parsed;
    $c->stash->{results} = $results;
    $c->stash->{no_count} = 1;
    $c->stash->{count} = @$results > 29 ? 1000 : 0;

    $c->stash->{query} = $query || "*";


    if ( $content_type eq 'text/html' ) {
      $c->forward('WormBase::Web::View::TT');
      return;
    }

    $self->status_ok(
        $c,
        entity => {
            page  => $c->stash->{page},
            type   => $c->stash->{type},
            count   => $c->stash->{count},
            results   => $c->stash->{results},
            query   => $c->stash->{query},
            state   => $c->stash->{state},
            uri    => $c->req->path,
        }
    );
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
  my $cache = ($q =~ /^all|\*$/);

  my $key = join('_', $species, $type, 'count');
  my ( $cached_data, $cache_source ) = $c->check_cache($key) if $cache;

  if($cached_data){
    $c->response->status(200);
    $c->response->body($cached_data);
    $c->detach();
    return;
  }

  my $tmp_query = $self->_prep_query($q);
  my $count = $api->xapian->search_count($c, $tmp_query, ($type=~/all/) ? undef : $type, $species);
  $c->response->body("$count");

  $c->set_cache($key => "$count") if $cache;
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
  return "*" unless $q;
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
