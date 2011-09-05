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
    $c->log->warn($c->config->{memcached}->{servers});
    my $page = $c->model('Schema::Page')->find({url=>"/"});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
}


=head2 DEFAULT

The default action is run last when no other action matches.

=cut

sub default :Path {
    my ($self,$c) = @_;
    $c->log->warn("DEFAULT: couldn't find an appropriate action");
    
    my $path = $c->request->path;

    # A user may be trying to request the top level page
    # for a class. Capturing that here saves me
    # having to create a separate index for each class.
    my ($class) = $path =~ /reports\/(.*)/;

    # Does this path exist as one of our pages?
    # This saves me from having to add an index action for
    # each class.  Each class will have a single default screen.
    if (defined $class && $c->config->{pages}->{$class}) {
	
	# Use the debug index pages.
	if ($c->config->{debug}) {
	  $c->stash->{template} = 'debug/index.tt2';
	} else {
	    $c->stash->{template} = 'species/report.tt2';
	    $c->stash->{path} = $c->request->path;
	}
    } else {
	$c->detach('/soft_404');
    }
}

sub soft_404 :Path('/soft_404') {
    my ($self,$c) = @_;
    # 404: Page not found...
    $c->stash->{template} = 'status/404.tt2';
    $c->error('page not found');
    $c->response->status(404);
}
    


#sub gbrowse :Path("/gbrowse") Args(0) {
#    my ($self,$c) = @_;
#    $c->stash->{noboiler}=1;
#    $c->stash->{template} = 'gbrowse.tt2';
#}
sub header :Path("/header") Args(0) {
    my ($self,$c) = @_;
    $c->stash->{noboiler}=1;
    $c->stash->{template} = 'header/default.tt2';
}

sub footer :Path("/footer") Args(0) {
      my ($self,$c) = @_;
      $c->stash->{noboiler}=1;
      $c->stash->{template} = 'footer/default.tt2';
} 

sub draw :Path("/draw") Args(1) {
    my ($self,$c,$format) = @_;
    my ($cache_source,$cached_img);
    my $params = $c->req->params;
    if ($params->{class} && $params->{id}
        && (!defined $params->{size} || $params->{size} > 0)) {
        my @keys = ('image', $params->{class}, $params->{id}, $params->{size} // ());
	my $uuid = join('-',@keys);
	($cached_img,$cache_source) = $c->check_cache({ cache_name => 'couchdb',
							uuid       => $uuid });
        unless($cached_img){ # not cached -- make new image and cache
            # the following line is a security risk
            my $source = $c->model('WormBaseAPI')->pre_compile->{$params->{class}}
                       . "/".$params->{id} . "." . $format;
            $c->log->debug("Attempt to draw image: $source");

            $cached_img = new GD::Image->new($source);
            if ($params->{size}) {
                my $scale_factor = $params->{size}/100;
                my ($w, $h) = $cached_img->getBounds;
                my ($nw, $nh) = ($w * $scale_factor, $h * $scale_factor);
                my $new_img = GD::Image->new($nw, $nh);
                $new_img->copyResized($cached_img, 0, 0, 0, 0, $nw, $nh, $w, $h);
                $cached_img = $new_img;
            }
	    $c->set_cache({cache_name => 'couchdb',
			   uuid       => $uuid,
			   data       => $cached_img });
        }
    }
    else {
        $cached_img = $c->flash->{gd};
    }
    $c->stash(gd_image=>$cached_img);
    $c->detach('WormBase::Web::View::Graphics');
}

sub issue_rss {
 my ($self,$c,$count) = @_;
 my @issues = $c->model('Schema::Issue')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
    my $threads= $c->model('Schema::IssueThread')->search(undef,{order_by=>'timestamp DESC'} );
     
    my %seen;
    my @rss;
    while($_ = $threads->next) {
      unless(exists $seen{$_->issue_id}) {
	  $seen{$_->issue_id} =1 ;
	  
	  push @rss, {	time=>$_->timestamp,
			people=>$_->user,
			title=>$_->issue->title,
			location=>$_->issue->page,
			id=>$_->issue->issue_id,
			re=>1,
		    } ;
      }
      last if(scalar(keys %seen)>=$count)  ;
    };

    map {	 
		push @rss, {      time=>$_->timestamp,
					      people=>$_->reporter,
					      title=>$_->title,
					      location=>$_->page,
				  id=>$_->issue_id,
			};
	} @issues;

    my @sort = sort {$b->{time} <=> $a->{time}} @rss;
    return \@sort;
}
 

 
sub me :Path("/me") Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'section'} = 'me';
    $c->stash->{'class'} = "me";
    $c->stash->{template} = "me.tt2";
} 




##############################################################
#
#   Fields
#   URL space : /fields
#   Params    : class, object, field
##############################################################
sub field :Path("/field") Args(3) {
    my ($self,$c,$class,$name,$field) = @_;
    
    # Save the requested field for formatting
    $c->stash->{field} = $field;
    $c->stash->{class} = ucfirst($class);

    $c->stash->{noboiler} = 1;
 
    # Fetch our external model
    my $api = $c->model('WormBaseAPI');
    # Fetch the object from our driver	 
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
    $c->log->debug("The requested class is " . ucfirst($class));
    $c->log->debug("The request is " . $name);
    
    my $object = $api->fetch({class=> ucfirst($class),
			       name => $name}) or die "$!";
    
    $c->log->debug("Instantiated an external object: " . ref($object));
    # $c->stash->{object} = $object;
    
    # Fetch the field content and stash it.
    # This is goofy; the object of interest is wrapped inside an object...
#    my $ace_object = $object->object;
#    $c->log->debug("The internal object is: " . ref($ace_object));
    
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
    $c->stash->{template} = $c->_select_template($field,$class,'field');    
    $c->log->debug("assigned template: " .  $c->stash->{template});
    
    # My end action isn't working... 
    # TH 2010.07.02: no longer necessary but still testing
    # $c->forward('WormBase::Web::View::TT');
};

=pod

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
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
    $c->log->debug("The requested class is " . ucfirst($class));
    $c->log->debug("The request is " . $name);
    
    my $object = $api->fetch({class=> ucfirst($class),
			       name => $name}) or die "$!";
	
    $c->log->debug("Instantiated an external object: " . ref($object));
    
    # Should I stash the object so I only need to fetch it once?
    $c->stash->{object} = $object;

    # Fetch the field content and stash it.
    
    # Currently, I have to provide EVERY tag in my wrapper model
    # since I cannot find a sensible way to AUTOLOAD under Moose
    # (if indeed AUTOLOADing under Moose makes any sense at all...)
    # This is a horrendous hack; get the field from my wrapper object
    # if implemented, otherwise get it from the wrapped object.
    
    # Fetch all of the fields (in order) that comprise
    # this widget from the app configuration.
    
    # The templates for each field are actually specified in the widget.
#    my @fields = @{ $c->config->{pages}->{$class}->{widgets}->{$widget} };


    # Access the component fields of this widget by name
    my @fields = $c->_get_widget_fields($class,$widget);

    # Call each of the component field method and stash the data.
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
    $c->stash->{template} = $c->_select_template($widget,$class,'widget');
    

    # My end action isn't working... 
    # TH 2010.07.02: no longer necessary but still testing
    # $c->forward('WormBase::Web::View::TT');
};




##############################################################
#
#   Reports (composites of widgets)
#   URL space : /reports
#   Params    : class, object, page
# 
##############################################################
# sub report :Path("/reports") Args(2) {
#     my ($self,$c,$class,$name) = @_;
# #        $c->response->redirect('http://www.hotmail.com');
#  
#     # Set the name of the widget. This is used 
#     # to choose a template and label sections.
# #    $c->stash->{page}  = $class;    # Um. Necessary?
#     unless ($c->config->{pages}->{$class}) {
#       my $link = $c->config->{external_url}->{uc($class)};
#       $link  ||= $c->config->{external_url}->{lc($class)};
#       if ($link =~ /\%s/) {
#           $link=sprintf($link,split(',',$name));
#       } else {
#           $link.=$name;
#       }
#       $c->response->redirect($link);
#       $c->detach;
#     }
#     $c->stash->{query_name} = $name;
#     $c->stash->{class} = $class;
#     $c->log->debug($name);
#     
#     # For now, a quick hack. A query parameter that let's us
#     # change the reports view from tabs, to sections, to a single page
#     # An optional view type can be passed as a query parameter
#     $c->stash->{view} = $c->request->query_parameters->{view};
#     
#     # Instantiate our external model directly (see below for alternate)
#     my $api = $c->model('WormBaseAPI');
#     
#     # TODO
#     # I may not want to actually fetch an object.
#     # Maybe I'd be visiting the page without an object specified...If so, I should default to search panel
#     
#     
#     # I don't think I need to fetch an object.  I just need to return the appropriate page template.
#     # Then, each widget will make calls to the rest API.
#     my $object = $api->fetch({class=> ucfirst($class),
# 			      name => $name}) || $self->error_custom($c, 500, "can't connect to database");
#      
#     # $c->log->debug("Instantiated an external object: " . ref($object));
#     $c->res->redirect($c->uri_for('/search',$class,"$name")."?redirect=1")  if($object == -1 );
#   
#     $c->stash->{object} = $object;  # Store the internal ace object. Goofy.
# if($object != -1 ){
#     $c->stash->{external_links} = $object->external_links if $class eq 'gene'; #if $object->meta->has_method("external_links") 
# }
# =head
# 
#     # To add later:
#     # * multi-results formatting
#     # * nothing found.
#     
#     # Fetch the field content and stash it.
#     
#     # Currently, I have to provide EVERY tag in my wrapper model
#     # since I cannot find a sensible way to AUTOLOAD under Moose
#     # (if indeed AUTOLOADing under Moose makes any sense at all...)
#     # This is a horrendous hack; get the field from my wrapper object
#     # if implemented, otherwise get it from the wrapped object.
#     
#     # To generically build a widget, store
#     # an ordered list of all necessary fields.
#     # page is $c->namespace;			
# 
# =cut
# 
#     # Stash the symbolic name of all widgets that comprise this page in default order.
# #     my @widgets = @{$c->config->{pages}->{$class}->{widget_order}};
# #     $c->stash->{widgets} = \@widgets;
# }

=cut



##############################################################
#
#   Resources
#   URL space : /resources
#   Params    : class, object
# 
##############################################################
# sub resources :Path("/resources") Args(2) {
#     my ($self,$c,$class,$name) = @_;
# 
#     $c->stash->{section} = 'resources';
#     $c->stash->{template} = 'report.tt2';
# 
#     unless ($c->config->{sections}->{resources}->{$class}) { 
#       # class doens't exist in this section
#       $c->detach;
#     }
# 
#     $c->stash->{query_name} = $name;
#     $c->stash->{class} = $class;
#     $c->log->debug($name);
#     
#     my $api = $c->model('WormBaseAPI');
#     my $object = $api->fetch({class=> ucfirst($class),
#                   name => $name}) || $self->error_custom($c, 500, "can't connect to database");
#      
#     $c->res->redirect($c->uri_for('/search',$class,"$name")."?redirect=1")  if($object == -1 );
# 
#     $c->stash->{object} = $object;  # Store the internal ace object. Goofy.
# }
# 
# 
# 
# 
# 




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
# in the dynamic action itself. 



#sub end : Path {
sub end : ActionClass('RenderView') {
  my ($self,$c) = @_;      
  
  # Forward to our view FIRST.
  # If we catach any errors, direct to
  # an appropriate error template.
  my $path = $c->req->path;
  if($path =~ /\.html/){
	$c->serve_static_file($c->path_to("root/static/$path"));
  } else{
  	$c->forward('WormBase::Web::View::TT') unless ($c->req->path =~ /cgi-bin|cgibin/i || $c->action->name eq 'draw');
 }

  # 404 errors will be caught in default.
  #$c->stash->{template} = 'status/404.tt2';
  #$c->response->status(404);

  # 5xx
#  if ( my @errors = @{ $c->errors } ) {
#      $c->response->content_type( 'text/html' );
#      $c->response->status( 500 );
#      $c->response->body( qq{
#                        <html>
#                        <head>
#                        <title>Error!</title>
#                        </head>
#                        <body>
#                                <h1>Oh no! An Error!</h1>
#			  } . ( map { "<p>$_</p>" } @errors ) . qq{
#                        </body>
#                        </html>
#			  } );
#  }

}

# /quit, used for profiling so that NYTProf can exit cleanly.
sub quit :Global { exit(0) }


#sub end : ActionClass('RenderView') {  }


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
