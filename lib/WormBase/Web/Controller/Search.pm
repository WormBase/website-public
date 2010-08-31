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
sub search :Chained('/') :ParthPart('search') :CaptureArgs(0) {
    my ($self, $c) = @_;
    $c->log->debug("search method...");
  
    #all search results will end up at the search/results template.
    $c->stash->{template} = "search/results.tt2";
}

# a gene search
sub gene_search :Chained('search') :PathPart('gene') :Args(1) {
    my ($self, $c, $query) = @_;
    $c->log->debug("gene_search method");
    $c->stash->{'query'} = $query;
    $c->log->debug(join(', ', @{$c->req->args}));

    my $api = $c->model('WormBaseAPI');
    my $objs = $api->search->gene({pattern => $query});

    # fix your redirect to just call action.  Find out how to do this.
    if(scalar @$objs == 1) {
      $c->res->redirect('/reports/gene/' . @$objs[0]->id);
    }

    $c->stash->{'results'} = $objs;
}

# a variation search
sub variation_search :Chained('search') :PathPart('variation') :Args(1) {
    my ($self, $c, $query) = @_;
    $c->log->debug("variation_search method");
    $c->stash->{'query'} = $query;
    $c->log->debug(join(', ', @{$c->req->args}));

    my $api = $c->model('WormBaseAPI');
    my $objs = $api->search->variation({pattern => $query});

    $c->stash->{'results'} = $objs;

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
