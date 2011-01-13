package WormBase::Web::Controller::Search;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';


##############################################################
#
#   Search
#   URL space : /search
#   Params    : class, query
#
##############################################################
# sub search :Chained('/') :ParthPart('search') :CaptureArgs(0) {
#     my ($self, $c) = @_;
#     $c->log->debug("search method...");
#   
#     #all search results will end up at the search/results template.
#     $c->stash->{template} = "search/results.tt2";
# }

sub search :Path('/search')  :Args(2) {
    my ($self, $c, $type, $query) = @_;
    $c->stash->{'search_guide'} = $query if($c->req->param("redirect"));
    if($type eq 'all' && !(defined $c->req->param("view"))) {
    $c->log->debug(" search all kinds...");
    $c->stash->{template} = "search/full_list.tt2";
    } else {
    $c->log->debug("$type search");
     
    my $api = $c->model('WormBaseAPI');
    my $class =  $c->req->param("class") || $type;
    my $search = $type;
    $search = "basic" unless  $api->search->meta->has_method($type);
    my $objs;

    # Does the data for this widget already exist in the cache?
# my $cached_data;
    my ($cache_id,$cached_data,$cache_server) = $c->check_cache('search', $type, $query, $class);
    unless($cached_data) {  
        $cached_data = $api->search->$search({class => $class, pattern => $query});
        $c->set_cache($cache_id,$cached_data);
    } else {
	$c->stash->{cache} = $cache_server if($cache_server);
    }
    $objs = $cached_data;

# 
#     if(@$objs<1) { #this may not be optimal
#       $query.="*";
#       $objs = $api->search->$search({class => $class, pattern => $query}) ;
#       ($cache_id,$cached_data) = $c->check_cache('search', $type, $class, $query);
#       unless($cached_data) {  
#           $cached_data = $api->search->$search({class => $class, pattern => $query});
#           $c->set_cache($cache_id,$cached_data);
#       } 
#       $objs = $cached_data;
#     }

    my $begin = $c->req->param("begin") || 0;
    my $end = $c->req->param("end") || 19;
    my $count = scalar(@$objs);
    if($end > ($count-1)){ $end = $count - 1;}

    my @results = @$objs[$begin..$end];
    $c->stash->{'type'} = $type; 
    $c->stash->{'results'} = \@results;
    $c->stash->{'count'} = $count;
    if(defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    } elsif(@$objs==1 ) {
        my $url;
        if(defined $c->config->{'sections'}->{'species'}->{$class}){
          $url = $c->uri_for('/species',$type,$objs->[0]->{obj_name});
        }else{
          $url = $c->uri_for('/resources',$type,$objs->[0]->{obj_name});
        }
        unless($query=~m/$objs->[0]->{obj_name}/){ $url = $url . "?query=$query";}
        $c->res->redirect($url);
    } 
      if($begin > 0) {
        $c->stash->{template} = "search/result_list.tt2";
      }else {
        $c->stash->{template} = "search/results.tt2";
      }
    }
    $c->stash->{'query'} = $query;
    $c->stash->{'class'} = $type;
     
}

sub search_preview :Path('/search/preview')  :Args(2) {
    my ($self, $c, $type, $species) = @_;

    $c->log->debug("search preview");

    $c->stash->{template} = "search/results.tt2";
    my $api = $c->model('WormBaseAPI');
    my $class =  $type;
    my $begin = $c->req->param("begin") || 0;
    my $end = $c->req->param("end") ||10;
    my $objs;
    $objs = $api->search->preview({class => $class, species => $species, begin=>$begin, end=>$end});

#     $c->stash->{'type'} = $type; 
#     $c->stash->{'results'} = $objs;
#     $c->stash->{noboiler} = 1;
# 
#     $c->stash->{'query'} = $species;
#     $c->stash->{'class'} = $type;
    $c->stash->{'type'} = $type; 
    $c->stash->{'results'} = $objs;
    $c->stash->{noboiler} = 1;

    $c->stash->{'query'} = $species || "*";
    $c->stash->{'class'} = $type;
}


#########################################
# Search actions
#########################################
# Display the search form itself
# 
# sub search : Path Form {
#   my ( $self, $c ) = @_;
#   my $ace = $c->model('AceDB');
#   my $dbh = $ace->dbh;
#   my @classes = $dbh->classes();
# 
#    my $form = $self->formbuilder;
# 
# #  $self->formbuilder->field('query');
# 
#   # Populate options for the class field
#   $self->formbuilder->field(
# 			    name     => 'class',
# 			    label    => 'Class',
# 			    options  => \@classes ,
# 			   );
# 
#   # Generically search a class
#   $c->stash->{template} = "search/basic.tt2";
#   if ( $form->submitted ) {
# 
#     # Has the form been submitted?
#     # Call the search method of the specified class (if it exists)
#     # WormBase::Web::Controller::$CLASS::search
# 
#     # ALTERNATIVELY:
#     # NEED TO INCLUDE: paging, basic vs advanced, limits, fields to return...
#     my $class = $c->req->params('class');
#     $c->stash->{results} = $c->model($class)->search();
#     
#     #    if ( $form->validate ) {
#     #      return $c->response->body("VALID FORM");
#     #    }
#     #    else {
#     #      $c->stash->{ERROR}          = "INVALID FORM";
#     #      $c->stash->{invalid_fields} =
#     #	[ grep { !$_->validate } $form->fields ];
#     #    }
#   }
# 
#   # WormBase::Web::Controller::$CLASS::search() should specify the cocrrect
#   # template (if a custom template is required)
# 
# }

=head1 basic_search

A site-wide and per-class basic search

=cut

sub basic : Args(2) {
  my ($self,$c,$class,$name) = @_;
  
  # Instantiate the Model
  my $model = $c->model(ucfirst($class));
  
  # Generically search a class
  $c->stash->{template} = "search/$class.tt2";
  
  # Pass the search form the appropriate configuration directives, too.
  $c->stash->{results}  = $model->search($name);
  
  # Design patterns:  Need generic search limits, fields to return,
  # paging, (or dynamic loading on scroll). 
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
