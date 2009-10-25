package WormBase::Web::Controller::Root;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in WormBase.pm
__PACKAGE__->config->{namespace} = '';

=head1 NAME

WormBase::Web::Controller::Root - Root Controller for WormBase

=head1 DESCRIPTION

Root level controller actions for the WormBase web application.

=head1 METHODS

=cut

=head2 INDEX

=cut

sub index :Path Args(0) {
    my ($self,$c) = @_;
    $c->stash->{template} = 'index.tt2';
}


=head2 DEFAULT

The default action. Before we 404 bomb out, let's check and see if we
are trying to display a class index page. This isn't optimal.

=cut

sub default :Path {
    my ($self,$c) = @_;
    $c->log->warn("couldn't find a path");
    
    my $path = $c->request->path;
    
    # Does this path exist as one of our pages?
    # This saves me from having to add an index action for
    # each class.  Each class will have a single default screen.
    if ($c->config->{pages}->{lc($path)}) {
	
	# Use the debug index pages.
	if ($c->config->{debug}) {
	} else {
	    $c->stash->{template} = 'generic/index.tt2';
	    $c->stash->{path} = $c->request->path;
	}
    } else {
# $c->response->body('Page not found (server error 404)');
	$c->stash->{template} = 'status/404.tt2';
	$c->response->status(404);
	$c->forward('WormBase::Web::View::TT');
    }
}


# /db/class/components - list all available widgets
#sub components :Path("/db/available") Args(1) {
#    my ($self,$c,$class) = @_;
#    $c->stash->{template} = 'generic/class_index.tt2';    
#    $c->stash->{class} = $class;
#}


##############################################################
#
#   Fields
#   URL space : /fields
#   Params    : class, object, field
#
# THis URL structure is rather goofy. I can't have two fields
# with the same name in two different widgets...
##############################################################
sub field :Path("/field") Args(3) {
    my ($self,$c,$class,$name,$field) = @_;
    
    # Save the requested field for formatting
    $c->stash->{field} = $field;
    $c->stash->{class} = ucfirst($class);
        
    # Fetch our external model
    my $api = $c->model('WormBaseAPI');
    # Fetch the object from our driver	 
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
    $c->log->debug("The requested class is " . ucfirst($class));
    $c->log->debug("The request is " . $name);
    
    # This code in essence calls the Factory for me.
    # It is the EXACT same thing the W::W::M::* would be doing.
    my $object = $api->fetch({class=> ucfirst($class),
			      name => $name}) or die "$!";
    
    $c->log->debug("Instantiated an external object: " . ref($object));
    # $c->stash->{object} = $object;
    
    # Fetch the field content and stash it.
    # This is goofy; the object of interest is wrapped inside an object...
    my $ace_object = $object->object;
    $c->log->debug("The internal object is: " . ref($ace_object));
    
    # Currently, I have to provide EVERY tag in my wrapper model
    # since I cannot find a sensible way to AUTOLOAD under Moose
    # (if indeed AUTOLOADing under Moose makes any sense at all...)
    # This is a horrendous hack; get the field from my wrapper object
    # if implemented, otherwise get it from the wrapped object.
    
    # This logic should probably be relocated to the external model.
    if ($object->can($field)) {
	$c->stash->{$field} = $object->$field;
    } else {
	# We are trying to call a direct method on an Ace::Object;
	# Method name needs to be ucfirst.
	# Tags that are not specifically included in the configuration
	# are not currently available because they are not actions
	
	my $method = ucfirst($field);
	$c->stash->{$field} = $object->object->$method;
    }
    
    $c->log->debug("Called a method on wrapped object->$field: " . $c->stash->{$field});

    # Select the appropriate template
    # Unless otherwise specified, use a generic template
    $c->stash->{template} = $self->_select_template($c,$field,$class,'field');    
    $c->log->debug("assigned template: " .  $c->stash->{template});
    
    # My end action isn't working... 
    $c->forward('WormBase::Web::View::TT');
};







##############################################################
#
#   Widgets (composites of fields)
#   URL space : /widget
#   Params    : class, object, widget
# 
##############################################################
sub widget :Path("/widget") Args(3) {
    my ($self,$c,$class,$name,$widget) = @_;
    
    # Set the name of the widget. This is used 
    # to choose a template and label sections.
    $c->stash->{widget} = $widget;
    $c->stash->{class}  = $class;
    
    # Fetch our external model
    my $api = $c->model('WormBaseAPI');

    # Fetch the object from our driver	 
#    $c->log->debug("WormBaseAPI model is $api " . ref($api));
#    $c->log->debug("The requested class is " . ucfirst($class));
#    $c->log->debug("The request is " . $name);
    
    my $object = $api->fetch({class=> ucfirst($class),
			      name => $name}) or die "$!";

    $c->log->debug("Instantiated an external object: " . ref($object));

    # Should I stash the object so I only need to fetch it once?
    # $c->stash->{object} = $object;
        
    # Fetch the field content and stash it.
    
    # Currently, I have to provide EVERY tag in my wrapper model
    # since I cannot find a sensible way to AUTOLOAD under Moose
    # (if indeed AUTOLOADing under Moose makes any sense at all...)
    # This is a horrendous hack; get the field from my wrapper object
    # if implemented, otherwise get it from the wrapped object.
    
    # Fetch all of the fields in order that comprise
    # this widget from the app configuration.

    # The templates for each field are actually specified in the widget.
    my @fields = @{ $c->config->{pages}->{$class}->{widgets}->{$widget} };
    $c->stash->{fields} = \@fields;

    # Forward to each of the component fields.
    foreach my $field (@fields) {
	# Currently, I have to provide EVERY tag in my wrapper model
	# since I cannot find a sensible way to AUTOLOAD under Moose
	# (if indeed AUTOLOADing under Moose makes any sense at all...)
	# This is a horrendous hack; get the field from my wrapper object
	# if implemented, otherwise get it from the wrapped object.
	
	# This logic should probably be relocated to the external model.
	if ($object->can($field)) {
	    $c->stash->{$field} = $object->$field;
	} else {
	    # We are trying to call a direct method on an Ace::Object;
	    # Method name needs to be ucfirst.
	    # Tags that are not specifically included in the configuration
	    # are not currently available because they are not actions
	    
	    my $method = ucfirst($field);
	    $c->stash->{$field} = $object->object->$method;
	}
	$c->log->debug("Called $field...");
    }
    
    # Did we request the widget by ajax?
    # Supress boilerplate wrapping.
    if ( $c->is_ajax() ) {
         $c->stash->{noboiler} = 1;
    }
    
    # Fetch the appropriate template for the widget
    $c->stash->{template} = $self->_select_template($c,$widget,$class,'widget');
    
    # My end action isn't working... 
    $c->forward('WormBase::Web::View::TT');   
};




##############################################################
#
#   Pages (composites of widgets)
#   URL space : /page
#   Params    : class, object, page
# 
##############################################################
sub page :Path("/reports") Args(2) {
    my ($self,$c,$class,$name) = @_;
    
    # Set the name of the widget. This is used 
    # to choose a template and label sections.
#    $c->stash->{page}  = $class;    # Um. Necessary?
    $c->stash->{class} = $class;
    
    # Instantiate our external model directly (see below for alternate)
    my $api = $c->model('WormBaseAPI');

    # TODO
    # I may not want to actually fetch an object.
    # Maybe I'd be visiting the page without an object specified...If so, I should default to search panel



    # I don't think I need to fetch an object.  I just need to return the appropriate page template.
    # Then, each widget will make calls to the rest API.
    my $object = $api->fetch({class=> ucfirst($class),
			      name => $name}) or die "$!";
    
    # $c->log->debug("Instantiated an external object: " . ref($object));
    $c->stash->{object} = $object;  # Store the internal ace object. Goofy.

=head
    
    # To add later:
    # * multi-results formatting
    # * nothing found.
    
    # Fetch the field content and stash it.
    
    # Currently, I have to provide EVERY tag in my wrapper model
    # since I cannot find a sensible way to AUTOLOAD under Moose
    # (if indeed AUTOLOADing under Moose makes any sense at all...)
    # This is a horrendous hack; get the field from my wrapper object
    # if implemented, otherwise get it from the wrapped object.
    
    # To generically build a widget, store
    # an ordered list of all necessary fields.
    # page is $c->namespace;			

=cut

    
    # Stash all widgets that comprise this page. We will build pages generically.
    my @widgets = @{ $c->config->{pages}->{$class}->{widget_order} };
    $c->stash->{widgets} = \@widgets;

    # Is any of this actually necessary?

    
    # All of the fields will be called dynamically from the template

=head

    # This approach means that EVERY widget and EVERY field will be rendered
    # at once for a report.
    # This is PROBABLY NOT what I want to settle with
    foreach my $widget (@widgets) {

	my @fields = qw/ids concise_description/;
#	print $widget;
#	my @fields = @{ $c->config->{pages}->{$class}->{$widget} };
	$c->stash->{fields} = \@fields;
	
	$c->log->debug($widget);	

	# Call each of the component fields in turn
	# PROBABLY NOT WHAT I WANT TO DO!
	foreach my $field (@fields) {	    
	    # This logic should probably be relocated to the external model.
	    if ($object->can($field)) {
		$c->stash->{$field} = $object->$field;
	    } else {
		# We are trying to call a direct method on an Ace::Object;
		# Method name needs to be ucfirst.
		# Tags that are not specifically included in the configuration
		# are not currently available because they are not actions
		
		my $method = ucfirst($field);
		$c->stash->{$field} = $object->object->$method;
	    }
	    $c->log->debug("Called $field...");
	}
    }

=cut
    
    # Did we request the widget by ajax?
    # Supress boilerplate wrapping.
    #if ( $c->is_ajax() ) {
	    $c->stash->{noboiler} = 1;
#	}
    
    # Normally, the template defaults to action name.
    # However, we have some generic templates. We will
    # specify the name of the template.  
    # MOST widgets can use a generic template.
    
    $c->stash->{template} = "report.tt2";
    $c->log->debug("assigned template: " .  $c->stash->{template});    
    
    # My end action isn't working... 
    $c->forward('WormBase::Web::View::TT');   
}










#######################################################
#
#     HELPER METHODS, NOT ACTIONS
#
#######################################################

# Template assignment is a bit of a hack.
# Maybe I should just maintain
# a hash, where each field/widget lists its corresponding template
sub _select_template {
    my ($self,$c,$render_target,$class,$type) = @_;

    # Normally, the template defaults to action name.
    # However, we have some generic templates. We will
    # specify the name of the template.  
    # MOST widgets can use a generic template.
    if ($type eq 'field') {
	if (defined $c->config->{generic_fields}->{$render_target}) {
	    return "generic/$type.tt2";    
	    # Some are shared across Models
	} elsif (defined $c->config->{common_fields}->{$render_target}) {
	    return "common_fields/$render_target.tt2";
	} else {  
	    return "$class/$render_target.tt2";
	}
    } else {
	# Widget template selection
	if (defined $c->config->{generic_widgets}->{$render_target}) {
	    return "generic/$type.tt2";    
	    # Some are shared across Models
	} elsif (defined $c->config->{common_widgets}->{$render_target}) {
	    return "common_widgets/$render_target.tt2";
	} else {  
	    return "$class/widgets/$render_target.tt2"; 
	}
    }

    # Approach 2: Most things are generic, those requiring custom fields are specified
    #if (defined ($c->config->{custom_fields}->{$field})) {
    #  $c->stash->{template} = "$page/$field.tt2";
    #} elsif (defined ($c->config->{common_fields}->{$field})) {
    #  $c->stash->{template} = "common_fields/$field.tt2";
    #} else {
    #  $c->stash->{template} = "generic/field.tt2";	  
    #}
   
}








#######################################################
#
#     SEARCHES
#
#######################################################

# Every class will have a basic and advanced search
# at /class/search/basic
# Alternatively, this should be /search/basic/class
# and be implemented only once.
sub register_basic_search {
    my ($self,$c,$page) = @_;
    # Basic search
    my $basic_search_code = sub {
	my ($self,$c) = @_;
	
	# Instantiate the Model - we need it for dynamically selecting examples.
	my $class = $c->model(ucfirst($page));
	
	$c->stash->{template} = "search/basic.tt2";
	$c->stash->{page}     = $page;   # maybe key should be class instead?
	$c->forward('WormBase::Web::View::TT');
    };
    
    my $basic_search_action = $self->create_action(
	name       => "basic_search",
	reverse    => "$page/basic_search",
	attributes => {
#							 Chained  => ["/$page/get_params"],
	    Path => ["/$page/basic_search"],
#							 Args     => [0],
	},
	namespace => $page,
	code      => \&$basic_search_code,
	class     => 'WormBase::Web::Controller::' . ucfirst($page),
	);
    $c->dispatcher->register( $c, $basic_search_action ) or warn "Couldn't register basic search action for $page: $!";	
}



#######################################################
#
#     CONFIGURATION - PROBABLY BELONGS ELSEWHERE
#
#######################################################

# Configure widgets and fields for a given page
sub configure : Chained('/') PathPart('configure') Args(1) {
  
  # Fetch all available widgets for a page
  # Let users drag and drop widgets onto the configuration target ala WordPress 

  # Let users pick and choose which data bits to display
  
}






=head2 end
    
    Attempt to render a view, if needed.
    
=cut 
    
# This is a kludge.  RenderView keeps tripping over itself
# for some Model/Controller combinations with the dynamic actions.
#  Namespace collision?  Missing templates?  I can't figure it out.

# This hack requires that the template be specified
# in the dynamic action itself.  Further, I have a list of fields
# which use generic templates in the configuration.



#sub end : Path {
sub end : ActionClass('RenderView') {
  my ($self,$c) = @_;

  # 5xx
  my $errors = scalar @{$c->error};
  if ($errors) {
      $c->res->status(500);
      $c->res->body('Internal Server Error!');
      $c->clear_errors;
  }
      
  $c->forward('WormBase::Web::View::TT');
}



#sub end : ActionClass('RenderView') {  }

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
