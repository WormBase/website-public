package WormBase::Web::Controller::ClassicCompatibility;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
 
__PACKAGE__->config->{namespace} = '';

=head1 NAME

WormBase::Web::Controller::ClassicCompatibility - Compatibility Controller for WormBase

=head1 DESCRIPTION

Backwards compatability for old-style WormBase URIs.

=head1 METHODS

=cut

=head2 classic_get

  GET report pages
  URL space: /db/get
  Params: name and class

Provided with a class and name via the classic /db/get script,
redirect to the correct report page.

Caveat: currently assumes Ace class is given. Requires
name & class to correspond exactly to an object in AceDB

=cut

sub classic_get :Path("/db/get") Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'species/report.tt2';

    my $requested_class = $c->req->param('class');
    my $name            = $c->req->param('name');

    # TODO: handle when these are not provided and when the object doesn't exist
    my $api    = $c->model('WormBaseAPI');
    my $ACE2WB = $api->modelmap->ACE2WB_MAP->{class};

    my $class           = $ACE2WB->{$requested_class} or $c->detach;
    my $canonical_class = lc $class;

    my $url;
    if (exists $c->config->{sections}->{species}->{$canonical_class}) { # /species
	
	unless ($c->stash->{object}) {

	    # Fetch our external model
	    my $api = $c->model('WormBaseAPI');
      
	    # Fetch a WormBase::API::Object::* object
	    if ($name eq '*' || $name eq 'all') {
		$c->stash->{object} = $api->instantiate_empty({class => ucfirst($class)});
	    } else {
		$c->stash->{object} = $api->fetch({class => ucfirst($class),
						   name  => $name,
						  }) or die "Couldn't fetch an object: $!";
	    }
	    # $c->log->debug("Tried to instantiate: $class");
	}
	
	my $object = $c->stash->{object};
	my $species = eval { $object->Species } || 'any';
        $url = $c->uri_for('/species', $species, $canonical_class, $name);
    } else { # /report
        $url = $c->uri_for('/resources', $canonical_class, $name);
    }

    $c->res->redirect($url);
}


=pod 

DEPRECATED: Safe to purge if we aren't supporting old views

##############################################################
#
#   "CLASSIC" PAGES
#   URL space : /db
#   Params    : class, object, page
#
#   Serve up pages using classic formatting so we don't
#   have to maintain two codebases
#   
#   Old-style URLs have the format of
#   /db/DIRECTORY/[CLASS]?name=[NAME]
# 
##############################################################
sub classic_report :Path("/db") Args(2) {
    my ($self,$c,$directory,$class) = @_;

    # $directory is not really necessary. We don't use it.
 
    # Set the name of the widget. This is used 
    # to choose a template and label sections.
#    $c->stash->{page}  = $class;    # Um. Necessary?
#    unless ($c->config->{pages}->{$class}) {
#	my $link = $c->config->{external_url}->{uc($class)};
#	$link  ||= $c->config->{external_url}->{lc($class)};
#	if ($link =~ /\%s/) {
#	    $link=sprintf($link,split(',',$name));
#	} else {
#	    $link.=$name;
#	}
#	$c->response->redirect($link);
#	$c->detach;
#    }

    $c->stash->{class} = $class;
    
    # Let's set a stash parameter to enable classic wrapping
    $c->stash->{is_classic}++;

    # Save the query name
    $c->stash->{query} = $c->request->query_parameters->{name} || "";

    # Instantiate our external model directly (see below for alternate)
    my $api = $c->model('WormBaseAPI');
    
    # TODO
    # I may not want to actually fetch an object.
    # Maybe I'd be visiting the page without an object specified...If so, I should default to search panel
        
    # I don't think I need to fetch an object.  I just need to return the appropriate page template.
    # Then, each widget will make calls to the rest API.
    
    if ($c->stash->{query}) {
	my $object = $api->fetch({class=> ucfirst($class),
				  name => $c->stash->{query}
				 }) or die "$!";
	
	# $c->log->debug("Instantiated an external object: " . ref($object));
	$c->stash->{object} = $object;  # Store the internal ace object. Goofy.
    }

    # Stash the symbolic name of all widgets that comprise this page in default order.
    my @widgets = @{$c->config->{pages}->{$class}->{widget_order}};
    $c->stash->{widgets} = \@widgets;

    # Set the classic template
    $c->stash->{template} = 'layout/classic.tt2';
}


=cut


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
