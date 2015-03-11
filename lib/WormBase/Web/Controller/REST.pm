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
use LWP;
use JSON;
use URI::Escape;
use Text::MultiMarkdown 'markdown';
use DateTime;
use Encode;

__PACKAGE__->config(
    'default'          => 'text/x-yaml',
    'stash_key'        => 'rest',
    'map'              => {
        'text/x-yaml'      => 'YAML',
        'text/html'        => [ 'View', 'TT' ], #'YAML::HTML',
        'text/xml'         => 'XML::Simple',
        'application/json' => 'JSON',
    }
);

=head1 NAME

WormBase::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

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
    my $session = $self->_get_session($c);

    my $url = $c->req->params->{url};
    if($url){
      my $save_to = $c->req->params->{save_to} || 'reports';
      my $is_obj = $c->req->params->{is_obj} || 0;
      my $name = $c->req->params->{name};
      my $page = $self->_get_page($c, $url) || $c->model('Schema::Page')->create({url=>$url,title=>$name,is_obj=>$is_obj});
      my $saved = $page->user_saved->find({session_id=>$session->id});
      if($saved){
            $saved->delete();
            $saved->update();
      } else{
            $c->model('Schema::Starred')->find_or_create({session_id=>$session->id,page_id=>$page->page_id, save_to=>$save_to, timestamp=>time()}) ;
      }
      $c->stash->{notify} = "$name has been " . ($saved ? 'removed from' : 'added to') . " your " . ($save_to eq 'reports' ?  "favorites" : "library");
    }
    $c->stash->{noboiler} = 1;
    $c->stash->{count} = $session->pages->count || 0;
    $c->response->headers->expires(time);
    $c->stash->{template} = "workbench/count.tt2";
    $c->forward('WormBase::Web::View::TT');
}

sub workbench_star :Path('/rest/workbench/star') :Args(0) :ActionClass('REST') {}

sub workbench_star_GET{
    my ( $self, $c) = @_;
    my $url = $c->req->params->{url};
    my $page = $self->_get_session($c)->pages->search({url=>$url}, {rows=>1})->next;

    $c->stash->{star}->{value} = $page ? 1 : 0;
    $c->stash->{star}->{wbid} = $c->req->params->{wbid};
    $c->stash->{star}->{name} = $c->req->params->{name};
    $c->stash->{star}->{save_to} = $c->req->params->{class} eq 'paper' ?  "my_library" : "reports";
    $c->stash->{star}->{url} = $url;
    $c->stash->{star}->{is_obj} = $c->req->params->{is_obj};
    $c->stash->{template} = "workbench/status.tt2";
    $c->stash->{noboiler} = 1;
    $c->response->headers->expires(time);
    $c->forward('WormBase::Web::View::TT');
}

sub layout :Path('/rest/layout') :Args(2) :ActionClass('REST') {}

sub layout_POST {
  my ( $self, $c, $class, $layout) = @_;
  $layout = 'default' unless $layout;
  my $i = 0;
  if($layout ne 'default'){
    $i = ((sort {$b <=> $a} keys %{$c->user_session->{'layout'}->{$class}})[0]) + 1;
  }

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
    $c->response->headers->expires(time);
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
  $c->log->debug("$class layout list:" . join(',',@layouts));
  $c->stash->{layouts} = \%l;
  $c->stash->{template} = "boilerplate/layouts.tt2";
  $c->stash->{noboiler} = 1;
  $c->stash->{section} = $c->req->params->{section};
  $c->stash->{class} = $class;
  $c->stash->{object}{name}{data}{class} = $class; #hack... sorry
  $c->response->headers->expires(time);
  $c->forward('WormBase::Web::View::TT');
}



sub auth :Path('/rest/auth') :Args(0) :ActionClass('REST') {}

sub auth_GET {
    my ($self,$c) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "nav/status.tt2";
    $self->status_ok($c,entity => {});
    $c->response->headers->expires(time);
    $c->forward('WormBase::Web::View::TT');
}


sub get_user_info :Path('/auth/info') :Args(1) :ActionClass('REST'){}

sub get_user_info_GET{
  my ( $self, $c, $name) = @_;

  my $api = $c->model('WormBaseAPI');
  my $object = $api->fetch({ class => 'Person', name  => $name });
  my $message;
  my $status_ok;
  my @users = $c->model('Schema::User')->search({wbid=>$name, wb_link_confirm=>1});
  if(@users){
    $message = "This account has already been linked";
  }elsif($object && $object->email->{data}){
    my $emails = join (', ', map {"<a href='mailto:$_'>$_</a>"} @{$object->email->{data}});
    $message = "An email will be sent to " . $emails . " to confirm your identity";
    $status_ok = 1;
  }else{
    $message = "This account cannot be linked at this time";
  }
  $self->status_ok(
      $c,
      entity =>  {
          wbid => $name,
          fullname => $object->name->{data}->{label},
          email => $object->email->{data},
          message => $message,
          status_ok => $status_ok || 0,
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

    $c->response->headers->expires(time);
    my $session = $self->_get_session($c);
    my $history_change = $c->req->params->{history_on};

    $c->stash->{noboiler} = 1;
    $c->stash->{template} = $history_change ? "shared/fields/turn_history_on.tt2" : "shared/fields/user_history.tt2";

    if(($c->user_session->{'history_on'} || 0 == 1) && !$history_change){
      if($c->req->params->{clear}){
        $session->user_history->delete();
        $session->update();
        $c->stash->{history} = "";
        $c->forward('WormBase::Web::View::TT');
        $self->status_ok($c,entity => {});
      }

      my $sidebar = $c->req->params->{sidebar};
      my @hist = $session->user_history if $session;
      my $size = @hist || 0;
      my $count = ($sidebar && ($size > 3)) ? 3 : $size;

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
      $c->stash->{sidebar} = $sidebar if $sidebar;
    }
    $c->forward('WormBase::Web::View::TT');
    $self->status_ok($c,entity => {});
}


sub history_POST {
    my ($self,$c) = @_;
    if($c->user_session->{'history_on'} || 0 == 1){
      my $session = $self->_get_session($c);
      my $url = $c->request->body_parameters->{'ref'};
      return unless $url;
      my $name = URI::Escape::uri_unescape($c->request->body_parameters->{'name'});
      my $is_obj = $c->request->body_parameters->{'is_obj'};

      my $page = $self->_get_page($c, $url) || $c->model('Schema::Page')->create({url=>$url,title=>$name,is_obj=>$is_obj});
      my $hist = $c->model('Schema::History')->find_or_create({session_id=>$session->id,page_id=>$page->page_id});
      $hist->set_column(timestamp=>time());
      $hist->set_column(visit_count=>(($hist->visit_count || 0) + 1));
      $hist->update;
    }
    $c->user_session->{'history_on'} = $c->request->body_parameters->{'history_on'} if defined $c->request->body_parameters->{'history_on'};
}



sub vote :Path('/rest/vote') :Args(0) :ActionClass('REST') {}
sub vote_POST {
    my ($self,$c) = @_;

    my $question_id = $c->request->body_parameters->{'q_id'};
    my $answer_id = $c->request->body_parameters->{'a_id'};
    my $session = $self->_get_session($c);
    my $vote = $c->model('Schema::Votes')->find_or_create({session_id=>$session->id,question_id=>$question_id,answer_id=>$answer_id });
    $vote->set_column(answer_id=>$answer_id);
    $vote->update;

    my %total_votes = map {$_->answer_id => $_->get_column('vote_count')} $c->model('Schema::Answers')->search(
      { 'me.question_id' => $question_id },
      {
        join => 'votes', columns => 'answer_id',
        select   => [ 'answer_id', { count => 'votes.answer_id' } ],
        as       => [qw/ answer_id vote_count /],
        group_by => [qw/ answer_id /]
      }
    );

    my ($sum, $max);
    $sum += $_ for (values %total_votes);
    $max = (sort { $b <=> $a } (values %total_votes))[0];

    $c->response->headers->expires(time);
    $self->status_ok(
        $c,
        entity =>  {
            total => "$sum",
            max => "$max",
            votes => \%total_votes,
        },
    );
}


sub update_role :Path('/rest/update/role') :Args(3) :ActionClass('REST') {}

sub update_role_POST {
    my ($self,$c,$id,$value,$checked) = @_;

    if($c->check_user_roles('admin')){
      my $user=$c->model('Schema::User')->find({user_id=>$id}) if($id);
      my $role=$c->model('Schema::Role')->find({role=>$value}) if($value);

      my $users_to_roles=$c->model('Schema::UserRole')->find_or_create(user_id=>$id,role_id=>$role->role_id);
      $users_to_roles->delete()  unless($checked eq 'true');
      $users_to_roles->update();
    }
}




sub download : Path('/rest/download') :Args(0) :ActionClass('REST') {}

sub download_POST {
    my ($self,$c) = @_;

    my $filename=$c->req->body_parameters->{filename};
    $filename =~ s/\s/_/g;
    $c->response->header('Content-Type' => 'text/html');
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
    $c->response->body($c->req->body_parameters->{content});
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
        $c->stash->{message} = "<h2>You're almost done!</h2> <p>An email has been sent to " . join(', ', map {"<a href='mailto:$_'>$_</a>"} @wbemails) . " to confirm that you are $wbid</p>" ;
      }else{
        $c->user->wb_link_confirm(1);
        $c->model('Schema::Email')->find_or_create({email=>$wbe, user_id=>$user_id, validated=>1});
        $c->stash->{message} = "<h2>Thank you!</h2> <p>Your account is now linked to <a href=\"" . $c->uri_for('/resources', 'person', $wbid)->path . "\">$wbid</a></p>" ;
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
      $c->stash->{message} = "<h2>You're almost done!</h2> <p>An email has been sent to " . join(', ', map {"<a href='mailto:$_'>$_</a>"} @emails) . ".</p><p>In order to use this account at <a href='" . $c->uri_for("/")->path . "'>wormbase.org</a> you will need to activate it by following the activation link in your email.</p>" ;
#       $c->stash->{redirect} = $c->req->params->{redirect};
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

    $c->stash->{current_time}=time();

    my $type = shift @args;

    if($type eq "download"){
      my $class = shift @args;
      my $wbid = shift @args;
      my $widget = shift @args;
      my $name = shift @args;
      $c->stash->{search} = 1 if ($widget eq 'references' && $wbid =~ m/^WB/);
      if($widget=~m/^static-widget-([\d]+)/){
        $c->stash->{url} = $c->uri_for('widget/static', $1)->path;
      }elsif ( ($widget=~m/browse/) && ($widget ne 'ontology_browser') ) {
        $c->stash->{search} = 1;
        $c->stash->{url} = $c->uri_for("/search", $class, "*")->path;
      }else{
        $c->stash->{url} = $c->uri_for('widget', $class, $wbid, $widget)->path;
      }
    }else{

      my $url = $c->req->params->{url};
      my $page = $self->_get_page($c, $url);
      $c->stash->{url} = $url;

      if($type eq "comment"){
        my @comments = $page->comments if $page;
        if($c->req->params->{count}){
          $c->response->body("(" . scalar(@comments) . ")");
          return;
        }
        $c->stash->{comments} = \@comments if(@comments);
      }else{
        # return 404 if the feed cannot be found
        $c->detach('/soft_404');
        return;
      }
    }
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "feed/$type.tt2";
    $c->forward('WormBase::Web::View::TT') ;
    $c->response->headers->expires(time);
}

sub feed_POST {
    my ($self,$c,$type) = @_;
    if($type eq 'comment'){
      if($c->req->params->{method}  || '' eq 'delete'){
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
        my $page = $self->_get_page($c, $url);
        my $user = $c->user;
        unless($c->user_exists){
          $user = $c->model('Schema::User')->create({username=>$c->req->params->{name}, active=>0});
          $c->model('Schema::Email')->find_or_create({email=>$c->req->params->{email}, user_id=>$user->user_id});
        }
        my $commment = $c->model('Schema::Comment')->find_or_create({user_id=>$user->user_id, page_id=>$page->page_id, content=>$content,'timestamp'=>time()});
      }
    }elsif($type eq 'issue'){
      if($c->req->params->{method} || '' eq 'delete'){
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
        my $name = $c->req->params->{name};
        my $email = $c->req->params->{email};
        if($c->user_exists){
          $name = $c->user->username;
          $email = $c->user->primary_email->email;
        }

        my $url = $c->req->params->{url};
        my $hash = $c->req->params->{hash};
        my $userAgent = $c->req->params->{userAgent};
        my $page = $c->req->params->{page} || $self->_get_page($c, $url);
        $url = $url . $hash;

        my ($issue_url,$issue_title,$issue_number) =
        $self->_post_to_github($c,$content, $email, $name, $title, $page, $userAgent, $url);
        $c->stash->{userAgent} = $userAgent;
        $self->_issue_email({ c       => $c,
                              page    => $page,
                              new     => 1,
                              content => encode('utf8', $content),
                              change  => undef,
                              reporter_email   => $email,
                              reporter_name    => encode('utf8', $name),
                              title   => $title,
                              url     => $url,
                              issue_url    => $issue_url,
                              issue_title  => encode('utf8', $title . ": " . $issue_title),
                              issue_number => $issue_number});
        my $message = "<p>You can track the progress on your question, <a href='$issue_url' target='_blank'>$issue_title (#$issue_number)</a> on our <a href='$issue_url' target='_blank'>issue tracker</a>.</p>";
        $self->status_ok(
          $c,
          entity => {
              message => $message,
          }
        );
      }
    }
}



######################################################
#
#   WIDGETS
#
######################################################



# Request a widget by REST. Gathers all component fields
# into a single data structure, passing it to a unified
# widget template.

=head widget(), widget_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/widget/[CLASS]/[NAME]/[FIELD]

=cut

sub widget :Path('/rest/widget') :Args(3) :ActionClass('REST') {}

sub widget_GET {
    my ( $self, $c, $class, $name, $widget ) = @_;
    $c->log->debug("        ------> we're requesting the widget $widget");

    # Cache key - "$class_$widget_$name"
    my $key = join( '_', $class, $widget, $name );

    # set header and content-type
    my $headers = $c->req->headers;
    my $content_type
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'text/html';
    $c->response->header( 'Content-Type' => $content_type );

    # references widget - no need for an object
    if ( $widget =~ m/references/i && $name =~ m/^WB/ ) {
          $c->req->params->{widget} = $widget;
          $c->req->params->{class} = $class;
          $c->go('search', 'search');
    }

    # check_cache checks couchdb
    my ( $cached_data, $cache_source ) = $c->check_cache($key);
    if($cached_data && (ref $cached_data eq 'HASH')){
        $c->stash->{fields} = $cached_data;

	# Served from cache? Let's include a link to it in the cache.
	# Primarily a debugging element.
	$c->stash->{served_from_cache} = $key;
    } elsif ($cached_data && (ref $cached_data ne 'HASH') && ($content_type eq 'text/html')) {
        $c->response->status(200);
        $c->response->body($cached_data);
        $c->detach();
        return;
    } else {
        my $api = $c->model('WormBaseAPI');
        my $object = ($name eq '*' || $name eq 'all'
                   ? $api->instantiate_empty(ucfirst $class)
                   : $api->fetch({ class => ucfirst $class, name => $name }))
            or die "Could not fetch object $name, $class";

        # Generate and cache the widget.
        # Load the stash with the field contents for this widget.
        # The widget itself is loaded by REST; fields are not.
        my @fields = $c->_get_widget_fields( $class, $widget );

        # Store name on all widgets - needed for display
        unless (grep /^name$/, @fields) {
            push @fields, 'name';
        }

        my $skip_cache;
        foreach my $field (@fields) {
            unless ($field) { next; }
            $c->log->debug("Processing field: $field");
            my $data = $object->$field;

            if ($c->config->{fatal_non_compliance}) {
                # checking for data compliance can be an overhead, only use
                # in testing env where its explicitly enabled
                my ($fixed_data, @problems) = $object->_check_data( $data, $class );
                if ( @problems ){
                    my $log = 'fatal';
                    $c->log->$log("${class}::$field returns non-compliant data: ");
                    $c->log->$log("\t$_") foreach @problems;

                    die "Non-compliant data in ${class}::$field. See log for fatal error.\n";
                }
            }

            # a field can force an entire widget to not caching
            if ($data->{'error'}){
                $skip_cache = 1;
            }

            # Conditionally load up the stash (for now) for HTML requests.
            $c->stash->{fields}->{$field} = $data;
        }

        $c->set_cache($key => $c->stash->{fields}) unless $skip_cache;
    }

    # Forward to the view to render HTML, set stash variables
    if ( $content_type eq 'text/html' ) {
        # No boiler since this is an XHR request.
        $c->stash->{noboiler} = 1;
        $c->stash->{colorbox} = $c->req->param('colorbox') if $c->req->param('colorbox');

        # Hack for empty widgets - know what object they're on
        $c->stash->{object}->{name} = $c->stash->{fields}->{name};

        # Save the name and class of the widget.
        $c->stash->{class}  = $class;
        $c->stash->{widget} = $widget;

        $c->stash->{species} = $c->req->params->{species};

          # Set the template
        $c->stash->{template} = 'shared/generic/rest_widget.tt2';
        $c->stash->{child_template}
            = $self->_select_template('widget', $class, $widget);

        my $html = $c->view('TT')->render( $c, $c->{stash}->{template} );
        $c->forward('WormBase::Web::View::TT');
        return;
    }

    $self->status_ok(
        $c,
        entity => {
            class  => $class,
            name   => $name,
            uri    => $c->req->path,
            fields => $c->stash->{fields},
        }
    );

    if($c->req->params->{'download'}){
      my $filename = join( '_', $class, $name, $widget ) . '.'
          . $c->config->{api}->{content_type}->{$content_type};
      $c->log->debug("$filename download in the format: $content_type");
      $c->response->header(
          'Content-Disposition' => 'attachment; filename=' . $filename );
    }
}



# For "static" pages
# that do not need to handle objects. They have a different linking structure
sub widget_static :Path('/rest/widget/static') :Args(1) :ActionClass('REST') {}

sub widget_static_GET {
    my ($self,$c,$widget_id) = @_;
    $c->response->headers->expires(time);
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
      my $widget = $c->model('Schema::Widgets')->find({widget_id=>$widget_id});
      $c->stash->{widget} = $widget;
      if($c->req->params->{rev}){ # getting a certain revision of the widget
        my $rev = $c->model('Schema::WidgetRevision')->find({widget_revision_id=>$c->req->params->{rev}});
        unless($rev->widget_revision_id == $widget->content->widget_revision_id){
          $c->stash->{rev} = $rev;
          $c->stash->{rev_content} = markdown($rev->content);
          my $time = DateTime->from_epoch( epoch => $rev->timestamp);
          $c->stash->{rev_date} =  $time->hms(':') . ', ' . $time->day . ' ' . $time->month_name . ' ' . $time->year;
        }
      }
      if(!($c->stash->{rev}) && $widget){
        $c->stash->{widget_content} = markdown($widget->content->content);
      }
      $c->stash->{timestamp} = ago(time()-($c->stash->{widget}->content->timestamp), 1) if($widget_id > 0);
      $c->stash->{path} = $c->request->params->{path};
    }
    $c->stash->{edit} = $c->req->params->{edit};
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = "shared/widgets/static.tt2";



    if($c->stash->{widget}){
      my $widget = $c->stash->{widget};
      my $headers = $c->req->headers;
      # Forward to the view for rendering HTML.
      my $format = $headers->header('Content-Type') || $c->req->params->{'content-type'};
      $c->detach('WormBase::Web::View::TT') unless($format) ;

      my $uri = $c->uri_for("/rest/widget",$widget_id)->path;
      $self->status_ok($c, entity => {
      id   => $widget_id,
      name    => $widget->widget_title,
      content => $widget->content->content,
      uri     => "$uri"
              }
      );

    $format ||= 'text/html';
    if ($format eq 'text/html') {
      $c->forward('WormBase::Web::View::TT');
      return;
    }
    my $filename = "static-widget-" . $widget_id.".".$c->config->{api}->{content_type}->{$format};
    $c->log->debug("$filename download in the format: $format");
    $c->response->header('Content-Type' => $format);
    $c->response->header('Content-Disposition' => 'attachment; filename='.$filename);
   }else{$c->forward('WormBase::Web::View::TT');}
}

sub widget_static_POST {
    my ($self,$c,$widget_id) = @_;
    #only admins and curators can modify widgets
    if($c->check_any_user_role(qw/admin curator editor/)){

      #only admins can delete
      if($c->req->params->{delete} && $c->check_any_user_role("admin", "curator")){
        my $widget = $c->model('Schema::Widgets')->find({widget_id=>$widget_id});
        $widget->delete();
        $widget->update();
        return;
      }
      my $widget_title = $c->request->body_parameters->{widget_title};
      my $widget_content = $c->request->body_parameters->{widget_content};
      my $widget_order = $c->request->body_parameters->{widget_order};

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
        $widget->widget_order($widget_order);
        $widget->update();

      #creating a widget - only admin & curator
      }elsif($c->check_any_user_role("admin", "curator")){
          my $url = $c->request->body_parameters->{path};
          my $page = $self->_get_page($c, $url);
          $widget_revision->widget($c->model('Schema::Widgets')->create({
                    page_id=>$page->page_id,
                    widget_title=>$widget_title,
                    widget_order=>$widget_order,
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

    if($widget eq "assemblies") {
      if ($species) {
        my $api = $c->model('WormBaseAPI');
        my $species_info = $c->config->{sections}->{species_list}->{$species};
        my $object = $api->fetch({class=>'Species',name=>$species_info->{genus} . " " . $species_info->{species}});
        $c->stash->{fields}->{current_assemblies}  = $object->current_assemblies()  if $object;
        $c->stash->{fields}->{previous_assemblies} = $object->previous_assemblies() if $object;
        $c->stash->{fields}->{name} = $object->name() if $object;
        $c->stash->{fields}->{ncbi_id} = $object->ncbi_id() if $object;
      }
    }

    if($widget=~m/browse|basic_search|summary|downloads|assemblies|data_unavailable/){
      $c->stash->{template}="shared/widgets/$widget.tt2";
    }else{
      $c->res->redirect($c->uri_for('widget', $class, 'all', $widget) . '?species=' . $species, 307);
      return;
    }
    $c->detach('WormBase::Web::View::TT');
}

sub widget_home :Path('/rest/widget/home') :Args(1) :ActionClass('REST') {}


sub widget_home_GET {
    my ($self,$c,$widget) = @_;
    $c->response->headers->expires(time);
    $c->log->debug("getting home page widget");
    if($widget eq 'activity') {
      if ($c->user_session->{'history_on'} || 0 == 1){
        $c->stash->{popular} = $self->_most_popular($c,5);
      }
      if($c->check_any_user_role(qw/admin curator/)){
        $c->stash->{recent} = $self->_recently_saved($c,3);
      }
      my @rand = ($c->model('WormBaseAPI')->xapian->random());
      $c->stash->{random} = \@rand;

    } elsif($widget eq 'discussion') {
      $c->stash->{comments} = $self->_comment_rss($c,2);
    } elsif($widget eq 'vote') {
      my @not_questions = map {$_->question_id} $c->model('Schema::Questions')->search({ 'votes.session_id' => $self->_get_session($c)->id },
                                                              { join => 'votes', columns => 'question_id'});
      my @questions = $c->model('Schema::Questions')->search({'question_id' => { '-not_in' => \@not_questions }});
      @questions = $c->model('Schema::Questions')->search() if (@questions == 0);

      my $question = @questions[int(rand(@questions))];
      my @answers = $question->answers;

      $c->stash->{question} = $question;
      $c->stash->{answers} = \@answers;
    }
    $c->stash->{template} = "classes/home/$widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
}


sub widget_me :Path('/rest/widget/me') :Args(1) :ActionClass('REST') {}

sub widget_me_GET {
    my ($self,$c,$widget) = @_;
    my $api = $c->model('WormBaseAPI');
    $c->stash->{'bench'} = 1;
    $c->response->headers->expires(time);
    if($widget eq 'user_history'){
      $self->history_GET($c);
      return;
    } elsif($widget eq 'profile'){
      $c->stash->{noboiler} = 1;
      $c->res->redirect('/profile');
      return;
    }elsif($widget eq 'issue'){
      $self->feed_GET($c,"issue");
      return;
    }


    my $session = $self->_get_session($c);
    my @reports = $session->user_saved->search({save_to => ($widget eq 'my_library') ? $widget : 'reports'});

    my @ret = map { $self->_get_search_result($c, $api, $_->page, "added " . ago((time() - $_->timestamp), 1) ) } @reports;

    $c->stash->{'widget'} = $widget;
    $c->stash->{'results'} = \@ret;
    $c->stash->{'type'} = ($widget eq 'my_library') ? 'paper' : 'all';
    $c->stash->{template} = "workbench/widget.tt2";
    $c->stash->{noboiler} = 1;
    $c->forward('WormBase::Web::View::TT');
    return;
}


# Making the configuration file available

sub rest_config :Path('/rest/config') :Args :ActionClass('REST') {}

sub rest_config_GET {
    my ($self, $c, @path_parts) = @_;

    my $headers = $c->req->headers;
    my $content_type
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'application/json';
    $c->response->header( 'Content-Type' => $content_type );
    my $config = $c->config;


    my $class = $c->req->params->{'class'};
    my $section = $config->{sections}->{species}->{$class} ? 'species' : 'resources' if $class;

    if($class && $section) {
        $config = $config->{sections}->{$section}->{$class};
    }else {
        for my $part (@path_parts){
          $config = $config->{$part};
        }
    }

    $self->status_ok(
        $c,
        entity => {
            uri    => $c->req->path,
            data => $config,
        }
    );
}

######################################################
#
#   Private methods
#
######################################################


sub _get_session {
    my ($self,$c) = @_;
    unless($c->user_exists){
      my $sid = $c->sessionid;
      return $c->model('Schema::Session')->find({session_id=>"session:$sid"})
        or die "Unable to retrieve session information for $sid";
    }else{
      return $c->model('Schema::Session')->find({session_id=>"user:" . $c->user->user_id})
        or die "Unable to retrieve session information for " . $c->user->user_id;
    }
}


sub _check_user_info {
  my ($self,$c) = @_;
  my $user;
  if($c->user_exists) {
      $user=$c->user;
      $user->username($c->req->params->{username}) if($c->req->params->{username});
      $user->email_address($c->req->params->{email}) if($c->req->params->{email});
  }else{
      my $email = $c->model('Schema::Email')->find({email=>$c->req->params->{email},validated =>1});
      return $email->user if $email;
      $user=$c->model('Schema::User')->create({username=>$c->req->params->{name}});
      $c->model('Schema::Email')->find_or_create({email=>$c->req->params->{email}, validated=>1, user_id=>$user->user_id, primary_email=>1});
  }
  $user->update();
  return $user;
}



sub _post_to_github {
  my ($self,$c,$content,$email, $name, $title, $page, $userAgent, $u) = @_;

  my $url     = "https://api.github.com/repos/" . $c->config->{github_repo} . "/issues";

  # Get a new authorization for the website repo,
  # curl -H "Content-Type: application/json"  -u "tharris" -X POST https://api.github.com/authorizations -d '{"scopes": [ "website" ],"note": "wormbase helpdesk cross-post" }'

  # This only needs to be done once.
  # Already have an OAuth token stored locally outside of our app.
  #  my $response = $browser->post($url,
  #				[
  #				 'scopes' = [ "website" ],
  #				 'note'   = "wormbase helpdesk cross-post" ]);


  # Get github issues (not particularly useful)
  # curl -H "Authorization: token OAUTH-TOKEN" https://api.github.com/repos/wormbase/website/issues

  # Post a new issue
  # Surely an easier way to do this.
  my $path = WormBase::Web->path_to('/') . '/credentials';
  my $token = `cat $path/github_token.txt`;
  chomp $token;
  return unless $token;

#      curl -H "Authorization: token TOKEN" -X POST -d '{ "title":"Test Issue","body":"this is the body of the issue","labels":["HelpDesk"]}' https://api.github.com/repos/wormbase/website/issues

  my $req = HTTP::Request->new(POST => $url);
  $req->content_type('application/json');
  $req->header('Authorization' => "token $token");

# Obscure names and emails.
  my $obscured_name  = substr($name, 0, 4) .  '*' x ((length $name)  - 4);
  my $obscured_email = substr($email, 0, 4) . '*' x ((length $email) - 4);
  my $contact = $obscured_email ? $obscured_name ? "Reported by: $obscured_name ($obscured_email)  (obscured for privacy))" :
    "Reported by: $obscured_email  (obscured for privacy)" :
    "";
  my $ptitle = eval { $page->title } || $page || '';
  my $purl = $u || eval { $page->url };
  $ptitle = URI::Escape::uri_unescape($ptitle);
  $purl = URI::Escape::uri_unescape($purl);
  my $purl_base = $c->req->base;

$content .= <<END;


$contact
Submitted From: $ptitle <a href="$purl_base$purl">$purl</a>

$userAgent

END
;

  my $json         = new JSON;

# Create a more informative title
  my $trim_content = "$content";
  $trim_content =~ s/\<[^\>]*\>/\ /g;
  my $pseudo_title = substr($trim_content,0,50) . '...';
  $pseudo_title =~ s/(&[^;]*;)+/\ /g;
  my $data = { title => $pseudo_title,
	       body  => "$content",
	       labels => $title ? [ 'HelpDesk', $title ] : ['HelpDesk']
  };

  my $request_json = $json->utf8(1)->encode($data);
  $req->content($request_json);

  # Send request, get response.
  my $lwp       = LWP::UserAgent->new;
  my $response  = $lwp->request($req) or $c->log->debug("Couldn't POST");
  my $response_json = $response->content;
  my $parsed    = $json->allow_nonref->utf8->relaxed->decode($response_json);

  my $issue_url = $parsed->{html_url};
  my $issue_title = $parsed->{title};
  my $issue_number = $parsed->{number};
  return ($issue_url,$issue_title,$issue_number);
}

sub _issue_email{
    my ($self,$params) = @_;

    my $c       = $params->{c};

    my $subject ='New Issue';
    my $bcc     = $params->{reporter_email};
    $subject    = '[wormbase-help] ' . $params->{issue_title};
    $subject   .= ' (' . $params->{reporter_name} . ')' if $params->{reporter_name};

    foreach (keys %$params) {
      next if $_ eq 'c';
      $c->stash->{$_} = $params->{$_};
    }
    $c->stash->{noboiler} = 1;
    $c->stash->{timestamp} = time();
    $c->log->debug(" send out email to $bcc");
    $c->stash->{email} = {
        header => [
	    to => $c->config->{issue_email},
	    cc => $bcc,
	    "Reply-To" => "$bcc," . $c->config->{issue_email},
	    from    => $c->config->{no_reply},
	    subject => $subject,
	    ],
	    template => "feed/issue_email.tt2",
    };

    $c->forward( $c->view('Email::Template') );
}


sub _recently_saved {
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

sub _most_popular {
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

    my $ret = $api->xapian->fetch({ id => $id, class => $class, fill => 1, footer => $footer});
    return $ret unless($ret->{name}{id} ne $id || $ret->{name}{class} ne $class || ($ret->{name}{taxonomy} && $ret->{name}{taxonomy} ne $parts[-3]));
  }

  return { 'name' => {  url => $page->url,
                                label => $page->title || $page->url,
                                id => $page->title,
                                class => 'page' },
            footer => "$footer",
                    };
}


sub _comment_rss {
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


# Template assignment is a bit of a hack.
# Maybe I should just maintain
# a hash, where each field/widget lists its corresponding template
sub _select_template {
    my ($self, $type, $class, $render_target) = @_;

    my $config = $self->_app->config;

    # Normally, the template defaults to action name.
    # However, we have some shared templates which are
    # not located under root/classes/CLASS
    if (-e WormBase::Web->path_to('root', 'templates', "classes/$class/$render_target.tt2")) {
        # Check root/classes/CLASS, and use this one if exists
        return "classes/$class/$render_target.tt2";
    }elsif (($type eq 'field') && ($config->{common_fields}->{$render_target})) {
        # Some templates are shared across Models
        return "shared/fields/$render_target.tt2";
    }elsif (($type eq 'widget') && ($config->{common_widgets}->{$render_target})){
        # Widget template selection
        # Some widgets are shared across Models
        return "shared/widgets/$render_target.tt2";
    } else {
      die "cannot locate template $render_target.tt2";
    }
}




######################################################
#
#   FIELDS
#
######################################################

=head2 available_fields(), available_fields_GET()

Fetch all available fields for a given WIDGET, PAGE, NAME

eg  GET /rest/fields/[WIDGET]/[CLASS]/[NAME]

/rest/class/*/widget/field

=cut


=head field(), field_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/field/[CLASS]/[NAME]/[FIELD]

=cut

sub field :Path('/rest/field') :Args(3) :ActionClass('REST') {}

sub field_GET {
    my ( $self, $c, $class, $name, $field ) = @_;

    # Cache key - "$class_$field_$name"
    my $key = join( '_', $class, $field, $name );

    my $headers = $c->req->headers;
    $c->log->debug( $headers->header('Content-Type') );
    $c->log->debug($headers);
    my $content_type
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'text/html';

    my ( $cached_data, $cache_source ) = $c->check_cache($key);
    if($cached_data && (ref $cached_data eq 'HASH')){
        $c->stash->{$field} = $cached_data;
    } else {
      my $api = $c->model('WormBaseAPI');
      my $object = $name eq '*' || $name eq 'all'
                 ? $api->instantiate_empty(ucfirst $class)
                 : $api->fetch({ class => ucfirst $class, name => $name });

      my $data   = $object->$field();
      $c->stash->{$field} = $data;

      # Include the full uri to the *requested* object.
      # IE the page on WormBase where this should go.
      # TODO: 2011.03.20 TH: THIS NEEDS TO BE UPDATED, TESTED, VERIFIED

      $c->set_cache($key => $data);
    }

    # Supress boilerplate wrapping.
    $c->stash->{noboiler} = 1;

    my $uri = $c->uri_for( "/species", $class, $name )->path;

    $c->response->header( 'Content-Type' => $content_type );
    if ( $content_type eq 'text/html' ) {
      $c->stash->{template} = $self->_select_template( 'field', $class, $field );
      $c->forward('WormBase::Web::View::TT');
    }elsif($content_type =~ m/image/i) {

      $c->res->body($c->stash->{$field});
    }
    $self->status_ok(
        $c,
        entity => {
            class  => $class,
            name   => $name,
            uri    => "$uri",
            $field => $c->stash->{$field}
        }
    );
}


# Return the current version of acedb for the installation.
# Just returns text.
sub version :Path('/rest/version') :Args(0) :ActionClass('REST') {}

sub version_GET {
    my ( $self, $c ) = @_;
    $c->log->debug("        ------> we're requesting the acedb version via rest");
    my $api = $c->model('WormBaseAPI');
    $self->status_ok(
	$c,
	entity => {
	    version => $api->version
	}
	);
}


sub _get_page {
    my ( $self, $c, $url ) = @_;
    return $c->model('Schema::Page')->search({url=>$url}, {rows=>1})->next;
}


########################################
#
# Admin level REST endpoints
#

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
