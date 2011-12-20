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
   
    # hack for references widget
    if($page_count =~ m/references/){
      $type = 'paper';
      $page_count = 1;
    }
    if($page_count =~ m/disease/){
      $type = $page_count;
      $page_count = 1;
    }

    my $species = $c->req->param("species");
    $c->stash->{widget} = $c->req->param("widget");
    $c->stash->{nostar} = $c->req->param("nostar");

    $c->stash->{'search_guide'} = $query if($c->req->param("redirect"));

    $c->log->debug("$type search");
    my $api = $c->model('WormBaseAPI');

    $c->stash->{template} = "search/results.tt2";
    if($page_count >1) {
      $c->stash->{template} = "search/result_list.tt2";
      $c->stash->{noboiler} = 1;
    }elsif($c->req->param("inline")){
      $c->stash->{noboiler} = 1;
    }

    my $tmp_query = $query;
    $tmp_query =~ s/-/_/g;
    $tmp_query .= " $query" unless( ($query=~/^\*$/) || $tmp_query =~ /$query/ );
    $c->log->debug("search $query");
      
    my $search = $type unless($type=~/all/);
    $c->response->headers->expires(time);
    $c->response->header('Content-Type' => 'text/html');

    # if it finds an exact match, redirect to the page
    if(( !($type=~/all/) || $c->req->param("redirect")) && !(($c->req->param("all"))||($c->stash->{noboiler})) && ($page_count < 2)){
      my ($it,$res)= $api->xapian->search_exact($c, $tmp_query, $search);
      if($it->{pager}->{total_entries} == 1 ){
        my $o = @{$it->{struct}}[0];
        my $url = $self->_get_url($c, $o->get_document->get_value(2), $o->get_document->get_value(1), $o->get_document->get_value(5));
        unless($query=~m/$o->get_document->get_value(1)/){ $url = $url . "?from=search&query=$query";}
        $c->res->redirect($url, 307);  #should this be inside unless? -xq
        return;
      }
    }


    # if we're on a search page, setup the search first. Load results as ajax later.
    if( !($c->stash->{noboiler}) ) {
            $c->stash->{template} = "search/result-all.tt2";
            $c->stash->{species} = $species;
            $c->stash->{page} = $page_count;
            $c->stash->{type} = $type;
            $c->stash->{query} = $query || "*";
            $c->forward('WormBase::Web::View::TT');
            return;
    }


# 
#     my ($cache_id,$it,$cache_server) = $c->check_cache('search', $query, $page_count, $search);
#     unless($it) {  
#         $c->log->debug("conducting search -- not cached; $cache_id");
#         my $it = $api->xapian->search($c, $tmp_query, $page_count, $search);
#         $c->set_cache($cache_id, $it);
#     }

    # this is the actual search
    my $it= $api->xapian->search($c, $tmp_query, $page_count, $search, $species);

    $c->stash->{species} = $species;
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

 my $search = $type unless($type=~/all/);
 $q =~ s/-/_/g;
  my $it = $api->xapian->search_autocomplete($c, $q, $search);

  my @ret;
  foreach my $o (@{$it->{struct}}){
    my $class = $o->get_document->get_value(2);
    my $id = $o->get_document->get_value(1);
    my $url = $self->_get_url($c, $class, $id, $o->get_document->get_value(5));
    my $label = $o->get_document->get_value(6) || $id;
    my $objs = {    class   =>  $class,
                    id      =>  $id,
                    label   =>  $label,
                    url     =>  $url,
                };
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

  my $search = $type unless($type=~/all/);

  my $tmp_query = $q;
  $tmp_query =~ s/-/_/g;
  $tmp_query .= " $q" unless( ($q=~/^\*$/) || $tmp_query =~ /$q/ );

  my $count = $api->xapian->search_count($c, $tmp_query, $search, $species);
  $c->response->body("$count");
  return;
}

sub _get_url {
  my ($self, $c, $class, $id, $species) = @_;
  if(defined $c->config->{sections}{species}{$class}){
    return $c->uri_for('/species',$species || 'all' ,$class,$id)->as_string;
  }
  return $c->uri_for('/resources',$class,$id)->as_string;
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
