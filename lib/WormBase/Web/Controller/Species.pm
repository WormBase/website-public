package WormBase::Web::Controller::Species;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';


##############################################################
#
#   Species
#   URL space : /species
#   Params    : species, class, object
# 
##############################################################
# sub species :Chained("/") :ParthPart('species') :Args(0) 
sub species :Path('/species') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section} = 'species';
    if(defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
#     $c->stash->{template} = 'report.tt2';
}





# An individual species summary
sub species_summary :Path('/species') :Args(1)  {
    my ($self,$c, $species) = @_;
    if(defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
    if(defined $c->config->{'species_list'}->{$species}){
      $c->stash->{section} = 'species';
      $c->stash->{species} = $species;
    }elsif(defined $c->config->{'sections'}->{'species'}->{$species}){
      $c->stash->{template} = 'species/species_class_summary.tt2';
        $c->stash->{class} = $species;
    }else{
      $c->detach;
    }
}

sub species_class_summary :Path("/species") Args(2) {
    my ($self,$c,$class,$name) = @_;
    if(defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
    if(defined $c->config->{'species_list'}->{$class}){
      if(defined $c->config->{'sections'}->{'species'}->{$name}){
        $c->stash->{template} = 'species/species_class_summary.tt2';
        $c->stash->{species} = $class;
        $c->stash->{class} = $name;
      }else{
        # maybe search class names?
        $c->detach;
      }
    }elsif(defined $c->config->{'sections'}->{'species'}->{$class}){
      get_report($self, $c, $class, $name);
    }else{
      $c->detach;
    }
}

sub species_report :Path("/species") Args(3) {
    my ($self,$c,$species,$class,$name) = @_;
    get_report($self, $c, $class, $name);
}


sub get_report {
    my ($self,$c,$class,$name) = @_;
    $c->stash->{section} = 'species';
    $c->stash->{template} = 'species/report.tt2';

    unless ($c->config->{sections}->{species}->{$class}) { 
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
