package WormBase::Web::Controller::Species;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';


##############################################################
#
#   Species
#   URL space : /species
#
#   /species -> a list of all species
#   /species/CLASS -> an Index page of class
#   /species/CLASS/OBJECT -> a report page
#
#   CUSTOM
#   /species/guide   -> NOTHING
#   /species/guide/SPECIES -> Species info page
#   /species/guide/component
# 
##############################################################




##############################################################
#
#   Species Reports
#
##############################################################

# Class summary: eg /species/strain, displays a custom search and widgets
sub species_class_index :Path('/species') :Args(1)   {
    my ($self,$c,$class) = @_;
    if (defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }

    $c->stash->{section}    = 'species';
    $c->stash->{class}      = $class;
    $c->stash->{is_index}   = 1;

    # Override the default template. Too confusing when editing.
    # Index and report are both handled by the same template: report.
    $c->stash->{template} = "species/report.tt2";
}




##############################################################
#
#   Species Atlas
#   URL space : /species and /species/guide
# 
##############################################################

# Species index page
sub species :Path('/species') :Args(0)   {
    my ($self,$c) = @_;
    $c->stash->{section}  = 'species';

    # Override the default template. Too confusing when editing.
    $c->stash->{template} = 'species/species_summary-all.tt2';
    if (defined $c->req->param("inline")) {
      $c->stash->{noboiler} = 1;
    }
}


# /species/guide/ARG: individual species summary
sub species_overview :Path('/species/guide') :Args(1)  {
    my ($self,$c, $species) = @_;
    if (defined $c->req->param("inline")) {
	$c->stash->{noboiler} = 1;
    }
    # I suppose we should try to trap errors here.
   if (defined $c->config->{'species_list'}->{$species}) {
	$c->stash->{template} = 'species/species_summary-individual.tt2';
	$c->stash->{section}  = 'species';
	$c->stash->{species}  = $species;
    } else {
	$c->detach;
    }
}


# Component widgets of the guide
# /species/guide/component: two cases
# 1. /species/guide/component/ARG - a widget for the overview page
# 2. /species/guide/component/SPECIES/ARG - a widget for an individual page
sub species_component_widgets :Path("/species/guide/component") Args {
    my ($self,$c, @args) = @_;
    $c->stash->{section} = 'species';

    # These could be species index page widgets
    if (@args == 1) {
      my $widget = shift @args;
      $c->stash->{template} = "species/summary/$widget.tt2";

    # Or per-species widgets
    } elsif (@args == 2) {
      my $species = shift @args;
      my $widget = shift @args;
      $c->stash->{template} = "species/$species/$widget.tt2";
      $c->stash->{name}= join(' ',
			      $c->config->{species_list}->{$species}->{genus},
			      $c->config->{species_list}->{$species}->{species});
      
      # Necessary?
#      unless ($c->stash->{object}) {
#	  my $api = $c->model('WormBaseAPI');  
#	  $c->log->debug("WormBaseAPI model is $api " . ref($api));
#	  $c->stash->{object} =  $api->fetch({class=> ucfirst("species"),
#					      name => $c->stash->{name}}) or die "$!";
#      }
#      my $object= $c->stash->{object};
#      my @fields = $c->_get_widget_fields("species_summary",$widget);
#      foreach my $field (@fields){
#	  $c->stash->{fields}->{$field} = $object->$field; 
#      }      
    }
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
}



# LEGACY CODE, but seems to be mixed in with /species calls?
# This is a widget listing all the classes available for a given species
#sub species_class_report :Path("/species") Args(2) {
sub species_report :Path("/species") Args(2) {
    my ($self,$c,$class,$name) = @_;
    if (defined $c->req->param("inline")) {
	$c->stash->{noboiler} = 1;
    }

#    if (defined $c->config->{'species_list'}->{$class}){
#	if(defined $c->config->{'sections'}->{'species'}->{$name}){
#	    $c->stash->{template} = 'species/species_class_summary.tt2';
#	    $c->stash->{species} = $class;
#	    $c->stash->{class} = $name;
#	} else {
#	    # maybe search class names?
#	    $c->detach;
#	}
#    } elsif(defined $c->config->{'sections'}->{'species'}->{$class}) {
    if(defined $c->config->{'sections'}->{'species'}->{$class}) {
	get_report($self, $c, $class, $name);
    } else {
	$c->detach;
    }
}


# Is this for handling PDFs?
# I have NO IDEA what this action is for.
# I renamed the action above to species_report to match resources.
#sub species_report :Path("/species") Args(3) {
#    my ($self,$c,$species,$class,$name) = @_;
#    get_report($self, $c, $class, $name);
#}


sub get_report {
    my ($self,$c,$class,$name) = @_;
    $c->stash->{section} = 'species';
    $c->stash->{template} = 'species/report.tt2';
    
    unless ($c->config->{sections}->{species}->{$class}) { 
	# class doesn't exist in this section
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
