package WormBase::Web::Controller::Resources;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';


##############################################################
#
#   Resources
#   URL space : /resources
#   Params    : class, object
# 
##############################################################
# sub species :Chained("/") :ParthPart('species') :Args(0) 
sub resources :Path('/resources') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section} = 'resources';
#     $c->stash->{template} = 'report.tt2';
}

sub resources_class_summary :Path('/resources') :Args(1)  {
    my ($self,$c, $class) = @_;
    if(defined $c->config->{'sections'}->{'resources'}->{$class}){
      $c->stash->{section} = 'resources';
      $c->stash->{class} = $class;
    }else{
      $c->detach;
    }
}

sub resources_report :Path("/resources") Args(2) {
    my ($self,$c,$class,$name) = @_;
    get_report($self, $c, $class, $name);
}


sub get_report {
    my ($self,$c,$class,$name) = @_;
    $c->stash->{section} = 'resources';
    $c->stash->{template} = 'resources/report.tt2';

    unless ($c->config->{sections}->{resources}->{$class}) { 
      # class doens't exist in this section
      $c->detach;
    }

    $c->stash->{query_name} = $name;
    $c->stash->{class} = $class;
    $c->log->debug($name);
    
    my $api = $c->model('WormBaseAPI');
    my $object = $api->fetch({class=> ucfirst($class),
                  name => $name}) || $self->error_custom($c, 500, "can't connect to database");
     
    $c->res->redirect($c->uri_for('/search',$class,"$name")."?redirect=1")  if($object == -1 );

    $c->stash->{object} = $object;  # Store the internal ace object. Goofy.
}



1;