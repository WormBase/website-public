package WormBase::Web::Controller::Tool;


use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use List::Util qw(shuffle);
use Badge::GoogleTalk;

__PACKAGE__->config->{namespace} = '';

sub tool_summary :Path("/tools") :Args(0) {
  my ( $self, $c) = @_;

    $c->stash->{template} = "tool/report.tt2";
    $c->forward('WormBase::Web::View::TT')
}

sub tool :Path("/tools") Args {
     my ( $self, $c, @args) = @_;
   #  $c->stash->{noboiler} = 1;
     my $tool = shift @args;
     my $action= shift @args || "index";
     $c->log->debug("using $tool and runiing $action\n");
      
     $c->stash->{'template'}="tool/$tool/$action.tt2";
     my $api = $c->model('WormBaseAPI');
     my ($data)= $api->_tools->{$tool}->$action($c->req->params);
     $c->stash->{noboiler} = 1 if($c->req->params->{inline});
     
    for my $key (keys %$data){

	$c->stash->{$key}=$data->{$key};
    }
}


sub issue :Path("tools/issues") Args {
    my ( $self, $c ,$id) = @_;
    unless($id) {
      $c->stash->{template} = "feed/issue.tt2";
      my @issues = $c->model('Schema::Issue')->search(undef);
      $c->stash->{issues} = \@issues;
      $c->stash->{current_time}=time();
      return;
    }
    $c->stash->{template} = "feed/issue_page.tt2";
    my $issue = $c->model('Schema::Issue')->find($id);
    $c->stash->{issue} = $issue;
    my @threads= $issue->issues_to_threads(undef,{order_by=>'thread_id ASC' } ); 
    $c->stash->{current_time}=time();
    my $last;
    if(@threads){
      $c->stash->{threads} = \@threads ;
      $last = $threads[scalar @threads -1];
      $c->stash->{last_edit}=$last->user ;
    }
    $c->stash->{last_edit}= $issue->owner unless($last);
    if($c->check_user_roles('admin')) {
	my $role=$c->model('Schema::Role')->find({role=>'curator'});
	$c->stash->{curators}=[$role->users];
    }
} 

sub operator :Path("tools/operator") Args {
    my ( $self, $c) = @_;
    $c->stash->{be_operator}=1 if($c->user_exists && !$c->check_user_roles("operator") && $c->check_any_user_role(qw/admin curator/)) ; 
    $c->stash->{template} = "auth/operator.tt2";
 
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
    
}


1;
