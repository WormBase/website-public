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

    # get static widgets/layout info for this page
    $self->_setup_page($c);
}

# eg /resources/{CLASS}
sub resources_class_index :Path('/resources') :Args(1)  {
    my ($self,$c, $class) = @_;
    if (defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }

    $c->stash->{template} = "resources/report.tt2";

    # get static widgets/layout info for this page
    $self->_setup_page($c);

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

    # get static widgets/layout info for this page
    $self->_setup_page($c);

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


# eg /resources/{class}/{object}/widget/{widgetId}
sub resources_widget_report :Path("/resources") Args(4) {
    my ($self,$c,$class,$name,$widgetOrField,$widget) = @_;
    $self->_get_report($c, $class, $name);
    $c->stash->{section}  = 'resources';
    $c->stash->{widget}  = $widget;
    $c->stash->{template} = 'resources/widget_report.tt2';
    $c->stash->{rest_url} = $c->uri_for("/rest/widget/$class/$name/$widget")->as_string;
}

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
      $c->res->redirect($c->uri_for('/search',"all","$class $name")->path."?redirect=1", 307);
      $c->detach;
    }

    $c->stash->{section}    = 'resources';
    $c->stash->{query_name} = $name;
    $c->stash->{class}      = $class;
    $c->log->debug($name);

    my $api = $c->model('WormBaseAPI');
    my $object = $api->xapian->fetch({ id => $name, class => lc($class), label => 1 });

    if(!($object->{label}) || $object->{id} ne $name || lc($object->{class}) ne lc($class)){
      $c->res->redirect($c->uri_for('/search',$class,"$name")->path."?redirect=1", 307);
      return;
    } else {
      $c->stash->{object}->{name}{data} = $object; # a hack to avoid storing Ace objects...
    }
}



1;
