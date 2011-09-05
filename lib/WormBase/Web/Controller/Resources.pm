package WormBase::Web::Controller::Resources;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';


##############################################################
#
#   Resources
#   URL space : /resources
#
#   /resources -> a list of all resources
#   /resources/CLASS -> an Index page of class
#   /resources/CLASS/OBJECT -> a report page
#
#   And things that don't handle objects
#   /resources/reagents
# 
##############################################################

# This would/should/could be a listing of all resources
sub resources :Path('/resources') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section} = 'resources';
    if(defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
      $c->stash->{is_class_index} = 1;      
    $c->stash->{template} = "resources/report.tt2";
      $c->stash->{class}   = 'all';

    # get static widgets for this page
    my $page = $c->model('Schema::Page')->find({url=>$c->req->uri->path});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
#     $c->stash->{template} = 'report.tt2';
}

# eg /resources/{CLASS}
sub resources_class_index :Path('/resources') :Args(1)  {
    my ($self,$c, $class) = @_;
    if (defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
    
    $c->stash->{template} = "resources/report.tt2";

    # get static widgets for this page
    my $page = $c->model('Schema::Page')->find({url=>$c->req->uri->path});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
    
    if (defined $c->config->{'sections'}->{'resources'}->{$class}){
      $c->stash->{section} = 'resources';
      $c->stash->{class}   = $class;
      
      # Special cases: like reagents
      # These will have a property of "static" set to "true".
      # We need to generate links to these a bit differently
      # since they do not have objects associated with them:
      #     /resources/class/widget instead of
      #     /resources/class/object/widget
      # We handle it here so that in the future we can just add a property.
      if (defined $c->config->{'sections'}->{'resources'}->{$class}->{static}) {
	  $c->stash->{is_static} = 1;	  
      }

      # We're also an index page, some for classes that DO handle objects.
      $c->stash->{is_class_index} = 1;      
      
    } else {
	# We aren't a recognized resource (ie specified in config or a custom action).
	# Detach to a soft 404.
	$c->detach('/soft_404');
    }
}



# eg /resources/{CLASS}/{OBJECT}
sub resources_report :Path("/resources") Args(2) {
    my ($self,$c,$class,$name) = @_;
    $self->_get_report($c, $class, $name);
}

# TH 2011.09.05: I think this is deprecated.
## Documentation: 
## Two directory hierarcy:
## about: privacy, copyright, mission statement (one document)
## advisory_board
#sub documentation :Path('/resources/documentation') Args(1) {
#    my ($self,$c,$category) = @_;
#    $c->stash->{section}  = 'resources';
#    $c->stash->{template} = "resources/documentation/$category.tt2";
#}

# Not in use, but retain. Could be useful.
sub downloads :Path('/resources/downloads') Args(0) {
    my ($self,$c) = @_;
    $c->stash->{template} = "resources/downloads.tt2";
}




#################################
#
#  Custom Resources:
#
#  These have their own tt2 and
#  set up a custom sidebar.
#  
#################################
#sub advisory_board :Path("/resources/advisory_board") Args {
#    my ($self,$c, @args) = @_;
#    $c->stash->{section} = 'resources';
#
#    my $widget = shift @args;
#    if($widget){
#      $c->stash->{noboiler} = 1;
#      $c->stash->{template} = "resources/advisory_board/$widget.tt2";
#      $c->forward('WormBase::Web::View::TT');
#    }
#
##     get_report($self, $c, "advisory_board", "");
#}



sub _get_report {
    my ($self,$c,$class,$name) = @_;
    $c->stash->{section}  = 'resources';
    $c->stash->{template} = 'resources/report.tt2';

    unless ($c->config->{sections}->{resources}->{$class}) { 
      # class doesn't exist in this section
      $c->detach;
    }

    $c->stash->{section}    = 'resources';
    $c->stash->{query_name} = $name;
    $c->stash->{class}      = $class;
    $c->log->debug($name);

    # get static widgets for this page
    my $page = $c->model('Schema::Page')->find({url=>$c->req->uri->path});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
    
    my $api = $c->model('WormBaseAPI');
    my $object = $api->fetch({class=> ucfirst($class),
                  name => $name}) || $self->error_custom($c, 500, "can't connect to database");
     
    $c->res->redirect($c->uri_for('/search',$class,"$name")."?redirect=1")  if($object == -1 );

    $c->stash->{object} = $object;  # Store the internal ace object. Goofy.
}



1;
