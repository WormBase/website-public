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
    $tmp_query .= " $query" unless($tmp_query =~ /$query/ );
    $c->log->debug("search $query");
      
    my $search = $type unless($type=~/all/);

    if(( !($type=~/all/) || $c->req->param("redirect")) && !($c->req->param("all"))){
      my ($it,$res)= $api->xapian->search_exact($c, $tmp_query, $search);
      if($it->{pager}->{total_entries} == 1 ){
        my $o = @{$it->{struct}}[0];
        my $url = $self->_get_url($c, $o->get_document->get_value(2), $o->get_document->get_value(1));
        unless($query=~m/$o->get_document->get_value(1)/){ $url = $url . "?query=$query";}
        $c->res->redirect($url);
        return;
      }
    }

#     my ($cache_id,$it,$cache_server) = $c->check_cache('search', $tmp_query, $page_count, $search);
#     unless($it) {  
#         $it = $api->xapian->search($c, $tmp_query, $page_count, $search);
#         $c->set_cache($cache_id,$it);
#     }

    my $it= $api->xapian->search($c, $tmp_query, $page_count, $search);

#     $c->stash->{template} = "search/xapian.tt2";
#     $c->stash->{iterator} = $it;

    $c->stash->{type} = $type;
    $c->stash->{count} = $it->{pager}->{total_entries}; 
    my @ret = map { $self->_get_obj($api, $_->get_document) } @{$it->{struct}};
    $c->stash->{results} = \@ret;
    $c->stash->{querytime} = $it->{querytime};
    $c->stash->{query} = $query || "*";
    $c->forward('WormBase::Web::View::TT');
    return;
}

sub search_autocomplete :Path('/search/autocomplete') :Args(0) {
  my ($self, $c) = @_;
  my $q = $c->req->param("term");
  $c->stash->{noboiler} = 1;
  $c->log->debug("autocomplete search: $q");
  my $api = $c->model('WormBaseAPI');

 $q =~ s/-/_/g;
  my ($it,$res)= $api->xapian->search_autocomplete(
    $c, $q
  );

  my @ret;
  foreach my $o (@{$it->{struct}}){
    my $class = $o->get_document->get_value(2);
    my $id = $o->get_document->get_value(1);
    my $url = $self->_get_url($c, $class, $id);
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

sub _get_url {
  my ($self, $c, $class, $id) = @_;
  my $url = "";
  if(defined $c->config->{sections}->{species}->{$class}){
    $url .= $c->uri_for('/species',$class,$id);
  }else{
    $url .= $c->uri_for('/resources',$class,$id);
  }
  return $url;
}

sub _get_obj {
  my ($self, $api, $doc) = @_;
  my $obj = $api->fetch({class=> $doc->get_value(0),
                          name => $doc->get_value(1)}) or die "$!";
  return $api->xapian->_wrap_objs($obj, $doc->get_value(2));
}

sub search_preview :Path('/search/preview')  :Args(2) {
    my ($self, $c, $type, $species) = @_;

    $c->log->debug("search preview");

    $c->stash->{template} = "search/results.tt2";
    my $api = $c->model('WormBaseAPI');
    my $class =  $type;
    my $offset = $c->req->param("begin") || 0;
    my $count = ($c->req->param("end")   || 10) - $offset;
    my $objs;
    my $total;
    ($total, $objs) = $api->search->preview({class => $class, species => $species, offset=>$offset, count=>$count});

    $c->stash->{'type'} = $type; 
    $c->stash->{'total'} = $total; 
    $c->stash->{'results'} = $objs;
    $c->stash->{noboiler} = 1;

    $c->stash->{'query'} = $species || "*";
    $c->stash->{'class'} = $type;
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
