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

    if ($species) {
	# Awful portability breaking hack. Need actual species names.
        my ($g,$s) = split('_',$species);
	my $api = $c->model('WormBaseAPI');    
	my $dsn = $api->_services->{'acedb'}->dbh || return 0; # OMG I am so sorry for this.
	$g = uc($g);
	my ($string) = $dsn->fetch(
	    -query => "find Species $g*$s");
	my ($object) = $dsn->fetch(-class=>'Species',-name=>"$string",-filled=>1);

	if ($object) {	    
	    my ($assembly) = $object->Assembly;
	    if ($assembly) {
		$c->log->warn($assembly);
		# Pull out various information about the assmebly.
		my $name = $assembly->Name;
		my $strain = $assembly->Strain;
		my $taxid  = $assembly->NCBITaxonomyID;
		my $first_release = $assembly->First_WS_release;
		$c->stash->{assembly_name}    = $name ? "$name" : undef;
		$c->stash->{sequenced_strain} = $strain ? $self->_pack_obj($strain) : undef;
		$c->stash->{ncbi_taxonomy_id} = $taxid  ? "$taxid" : undef;
		$c->stash->{first_wormbase_release} = $first_release ? "$first_release" : undef;
	    }
	}
    }

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

    $c->stash->{section}  = 'species';
    $c->stash->{species}  = $species,
    $c->stash->{class}    = $class;
    $c->stash->{is_class_index} = 0;  
    $c->stash->{template} = 'species/report.tt2';

    $c->detach unless $self->_is_class($c, $class);

    $c->stash->{species}    = $species;
    $c->stash->{query_name} = $name;
    $c->stash->{class}      = $class;

    my $api = $c->model('WormBaseAPI');
    my $object = $api->xapian->_get_tag_info($c, $name, lc($class));


    #temporary fix
    if((lc($class) eq 'pcr_oligo') && ($object->{id} ne $name)){
      $object->{id} = $name;
      $object->{label} = $object->{id};
      $object->{taxonomy} = $species;
      $object->{class} = lc($class);
    }

    if(!($object->{label}) || $object->{id} ne $name || $object->{class} ne lc($class)){
      $c->res->redirect($c->uri_for('/search',$class,"$name")->path."?redirect=1", 307);
      return;
    } else {
      $c->stash->{object}->{name}{data} = $object; # a hack to avoid storing Ace objects...
      if((my $taxonomy = $c->stash->{object}->{name}{data}{taxonomy}) ne $species){
        $c->res->redirect($c->uri_for("/species", $taxonomy, $class, $name)->path, 307);
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

    $self->_setup_page($c);
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



1;
