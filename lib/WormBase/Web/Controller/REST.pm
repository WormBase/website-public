package WormBase::Web::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';
use Time::Duration;
use XML::Simple;
use Crypt::SaltedHash;
use List::Util qw(shuffle);
use Badge::GoogleTalk;
use WormBase::API::ModelMap;

__PACKAGE__->config(
    'default' => 'text/x-yaml',
    'stash_key' => 'rest',
    'map' => {
	'text/x-yaml' => 'YAML',,
	'text/html'          => 'YAML::HTML',
	'text/xml' => 'XML::Simple',
	'application/json'   => 'JSON',
    }
    );

=head1 NAME

WormBase::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut
 
sub livechat :Path('/rest/livechat') :Args(0) :ActionClass('REST') {} 
sub livechat_GET {
    my ( $self, $c) = @_;
    $c->user_session->{'livechat'}=1;
    $c->stash->{template} = "auth/livechat.tt2";
    my $role= $c->model('Schema::Role')->find({role=>"operator"});
     
    foreach my $op ( shuffle $role->users){
      next unless($op->gtalk_key );
      my $badge = Badge::GoogleTalk->new( key => $op->gtalk_key);
      my $online_status = $badge->is_online();
      my $status = $badge->get_status();
      my $away_status = $badge->is_away();
      if($online_status && $status ne 'Busy' && !$away_status) {
	  $c->log->debug("get gtalk badge for ",$op->username);
  	  $c->stash->{badge_html}  = $badge->get_badge();
	  $c->stash->{operator}  = $op;
	  $c->log->debug($c->stash->{badge_html});
	  last;
      }
    }
    $c->stash->{noboiler}=1;
    $c->forward('WormBase::Web::View::TT');
}
sub livechat_POST {
    my ( $self, $c) = @_;
    $c->user_session->{'livechat'}=0;
    $c->user_session->{'livechat'}=1 if($c->req->param('open'));
    $c->log->debug('livechat open? '.$c->user_session->{'livechat'});
}

sub print :Path('/rest/print') :Args(0) :ActionClass('REST') {}
sub print_POST {
    my ( $self, $c) = @_;
   
    my $api = $c->model('WormBaseAPI');
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
     
    my $path = $c->req->param('layout');
    
    if($path) {
      $path = $c->req->headers->referer.'#'.$path;
      $c->log->debug("here is the path $path");
      my $file = $api->_tools->{print}->run($path);
     
      if ($file) {
	  $c->log->debug("here is the file: $file");	 
	  $file =~ s/.*print/\/print/;
	  $c->res->body($file);
      }

    }
}


sub workbench :Path('/rest/workbench') :Args(0) :ActionClass('REST') {}
sub workbench_GET {
    my ( $self, $c) = @_;
    my $session = $self->get_session($c);
    my $url = $c->req->params->{url};
	if($url){
      my $class = $c->req->params->{class};
      my $save_to = $c->req->params->{save_to};
      my $is_obj = $c->req->params->{is_obj} || 0;
#       $c->stash->{is_obj} = $is_obj;
      my $loc = "saved reports";
      $save_to = 'reports' unless $save_to;
      if ($class eq 'paper') {
        $loc = "library";
        $save_to = 'my_library';
      }
      my $name = $c->req->params->{name};

      my $page = $c->model('Schema::Page')->find_or_create({url=>$url,title=>$name,is_obj=>$is_obj});
      my $saved = $page->user_saved->find({session_id=>$session->id});
      if($saved){
            $c->stash->{notify} = "$name has been removed from your $loc";
            $saved->delete();
            $saved->update(); 
      } else{
            $c->stash->{notify} = "$name has been added to your $loc"; 
            $c->model('Schema::UserSave')->find_or_create({session_id=>$session->id,page_id=>$page->page_id, save_to=>$save_to, time_saved=>time()}) ;
      }
    }
 	$c->stash->{noboiler} = 1;
    my $count = $session->pages->count;
    $c->stash->{count} = $count || 0;

    $c->stash->{template} = "workbench/count.tt2";
    $c->forward('WormBase::Web::View::TT');
} 

sub workbench_star :Path('/rest/workbench/star') :Args(0) :ActionClass('REST') {}

sub workbench_star_GET{
    my ( $self, $c) = @_;
    my $wbid = $c->req->params->{wbid};
    my $name = $c->req->params->{name};
    my $class = $c->req->params->{class};
    my $is_obj = $c->req->params->{is_obj};

    my $url = $c->req->params->{url};
    my $page = $self->get_session($c)->pages->find({url=>$url});

    if($page) {
          $c->stash->{star}->{value} = 1;
    } else{
        $c->stash->{star}->{value} = 0;
    }
    $c->stash->{star}->{wbid} = $wbid;
    $c->stash->{star}->{name} = $name;
    $c->stash->{star}->{class} = $class;
    $c->stash->{star}->{url} = $url;
    $c->stash->{star}->{is_obj} = $is_obj;
    $c->stash->{template} = "workbench/status.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
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

  my $lstring = $c->request->body_parameters->{'lstring'};
  $c->user_session->{'layout'}->{$class}->{$i}->{'name'} = $layout;

  $c->user_session->{'layout'}->{$class}->{$i}->{'lstring'} = $lstring;
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

  my $name = $c->user_session->{'layout'}->{$class}->{$layout}->{'name'};
  my $lstring = $c->user_session->{'layout'}->{$class}->{$layout}->{'lstring'};


  $c->log->debug("lstring:" . $lstring);

  $self->status_ok(
      $c,
      entity =>  {
          name => $name,
          lstring => $lstring,
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
    $c->forward('WormBase::Web::View::TT');
}



sub auth :Path('/rest/auth') :Args(0) :ActionClass('REST') {}

sub auth_GET {
    my ($self,$c) = @_;   
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "nav/status.tt2"; 
    $self->status_ok($c,entity => {});
    $c->forward('WormBase::Web::View::TT');
}

sub get_session {
    my ($self,$c) = @_;
    my $sid = $c->get_session_id;
    return $c->model('Schema::Session')->find({id=>"session:$sid"});
}


sub history :Path('/rest/history') :Args(0) :ActionClass('REST') {}

sub history_GET {
    my ($self,$c) = @_;
    my $clear = $c->req->params->{clear};
    $c->log->debug("history");
    my $session = $self->get_session($c);
    my @hist = $session->user_history;

    if($clear){ 
      $c->log->debug("clearing");
      $session->user_history->delete();
      $session->update();
    }

    my $size = @hist;
    my $count = $c->req->params->{count} || $size;
    if($count > $size) { $count = $size; }

    @hist = sort { $b->get_column('latest_visit') <=> $a->get_column('latest_visit')} @hist;

    my @histories;
    map {
      if($_->visit_count > 0){
        my $time = $_->get_column('latest_visit');
        push @histories, {  time_lapse => concise(ago(time()-$time, 1)),
                            visits => $_->visit_count,
                            page => $_->page,
                          };
      }
    } @hist[0..$count-1];
    $c->stash->{history} = \@histories;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "shared/fields/user_history.tt2"; 
    $c->forward('WormBase::Web::View::TT');
    $self->status_ok($c,entity => {});
}


sub history_POST {
    my ($self,$c) = @_;
    $c->log->debug("history logging");
    my $session = $self->get_session($c);
    my $path = $c->request->body_parameters->{'ref'};
    my $name = $c->request->body_parameters->{'name'};
    my $is_obj = $c->request->body_parameters->{'is_obj'};

    my $page = $c->model('Schema::Page')->find_or_create({url=>$path,title=>$name,is_obj=>$is_obj});
    $c->log->debug("logging:" . $page->page_id . " is_obj: " . $is_obj);
    my $hist = $c->model('Schema::UserHistory')->find_or_create({session_id=>$session->id,page_id=>$page->page_id});
    $hist->set_column(latest_visit=>time());
    $hist->set_column(visit_count=>($hist->visit_count + 1));
    $hist->update;
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
    $c->forward('WormBase::Web::View::TT');
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
 
sub rest_register :Path('/rest/register') :Args(0) :ActionClass('REST') {}

sub rest_register_POST {
    my ( $self, $c) = @_;
     
    my $email = $c->req->params->{email};
    my $username = $c->req->params->{username};
    my $password = $c->req->params->{password};
    if($email && $username && $password){
	my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
	$csh->add($password);
	my $hash_password= $csh->generate();
	my @users = $c->model('Schema::User')->search({email_address=>$email});
  	foreach (@users){
	   if($_->password && $_->active){
	      $c->res->body(0);
	      return 0;
	    }
	}  
	my $user=$c->model('Schema::User')->find_or_create({email_address=>$email, username=>$username, password=>$hash_password,active=>0}) ;
	 
	foreach my $key (sort keys %{$c->req->params}){
	  $c->stash->{info}->{$key}=$c->req->params->{$key};
	}
	$c->stash->{noboiler}=1;
	 
	$csh->clear();
	$csh->add($email."_".$username);
	my $digest = $csh->generate();
	$digest =~ s/^{SSHA}//;
	$digest =~ s/\+/\%2B/g;
	$c->stash->{digest}=$c->uri_for('/confirm')."?u=".$user->id."&code=".$digest ;
	
	$c->stash->{email} = {
	    to       => $email,
	    from     => $c->config->{register_email},
	    subject  => "WormBase Account Activation", 
	    template => "auth/register_email.tt2",
	};
	
	$c->forward( $c->view('Email::Template') );
	$c->res->body(1);
	
    }
    return 1;
}

sub feed :Path('/rest/feed') :Args :ActionClass('REST') {}

sub feed_GET {
    my ($self,$c,$type) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{current_time}=time();

    my $url = $c->req->params->{url};
    my $page = $c->model('Schema::Page')->find({url=>$url});
$c->log->debug("page: " . $page . ", url:" . $url);
    $c->stash->{url} = $url;


    if($type eq "comment"){
      my @comments = $page->comments;
      if($c->req->params->{count}){
        $c->response->body("(" . scalar(@comments) . ")");
        return;
      }
      $c->stash->{comments} = \@comments if(@comments);  
    }elsif($type eq "issue"){
      my @issues;
      if($page) {
        @issues = $page->issues;
      }else {
        @issues= $c->user->issues if $c->user;
      }
      if($c->req->params->{count}){
        $c->response->body(scalar(@issues));
        return;
      }
      $c->stash->{issues} = \@issues if(@issues);  
    }
      
     $c->stash->{template} = "feed/$type.tt2"; 
     $c->forward('WormBase::Web::View::TT') ;
    
     #$self->status_ok($c,entity => {});
}

sub feed_POST {
    my ($self,$c,$type) = @_;
    if($type eq 'comment'){
      if($c->req->params->{method} eq 'delete'){
        my $id = $c->req->params->{id};
        if($id){
          my $comment = $c->model('Schema::Comment')->find($id);
          $c->log->debug("delete comment #",$comment->id);
          $comment->delete();
          $comment->update();
        }
      }else{
        my $content= $c->req->params->{content};
        my $name= $c->req->params->{name};

        my $url = $c->req->params->{url};
        my $page = $c->model('Schema::Page')->find({url=>$url});
        my $commment = $c->model('Schema::Comment')->find_or_create({reporter=>$name, page_id=>$page->page_id, content=>$content,'submit_time'=>time()});

      }
    }
    elsif($type eq 'issue'){
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

      my $url = $c->req->params->{url};

      my $page = $c->model('Schema::Page')->find({url=>$url});

      my $user = $self->check_user_info($c);
      return unless $user;
      $c->log->debug("create new issue $content ",$user->id);
      my $issue = $c->model('Schema::Issue')->find_or_create({reporter=>$user->id, title=>$title,page_id=>$page->page_id,content=>$content,state=>"new",'submit_time'=>time()});
      $c->model('Schema::UserIssue')->find_or_create({user_id=>$user->id,issue_id=>$issue->id}) ;
      $self->issue_email($c,$issue,1,$content);
	}
    }elsif($type eq 'thread'){
	my $content= $c->req->params->{content};
	my $issue_id= $c->req->params->{issue};
	my $state= $c->req->params->{state};
	my $assigned_to= $c->req->params->{assigned_to};
	if($issue_id) { 
	   my $hash;
	   my $issue = $c->model('Schema::Issue')->find($issue_id);
	   if($state) {
	      $hash->{status}={old=>$issue->state,new=>$state};
	      $issue->state($state) ;
	   }
	   if($assigned_to) {
	      my $people=$c->model('Schema::User')->find($assigned_to);
	      $hash->{assigned_to}={old=>$issue->assigned_to,new=>$people};
	      $issue->assigned_to($assigned_to)  ;
	      $c->model('Schema::UserIssue')->find_or_create({user_id=>$assigned_to,issue_id=>$issue_id}) ;
	   }
	   $issue->update();
	    
	   my $user = $self->check_user_info($c);
	   return unless $user;
	   my $thread  = { owner=>$user,
			  submit_time=>time(),
	   };
	   if($content){
		$c->log->debug("create new thread for issue #$issue_id!");
		my @threads= $issue->issues_to_threads(undef,{order_by=>'thread_id DESC' } ); 
		my $thread_id=1;
		$thread_id = $threads[0]->thread_id +1 if(@threads);
		$thread= $c->model('Schema::IssueThread')->find_or_create({issue_id=>$issue_id,thread_id=>$thread_id,content=>$content,submit_time=>$thread->{submit_time},user_id=>$user->id});
		$c->model('Schema::UserIssue')->find_or_create({user_id=>$user->id,issue_id=>$issue_id}) ;
	  }  
	  if($state || $assigned_to || $content){
	     
	      $self->issue_email($c,$issue,$thread,$content,$hash);
	  }
	}
    }
}

sub check_user_info {
  my ($self,$c) = @_;
  my $user;
  if($c->user_exists) {
	  $user=$c->user; 
	  $user->username($c->req->params->{username}) if($c->req->params->{username});
	  $user->email_address($c->req->params->{email}) if($c->req->params->{email});
  }else{
	  if($user = $c->model('Schema::User')->find({email_address=>$c->req->params->{email},active =>1})){
	    $c->res->body(0) ;return 0 ;
	  }
	  $user=$c->model('Schema::User')->find_or_create({email_address=>$c->req->params->{email}}) ;
	  $user->username($c->req->params->{username}),
  }
  $user->update();
  return $user;
}
=head2 pages() pages_GET()

Return a list of all available pages and their URIs

TODO: This is currently just returning a dummy object

=cut

sub issue_email{
 my ($self,$c,$issue,$new,$content,$change) = @_;
 my $subject='New Issue';
 my $bcc ;
 $bcc= $issue->owner->email_address  if($issue->owner);

 unless($new == 1){
    $subject='Issue Update';
    my @threads= $issue->issues_to_threads;
    $bcc .= ",".$issue->assigned_to->email_address if($issue->assigned_to);
    my %seen=();  
    $bcc = $bcc.",". join ",", grep { ! $seen{$_} ++ } map {$_->user->email_address} @threads;
 }
 $subject = '[WormBase.org] '.$subject.' '.$issue->id.': '.$issue->title;
 
 $c->stash->{issue}=$issue;
 
 $c->stash->{new}=$new;
 $c->stash->{content}=$content;
 $c->stash->{change}=$change;
 $c->stash->{noboiler} = 1;
 $c->log->debug(" send out email to $bcc");
 $c->stash->{email} = {
		  to      => $c->config->{issue_email},
		  cc => $bcc,
		  from    => $c->config->{issue_email},
		  subject => $subject, 
		  template => "feed/issue_email.tt2",
	      };
   
  $c->forward( $c->view('Email::Template') );
}

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
   
    my $headers = $c->req->headers;
    $c->log->debug("widget GET header ".$headers->header('Content-Type'));
    $c->log->debug($headers);
    $c->stash->{is_class_index} = 0;  

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
      if ($name eq '*' || $name eq 'all' || $widget eq 'browse') {
          $c->stash->{species} = $name;
#           $c->stash->{object} = $api->instantiate_empty({class => ucfirst($class)});
      } else {
          $c->stash->{object} = $api->fetch({class => ucfirst($class),
                            name  => $name,
                            }) or die "$!";
      }
      $c->log->debug("Tried to instantiate: $class");
    }

    my $object = $c->stash->{object};
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
	
    # If you have a tool that you want to display inline as a widget, be certain to add it here.
    # Otherwise, it will try to load a template under class/action.tt2...
    } elsif ($widget eq "aligner" || $widget eq "show_mult_align" || $widget eq 'tree') {
      return $c->res->redirect("/tools/$widget/run?inline=1;name=$name;class=$class") if ($widget eq 'tree');
      return $c->res->redirect("/tools/" . $widget . "/run?inline=1&sequence=$name");
    }
    
    # Does the data for this widget already exist in the cache?
    my ($cache_id,$cached_data,$cache_server) = $c->check_cache('rest','widget',$class,$name,$widget);

    # The cache ONLY includes the field data for the widget, nothing else.
    # This is because most backend caches cannot store globs.
    if ($cached_data) {
      $c->stash->{fields} = $cached_data;
      $c->stash->{cache} = $cache_server if($cache_server);
    } else {

      # No result? Generate and cache the widget.		
      # Load the stash with the field contents for this widget.
      # The widget itself is loaded by REST; fields are not.
      my @fields = $c->_get_widget_fields($class,$widget);

      my $fatal_non_compliance = 0;
      foreach my $field (@fields) {
          unless ($field) { next;}
          $c->log->debug($field);
          my $data = $object->$field; # $object->can($field) for a check
          if ($c->config->{installation_type} eq 'development' and
              my ($fixed_data, @problems) = $object->check_data($data, $class)) {
              $data = $fixed_data;
              $c->log->fatal("${class}::$field returns non-compliant data: ");
              $c->log->fatal("\t$_") foreach @problems;

              $fatal_non_compliance = $c->config->{fatal_non_compliance};
          }

          # Conditionally load up the stash (for now) for HTML requests.
          # Alternatively, we could return JSON and have the client format it.
          $c->stash->{fields}->{$field} = $data; 
      }

      if ($fatal_non_compliance) {
          die "Non-compliant data. See log for fatal error.\n"
      }

      # Cache the field data for this widget.
      $c->set_cache($cache_id,$c->stash->{fields});
    }

    $c->stash->{class} = $class;
    
    # Save the name of the widget.
    $c->stash->{widget} = $widget;

    # No boiler since this is an XHR request.
    $c->stash->{noboiler} = 1;

    # Set the template
    $c->stash->{template}="shared/generic/rest_widget.tt2";
    $c->stash->{child_template} = $c->_select_template($widget,$class,'widget'); 	

    # Forward to the view for rendering HTML.
    my $format = $headers->header('Content-Type') || $c->req->params->{'content-type'};
    $c->detach('WormBase::Web::View::TT') unless($format) ;
    
	# TODO: AGAIN THIS IS THE REFERENCE OBJECT
    # PERHAPS I SHOULD INCLUDE FIELDS?
    # Include the full uri to the *requested* object.
    # IE the page on WormBase where this should go.
    my $uri = $c->uri_for("/page",$class,$name);
    $self->status_ok($c, entity => {
	class   => $class,
	name    => $name,
	uri     => "$uri",
	fields => $c->stash->{fields},
		     }
	);
   $format ||= 'text/html';
   my $filename = $class."_".$name."_".$widget.".".$c->config->{api}->{content_type}->{$format};
   $c->log->debug("$filename download in the format: $format");
   $c->response->header('Content-Type' => $format);
   $c->response->header('Content-Disposition' => 'attachment; filename='.$filename);
   
}

# For "static" pages -- which are most likely resources --
# that do not need to handle objects. They have a different linking structure
# eg /rest/widget/static/nomenclature/overview
# and have the "static = true" property set in teh configuration file.
sub widget_static :Path('/rest/widget/static') :Args(2) :ActionClass('REST') {}

sub widget_static_GET {
    my ($self,$c,$class,$widget) = @_; 
    $c->log->debug("getting resource widget");
    $c->stash->{template} = "resources/$class/$widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT')
}


# widgets on the species summary pages
sub widget_species :Path('/rest/widget/species') :Args(2) :ActionClass('REST') {}

sub widget_species_GET {
    my ($self,$c,$species,$widget) = @_; 
    $c->log->debug("getting species widget");

    $c->stash->{template} = "species/$species/$widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT')
}


# for the generic summary page widgets (Browse, Search, etc)
sub widget_class_index :Path('/rest/widget/index') :Args(3) :ActionClass('REST') {}

sub widget_class_index_GET {
    my ($self,$c,$species,$class, $widget) = @_; 
    $c->log->debug("getting one of the class index page widgets");

    $c->stash->{species} = $species;
    $c->stash->{class} = $class;
    
    # Save the name of the widget.
    $c->stash->{widget} = $widget;

    # No boiler since this is an XHR request.
    $c->stash->{noboiler} = 1;

    # Set the template
    $c->stash->{template}="shared/widgets/$widget.tt2";
    $c->detach('WormBase::Web::View::TT'); 
}




sub widget_home :Path('/rest/widget/home') :Args(1) :ActionClass('REST') {}

sub widget_home_GET {
    my ($self,$c,$widget) = @_; 
    $c->log->debug("getting home page widget");
    if($widget=~m/issues/){
      $c->stash->{issues} = $self->issue_rss($c,2);
    }
    elsif($widget=~m/activity/){
      $c->stash->{recent} = $self->recently_saved($c,3);
      $c->stash->{popular} = $self->most_popular($c,3);
    }   
    elsif($widget=~m/discussion/){
      $c->stash->{comments} = $self->comment_rss($c,2);
    }
    $c->stash->{template} = "classes/home/$widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT')
}

sub recently_saved {
 my ($self,$c,$count) = @_;
    my $api = $c->model('WormBaseAPI');
    my @saved = $c->model('Schema::UserSave')->search(undef,
                {   select => [ 
                      'page_id', 
                      { max => 'time_saved', -as => 'latest_save' }, 
                    ],
                    as => [ qw/
                      page_id 
                      time_saved
                    /], 
                    order_by=>'latest_save DESC', 
                    group_by=>[ qw/page_id/]
                })->slice(0, $count-1);

    my @ret = map { $self->_get_search_result($c, $api, $_->page, ago((time() - $_->time_saved), 1)) } @saved;

    $c->stash->{type} = 'all'; 

    return \@ret;
}

sub most_popular {
 my ($self,$c,$count) = @_;

    my $api = $c->model('WormBaseAPI');
#     my $interval = "> UNIX_TIMESTAMP() - 604800"; # one week ago
    my $interval = "> UNIX_TIMESTAMP() - 86400"; # one day ago
#     my $interval = "> UNIX_TIMESTAMP() - 3600"; # one hour ago
#     my $interval = "> UNIX_TIMESTAMP() - 60"; # one minute ago
    my @saved = $c->model('Schema::UserHistory')->search({is_obj=>1, latest_visit => \$interval},
                {   select => [ 
                      'page.page_id', 
                      { sum => 'visit_count', -as => 'total_visit' }, 
                    ],
                    as => [ qw/
                      page_id 
                      visit_count
                    /], 
                    order_by=>'total_visit DESC', 
                    group_by=>[ qw/page_id/],
                    join=>'page'
                })->slice(0, $count-1);

    my @ret = map { $self->_get_search_result($c, $api, $_->page, $_->visit_count . " visits") } @saved;

    $c->stash->{type} = 'all'; 
    return \@ret;
}


#input page obj from user db, return result
sub _get_search_result {
  my ($self,$c, $api, $page, $footer) = @_;

  if($page->is_obj){
    my @parts = split(/\//,$page->url); 
    my $class = $parts[-2];
    my $id = $parts[-1];
    my $obj = $api->fetch({class=> ucfirst($class),
                              name => $id}) or die "$!";
    my %ret = %{$api->xapian->_wrap_objs($c, $obj, $class, $footer);};
    unless (defined $ret{name}) {
      $ret{name}{id} = $id;
      $ret{name}{class} = $class;
    }
    return \%ret;
  }

  return { 'name' => {  url => $page->url, 
                                label => $page->title,
                                id => $page->title,
                                class => 'page' },
            footer => "$footer",
                    };
}

sub comment_rss {
 my ($self,$c,$count) = @_;
 my @rss;
 my @comments = $c->model('Schema::Comment')->search(undef,{order_by=>'submit_time DESC'} )->slice(0, $count-1);
 map {
        my $time = ago((time() - $_->submit_time), 1);
        push @rss, {      time=>$_->submit_time,
                          time_lapse=>$time,
                          people=>$_->reporter,
                          page=>$_->page,
                          content=>$_->content,
                          id=>$_->id,
             };
     } @comments;
 return \@rss;
}

sub issue_rss {
 my ($self,$c,$count) = @_;
 my @issues = $c->model('Schema::Issue')->search(undef,{order_by=>'submit_time DESC'} )->slice(0, $count-1);
    my $threads= $c->model('Schema::IssueThread')->search(undef,{order_by=>'submit_time DESC'} );
     
    my %seen;
    my @rss;
    while($_ = $threads->next) {
      unless(exists $seen{$_->issue_id}) {
      $seen{$_->issue_id} =1 ;
      my $time = ago((time() - $_->submit_time), 1);
      push @rss, {  time=>$_->submit_time,
            time_lapse=>$time,
            people=>$_->user,
            title=>$_->issue->title,
            page=>$_->issue->page,
            id=>$_->issue->id,
            re=>1,
            } ;
      }
      last if(scalar(keys %seen)>=$count)  ;
    };

    map {    
      my $time = ago((time() - $_->submit_time), 1);
        push @rss, {      time=>$_->submit_time,
                          time_lapse=>$time,
                          people=>$_->owner,
                          title=>$_->title,
                          page=>$_->page,
                  id=>$_->id,
            };
    } @issues;

    my @sort = sort {$b->{time} <=> $a->{time}} @rss;
    return \@sort;
}

sub widget_me :Path('/rest/widget/me') :Args(1) :ActionClass('REST') {}

sub widget_me_GET {
    my ($self,$c,$widget) = @_; 
    my $api = $c->model('WormBaseAPI');
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

    my $session = $self->get_session($c);
    my @reports = $session->user_saved->search({save_to => $widget});
#     $c->log->debug("getting saved reports @reports for user $session->id");  

    my @ret = map { $self->_get_search_result($c, $api, $_->page, "added " . ago((time() - $_->time_saved), 1) ) } @reports;

    $c->stash->{'results'} = \@ret;
    $c->stash->{'type'} = $type; 
    $c->stash->{template} = "workbench/widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
    return;
}






######################################################
#
#   SPECIES WIDGETS (as opposed to /species)
#
######################################################
#sub widget_species :Path('/rest/widget/species_summary') :Args(2) :ActionClass('REST') {}
#
#sub widget_species_GET {
#    my ($self,$c,$species,$widget) = @_; 
#    $c->log->debug("getting species widget");#
#
#    $c->stash->{template} = "species/$species/$widget.tt2";
#    $c->stash->{noboiler} = 1;
#}








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
	# * and all are placeholders to match the /species/class/object structure for species/class index pages
	if ($name eq '*' || $name eq 'all') {
	    $c->stash->{object} = $api->instantiate_empty({class => ucfirst($class)});
	} else {
	    $c->stash->{object} = $api->fetch({class => ucfirst($class),
					       name  => $name,
					      }) or die "$!";
	}
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

    # Anything in $c->stash->{rest} will automatically be serialized
    #  $c->stash->{rest} = $data;
    
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
