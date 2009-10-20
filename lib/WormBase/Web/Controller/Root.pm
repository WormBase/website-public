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
#    $c->response->body( $c->welcome_message );
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
#	$c->response->body('Page not found (server error 404)');
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


# /db actions
sub generic_fields :Path("/fields") Args(3) {
    my ($self,$c,$class,$name,$field) = @_;
    
    # Save the requested field for formatting
    $c->stash->{field} = $field;
    $c->stash->{class} = ucfirst($class);
        
    # Instantiate our external model directly (see below for alternate)
    if (1) {
	
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
	
	# To add later:
	# * multi-results formatting
	# * nothing found.
	
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
    }

    # Use Catalyst::Model::Factory to instantiate our external models.
    # This would be the smart way to do things, huh?
    # Instantiate a WB::Web::Model::* would in turn instantiate an external WB::API::O::* model
    # and in doing so, try to fetch an object.
    if (0) {
	# Instantiate the Model
	my $target_class = $c->model(ucfirst($class));
	$c->log->debug(ref($target_class));
	
	# Fetch the field content and stash it.
	# This is goofy; the object of interest is wrapped inside an object...
	$c->stash->{$field} = $target_class->object->$field();
    }

    # Select the appropriate template
    # Unless otherwise specified, use a generic template
    $c->log->debug("choosing template:" . $field);
    # Common fields: shared among multiple pages
    if (defined $c->config->{common_fields}->{$field}) {
	$c->stash->{template} = "common_fields/$field.tt2";

	# Generic: simple fields or widgets.
	# I should probably just get rid of these as they are confusing
    } elsif (defined $c->config->{generic_fields}->{$field}) {
	$c->stash->{template} = "generic/field.tt2";
    } else {  
	$c->stash->{template} = "$class/$field.tt2";
    }

#    $c->stash->{template} = "generic/field.tt2";
    
    $c->log->debug("assigned template: " .  $c->stash->{template});
    # Approach 2: Most things are generic, those requiring custom fields are specified
    #if (defined ($c->config->{custom_fields}->{$field})) {
    #  $c->stash->{template} = "$page/$field.tt2";
    #} elsif (defined ($c->config->{common_fields}->{$field})) {
    #  $c->stash->{template} = "common_fields/$field.tt2";
    #} else {
    #  $c->stash->{template} = "generic/field.tt2";	  
    #}
    
    # My end action isn't working... 
    $c->forward('WormBase::Web::View::TT');
};








sub generic_widgets :Path("/widget") Args(3) {
    my ($self,$c,$class,$name,$widget) = @_;
    
    # Set the name of the widget. This is used 
    # to choose a template and label sections.
    $c->stash->{widget} = 'overview';
    $c->stash->{class}  = ucfirst($class);
    
    # Instantiate our external model directly (see below for alternate)
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
    my @fields = @{ $c->config->{pages}->{gene}->{widgets}->{overview} };
    $c->stash->{fields} = \@fields;
    
    # Stash the appropriate templates for each field.
    # The widget template itself will rely on these. Necessary? Doesn't each field choose its template?
#	foreach (@fields) {
#	    my $template;
#	    # Approach 1:
#	    # Most templates are custom so fall through to that state.
#	    if (defined $c->config->{common_fields}->{$_}) {
#		$template = "common_fields/$_.tt2";
#	    } elsif (defined $c->config->{generic_fields}->{$_}) {
#		$template = "generic/field.tt2";
#	    } else {  
#		$template = "gene/$_.tt2";
#	    }
#	    # $c->stash->{fields}->{$_} = $template;
#	}
    
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
#	if ( $c->is_ajax() ) {
#	    $c->stash->{noboiler} = 1;
#	}
    
    # Normally, the template defaults to action name.
    # However, we have some generic templates. We will
    # specify the name of the template.  
    # MOST widgets can use a generic template.
    if (defined $c->config->{generic_widgets}->{$widget}) {
	$c->stash->{template} = "generic/widget.tt2";    
	# Some are shared across Models
    } elsif (defined $c->config->{common_widgets}->{$widget}) {
	$c->stash->{template} = "common_widgets/$widget.tt2";
    } else {  
	$c->stash->{template}    = "$class/widgets/$widget.tt2"; 
    }
    
    $c->log->debug("assigned template: " .  $c->stash->{template});    
    
    # My end action isn't working... 
    $c->forward('WormBase::Web::View::TT');   
};



=head1 fetch_object()

Generically fetch an object from acedb when provided with
a class and object ID.

=cut

sub fetch : Chained('/') PathPart('fetch') CaptureArgs(2) {
    my ( $self, $c, $class, $name ) = @_;
    
    $c->log->debug("generic fetch: $class $name");
    
    # Generically fetch an object from AceDB if we've been passed
    # the name of an object.
    if ($name) {
#	$c->model('WormBase::Web::Model::AceDB')->fetch_object( $c, ucfirst($class), $name );
	$c->model('AceDB')->fetch_object( $c, ucfirst($class), $name );
    }
}




=head2 $app->register_page_actions()

For each Page -- typically but not always a database
class -- register a series of simple actions.

  - simple search
  - advanced search
  - report

For now, each Controller needs its own get_params method.
This seems pointless and redundant. 

Perhaps I should embed all dynamic queries under /db then chain to that.

  sub get_params : Chained('/') PathPart("gene") CaptureArgs(1) {
     my ($self,$c,$name) = @_;
     $c->stash->{request} = $name;
     #  my $ace = $c->model('AceDB');
  }

=cut

# PAGE actions to become /reports


sub register_page_actions {
    my ($self,$c) = @_;
    
    my @pages = $self->pages($c);
    foreach my $page (@pages) {	
	
	# When the class is called without parameters, 
	# present a page with the basic search enabled by default

		# A basic search for every class
#	$self->register_basic_search($self,$c,$page);
	

#	$c->log->debug("Registering get_object action for $page");
	
	my $page_code = sub {
	    my ( $self, $c, $name ) = @_;
            $c->stash->{request} = $name;
            # $c->action_namespace( ucfirst($page) );
            # my $namespace = $c->namespace;
        };

        my $page_action = $self->create_action(
                    name       => 'get_params',
                    reverse    => '/',
                    attributes => {
			Chained     => ['/'],
                        PathPart    => [$page],
                        CaptureArgs => [1],
                    },
                    namespace => $page,
                    code      => \&$page_code,
                    class     => 'WormBase::Web::Controller::' . ucfirst($page),
                );
        $c->dispatcher->register( $c, $page_action );

        # These need to be registered before I build any other actions.
        #$self->SUPER::register_actions(@_);    # or NEXT?
    
    }
}


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


#########################################
# Configuration actions
#########################################

# Configure widgets and fields for a given page


sub configure : Chained('/') PathPart('configure') Args(1) {
  
  # Fetch all available widgets for a page
  # Let users drag and drop widgets onto the configuration target ala WordPress 

  # Let users pick and choose which data bits to display
  
}

############################################                                                   
#                                                                                              
# REST                                                                                         
#                                                                                              
# Approach 1: Dynamically expose REST targets                                                  
# based on the site configuration.                                                             
#                                                                                              
############################################                                                   

=head2 $self->register_rest_uris()                                                             
    
    Expose REST uris for every page, widget, and field                                             
    
=cut                                                                                           
    
sub register_rest_uris {
    my ($self,$c) = @_;

=pod                                                                                           
                                                                                               
    $c->log->debug("Registering get_object action for $page");                                
                                                                                               
    my $page_code = sub {                                                                   
	my ( $self, $c, $name ) = @_;                                                       
	$c->stash->{request} = $name;                                                       
           # $c->action_namespace( ucfirst($page) );                                           
           # my $namespace = $c->namespace;
    }; 

         my $page_action = $self->create_action(                                               
                    name       => 'get_params',                                                
                    reverse    => "rest/$page",                                                
	            attributes => {
                           Chained     => ['/'],                                                  
                           PathPart    => ["rest/$page"],                                         
                           CaptureArgs => [1],                                                    
	            },                                                                         
                    namespace => $page,                                                        
                    code      => \&$page_code,                                                 
                    class     => 'WormBase::Web::Controller::REST' . ucfirst($page),           
                );                                                                             
        $c->dispatcher->register( $c, $page_action );                                          
                                                                                               
        # These need to be registered before I build any other actions.                        
        #$self->SUPER::register_actions(@_);    # or NEXT? 
=cut                                                                                                                                    

    my @pages = $self->pages($c);
    foreach my $page (@pages) {
	my @widgets = $self->widgets($page,$c);
	foreach my $widget (@widgets) {
	    
	    # Fetch all available fields for this widget
 	    my @fields = $self->fields( $page, $widget, $c );
	    @fields = $widget unless @fields;  # For cases where the config is empty, ie the name of the widget is also its contents. 
	    foreach my $field (@fields) {
		#       my $class = "WormBase::Web::Controller::" . ucfirst($page) . "::REST";
#		my $class = "WormBase::Web::Controller::REST::" . ucfirst($page);
                #  my $class = "WormBase::Web::Controller::REST";

		my $rest_noun_code = sub {
		    my ($self,$c) = @_;
		    $c->log->debug("here I am, in the rest noun code reference");
		};   # It doesn't really do anything.
		
		############################## 
		# APPROACH 1:
                # methods exist in WormBase::Web::Controller::REST::PAGE namespace      
		
		# APPROACH 2: methods exist in ::REST namespace; get_params accepts 2 ARgs (class,name) followed by the rest target        
		# APPROACH 2: methods exist in ::REST namespace; get_params accepts 2 ARgs (class,name) followed by the rest target
		############################## 
		my $class = "WormBase::Web::Controller::REST::" . ucfirst($page);
		my $rest_noun_action = $self->create_action(
		    name       => $field,
		    reverse    => "rest/$page/$field",
		    attributes => {
#                                                                 Chained     => ['get_params'],                                        
#                                                                 PathPart    => [$field],                                              
			Path        => [$field],
			CaptureArgs => [1],
			ActionClass => ['Catalyst::Action::REST'],
		    },
		    namespace => "rest/$page",
		    code      => \&$rest_noun_code,
		    class     => $class,
		    );
		
		if (0) {
		    my $rest_noun_action = $self->create_action(
			name       => $field,
			reverse    => "$field",
			attributes => {
			    Path        => ["$page/$field"],
			    CaptureArgs => [1],
			    ActionClass => ['REST'],
			},
			namespace => "rest/$page",
			code      => \&$rest_noun_code,
			class     => $class,
			);
		}
		$c->dispatcher->register( $c, $rest_noun_action );
                #       $self->SUPER::register_actions(@_);
		
                #       # CLASS: REST or $page?
                #       $self->_register_rest_verb($c,{name => $field;
                #                                     reverse => $field,
                #                                     reverse => "rest/$page/$field",
                #                                     class   => $class,
		#                                    });

		my $rest_verb_code = sub {
		    my ( $self, $c, $name ) = @_;
		    
		    # Instantiate the Model
		    my $model = $c->model(ucfirst($class));
                    #        $c->log->debug("here: $name");

                    # Fetch the field content and stash it.                   
                    #   $c->stash->{rest}->{$name} = $model->$name(); 
		    $c->stash->{$field} = $model->$field();
		    $self->status_ok( $c, entity => { $c->stash->{$field} } );
		};
		my $rest_verb_action = $self->create_action(
		    name       => $field . '_GET',
		    reverse    => "rest/$page/$field" . '_GET',
		    attributes => { Args => [0],
		    },
		    namespace => "rest/$page",
		    code      => \&$rest_verb_code,
		    class     => $class,
		    );
		$c->dispatcher->register( $c, $rest_verb_action );
	    }
	}
    }
}


=head2 $self->_register_rest_noun();                                                                                                    
                                                                                                                                        
Register a REST noun.                                                                                                                   
                                                                                                                                        
Here is an example for a field.                                                      
  sub genetic_position : Chained('fetch') PathPart('genetic_position') CaptureArgs(1) ActionClass('REST') {}                            

=cut

sub _register_rest_noun {
    my ($self,$c,$params) = @_;
    
    my $rest_noun_code = sub { };   # It doesn't really do anything. 
#  my $rest_noun_action = $self->create_action(                              
#                                             #     name       => $page . '_' . $field . "_rest",
#                                             #     reverse    => $field . "_rest",  
#                                             name       => $params->{name},              
#                                             reverse    => $params->{reverse},         
#                                             attributes => {
#                                                            Chained  => ['get_params'], 
#                                                            PathPart => [$params->{pathpart}],                                         
##                                                           Args     => [0],                                                           
#                                                           },                                                                          
#                                             namespace => 'rest',                                                                      
#                                             code      => \&$rest_noun_code,                                                           
#                                             class     => $params->{class},                                                            
#                                             #  class     => "WormBase::Web::Controller::" . ucfirst($page) . "::REST",                
#                                             # class     => "WormBase::Web::Controller::REST::" . ucfirst($params->{class}),           
#                                            );                                                                                         
    
    my $rest_noun_action = $self->create_action(
	name       => $params->{name},
	reverse    => $params->{reverse},
	attributes => {
	    Path => [$params->{pathpart}],
	    Args => [1],
	},
	namespace => 'rest',
	code      => \&$rest_noun_code,
	class     => $params->{class},
	);
    
    $c->dispatcher->register( $c, $rest_noun_action );
    return;
}

=head2 $self->_register_rest_verb()                                                                    
    
    Register a REST URI for a given field.  For now, we are only supplying GET.
    
    The final result looks like this:
    
    sub genetic_position_GET {                                           
	$c->stash->{genetic_position} = $c->model('WormBase::Web::Model::Gene')->genetic_position($c); 
	$self->status_ok( $c, entity => $c->stash );
}

=cut 


sub _register_rest_verb {
    my ($self,$c,$params) = @_;
    
    my $name       = $params->{name};
    my $this_class = $params->{class};
    
    my $rest_verb_code = sub {
	my ( $self, $c, $name ) = @_;
	
	# Instantiate the Model                                                                                                             
	my $model = $c->model(ucfirst($this_class));
	$c->log->debug("here: $name");
	
	# Fetch the field content and stash it.                                                                                             
	#   $c->stash->{rest}->{$name} = $model->$name();                                                                                   
	$c->stash->{$name} = $model->$name();
	$self->status_ok( $c, entity => { $c->stash->{$name} } );
    };
    
    my $rest_verb_action = $self->create_action(
	name       => $name . '_GET',
	reverse    => $params->{reverse} . '_GET',
	namespace => 'rest/gene',
	#"WormBase::Web::Controller::REST::Gene",                                                 
	code      => \&$rest_verb_code,
	class     => $this_class,
	);
    $c->dispatcher->register( $c, $rest_verb_action );
    return;
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
