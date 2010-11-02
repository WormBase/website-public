package WormBase::Web::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';
use Time::Duration;
use XML::Simple;

__PACKAGE__->config(
    'default' => 'text/x-yaml',
    'stash_key' => 'rest',
    'map' => {
      'text/html'        => [ 'View', 'TT' ],
      'text/xml' => 'XML::Simple',
    }
);

=head1 NAME

WormBase::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut
 
sub workbench :Path('/rest/workbench') :Args(0) :ActionClass('REST') {}
sub workbench_GET {
    my ( $self, $c) = @_;
	my $path = $c->req->params->{ref};
	if($path){
      my ($type, $class, $id) = split(/\//,$path); 
      $c->log->debug("type: $type, class: $class, id: $id");
      $type = "my_library" if ($class eq 'paper');
      my $name = $c->req->params->{name} || "this $class";
      if(exists $c->user_session->{bench} && exists $c->user_session->{bench}{$type}{$class}{$id}){
            $c->user_session->{bench}{count}--;
            delete $c->user_session->{bench}{$type}{$class}{$id};
            $c->stash->{notify} = "$name has been removed from your favourites"; 
      } else{
            $c->user_session->{bench}{count}++;
            $c->user_session->{bench}{$type}{$class}{$id}=localtime();
            $c->stash->{notify} = "$name has been added to your favourites"; 
      }
      $c->stash->{path} = $path; 
    }
 	$c->stash->{noboiler} = 1;

    my $count = scalar($c->user_session->{bench}{count}) || 0;
    $c->stash->{count} = $count;
#     $c->response->body("($count)");
    $c->stash->{template} = "workbench/count.tt2";
} 

sub workbench_star :Path('/rest/workbench/star') :Args(0) :ActionClass('REST') {}

sub workbench_star_GET{
    my ( $self, $c) = @_;
    $c->log->debug("workbench_star method");
    my $path = $c->req->params->{ref};
    my $wbid = $c->req->params->{id};
    my $name = $c->req->params->{name};
    $c->log->debug("workbench_star method: path = $path");
    my ($type, $class, $id) = split(/\//,$path); 
    $type = "my_library" if ($class eq 'paper');
    if(exists $c->user_session->{bench} && exists $c->user_session->{bench}{$type}{$class}{$id}){
          $c->stash->{star} = 1;
    } else{
        $c->stash->{star} = 0;
    }
    $c->stash->{path} = $path;
    $c->stash->{id} = $wbid;
    $c->stash->{name} = $name;
    $c->stash->{template} = "workbench/status.tt2";
    $c->stash->{noboiler} = 1;
}

sub layout :Path('/rest/layout') :Args(2) :ActionClass('REST') {}

sub layout_POST {
  my ( $self, $c, $class, $layout) = @_;
  $layout = 'default' unless $layout;
#   my %layoutHash = %{$c->user_session->{'layout'}->{$class}};
  my $i = 0;
  if($layout ne 'default'){
    $c->log->debug("max: " . join(',', (sort {$b <=> $a} keys %{$c->user_session->{'layout'}->{$class}})));
    
    $i = ((sort {$b <=> $a} keys %{$c->user_session->{'layout'}->{$class}})[0]) + 1;
    $c->log->debug("not default: $i");
  }
  $c->log->debug($i);
  my $left = $c->request->body_parameters->{'left[]'};
  my $right = $c->request->body_parameters->{'right[]'};  
  my $leftWidth = $c->request->body_parameters->{'leftWidth'};
  $c->user_session->{'layout'}->{$class}->{$i}->{'name'} = $layout;
  $c->user_session->{'layout'}->{$class}->{$i}->{'left'} = $left;
  $c->user_session->{'layout'}->{$class}->{$i}->{'right'} = $right;
  $c->user_session->{'layout'}->{$class}->{$i}->{'leftWidth'} = $leftWidth;
}

sub layout_GET {
  my ( $self, $c, $class, $layout) = @_;
  $c->stash->{noboiler} = 1;
  if ($c->req->params->{delete}){
    delete $c->user_session->{'layout'}->{$class}->{$layout};
    return;
  }


  my $left = $c->user_session->{'layout'}->{$class}->{$layout}->{'left'};
  my $right = $c->user_session->{'layout'}->{$class}->{$layout}->{'right'};
  my $leftWidth = $c->user_session->{'layout'}->{$class}->{$layout}->{'leftWidth'};
  my $name = $c->user_session->{'layout'}->{$class}->{$layout}->{'name'};
  if(ref($left) eq 'ARRAY') {$left = join(',', @$left);}
  if(ref($right) eq 'ARRAY') {$right = join(',', @$right);}

  $c->log->debug("left:" . $left);
  $c->log->debug("right:" . $right);
  $c->log->debug("leftWidth:" . $leftWidth);

  $self->status_ok(
      $c,
      entity =>  {left => $left,
          right => $right,
          leftWidth => $leftWidth,
          name => $name,
      },
  );
}

sub layout_list :Path('/rest/layout_list') :Args(1) :ActionClass('REST') {}

sub layout_list_GET {
  my ( $self, $c, $class ) = @_;
  my @layouts = keys(%{$c->user_session->{'layout'}->{$class}});
  my %l;
  map {$l{$_} = $c->user_session->{'layout'}->{$class}->{$_}->{'name'};
       $c->log->debug($c->user_session->{'layout'}->{$class}->{$_}->{'name'});
      } @layouts;
  $c->log->debug("layout list:" . join(',',@layouts));
  $c->stash->{layouts} = \%l;#\@layouts;
  $c->stash->{template} = "boilerplate/layouts.tt2";
  $c->stash->{noboiler} = 1;
}


sub _bench {
    my ($self,$c, $widget) = @_; 
    $c->log->debug("getting bench widget");
    my $api = $c->model('WormBaseAPI');
    my @ret;
    my $type;
    if($widget=~m/user_history/){
      $self->history_GET($c);
      return;
    }
    if($widget=~m/my_library/){ $type = 'paper';} else { $type = 'all';}
    foreach my $class (keys(%{$c->user_session->{bench}{$widget}})){
      my @objs;
      foreach my $id (keys(%{$c->user_session->{bench}{$widget}{$class}})){
        my $obj = $api->fetch({class=> ucfirst($class),
                          name => $id}) or die "$!";
        push(@objs, $obj);
      }
      push(@ret, @{$api->search->_wrap_objs(\@objs, $class)});
    }
    @ret = map{
            my $class = lcfirst($_->{name}->{class});
            my $id = $_->{name}->{id};
            $_->{footer} = "added " . $c->user_session->{bench}{$widget}{$class}{$id};
            $_;
              } @ret;
    $c->stash->{'results'} = \@ret;
    $c->stash->{'type'} = $type; 
    $c->stash->{template} = "search/results.tt2";
    $c->stash->{noboiler} = 1;
}


sub auth :Path('/rest/auth') :Args(0) :ActionClass('REST') {}

sub auth_GET {
    my ($self,$c) = @_;   
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "nav/status.tt2"; 
    $self->status_ok($c,entity => {});
}


sub history :Path('/rest/history') :Args(0) :ActionClass('REST') {}

sub history_GET {
    my ($self,$c) = @_;
    my $clear = $c->req->params->{clear};
    if($clear){ delete $c->user_session->{history};}
    my $history = $c->user_session->{history};
    my $size = (scalar keys(%{$history}));
    my $count = $c->req->params->{count} || $size;
    if($count > $size) { $count = $size; }
    my @history_keys = sort {@{$history->{$b}->{time}}[-1] <=> @{$history->{$a}->{time}}[-1]} (keys(%{$history}));
    my @ret = map {$history->{$_}->{path} = $_; $history->{$_}} @history_keys[0..$count-1];
    @ret = map {
      my $t = (time() - @{$_->{time}}[-1]); 
      $_->{time_lapse} = concise(ago($t, 1));
      $_ } @ret;
    $c->stash->{history} = \@ret;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "shared/fields/user_history.tt2"; 
    $self->status_ok($c,entity => {});
}


sub history_POST {
    my ($self,$c) = @_;
    $c->log->debug("history logging");
    my $path = $c->req->params->{ref};
    unless($c->user_session->{history}->{$path}){
      my ($i,$type, $class, $id) = split(/\//,$path); 
      my $name = $c->req->params->{name} || $id;
      $c->log->debug("type:$type, class:$class, id:$id, name:$name");
      $c->user_session->{history}->{$path}->{data} = { label => $name, class => $class, id => $id, type => $type };
    }
    push(@{$c->user_session->{history}->{$path}->{time}}, time());
}


sub evidence :Path('/rest/evidence') :Args :ActionClass('REST') {}

sub evidence_GET {
    my ($self,$c,$class,$name,$tag,$index,$right) = @_;

    my $headers = $c->req->headers;
    $c->log->debug($headers->header('Content-Type'));
    $c->log->debug($headers);
   
    unless ($c->stash->{object}) {
	# Fetch our external model
	my $api = $c->model('WormBaseAPI');
 
	# Fetch the object from our driver	 
	$c->log->debug("WormBaseAPI model is $api " . ref($api));
	$c->log->debug("The requested class is " . ucfirst($class));
	$c->log->debug("The request is " . $name);
	
	# Fetch a WormBase::API::Object::* object
	# But wait. Some methods return lists. Others scalars...
	$c->stash->{object} =  $api->fetch({class=> ucfirst($class),
					    name => $name}) or die "$!";
    }
    
    # Did we request the widget by ajax?
    # Supress boilerplate wrapping.
    if ( $c->is_ajax() ) {
	$c->stash->{noboiler} = 1;
    }

    my $object = $c->stash->{object};
    my @node = $object->object->$tag; 
    $right ||= 0;
    $index ||= 0;
    my $data = $object-> _get_evidence($node[$index]->right($right));
    $c->stash->{evidence} = $data;
    $c->stash->{template} = "shared/generic/evidence.tt2"; 

    my $uri = $c->uri_for("/reports",$class,$name);
    $self->status_ok($c, entity => {
	                 class  => $class,
			 name   => $name,
	                 uri    => "$uri",
			 evidence => $data
		     }
	);
}

sub search_new :Path('/search_new')  :Args(2) {
    my ($self, $c, $type, $query) = @_;
      
    $c->stash->{'search_guide'} = $query if($c->req->param("redirect"));
    if($type eq 'all' && !(defined $c->req->param("view"))) {
	$c->log->debug(" search all kinds...");
	$c->stash->{template} = "search/full_list.tt2";
	$c->stash->{type} =  [keys %{ $c->config->{pages} } ];
    } else {
	$c->log->debug("$type search");
	 
	my $api = $c->model('WormBaseAPI');
	my $class =  $c->req->param("class") || $type;
	my $search = $type;
	$search = "basic" unless  $api->search->meta->has_method($type);
	my $objs = $api->search->$search({class => $class, pattern => $query});
	if(@$objs<1) { #this may not be optimal
	  $query.="*";
	  $objs = $api->search->$search({class => $class, pattern => $query}) ;
	}
	$c->stash->{'type'} = $type; 
	$c->stash->{'results'} = $objs;
	if(defined $c->req->param("inline")) {
	  $c->stash->{noboiler} = 1;
	} elsif(@$objs==1 ) {
	    $c->res->redirect($c->uri_for('/reports',$type,$objs->[0]->{obj_name}));
	} 
        $c->stash->{template} = "search/results.tt2";
    }
    $c->stash->{'query'} = $query;
    $c->stash->{'class'} = $type;
     
}

#  
# sub search :Path('/rest/search') :Args(2) :ActionClass('REST') {}
# 
# sub search_GET {
#     my ($self,$c,$class,$name) = @_; 
#    
#     unless ($c->stash->{object}) {
# 	
# 	# Fetch our external model
# 	my $api = $c->model('WormBaseAPI');
# 	
# 	# Fetch the object from our driver	 
# 	$c->log->debug("WormBaseAPI model is $api " . ref($api));
# 	$c->log->debug("The requested class is " . ucfirst($class));
# 	$c->log->debug("The request is " . $name);
# 	
# 	# Fetch a WormBase::API::Object::* object
# 	# But wait. Some methods return lists. Others scalars...
# 	$c->stash->{object} = $api->fetch({class=> ucfirst($class),
# 					   name => $name}) or die "$!";
#     }
#     my $object = $c->stash->{object};
# 
#     # TODO: Load up the data content.
#     # The widget itself could make a series of REST calls for each field
#     
#     foreach my $field (@{$c->config->{pages}->{$class}->{search}->{fields}}) {
# 	my $data = $object->$field if  $object->meta->has_method($field);
# 	$c->stash->{'fields'}->{$field} = $data;
#     }
#  
#  
#     my $uri = $c->uri_for("/rest/search",$class,$name);
#     $c->stash->{class}=$class;
#     $c->stash->{id}=$name;
#     $c->stash->{noboiler} = 1;
#     if($class eq 'paper') {
# 	$c->stash->{template} = "search/$class.tt2";
#     } else {
# 	$c->stash->{template} = "search/generic.tt2";
#     }
#     $c->forward('WormBase::Web::View::TT');
# 
#     $self->status_ok($c, entity => {
# 	class   => $class,
# 	name    => $name,
# 	uri     => "$uri"
# 		     }
# 	);
# }
# 



sub download : Path('/rest/download') :Args(0) :ActionClass('REST') {}

sub download_GET {
    my ($self,$c) = @_;
     
    my $filename=$c->req->param("type");
    $filename =~ s/\s/_/g;
    $c->response->header('Content-Type' => 'text/html');
    $c->response->header('Content-Disposition' => 'attachment; filename='.$filename);
#     $c->response->header('Content-Description' => 'A test file.'); # Optional line
#         $c->serve_static_file('root/test.html');
    $c->response->body($c->req->param("sequence"));
}


=head2 pages() pages_GET()

Return a list of all available pages and their URIs

TODO: This is currently just returning a dummy object

=cut

sub pages : Path('/rest/pages') :Args(0) :ActionClass('REST') {}

sub pages_GET {
    my ($self,$c) = @_;
    my @pages = keys %{ $c->config->{pages} };

    my %data;
    foreach my $page (@pages) {
	my $uri = $c->uri_for('/page',$page,'WBGene00006763');
	$data{$page} = "$uri";
    }

    $self->status_ok( $c,
		      entity => { resultset => {  data => \%data,
						  description => 'Available (dynamic) pages at WormBase',
				  }
		      }
	);
}



######################################################
#
#   WIDGETS
#
######################################################

=head2 available_widgets(), available_widgets_GET()

For a given CLASS and OBJECT, return a list of all available WIDGETS

eg http://localhost/rest/available_widgets/gene/WBGene00006763

=cut

sub available_widgets : Path('/rest/available_widgets') :Args(2) :ActionClass('REST') {}

sub available_widgets_GET {
    my ($self,$c,$class,$name) = @_;

    # Does the data for this widget already exist in the cache?
    my ($cache_id,$data) = $c->check_cache('available_widgets');

    my @widgets = @{$c->config->{pages}->{$class}->{widget_order}};
    
    foreach my $widget (@widgets) {
	my $uri = $c->uri_for('/widget',$class,$name,$widget);
	push @$data, { widgetname => $widget,
		       widgeturl  => "$uri"
	};
	$c->cache->set($cache_id,$data);
    }
    
    # Retain the widget order
    $self->status_ok( $c, entity => {
	data => $data,
	description => "All widgets available for $class:$name",
		      }
	);
}




# Request a widget by REST. Gathers all component fields
# into a single data structure, passing it to a unified
# widget template.

=head widget(), widget_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/widget/[CLASS]/[NAME]/[FIELD]

=cut

sub widget :Path('/rest/widget') :Args(3) :ActionClass('REST') {}

sub widget_GET {
    my ($self,$c,$class,$name,$widget) = @_; 

    if($class eq "bench"){
      $c->log->debug("this is a bench page widget");
      $self->_bench($c, $widget);
      return;
    }
    $c->log->debug("this is NOT a bench page widget");
    # It seems silly to fetch an object if we are going to be pulling
    # fields from the cache but I still need for various page formatting duties.
    unless ($c->stash->{object}) {
	# Fetch our external model
	my $api = $c->model('WormBaseAPI');
	
	# Fetch the object from our driver	 
	$c->log->debug("WormBaseAPI model is $api " . ref($api));
	$c->log->debug("The requested class is " . ucfirst($class));
	$c->log->debug("The request is " . $name);
	
	# Fetch a WormBase::API::Object::* object
	# But wait. Some methods return lists. Others scalars...
	$c->stash->{object} = $api->fetch({class=> ucfirst($class),
					   name => $name}) or die "$!";
    }
    my $object = $c->stash->{object};

    # Does the data for this widget already exist in the cache?
    my ($cache_id,$cached_data) = $c->check_cache($class,$widget,$name);


    my $status;

    # The cache ONLY includes the field data for the widget, nothing else.
    # This is because most backend caches cannot store globs.
    if ($cached_data) {
	$c->stash->{fields} = $cached_data;
    } else {

	# No result? Generate and cache the widget.		

	# Is this a request for the references widget?
	# Return it (of course, this will ONLY be HTML).
	if ($widget eq "references") {
	    $c->stash->{class}    = $class;
	    $c->stash->{query}    = $name;
	    $c->stash->{noboiler} = 1;
	    
	    # Looking up the template is slow; hard-coded here.
	    $c->stash->{template} = "shared/widgets/references.tt2";
	    $c->forward('WormBase::Web::View::TT');
	    return;
	}

#    unless ($c->stash->{object}) {
#	# Fetch our external model
#	my $api = $c->model('WormBaseAPI');
#	
#	# Fetch the object from our driver	 
#	$c->log->debug("WormBaseAPI model is $api " . ref($api));
#	$c->log->debug("The requested class is " . ucfirst($class));
#	$c->log->debug("The request is " . $name);
#	
#	# Fetch a WormBase::API::Object::* object
#	# But wait. Some methods return lists. Others scalars...
#	$c->stash->{object} = $api->fetch({class=> ucfirst($class),
#					   name => $name}) or die "$!";
#    }
#    my $object = $c->stash->{object};

	
	# Load the stash with the field contents for this widget.
	# The widget itself could make a series of REST calls for each field but that could quickly become unwieldy.
	my @fields = $c->_get_widget_fields($class,$widget);
	       		
	foreach my $field (@fields) {
	    $c->log->debug($field);
	    my $data = {};
	    $data = $object->$field if defined $object->$field;
	    
	    # Conditionally load up the stash (for now) for HTML requests.
	    # Alternatively, we could return JSON and have the client format it.
	    $c->stash->{fields}->{$field} = $data; 
	}
		
	# Cache the field data for this widget.
	$c->set_cache($cache_id,$c->stash->{fields});
    }
    
    # Save the name of the widget.
    $c->stash->{widget} = $widget;

    # No boiler since this is an XHR request.
    $c->stash->{noboiler} = 1;

    # Set the template
    $c->stash->{template} = $c->_select_template($widget,$class,'widget'); 	

    # Forward to the view for rendering HTML.
    $c->forward('WormBase::Web::View::TT');
    
    # TODO: AGAIN THIS IS THE REFERENCE OBJECT
    # PERHAPS I SHOULD INCLUDE FIELDS?
    # Include the full uri to the *requested* object.
    # IE the page on WormBase where this should go.
    my $uri = $c->uri_for("/page",$class,$name);
    
    $self->status_ok($c, entity => {
	class   => $class,
	name    => $name,
	uri     => "$uri"
		     }
	);
}



######################################################
#
#   FIELDS
#
######################################################

=head2 available_fields(), available_fields_GET()

Fetch all available fields for a given WIDGET, PAGE, NAME

eg  GET /rest/fields/[WIDGET]/[CLASS]/[NAME]


# This makes more sense than what I have now:
/rest/class/*/available_widgets  - all available widgets
/rest/class/*/widget   - the content for a given widget

/rest/class/*/widget/available_fields - all available fields for a widget
/rest/class/*/widget/field

=cut

sub available_fields : Path('/rest/available_fields') :Args(3) :ActionClass('REST') {}

sub available_fields_GET {
    my ($self,$c,$widget,$class,$name) = @_;


    # Does the data for this widget already exist in the cache?
    my ($cache_id,$data) = $c->check_cache('available_fields');

    unless ($data) {	
	my @fields = eval { @{ $c->config->{pages}->{$class}->{widgets}->{$widget} }; };
	
	foreach my $field (@fields) {
	    my $uri = $c->uri_for('/rest/field',$class,$name,$field);
	    $data->{$field} = "$uri";
	}
	$c->set_cache($cache_id,$data);
    }
    
    $self->status_ok( $c, entity => { data => $data,
				      description => "All fields that comprise the $widget for $class:$name",
		      }
	);
}


=head field(), field_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/field/[CLASS]/[NAME]/[FIELD]

=cut

sub field :Path('/rest/field') :Args(3) :ActionClass('REST') {}

sub field_GET {
    my ($self,$c,$class,$name,$field) = @_;

    my $headers = $c->req->headers;
    $c->log->debug($headers->header('Content-Type'));
    $c->log->debug($headers);

    unless ($c->stash->{object}) {
	# Fetch our external model
	my $api = $c->model('WormBaseAPI');
 
	# Fetch the object from our driver	 
	$c->log->debug("WormBaseAPI model is $api " . ref($api));
	$c->log->debug("The requested class is " . ucfirst($class));
	$c->log->debug("The request is " . $name);
	
	# Fetch a WormBase::API::Object::* object
	# But wait. Some methods return lists. Others scalars...
	$c->stash->{object} =  $api->fetch({class=> ucfirst($class),
					    name => $name}) or die "$!";
    }
    
    # Did we request the widget by ajax?
    # Supress boilerplate wrapping.
    if ( $c->is_ajax() ) {
	$c->stash->{noboiler} = 1;
    }


    my $object = $c->stash->{object};
    my $data = $object->$field();

    # Should be conditional based on content type (only need to populate the stash for HTML)
     $c->stash->{$field} = $data;
#      $c->stash->{data} = $data->{data};
#     $c->stash->{field} = $field;
    # Anything in $c->stash->{rest} will automatically be serialized
#    $c->stash->{rest} = $data;

    
    # Include the full uri to the *requested* object.
    # IE the page on WormBase where this should go.
    my $uri = $c->uri_for("/page",$class,$name);

    $c->stash->{template} = $c->_select_template($field,$class,'field'); 

    $self->status_ok($c, entity => {
	class  => $class,
			 name   => $name,
	                 uri    => "$uri",
			 $field => $data
		     }
	);
}





=cut

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
