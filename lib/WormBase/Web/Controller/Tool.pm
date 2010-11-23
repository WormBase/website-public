package WormBase::Web::Controller::Tool;


use strict;
use warnings;
use parent 'WormBase::Web::Controller';

__PACKAGE__->config->{namespace} = '';

sub tool :Path("/tools") Args {
     my ( $self, $c, @args) = @_;
   #  $c->stash->{noboiler} = 1;
     my $tool = shift @args;
     my $action= shift @args || "index";
     $c->log->debug("using $tool and runiing $action\n");
      
     $c->stash->{'template'}="tool/$tool/$action.tt2";
     my $api = $c->model('WormBaseAPI');
     my ($data)= $api->_tools->{$tool}->$action($c->req->params);
          
     
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
      $c->stash->{issues_type} = "all";
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
     
} 

1;
