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
   

}



sub summary_widgets :Path("/species/summary") Args {
    my ($self,$c, @args) = @_;
    $c->stash->{section} = 'species';

    if(@args == 1){
      my $widget = shift @args;
      $c->stash->{template} = "species/summary/$widget.tt2";
    }elsif(@args ==2){
      my $species = shift @args;
      my $widget = shift @args;
      $c->stash->{template} = "species/summary/$species/$widget.tt2";
      $c->stash->{name}= $c->config->{species_list}->{$species}->{genus}." ".$c->config->{species_list}->{$species}->{species};
      unless ($c->stash->{object}) {
	    my $api = $c->model('WormBaseAPI');  
	    $c->log->debug("WormBaseAPI model is $api " . ref($api));
	    $c->stash->{object} =  $api->fetch({class=> ucfirst("species"),
						name => $c->stash->{name}}) or die "$!";
      }
      my $object= $c->stash->{object};
      my @fields = $c->_get_widget_fields("species_summary",$widget);
      foreach my $field (@fields){
	  $c->stash->{fields}->{$field} = $object->$field; 
      }

    }
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
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
  
    if($c->req->param('left') || $c->req->param('right')) {
       $c->log->debug("print the page as pdf");
      $c->stash->{print}={	    left=>[split /-/, $c->req->param('left')],
				      right=>[split /-/, $c->req->param('right')],
				      leftWidth=>$c->req->param('leftwidth'),
			      };
    }
    $c->stash->{object} = $object;  # Store the internal ace object. Goofy.
}



1;
