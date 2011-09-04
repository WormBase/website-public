package WormBase::Web::Controller::Tool;


use strict;
use warnings;
use parent 'WormBase::Web::Controller';
 

__PACKAGE__->config->{namespace} = '';

sub tool_summary :Path("/tools") :Args(0) {
  my ( $self, $c) = @_;

    $c->stash->{template} = "tool/report.tt2";
    $c->stash->{section} = "tools";
    $c->forward('WormBase::Web::View::TT')
}

sub tool :Path("/tools") Args {
    my ( $self, $c, @args) = @_;
    #  $c->stash->{noboiler} = 1;
    my $tool = shift @args;
    my $action= shift @args || "index";
    $c->log->debug("using $tool and running $action\n");
    
    $c->stash->{section} = "tools";
    $c->stash->{template}="tool/$tool/$action.tt2";
    $c->stash->{noboiler} = 1 if($c->req->params->{inline});
    my $api = $c->model('WormBaseAPI');
    my $data;
    
    # Does the data already exist in the cache?
    
    if ($action eq 'run' && $tool =~/aligner/ && !(defined $c->req->params->{Change})) {
      my ($cache_id,$cache_server);
      ($cache_id,$data,$cache_server) = $c->check_cache('tools', $tool, $c->req->params->{sequence});
      unless ($data) {  
          $data = $api->_tools->{$tool}->$action($c, $c->req->params);
#    I don't know how to set up caching now with the new cache stuff... -AC
#           $c->set_cache('filecache',$cache_id,$data);
#         $c->set_cache({cache_name => 'couchdb',
#                uuid       => $cache_id,
#                data       => $data,           
#               });
      } else {
          $c->stash->{cache} = $cache_server if($cache_server);
      }
    } else{
      if($tool =~/aligner/){
        $data = $api->_tools->{$tool}->$action($c, $c->req->params);
      }else{
        $data = $api->_tools->{$tool}->$action($c->req->params);
      }
    }
    
    # Um. Not sure how this works for other tools.    
    if ($tool eq 'tree') {
	$c->stash->{data} = $data;
    } else {
	for my $key (keys %$data){
	    $c->stash->{$key}=$data->{$key};
	}
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
    my @threads= $issue->threads(undef,{order_by=>'thread_id ASC' } ); 
    $c->stash->{current_time}=time();
    my $last;
    if(@threads){
      $c->stash->{threads} = \@threads ;
      $last = $threads[scalar @threads -1];
      $c->stash->{last_edit}=$last->user ;
    }
    $c->stash->{last_edit}= $issue->reporter unless($last);
    if($c->check_user_roles('admin')) {
	my $role=$c->model('Schema::Role')->find({role=>'curator'});
	$c->stash->{curators}=[$role->users];
    }
} 

sub issue_report :Path("tools/issues/report") Args(0) {
    my ($self, $c) = @_; 
    $c->stash->{template} = "feed/issue.tt2";
    $c->stash->{url} = "/";
}

sub operator :Path("tools/operator") Args {
    my ($self, $c) = @_; 
    $c->stash->{template} = "auth/operator.tt2";
}

sub comment :Path("tools/comments") Args {
    my ( $self, $c) = @_;
    $c->stash->{template} = "feed/comment_list.tt2";
    my @comments = $c->model('Schema::Comment')->search(undef);
    $c->stash->{comments} = \@comments;
    $c->stash->{current_time}=time();
    return;
} 


1;
