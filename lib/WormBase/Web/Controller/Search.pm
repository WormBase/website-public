package WormBase::Web::Controller::Search;

use strict;
use warnings;
use Moose;
use JSON::XS;

BEGIN { extends 'Catalyst::Controller::REST' }


__PACKAGE__->config(
    'default' => 'JSON',
    'stash_key' => 'rest',
    'map' => {
    'application/json'   => 'JSON',
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

    my $species = $c->req->param("species");
    $c->stash->{widget} = $c->req->param("widget") if $c->req->param("widget");

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


    if($query=~/^\*$/){
      $query = " ";
    }
    my $tmp_query = $query;
    $tmp_query =~ s/-/_/g;
    $tmp_query .= " $query" unless($tmp_query =~ /$query/ );
    $c->log->debug("search $query");
      
    my $search = $type unless($type=~/all/);

    if(( !($type=~/all/) || $c->req->param("redirect")) && !(($c->req->param("all"))||($c->req->param("inline"))) && ($page_count < 2)){
      my ($it,$res)= $api->xapian->search_exact($c, $tmp_query, $search);
      if($it->{pager}->{total_entries} == 1 ){
        my $o = @{$it->{struct}}[0];
        my $url = $self->_get_url($c, $o->get_document->get_value(2), $o->get_document->get_value(1), $o->get_document->get_value(5));
        unless($query=~m/$o->get_document->get_value(1)/){ $url = $url . "?query=$query";}
        $c->res->redirect($url);
        return;
      }
    }


    if( !($c->stash->{noboiler}) && (( !($species) && (defined $c->config->{sections}{$type} || $type == 'all') ) || ($type == 'all'))) {
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

    my $it= $api->xapian->search($c, $tmp_query, $page_count, $search, $species);

    $c->stash->{species} = $species;
    $c->stash->{page} = $page_count;
    $c->stash->{type} = $type;
    $c->stash->{count} = $it->{pager}->{total_entries}; 
    my @ret = map { $self->_get_obj($c, $_->get_document) } @{$it->{struct}}; #see if you can cache @ret
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
    my $label = $o->get_document->get_data() || $id;
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
  $q =~ s/-/_/g;
  my $count = $api->xapian->search_count($c, $q, $search, $species);
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

sub _get_obj {
  my ($self, $c, $doc) = @_;
  my $api = $c->model('WormBaseAPI');
  $c->log->debug("class:" . $doc->get_value(0) . ", name:" . $doc->get_value(1));
  if($doc->get_value(2) =~ /cell/){ return; } #remove this after you rebuilt the search database
  my $obj = $api->fetch({aceclass=> $doc->get_value(0),
                          name => $doc->get_value(1)}) or die "$!";
  my %ret = %{$api->xapian->_wrap_objs($c, $obj, $doc->get_value(2))};
  unless (defined $ret{name}) {
    $ret{name}{id} = $doc->get_value(1);
    $ret{name}{class} = $doc->get_value(2);
    $ret{name}{label} = $doc->get_value(1);
  }
  return \%ret;
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
