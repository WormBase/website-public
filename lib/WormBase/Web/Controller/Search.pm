package WormBase::Web::Controller::Search;

use strict;
use warnings;
use parent 'Catalyst::Controller::FormBuilder';


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
      
    my $search = $type unless($type=~/All/);

    my ($it,$res)= $api->search->search(
      $tmp_query, $page_count, $search
    );

    $c->stash->{type} = $type;
    $c->stash->{count} = $it->{pager}->{total_entries}; 
    my @ret;
    foreach my $o (@{$it->{struct}}){
      my @objs;
      my $class = $o->get_document->get_value(0);
      my $obj = $api->fetch({class=> $class,
                          name => $o->get_document->get_value(1)}) or die "$!";
      my %obj = %{$api->search->_wrap_objs($obj, lcfirst($class))};
      push(@ret, \%obj);
    }
    $c->stash->{results} = \@ret;
    $c->stash->{query} = $query || "*";

    return;
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


#########################################
# Search actions
#########################################
# Display the search form itself


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
