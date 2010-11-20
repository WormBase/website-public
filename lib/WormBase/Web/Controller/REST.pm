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
    my $id = $c->req->params->{id};
	if($id){
      my $class = $c->req->params->{class};
      my $type = $c->req->params->{type};
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
    }
 	$c->stash->{noboiler} = 1;
    my $count = scalar($c->user_session->{bench}{count}) || 0;
    $c->stash->{count} = $count;
    $c->stash->{template} = "workbench/count.tt2";
} 

sub workbench_star :Path('/rest/workbench/star') :Args(0) :ActionClass('REST') {}

sub workbench_star_GET{
    my ( $self, $c) = @_;
    my $wbid = $c->req->params->{wbid};
    my $name = $c->req->params->{name};
    my $class = $c->req->params->{class};
    my $type = $c->req->params->{type};
    my $id = $c->req->params->{id};

    $type = "my_library" if ($class eq 'paper');
    if(exists $c->user_session->{bench} && exists $c->user_session->{bench}{$type}{$class}{$id}){
          $c->stash->{star}->{value} = 1;
    } else{
        $c->stash->{star}->{value} = 0;
    }
    $c->stash->{star}->{wbid} = $wbid;
    $c->stash->{star}->{name} = $name;
    $c->stash->{star}->{class} = $class;
    $c->stash->{star}->{id} = $id;
    $c->stash->{star}->{type} = $type;
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
  unless (defined $c->user_session->{'layout'}->{$class}->{$layout}){
    $layout = 0;
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
  map {$l{$_} = $c->user_session->{'layout'}->{$class}->{$_}->{'name'};} @layouts;
  $c->log->debug("layout list:" . join(',',@layouts));
  $c->stash->{layouts} = \%l;
  $c->stash->{template} = "boilerplate/layouts.tt2";
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
    my $path = $c->request->body_parameters->{'ref'};
    unless($c->user_session->{history}->{$path}){
#       my ($i,$type, $class, $id) = split(/\//,$path); 
      my $id = $c->request->body_parameters->{'id'};
      my $class = $c->request->body_parameters->{'class'};
      my $type = $c->request->body_parameters->{'type'};
      my $name = $c->request->body_parameters->{'name'} || $id;
#       my $name = $c->req->params->{name} || $id;
      $c->log->debug("type:$type, class:$class, id:$id, name:$name");
      $c->user_session->{history}->{$path}->{data} = { label => $name, class => $class, id => $id, type => $type };
    }
    push(@{$c->user_session->{history}->{$path}->{time}}, time());
}

 
sub update_role :Path('/rest/update/role') :Args :ActionClass('REST') {}

sub update_role_POST {
      my ($self,$c,$id,$value,$checked) = @_;
       
      my $user=$c->model('Schema::User')->find({id=>$id}) if($id);
      my $role=$c->model('Schema::Role')->find({role=>$value}) if($value);
      
      my $users_to_roles=$c->model('Schema::UserRole')->find_or_create(user_id=>$id,role_id=>$role->id);
      $users_to_roles->delete()  unless($checked eq 'true');
      $users_to_roles->update();
       
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

sub feed :Path('/rest/feed') :Args :ActionClass('REST') {}

sub feed_GET {
    my ($self,$c,$type,$class,$name,$widget,$label) = @_;
    $c->stash->{noboiler} = 1;
    my $page = "/rest/widget/$class/$name/$widget/$label";
    $c->stash->{page} = $page;
    $c->stash->{class}=$class;
    if($type eq "issue"){
      unless($c->user_exists) { $c->res->body("<script>alert('you need to login to use this function');</script>") ;return ;}
      my @issues;
      if( $class) {
	  @issues= $c->user->issues->search({location=>$page});
      }else {
	  @issues= $c->user->issues;
      }
      $c->stash->{issues} = \@issues if(@issues);  
      $c->stash->{current_time}=time();
    }
     
    $c->stash->{template} = "feed/$type.tt2"; 
    $self->status_ok($c,entity => {});
}

sub feed_POST {
    my ($self,$c,$type) = @_;
    if($type eq 'issue'){
	if($c->req->params->{method} eq 'delete'){
	  my $id = $c->req->params->{issues};
	  if($id){
	    foreach (split('_',$id) ) {
		my $issue = $c->model('Schema::Issue')->find($_);
		$c->log->debug("delete issue #",$issue->id);
		$issue->delete();
		$issue->update();
	    }
	  }
	}else{
	  my $content= $c->req->params->{content};
	  my $title= $c->req->params->{title};
	  my $location= $c->req->params->{location};
	  if( $title && $content && $location) { 
	      
	      $c->log->debug("create new issue $content ",$c->user->id);
	      my $issue = $c->model('Schema::Issue')->find_or_create({report_user=>$c->user->id, title=>$title,location=>$location,content=>$content,state=>"new",'submit_time'=>time()});
	      $c->model('Schema::UserIssue')->find_or_create({user_id=>$c->user->id,issue_id=>$issue->id}) ;
	  }
	}
    }elsif($type eq 'thread'){
	my $content= $c->req->params->{content};
	my $issue= $c->req->params->{issue};
	if($issue && $content) { 
	    $c->log->debug("create new thread for issue #$issue!!!");
	     my @threads= $c->model('Schema::Issue')->find($issue)->issues_to_threads(undef,{order_by=>'thread_id DESC' } ); 
	     my $thread_id=1;
	     $thread_id = $threads[0]->thread_id +1 if(@threads);
	     $c->model('Schema::IssueThread')->create({issue_id=>$issue,thread_id=>$thread_id,content=>$content,submit_time=>time(),user_id=>$c->user->id});
	       
	}
    }
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
    $c->stash->{template}="shared/generic/rest_widget.tt2";
    $c->stash->{child_template} = $c->_select_template($widget,$class,'widget'); 	

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


sub widget_me :Path('/rest/widget/me') :Args(1) :ActionClass('REST') {}

sub widget_me_GET {
    my ($self,$c,$widget) = @_; 
    $c->log->debug("getting me widget");
    my $api = $c->model('WormBaseAPI');
    my @ret;
    my $type;
    $c->stash->{'bench'} = 1;
    if($widget=~m/user_history/){
      $self->history_GET($c);
      return;
    } elsif($widget=~m/profile/){
    $c->stash->{noboiler} = 1;
        $c->res->redirect('/profile');
    return;
    }elsif($widget=~m/issue/){
    $self->feed_GET($c,"issue");
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


sub _bench {
    my ($self,$c, $widget) = @_; 
    $c->log->debug("getting bench widget");
    my $api = $c->model('WormBaseAPI');
    my @ret;
    my $type;
    $c->stash->{'bench'} = 1;
    if($widget=~m/user_history/){
      $self->history_GET($c);
      return;
    } elsif($widget=~m/profile/){
    $c->stash->{noboiler} = 1;
        $c->res->redirect('/profile');
    return;
    }elsif($widget=~m/issue/){
    $self->feed_GET($c,"issue");
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
