package WormBase::Web::Controller::Root;

use strict;
use warnings;
use base 'WormBase::Web::Controller';
#use base 'Catalyst::Controller';

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

sub index : Private {
  my ( $self, $c ) = @_;
  $c->res->body("Hello, WormBase users!");
}


=head2 DEFAULT

The default action. Before we 404 bomb out, let's check and see if we
are trying to display a class index page. This isn't optimal.

=cut

sub default : Private {
  my ( $self, $c ) = @_;
  
  my $path = $c->request->path;
  
  # Does this path exist as one of our pages?
  # This saves me from having to add an index action for
  # each class.  Each class will have a single default screen.
  if ($c->config->{pages}->{lc($path)}) {
    
    # Use the debug index pages.
    if ($c->config->{debug}) {
      $c->stash->{template} = 'debug/class_index.tt2';
      $c->stash->{path} = $c->request->path;
      # $c->response->body('Matched WormBase::Web::Controller::Gene_class in Gene_class.');
    } else {
      $c->stash->{template} = 'generic/index.tt2';
      $c->stash->{path} = $c->request->path;
    }
  } else {
    $c->res->status(404);
    $c->stash->{template} = 'status/404.tt2';
  }
}


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
    $c->model('WormBase::Web::Model::AceDB')->fetch_object( $c, ucfirst($class), $name );
  }
}


=head1 register_actions();

Over-ride Catalyst's default register_actions()
method to programmatically create actions for
each page, widget, field.

=cut

sub register_actions {
  my $self = shift;
  my ($c) = @_;
  
  #$c->config->{debug} = { ignore_classes => [] };
  
  $self->register_dynamic_actions($c) or warn "Couldn't register dynamic actions: $!";
  return $self->SUPER::register_actions(@_); # or warn "Couldn't register_actions: $!";    # or NEXT?
}

=head1 register_dynamic_actions()

Create actions for every page, widget, and field.

These actions are created at application launch by
over-riding Catalyst's register_actions() method, 
and in turn call register_dynamic_actions().

=cut

sub register_dynamic_actions {
  my ($self,$c) = @_;
  
  $self->register_classic_page_actions($c);
  
#  $self->register_page_actions($c);
#  $self->register_widget_actions($c);
#  $self->register_field_actions($c);

  $self->register_rest_uris($c);  
}


=head2 $app->register_page_actions()

Register a dynamic action for each page.  This
will be the parent of the chain, simply stashing
the argument passed to it.

  sub get_params : Chained('/') PathPart("gene") CaptureArgs(1) {
     my ($self,$c,$name) = @_;
     $c->stash->{request} = $name;
     #  my $ace = $c->model('AceDB');
  }

=cut

sub register_page_actions {
  my ($self,$c) = @_;

  my @pages = $self->pages($c);
  foreach my $page (@pages) {

=pod

This does not work!  Do I need to register the get_params actions
before I can chain against it?

       $c->log->debug("Registering get_object action for $page");

       my $page_code = sub {
           my ( $self, $c`, $name ) = @_;
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

=cut
    
  }
}


=head2 $self->register_widget_actions

Generate actions for every widget.

Here's an example of what a widget action looks like once generated:

  sub identification_widget : Chained('get_params') PathPart('identification') Args(0) {
    my ( $self, $c ) = @_;
    
    # Set the name of the widget. This is used 
    # to choose a template and label sections.
    $c->stash->{widget} = 'identification';
    $c->stash->{class}  = 'Gene';
    
    # To generically build a widget, store
    # an ordered list of all necessary fields.
    # page is $c->namespace;			
    my @fields = @{ $c->config->{available_widgets}->{gene_page}->{identification} };
    
    $c->stash->{fields} = \@fields;
    
    # Stash the appropriate templates for each field.
    # The widget template itself will rely on these. Necessary? Doesn't each field choose its template?
    foreach (@fields) {
      my $template;
      # Approach 1:
      # Most templates are custom so fall through to that state.
      if (defined $c->config->{common_fields}->{$_}) {
	$template = "common_fields/$_.tt2";
      } elsif (defined $c->config->{generic_fields}->{$_}) {
	$template = "generic/field.tt2";
      } else {  
	$template = "gene/$_.tt2";
      }
      # $c->stash->{fields}->{$_} = $template;
    }
    
    # Forward to each of the component fields.
    foreach my $field (@fields) {
      $c->forward($field);
    }
    
    # Did we request the widget by ajax?
    # Supress boilerplate wrapping.
    if ( $c->is_ajax() ) {
      $c->stash->{noboiler} = 1;
    }
    
    # Normally, the template defaults to action name.
    # However, we have some generic templates. We will
    # specify the name of the template.  
    # MOST widgets can use a generic template.
    if (defined $c->config->{generic_widgets}->{identification}) {
      $c->stash->{template} = "generic/widget.tt2";    
      # Some are shared across Models
    } elsif (defined $c->config->{common_widgets}->{identification}) {
      $c->stash->{template} = "common_widgets/identification.tt2";
    } else {  
      $c->stash->{template} = "gene/widgets/identification.tt2";
    }
  }

=cut
    
sub register_widget_actions {
  my ($self,$c) = @_;
  
  my @pages = $self->pages($c);
  foreach my $page (@pages) {  
    my @widgets = $self->widgets($page,$c);
    foreach my $widget (@widgets) {
      
      # Chaining widgets and fields
      # Widgets and fields are both chained to the same parent.
      # Although we *could* chain as class/widget/field, these means
      # that users must know to which widget a field belongs.
      
      # To change to /gene/ID/widget, set to 'fetch';
      # Each Controller will also have to implement a fetch().
      my $chain_to = 'get_params';
      
      $c->log->debug("Registering action for the $page:$widget widget");
      
      my $widget_code = sub {
	my ( $self, $c ) = @_;
	
	# Set the name of the widget and save it's class.
	# These are used to pick the correct templates for component sections.
	# Templates are stored in the file system by its class.
	$c->stash->{widget} = $widget;
	$c->stash->{class}  = $page;
	
	# $page could possibly be $c->namespace?     
	
	# Store an ordered list of all available fields for
	# the widget so we can build it generically
	my (@fields) =
	  @{ $c->config->{pages}->{$page}->{widgets}->{$widget} };
	
	$c->stash->{fields} = \@fields;
	
	# This is a second approach, where I actually store both
	# the field and its required template. If I was checking for
	# the existence of a template on the FS, this could go away
	foreach (@fields) {
	  my $template;
	  # Approach 1:
	  # Most templates are custom so fall through to that state.
	  if (defined $c->config->{common_fields}->{$_}) {
	    $template = "common_fields/$_.tt2";
	  } elsif (defined $c->config->{generic_fields}->{$_}) {
	    $template = "generic/field.tt2";
	  } else {  
	    $template = "$page/$_.tt2";
	  }
	  #        $c->stash->{fields}->{$_} = $template;
	}
	
	# Dealing with so-called "empty" widgets
	@fields = $widget unless @fields;
	foreach my $field (@fields) {
	  $c->forward($field);
	}
	
	if ( $c->is_ajax() ) {
	  $c->stash->{noboiler} = 1;
	}
	
	# MOST widgets can use a generic template.
	if (defined $c->config->{generic_widgets}->{$widget}) {
	  $c->stash->{template} = "generic/widget.tt2";
	  # Some are shared across Models
	} elsif (defined $c->config->{common_widgets}->{$widget}) {
	  $c->stash->{template} = "common_widgets/$widget.tt2";
	} else {  
	  $c->stash->{template} = "$page/widgets/$widget.tt2";
	}
      };
      
      # Create and register the action
      my $widget_action = $self->create_action(
					       name       => $widget . '_widget',
					       reverse    => "$page/$widget",
					       attributes => {
							      Chained  => [$chain_to],
							      PathPart => [$widget],
							      Args     => [0],
							     },
					       namespace => $page,
					       code      => \&$widget_code,
					       class     => 'WormBase::Web::Controller::' . ucfirst($page),
					      );
      $c->dispatcher->register( $c, $widget_action ) or die "$!";
    }   
  }
}



=head2 $self->register_field_actions($c);

Generate actions for every field.

Here's an example of a field action once generated:

  sub common_name : Chained('get_params') PathPart('test') Args(0) {
      my ($self,$c) = @_;
      
      # Instantiate the correct model
      my $model = $c->model('Gene');
      
      # Fetch the appropriate field
      $c->stash->{common_name} = $model->common_name();
      
      # Stash the correct template
      $c->stash->{template} = 'common_fields/common_name.tt2';
    }

=cut

sub register_field_actions {    
  my ($self,$c) = @_;
  
  my @pages = $self->pages($c);
  foreach my $page (@pages) {
    my @widgets = $self->widgets($page,$c);
    foreach my $widget (@widgets) {
      
      # Fetch all available fields for this widget
      my @fields = $self->fields( $page, $widget, $c );
      @fields = $widget unless @fields;  # For cases where the config is empty, ie the name of the widget is also its contents.
      foreach my $field (@fields) {
	# $c->log->debug("Registering action for $page:$widget:$field");
	
	my $code = sub {
	  my ($self, $c) = @_;
	  
	  # Necessary?
	  # $c->action_namespace( ucfirst($page) );
	  
	  # Instantiate the Model
	  my $class = $c->model(ucfirst($page));
	  
	  # Choosing which template to render:
	  # 1. Is it common field/widget?
	  # 2. Is it a custom field/widget?
	  # 3. Fall back to generic field/widget
	  
	  # Approach 1:
	  # Most templates are custom so fall through to that state.
	  if (defined $c->config->{common_fields}->{$field}) {
	    $c->stash->{template} = "common_fields/$field.tt2";
	  } elsif (defined $c->config->{generic_fields}->{$field}) {
	    $c->stash->{template} = "generic/field.tt2";
	  } else {  
	    $c->stash->{template} = "$page/$field.tt2";
	  }
	  
	  # Approach 2: Most things are generic, those requiring custom fields are specified
	  #if (defined ($c->config->{custom_fields}->{$field})) {
	  #  $c->stash->{template} = "$page/$field.tt2";
	  #} elsif (defined ($c->config->{common_fields}->{$field})) {
	  #  $c->stash->{template} = "common_fields/$field.tt2";
	  #} else {
	  #  $c->stash->{template} = "generic/field.tt2";	  
	  #}
	  
	  # What to store for my session
	  #	push @{ $c->session->{field}}, $field;
	  
	  # Save the requested field for formatting
	  $c->stash->{field} = $field;
	  
	  # Fetch the field content and stash it.
	  $c->stash->{$field} = $class->$field();
	};
	
	my $action = $self->create_action(
					  name       => "$field",
					  reverse    => "$page/$field",
					  attributes => {
							 Chained  => ['get_params'],
							 PathPart => ["$field"],
							 Args     => [0],
							},
					  namespace => $page,
					  code      => \&$code,
					  class     => 'WormBase::Web::Controller::' . ucfirst($page),
					 );
	
	$c->dispatcher->register( $c, $action ) or warn "Couldn't register action for $page:$widget:$field: $!";
	
      }
    }
  }
}


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
       my $class = "WormBase::Web::Controller::REST::" . ucfirst($page);
#       my $class = "WormBase::Web::Controller::REST";       

       my $rest_noun_code = sub {
	 my ($self,$c) = @_;
	 $c->log->debug("here I am, in the rest noun code reference");
       };   # It doesn't really do anything.

       ##############################
       # APPROACH 1:
       # methods exist in WormBase::Web::Controller::REST::PAGE namespace
       
       # APPROACH 2: methods exist in ::REST namespace; get_params accepts 2 ARgs (class,name) followed by the rest target
       ##############################
       my $class = "WormBase::Web::Controller::REST::" . ucfirst($page);
       my $rest_noun_action = $self->create_action(
						   name       => $field,
						   reverse    => "rest/$page/$field",
						   attributes => {
#								  Chained     => ['get_params'], 
#								  PathPart    => [$field],
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
#       $self->_register_rest_verb($c,{name => $field,
#				      reverse => $field,
#				      reverse => "rest/$page/$field",
#				      class   => $class,
#				     });
#       


       
       my $rest_verb_code = sub {
	 my ( $self, $c, $name ) = @_;
	 
	 # Instantiate the Model
	 my $model = $c->model(ucfirst($class));
#	 $c->log->debug("here: $name");
	 
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
#					      #                                             name       => $page . '_' . $field . "_rest",
#					      #                                             reverse    => $field . "_rest",
#					      name       => $params->{name},
#					      reverse    => $params->{reverse},
#					      attributes => {
#							     Chained  => ['get_params'], 
#							     PathPart => [$params->{pathpart}],
##							     Args     => [0],
#							    },
#					      namespace => 'rest',
#					      code      => \&$rest_noun_code,
#					      class     => $params->{class},
#					      #  class     => "WormBase::Web::Controller::" . ucfirst($page) . "::REST",
#					      # class     => "WormBase::Web::Controller::REST::" . ucfirst($params->{class}),
#					     );

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
      my ($self,$c) = @_;
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



sub register_classic_page_actions {
  my ($self,$c) = @_;
  
  # REGISTER dynamic full page actions using the classic site
  
  # Recreate the classic URL paths
  my %pages2classic_urls = (
			    operon      => '/db/gene',
			    transgene   => '/db/gene',
			    variation   => '/db/gene',
			   ); 
  
  foreach my $page (keys %pages2classic_urls) {
    
    my $code = sub {
      my ($self,$c,$request) = @_;
      
      $request = $c->req->params->{name};
      
      # Seed the request so I can fetch the correct object
      $c->stash->{request} = $request;  # This is the REQUEST (as opposed to the OBJECT returned)
      
      # Instantiate the correct model (and fetch the object)
      my $model = $c->model(ucfirst($page));
      
      my @widgets = $self->widgets($page,$c);
      $c->stash->{widgets} = \@widgets;
      
      # Did I request an object and retrieve one?
      if ($request && $model->current_object() ) {
	
	#	# Get all required sections (widgets) and subsections (fields)
	my @widgets = $self->widgets($page,$c);
	$c->stash->{widgets} = \@widgets;
	
	foreach my $widget (@widgets) {
	  my @fields = $self->fields($page,$widget,$c);
	  $c->stash->{fields}->{$widget} = \@fields;
	  foreach my $field (@fields) {	    
	    $c->log->info("$field $widget");
	    
	    # Forward to each of the fields.
	    $c->stash->{$field} = $model->$field;	  
	  }
        }
        $c->stash->{name}             = $model->current_object();
        $c->stash->{species}          = $model->species();
      }    
      
      $c->stash->{class}               = ucfirst($page);
      $c->stash->{page}               = $page;
      $c->stash->{target}             = $pages2classic_urls{$page};
      
      # CURRENTLY THE CLASSIC TEMPLATES ARE NOT GENERIC - I need classic_report.tt2
      # FOR EACH PAGE.   I should make this generic
      
      # Stash the classic report template
      # This needs to INCLUDE and wrap according to classic settings
      $c->stash->{classic} = 1;
      #      $c->stash->{template} = "classic/report_$page.tt2";  
      #      $c->stash->{template} = "classic/page-ajax.tt2";  
      $c->stash->{template} = "classic/report.tt2";  
    };
    
    my $action = $self->create_action(name    => $pages2classic_urls{$page} . "/$page",
				      reverse     => $pages2classic_urls{$page} . "/$page",
				      attributes => {
						     Path => [$pages2classic_urls{$page} . "/$page"],
						    },
                                      namespace  => $page,
				      code            => \&$code,
				      class           => 'WormBase::Web::Controller::' . ucfirst($page),
				     );
    
    $c->dispatcher->register( $c, $action ) or die "$!";
  }
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





=pod

sub display : Chained("/") PathPart('display') CaptureArgs(2) {
	my ($self,$c,$class,$name) = @_;

	# Save the current page for easy access. I'll need this
	# for the actual report.
	$c->stash->{display_class} = $class;

	if ($name) {
    	$c->model('WormBase::Web::Model::AceDB')->fetch_object( $c, $class, $name );
	}
}

=cut



###################################
# The generic report controller
###################################

=pod

sub report : Chained('/') PathPart('display') CaptureArgs(2) {
  my ( $self, $c, $page, $name ) = @_;
  
  my $page = $c->stash->{display_class};    # Why is this called display class?
  
  # How to get the page/class?
  my @widgets = $self->widgets( $page, $c );
  
#  $c->stash->{view}  = $view_type;
  $c->stash->{title} = "$page Summary";
  
  my $view_type;

  # Dynamically building a page from available widgets - unbuffered
  # Each widget is rendered in turn.
  if ( $view_type eq 'unbuffered' ) {
    
    # We'll render the page template-by-template instead of all at once.
    # This means that we have to break away from full-page wrapping.
    # Instead, each section will be rendered and wrapped into a widget
    # and/or loaded by ajax.
    $c->stash->{unbuffer} = 1;
    
    $c->finalize_headers();
    
    $c->write(
	      $c->view('TT')->render( $c, "boilerplate/html_start", $c->stash ) );
    
    foreach my $widget (@widgets) {
      $c->log->info("Building the $widget widget...");
      
      # Save the name of the widget for formatting
      $c->stash->{widget} = $widget;
      
      # Fetch the fields for each widget
      my @fields = $self->fields( $page, $widget, $c );
      foreach my $field (@fields) {
	$c->log->debug("adding the $field field to the $widget widget");
	if ( $widget eq 'references' ) {
	  
	  #		$c->forward($c->uri_for('/references', 'Gene','unc-26'));
	  #			$c->forward("/references/Gene/unc-26");
	  $c->forward( "/references/"
		       . $c->stash->{object} . "/"
		       . $c->stash->{object}->class );
	} else {
	  $c->forward($_);
	}
      }
      
      my $template =
	( $widget eq 'references' )
	  ? 'paper/references.tt2'
	    : "gene/widgets/$widget.tt2";
      
      # Render and wrap the widget
      $c->write( $c->view('TT')->render( $c, $template, $c->stash ) );
    }
  } else {
    
    # Available options include: "tabs, lazy_tabs, sidebar, portlets"
    $c->stash->{widgets}  = \@widgets;
    $c->stash->{template} = 'report.tt2';
  }
}

=cut


=pod

DEPRECATED.  Each Controller now has its own references action.

It might be a smaller memory footprint with a single references action...

ie: /references/id

###################################
#  WIDGET: REFERENCES
#
#  url: /references/OBJECT_ID/OBJECT_CLASS
###################################

# Generically display all references for a given object
sub references_widget : Chained('/') PathPart('references') Args(2) {
    my ( $self, $c, $name, $class ) = @_;

    # Generically fetch an object from AceDB if we've been passed
    # the name of an object.
    if ($name) {    # Fetch an object if we've been given one.
        $c->model('AceDB')->fetch_object( $c, $name );
    }

    #    $c->forward('/paper/references');
    $c->stash->{references} =
      $c->model('WormBase::Web::Model::Paper')->references($c);

    if ( $c->is_ajax() ) {
        $c->stash->{noboiler} = 1;
        $c->stash->{template} = 'paper/references.tt2';
    }
    $c->stash->{template} = 'paper/references.tt2';
}

=cut


=head2 end

Attempt to render a view, if needed.

=cut 

#sub end : ActionClass('RenderView') {  }

# This is a kludge.  RenderView keeps tripping over itself
# for some Model/Controller combinations with the dynamic actions.
#  Namespace collision?  Missing templates?  I can't figure it out.

# This hack requires that the template be specified
# in the dynamic action itself.  Further, I have a list of fields
# which use generic templates in the configuration.
sub end : Private {
  my ($self,$c) = @_;
  $c->forward('Wormbase::Web::View::TT');
}


=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
