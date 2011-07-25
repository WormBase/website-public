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
use URI::Escape;
use Text::WikiText;
use Text::WikiText::Output::HTML;
use DateTime;

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
            $c->model('Schema::Starred')->find_or_create({session_id=>$session->id,page_id=>$page->page_id, save_to=>$save_to, timestamp=>time()}) ;
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
    unless($c->user_exists){
      my $sid = $c->get_session_id;
      return $c->model('Schema::Session')->find({session_id=>"session:$sid"});
    }else{
      return $c->model('Schema::Session')->find({session_id=>"user:" . $c->user->user_id});
    }
}


sub get_user_info :Path('/auth/info') :Args(1) :ActionClass('REST'){}

sub get_user_info_GET{
  my ( $self, $c, $name) = @_;

  my $api = $c->model('WormBaseAPI');
  my $object = $api->fetch({class => 'Person',
                    name  => $name,
                    }) or die "$!";

  my $message;
  my $status_ok = 1;
  my @users = $c->model('Schema::User')->search({wbid=>$name, wb_link_confirm=>1});
  if(@users){
    $status_ok = 0;
    $message = "This account has already been linked";
  }elsif($object && $object->email->{data}){
    my $emails = join (', ', map {"<a href='mailto:$_'>$_</a>"} @{$object->email->{data}});
    $message = "An email will be sent to " . $emails . " to confirm your identity";
  }else{
    $status_ok = 0;
    $message = "This account cannot be linked at this time";
  }
  $self->status_ok(
      $c,
      entity =>  {
          wbid => $name,
          fullname => $object->name->{data}->{label},
          email => $object->email->{data},
          message => $message,
          status_ok => $status_ok,
      },
  );

}

sub system_message :Path('/rest/system_message') :Args(1) :ActionClass('REST') {}
sub system_message_POST {
    my ($self,$c,$message_id) = @_;
    $c->user_session->{close_system_message}->{$message_id} = 1;
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

    @hist = sort { $b->get_column('timestamp') <=> $a->get_column('timestamp')} @hist;

    my @histories;
    map {
      if($_->visit_count > 0){
        my $time = $_->get_column('timestamp');
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
    my $hist = $c->model('Schema::History')->find_or_create({session_id=>$session->id,page_id=>$page->page_id});
    $hist->set_column(timestamp=>time());
    $hist->set_column(visit_count=>($hist->visit_count + 1));
    $hist->update;
}

 
sub update_role :Path('/rest/update/role') :Args :ActionClass('REST') {}

sub update_role_POST {
      my ($self,$c,$id,$value,$checked) = @_;
      
    my $user=$c->model('Schema::User')->find({id=>$id}) if($id);
    my $role=$c->model('Schema::Role')->find({role=>$value}) if($value);
    
    my $users_to_roles=$c->model('Schema::UserRole')->find_or_create(user_id=>$id,role_id=>$role->role_id);
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
    $c->response->body($c->req->param("sequence"));
}

sub rest_link_wbid :Path('/rest/link_wbid') :Args(0) :ActionClass('REST') {}
sub rest_link_wbid_POST {
    my ( $self, $c) = @_;
    my $wbemail = $c->req->params->{wbemail};
    my $username = $c->req->params->{username};
    my $user_id = $c->req->params->{user_id};
    my $wbid = $c->req->params->{wbid};
    my $confirm = $c->req->params->{confirm};

    my @wbemails = split(/,/, $wbemail);
    foreach my $wbe (@wbemails){
      $c->user->wbid($wbid);
      unless($confirm){
        $c->model('Schema::Email')->find_or_create({email=>$wbe, user_id=>$user_id});
        $self->rest_register_email($c, $wbe, $username, $user_id, $wbid);
        $c->stash->{message} = "<h2>Thank you!</h2> <p>An email has been sent to " . join(', ', map {"<a href='mailto:$_'>$_</a>"} @wbemails) . " to confirm that you are $wbid</p>" ; 
      }else{
        $c->user->wb_link_confirm(1);
        $c->model('Schema::Email')->find_or_create({email=>$wbe, user_id=>$user_id, validated=>1});
        $c->stash->{message} = "<h2>Thank you!</h2> <p>Your account is now linked to <a href=\"" . $c->uri_for('/resources', 'person', $wbid) . "\">$wbid</a></p>" ; 
      }
      $c->user->update();
    }

    $c->stash->{template} = "shared/generic/message.tt2"; 
    $c->stash->{redirect} = $c->req->params->{redirect};
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
}
 
sub rest_register :Path('/rest/register') :Args(0) :ActionClass('REST') {}

sub rest_register_POST {
    my ( $self, $c) = @_;
    my $email = $c->req->params->{email};
    my $wbemail = $c->req->params->{wbemail};
    my $username = $c->req->params->{username};
    my $password = $c->req->params->{password};
    my $wbid = $c->req->params->{wbid};
    if(($email || $wbemail) && $username && $password){
      my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
      $csh->add($password);
      my $hash_password= $csh->generate();

      my @emails = $c->model('Schema::Email')->search({email=>$email, validated=>1});
      foreach (@emails) {
          $c->res->body(0);
          return 0;         
      }

      my @users = $c->model('Schema::User')->search({wbid=>$wbid, wb_link_confirm=>1});
      foreach (@users){
        if($_->password && $_->active){
            $c->res->body(0);
            return 0;
          }
      }  

      my $user=$c->model('Schema::User')->find_or_create({username=>$username, password=>$hash_password,active=>0,wbid=>$wbid,wb_link_confirm=>0}) ;
      my $user_id = $user->user_id;

      @emails = split(/,/, $email);
      foreach my $e (@emails){
        $e =~ s/\s//g;
        $c->model('Schema::Email')->find_or_create({email=>$e, user_id=>$user_id}) ;
        $self->rest_register_email($c, $e, $username, $user_id);
      }

      my @wbemails = split(/,/, $wbemail);
      foreach my $wbe (@wbemails){
        $wbe =~ s/\s//g;
        $c->model('Schema::Email')->find_or_create({email=>$wbe, user_id=>$user_id}) ;
        $self->rest_register_email($c, $wbe, $username, $user_id, $wbid);
      }
      
      push(@emails, @wbemails);
      $c->stash->{template} = "shared/generic/message.tt2"; 
      $c->stash->{message} = "<h2>Thank you!</h2> <p>Thank you for registering at <a href='" . $c->uri_for("/") . "'>wormbase.org</a>. An email has been sent to " . join(', ', map {"<a href='mailto:$_'>$_</a>"} @emails) . " to confirm your registration</p>" ; 
      $c->stash->{redirect} = $c->req->params->{redirect};
      $c->forward('WormBase::Web::View::TT');

    }



}


sub rest_register_email {
  my ($self,$c,$email,$username,$user_id, $wbid) = @_;


  $c->stash->{info}->{username}=$username;
  $c->stash->{info}->{email}=$email;

  $c->stash->{noboiler}=1;
  
  my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
  $csh->add($email."_".$username);
  my $digest = $csh->generate();
  $digest =~ s/^{SSHA}//;
  $digest =~ s/\+/\%2B/g;
  my $url = $c->uri_for('/confirm')."?u=".$user_id."&code=".$digest;

  if($wbid){
    $c->stash->{info}->{wbid}=$wbid;
    my $csh2 = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
    $csh2->add($email."_".$wbid);
    my $wb_hash = $csh2->generate();
    $wb_hash =~ s/^{SSHA}//;
    $wb_hash =~ s/\+/\%2B/g;
    $url = $url . "&wb=" . $wb_hash;
  }

  $c->stash->{digest}=$url;
  
  $c->log->debug(" send out email to $email");
  $c->stash->{email} = {
      to       => $email,
      from     => $c->config->{register_email},
      subject  => "WormBase Account Activation", 
      template => "auth/register_email.tt2",
  };
  
  $c->forward( $c->view('Email::Template') );

}


sub feed :Path('/rest/feed') :Args :ActionClass('REST') {}

sub feed_GET {
    my ($self,$c,@args) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{current_time}=time();

    my $type = shift @args;
    
    if($type eq "download"){
      my $class = shift @args;
      my $wbid = shift @args;
      my $widget = shift @args;
      my $name = shift @args;

      $c->stash->{url} = $c->uri_for('widget', $class, $wbid, $widget);

    }else{

      my $url = $c->req->params->{url};
      my $page = $c->model('Schema::Page')->find({url=>$url});
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
          $c->stash->{issue_type} = 'page';
        }else {
          @issues= $c->user->issues_reported if $c->user;
          push(@issues, $c->user->issues_responsible) if $c->user;
          $c->stash->{issue_type} = 'user';
        }
        if($c->req->params->{count}){
          $c->response->body(scalar(@issues));
          return;
        }
        $c->stash->{issues} = \@issues if(@issues);  
      }
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
          $c->log->debug("delete comment #",$comment->comment_id);
          $comment->delete();
          $comment->update();
        }
      }else{
        my $content= $c->req->params->{content};

        my $url = $c->req->params->{url};
        my $page = $c->model('Schema::Page')->find({url=>$url});

        my $user = $c->user;
        unless($c->user_exists){
          $user = $c->model('Schema::User')->create({username=>$c->req->params->{name}, active=>0});
          $c->model('Schema::Email')->find_or_create({email=>$c->req->params->{email}, user_id=>$user->user_id});
        }

        my $commment = $c->model('Schema::Comment')->find_or_create({user_id=>$user->user_id, page_id=>$page->page_id, content=>$content,'timestamp'=>time()});

      }
    }
    elsif($type eq 'issue'){
    if($c->req->params->{method} eq 'delete'){
      my $id = $c->req->params->{issues};
      if($id){
        foreach (split('_',$id) ) {
        my $issue = $c->model('Schema::Issue')->find($_);
        $c->log->debug("delete issue #",$issue->issue_id);
        $issue->delete();
        $issue->update();
        }
      }
    }else{
      my $content    = $c->req->params->{content};
      my $title      = $c->req->params->{title};
      my $is_private = $c->req->params->{isprivate};
      
      my $url = $c->req->params->{url};
      $c->log->debug(keys %{$c->req->params});
      my $page = $c->model('Schema::Page')->find({url=>$url});
      $c->log->debug("private: $is_private");
      my $user = $self->check_user_info($c);
      return unless $user;
      $c->log->debug("create new issue $content ",$user->user_id);
      my $issue = $c->model('Schema::Issue')->find_or_create({reporter_id=>$user->user_id,
                                  title=>$title,
                                  page_id=>$page->page_id,
                                  content=>$content,
                                  state      =>"new",
                                  is_private => $is_private,
                                  'timestamp'=>time()});
      $self->issue_email($c,$issue,1,$content);
    }
    }elsif($type eq 'thread'){
    my $content= $c->req->params->{content};
    my $issue_id = $c->req->params->{issue};
    my $state    = $c->req->params->{state};
    my $severity = $c->req->params->{severity};
    my $assigned_to= $c->req->params->{assigned_to};
    if($issue_id) { 
       my $hash;
       my $issue = $c->model('Schema::Issue')->find($issue_id);
       if ($state) {
          $hash->{status}={old=>$issue->state,new=>$state};
          $issue->state($state) ;
       }

       if ($severity) {
          $hash->{severity}={old=>$issue->severity,new=>$severity};
          $issue->severity($severity);
       }

       if($assigned_to) {
          my $people=$c->model('Schema::User')->find($assigned_to);
          $hash->{assigned_to}={old=>$issue->responsible_id,new=>$people};
          $issue->responsible_id($assigned_to);
#         $c->model('Schema::UserIssue')->find_or_create({user_id=>$assigned_to,issue_id=>$issue_id}) ;
       }
       $issue->update();
        
       my $user = $self->check_user_info($c);
       return unless $user;
       my $thread  = { owner=>$user,
              timestamp=>time(),
       };
       if($content){
        $c->log->debug("create new thread for issue #$issue_id!");
        my @threads= $issue->threads(undef,{order_by=>'thread_id DESC' } ); 
        my $thread_id=1;
        $thread_id = $threads[0]->thread_id +1 if(@threads);
        $thread= $c->model('Schema::IssueThread')->find_or_create({issue_id=>$issue_id,thread_id=>$thread_id,content=>$content,timestamp=>$thread->{timestamp},user_id=>$user->user_id});
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
 my $bcc;
 $bcc = $issue->reporter->primary_email->email if ($issue->reporter && $issue->reporter->primary_email);

 unless($new == 1){
    $subject='Issue Update';
    my @threads= $issue->threads;
    $bcc = "$bcc, " . $issue->responsible->primary_email->email if $issue->responsible;
    my %seen=();  
    $bcc = $bcc.",". join ",", grep { ! $seen{$_} ++ } map {$_->user->primary_email if $_->user} @threads;
 }
 $subject = '[WormBase.org] '.$subject.' '.$issue->issue_id.': '.$issue->title;
 
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
#    my ($cache_id,$data) = $c->check_cache('available_widgets');
    my ($cache_id,$data) = $c->check_cache('filecache','available_widgets');

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
    $c->log->debug("widget GET header ".$headers->content_type);
    $c->log->debug($headers);

    # It seems silly to fetch an object if we are going to be pulling
    # fields from the cache but I still need for various page formatting duties.
    unless ($c->stash->{object}) {
        # AD: this condition is an illusion -- the stash will never have an object
        #     unless we were forwarded here by another action. since this is a
        #     RESTful action, that likely isn't the case.
      # Fetch our external model
      my $api = $c->model('WormBaseAPI');
      
      # Fetch the object from our driver     
      $c->log->debug("WormBaseAPI model is $api " . ref($api));
      $c->log->debug("The requested class is " . ucfirst($class));
      $c->log->debug("The request is " . $name);
      
      # Fetch a WormBase::API::Object::* object
      if ($name eq '*' || $name eq 'all') {
          $c->stash->{object} = $api->instantiate_empty({class => ucfirst($class)});
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
    } elsif ($widget eq "nucleotide_aligner" || $widget eq "protein_aligner" || $widget eq 'tree') {
      return $c->res->redirect("/tools/$widget/run?inline=1;name=$name;class=$class") if ($widget eq 'tree');
      return $c->res->redirect("/tools/" . $widget . "/run?inline=1&sequence=$name");
    }
    
    # Does the data for this widget already exist in the cache?
#    my ($cache_id,$cached_data,$cache_server) = $c->check_cache('rest','widget',$class,$name,$widget);
    my ($cache_id,$cached_data,$cache_server) = $c->check_cache('filecache','rest','widget',$class,$name,$widget);

    # The cache ONLY includes the field data for the widget, nothing else.
    # This is because most backend caches cannot store globs.
    if ($cached_data) {
      $c->stash->{fields} = $cached_data;
      $c->stash->{cache} = $cache_server if ($cache_server);
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
              my ($fixed_data, @problems) = $object->_check_data($data, $class)) {
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
#      $c->set_cache($cache_id,$c->stash->{fields});
      $c->set_cache('filecache',$cache_id,$c->stash->{fields});
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

# For "static" pages
# that do not need to handle objects. They have a different linking structure
sub widget_static :Path('/rest/widget/static') :Args(1) :ActionClass('REST') {}

sub widget_static_GET {
    my ($self,$c,$widget_id) = @_; 
    $c->log->debug("getting static widget");
    if($c->req->params->{history}){ # just getting history of widget
      my @revisions = $c->model('Schema::WidgetRevision')->search({widget_id=>$widget_id}, {order_by=>'timestamp DESC'});
      map {
        my $time = DateTime->from_epoch( epoch => $_->timestamp);
        $_->{time_lapse} =  $time->hms(':') . ', ' . $time->day . ' ' . $time->month_name . ' ' . $time->year;
      } @revisions;
      $c->stash->{revisions} = \@revisions if @revisions;
      $c->stash->{widget_id} = $widget_id;
    } else { # getting actual widget
      my $parser = Text::WikiText->new;
      my $widget = $c->model('Schema::Widgets')->find({widget_id=>$widget_id});
      $c->stash->{widget} = $widget;
      if($c->req->params->{rev}){ # getting a certain revision of the widget
        my $rev = $c->model('Schema::WidgetRevision')->find({widget_revision_id=>$c->req->params->{rev}});
        unless($rev->widget_revision_id == $widget->content->widget_revision_id){
          $c->stash->{rev} = $rev;
          my $document = $parser->parse($rev->content);
          $c->stash->{rev_content} = Text::WikiText::Output::HTML->new->dump($document);
          my $time = DateTime->from_epoch( epoch => $rev->timestamp);
          $c->stash->{rev_date} =  $time->hms(':') . ', ' . $time->day . ' ' . $time->month_name . ' ' . $time->year;
        }
      }
      if(!($c->stash->{rev}) && $widget){
        my $document = $parser->parse($widget->content->content);
        $c->stash->{widget_content} = Text::WikiText::Output::HTML->new->dump($document);
      }
      $c->stash->{timestamp} = ago(time()-($c->stash->{widget}->content->timestamp), 1) if($widget_id > 0);
      $c->stash->{path} = $c->request->params->{path};
    }
    $c->stash->{edit} = $c->req->params->{edit};
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "shared/widgets/static.tt2";
    $c->forward('WormBase::Web::View::TT');
}

sub widget_static_POST {
    my ($self,$c,$widget_id) = @_; 

    #only admins and curators can modify widgets
    if($c->check_any_user_role(qw/admin curator/)){ 

      #only admins can delete
      if($c->req->params->{delete} && $c->check_user_roles("admin")){ 
        my $widget = $c->model('Schema::Widgets')->find({widget_id=>$widget_id});
        $widget->delete();
        $widget->update();
        return;
      }
      my $widget_title = $c->request->body_parameters->{widget_title};
      my $widget_content = $c->request->body_parameters->{widget_content};

      my $widget_revision = $c->model('Schema::WidgetRevision')->create({
                    content=>$widget_content, 
                    user_id=>$c->user->user_id, 
                    timestamp=>time()});

      # modifying a widget
      if($widget_id > 0){
        my $widget = $c->model('Schema::Widgets')->find({widget_id=>$widget_id});
        $widget->content($widget_revision);
        $widget_revision->widget_id($widget_id);
        $widget->widget_title($widget_title);
        $widget->update();

      #creating a widget - only admin
      }elsif($c->check_user_roles("admin")){ 
          my $url = $c->request->body_parameters->{path};
          my $page = $c->model('Schema::Page')->find({url=>$url});
          $widget_revision->widget($c->model('Schema::Widgets')->create({ 
                    page_id=>$page->page_id, 
                    widget_title=>$widget_title, 
                    current_revision_id=>$widget_revision->widget_revision_id}));
          $widget_id = $widget_revision->widget->widget_id;
      }else{
        $self->status_bad_request(
          $c,
          message => "You do not have premissions to create a widget!",
        );
      }
      $widget_revision->update();

      $self->status_created(
          $c,
          location => $c->req->uri->as_string,
          entity =>  {
              widget_id => "$widget_id",
          },
      );
    }
}


# for the generic summary page widgets
sub widget_class_index :Path('/rest/widget/index') :Args(3) :ActionClass('REST') {}

sub widget_class_index_GET {
    my ($self,$c,$species,$class, $widget) = @_; 
    
    $c->stash->{widget} = $widget;
    $c->stash->{species} = $species;
    $c->stash->{class} = $class;

    # No boiler since this is an XHR request.
    $c->stash->{noboiler} = 1;

    if($widget=~m/browse|basic_search|summary/){
      $c->stash->{template}="shared/widgets/$widget.tt2";
    }elsif($class=~m/all/){
      $c->stash->{template} = "species/$species/$widget.tt2";
    }else{
      $c->stash->{template} = "species/$species/$class/$widget.tt2";
    }
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
    $c->forward('WormBase::Web::View::TT');
}

sub recently_saved {
 my ($self,$c,$count) = @_;
    my $api = $c->model('WormBaseAPI');
    my @saved = $c->model('Schema::Starred')->search(undef,
                {   select => [ 
                      'page_id', 
                      { max => 'timestamp', -as => 'latest_save' }, 
                    ],
                    as => [ qw/
                      page_id 
                      timestamp
                    /], 
                    order_by=>'latest_save DESC', 
                    group_by=>[ qw/page_id/]
                })->slice(0, $count-1);

    my @ret = map { $self->_get_search_result($c, $api, $_->page, ago((time() - $_->timestamp), 1)) } @saved;

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
    my @saved = $c->model('Schema::History')->search({is_obj=>1, timestamp => \$interval},
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
    my $id = uri_unescape($parts[-1]);
    $c->log->debug("class: $class, id: $id");

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
 my @comments = $c->model('Schema::Comment')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
 map {
        my $time = ago((time() - $_->timestamp), 1);
        push @rss, {      time=>$_->timestamp,
                          time_lapse=>$time,
                          people=>$_->reporter,
                          page=>$_->page,
                          content=>$_->content,
                          id=>$_->comment_id,
             };
     } @comments;
 return \@rss;
}

sub issue_rss {
  my ($self,$c,$count) = @_;
  my @issues = $c->model('Schema::Issue')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
  my $threads= $c->model('Schema::IssueThread')->search(undef,{order_by=>'timestamp DESC'} )->slice(0, $count-1);
    
  my %seen;
  my @rss;
  while($_ = $threads->next) {
    unless(exists $seen{$_->issue_id}) {
    $seen{$_->issue_id} =1 ;
    my $time = ago((time() - $_->timestamp), 1);
    push @rss, {  time=>$_->timestamp,
          time_lapse=>$time,
          people=>$_->user,
          title=>$_->issue->title,
          page=>$_->issue->page,
          id=>$_->issue->issue_id,
          re=>1,
          } ;
    }
    last if(scalar(keys %seen)>=$count)  ;
  };

  map {    
    my $time = ago((time() - $_->timestamp), 1);
      push @rss, {      time=>$_->timestamp,
                        time_lapse=>$time,
                        people=>$_->reporter,
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

    my @ret = map { $self->_get_search_result($c, $api, $_->page, "added " . ago((time() - $_->timestamp), 1) ) } @reports;

    $c->stash->{'results'} = \@ret;
    $c->stash->{'type'} = $type; 
    $c->stash->{template} = "workbench/widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
    return;
}





######################################################
#
#   ADMIN WIDGETS 
#
######################################################

sub widget_admin :Path('/rest/widget/admin') :Args(1) :ActionClass('REST') {}

sub widget_admin_GET {
    my ($self,$c,$widget) = @_; 
    my $api = $c->model('WormBaseAPI');
    my $type;
    $c->stash->{'bench'} = 1;
    $c->res->redirect("/admin/$widget");
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
#    my ($cache_id,$data) = $c->check_cache('available_fields');
    my ($cache_id,$data) = $c->check_cache('filecache','available_fields');

    unless ($data) {    
    my @fields = eval { @{ $c->config->{pages}->{$class}->{widgets}->{$widget} }; };
    
    foreach my $field (@fields) {
        my $uri = $c->uri_for('/rest/field',$class,$name,$field);
        $data->{$field} = "$uri";
    }
#   $c->set_cache($cache_id,$data);
    $c->set_cache('filecache',$cache_id,$data);
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
    # TODO: 2011.03.20 TH: THIS NEEDS TO BE UPDATED, TESTED, VERIFIED
    my $uri = $c->uri_for("/species",$class,$name);

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
