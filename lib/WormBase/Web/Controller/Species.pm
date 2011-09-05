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
#   /species
# 
#        --> Redirects to the species summary: /species/all
#
##############################################################

sub species_summary :Path('/species') :Args(0)   {
    my ($self,$c) = @_;
    $c->detach('species_index',['all']);
}


##############################################################
#
#   /species/[SPECIES] : The species index page 
#    
#            all     -> all species
#            SPECIES -> an individual species
#
##############################################################

sub species_index :Path('/species') :Args(1)   {
    my ($self,$c,$species) = @_;

    if (defined $c->req->param('inline')) {
	$c->stash->{noboiler} = 1;
    }

    # get static widgets for this page
    my $page = $c->model('Schema::Page')->find({url=>$c->req->uri->path});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);

    if ($species eq 'all' || $self->_is_species($c,$species)) {
      $c->stash->{section}    = 'species';     # Section of the site we're in. Used in navigation.
      $c->stash->{class}      = 'all';
      $c->stash->{is_class_index} = 1;   # 0? 
      $c->stash->{is_static}      = 1;	 # Disable widgets like "browse" and "search" 
      $c->stash->{species}    = $species;           # Class is the subsection	
      $c->stash->{template}   = 'species/report.tt2';
    } else {
	$c->detach('/soft_404');   # We are neither a supported class or proper species name. Error!
    }
}



##############################################################
#
#   /species/[SPECIES]/[CLASS]:
#    
#      Class Summary pages, general and species specific.
#
##############################################################
sub class_index :Path("/species") Args(2) {
    my ($self,$c,$species,$class) = @_;
    if (defined $c->req->param('inline')) {
	$c->stash->{noboiler} = 1;
    }

    # get static widgets for this page
    my $page = $c->model('Schema::Page')->find({url=>$c->req->uri->path});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);

    # Is this a species known to WormBase?
    if ($species eq 'all' || $self->_is_species($c,$species)) {

#	if ($self->_is_class($c,$class)) {
    $c->stash->{template} = 'species/report.tt2';
	    $c->stash->{section}     = 'species';
	    $c->stash->{class}       = $class;
	   
	    $c->stash->{species}     = $species;  # Provided for formatting, limit searches
	    $c->stash->{is_class_index} = 1;       # used by report_page macro as a flag that this is an index page.
    } else {
	# maybe search class names?
	$c->detach;
    }   
}


##############################################################
#
#   /species/SPECIES/CLASS/OBJECT
#
#            Object Report page via
#                CLASS/OBJECT/FIELD
#                SPECIES/CLASS/OBJECT
#
##############################################################

sub object_report :Path("/species") Args(3) {
    my ($self,$c,$species,$class,$name) = @_;
#    $self->_get_report($self, $c, $class, $name);
    $c->stash->{section}  = 'species';
    $c->stash->{species}  = $species,
    $c->stash->{class}    = $class;
    $c->stash->{is_class_index} = 0;  
    $c->stash->{template} = 'species/report.tt2';
    
    unless ($c->config->{sections}->{species}->{$class}) { 
	# class doesn't exist in this section
	$c->detach;
    }
    
    $c->stash->{species}    = $species;
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
    
    if($c->req->param('left') || $c->req->param('right')) {
	$c->log->debug("print the page as pdf");
	$c->stash->{print}={	    left=>[split /-/, $c->req->param('left')],
				    right=>[split /-/, $c->req->param('right')],
				    leftWidth=>$c->req->param('leftwidth'),
	};
    }
    $c->stash->{object} = $object;  # Store the WB object.
   
}



##############################################################
#
#   PRIVATE METHODS
#
##############################################################

# Is the argument a class?
sub _is_class {
    my ($self,$c,$arg) = @_;
    return 1 if (defined $c->config->{'sections'}->{'species'}->{$arg});
    return 0;
}

# Is the argument a species?
sub _is_species {
    my ($self,$c,$arg) = @_;
    return 1 if (defined $c->config->{sections}->{'species_list'}->{$arg});
    return 0;
}




1;
