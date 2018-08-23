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
    $c->res->redirect($c->uri_for('/species',"all")->path, 307);
    $c->go('species_index',['all']);
    return;
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

    $self->_setup_page($c);

    $c->stash->{section}    = 'species';     # Section of the site we're in. Used in navigation.
    $c->stash->{class}      = 'all';
    $c->stash->{is_class_index} = 1;
    $c->stash->{species}    = $species;           # Class is the subsection
    $c->stash->{template}   = 'species/report.tt2';
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

    # get static widgets / layout info for this page
    $self->_setup_page($c);

    $c->stash->{template} = 'species/report.tt2';
    $c->stash->{section}     = 'species';
    $c->stash->{class}       = $class;

    $c->stash->{species}     = $species;  # Provided for formatting, limit searches
    $c->stash->{is_class_index} = 1;       # used by report_page macro as a flag that this is an index page.
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
    $self->_get_report($c,$species,$class,$name);
    $self->_setup_page($c);
}

sub object_widget_report :Path("/species") Args(5) {
    my ($self,$c,$species,$class,$name,$widgetOrField, $widget) = @_;
    $self->_get_report($c,$species,$class,$name);
    $c->stash->{section}  = 'species';
    $c->stash->{widget}  = $widget;
    $c->stash->{template} = 'species/widget_report.tt2';
    $c->stash->{rest_url} = $c->uri_for("/rest/widget/$class/$name/$widget")->as_string;
    $self->_setup_page($c);
}

sub _get_report {
    my ($self,$c,$species,$class,$name) = @_;
    $c->stash->{section}  = 'species';
    $c->stash->{species}  = $species,
    $c->stash->{class}    = $class;
    $c->stash->{is_class_index} = 0;
    $c->stash->{template} = 'species/report.tt2';



    if($class eq 'species'){
      $c->res->redirect($c->uri_for('/species',"$species")->path."?redirect=1", 307);
    }
    $c->res->redirect($c->uri_for("/species", 'all', $class, $name, $c->req->params)->as_string, 307) unless $species;

    unless ($self->_is_class($c, $class)) {
        $c->res->redirect($c->uri_for('/search',"all","$class $name")->path."?redirect=1", 307);
        $c->detach;
    }

    $c->stash->{species}    = $species;
    $c->stash->{query_name} = $name;
    $c->stash->{class}      = $class;

    my $api = $c->model('WormBaseAPI');
    my $object = $api->xapian->fetch({id => $name, class => lc($class), label => 1});


    #temporary fix
    if ((lc($class) eq 'pcr_oligo' && $object->{id} ne $name) ||
        (lc($class) =~ /^antibody|expression_cluster$/ && !($object->{label}) )){
      $object->{id} = $name;
      $object->{label} = $object->{id};
      $object->{taxonomy} = $species;
      $object->{class} = lc($class);
    }

    if(!($object->{label}) || $object->{id} ne $name || lc($object->{class}) ne lc($class)){
      $c->res->redirect($c->uri_for('/search',$class,"$name")->path."?redirect=1", 307);
      return;
    } else {
      $c->stash->{object}->{name}{data} = $object; # a hack to avoid storing Ace objects...
      if((my $taxonomy = ($c->stash->{object}->{name}{data}{taxonomy} || 'all')) ne $species){
        $c->res->redirect($c->uri_for("/species", $taxonomy, $class, $name, $c->req->params)->as_string, 307) if $taxonomy;
      }
    }


    if ($c->req->param('left') || $c->req->param('right')) {
        $c->log->debug("print the page as pdf");
        $c->stash->{print} = {
            left=>[split /-/, $c->req->param('left')],
            right=>[split /-/, $c->req->param('right')],
            leftWidth=>$c->req->param('leftwidth'),
        };
    }
}



##############################################################
#
#   PRIVATE METHODS
#
##############################################################

# Is the argument a class?
sub _is_class {
    my ($self,$c,$arg) = @_;
    return (defined $c->config->{'sections'}->{'species'}->{$arg});
}



1;
