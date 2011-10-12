package WormBase::Web::Controller::Tools;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

# TODO: blast_blat requires its own controller..

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = "tools/report.tt2";
    $c->stash->{section}  = "tools";
}

sub issue :Path('issue') Args {
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

sub issue_report :Path('issue_report') Args(0) {
    my ($self, $c) = @_; 
    $c->stash->{template} = "feed/issue.tt2";
    $c->stash->{url} = "/";
}

sub operator :Path("operator") Args {
    my ($self, $c) = @_; 
    $c->stash->{template} = "auth/operator.tt2";
}

sub comment :Path("comments") Args {
    my ( $self, $c) = @_;
    $c->stash->{template} = "feed/comment_list.tt2";
    my @comments = $c->model('Schema::Comment')->search(undef);
    $c->stash->{comments} = \@comments;
    $c->stash->{current_time}=time();
}

sub tools :Path Args {
    my ( $self, $c, @args) = @_;
    #  $c->stash->{noboiler} = 1;
    my $tool = shift @args;
    my $action= shift @args || "index";
    $c->log->debug("using $tool and running $action\n");

    $c->stash->{section} = "tools";
    $c->stash->{template}="tools/$tool/$action.tt2";
    $c->stash->{noboiler} = 1 if($c->req->params->{inline});
    my $api = $c->model('WormBaseAPI');
    my $data;

    # Does the data already exist in the cache?

    if ($action eq 'run' && $tool =~/aligner/ && !(defined $c->req->params->{Change})) {
        my ($cache_id,$cache_server);
        ($cache_id,$data,$cache_server) = $c->check_cache('tools', $tool, $c->req->params->{sequence});
        unless ($data) {
            $data = $api->_tools->{$tool}->$action($c, $c->req->params);
            $c->set_cache('filecache',$cache_id,$data);
        }
        else {
            $c->stash->{cache} = $cache_server if($cache_server);
        }
    }
    elsif ($tool =~/aligner/) {
        $data = $api->_tools->{$tool}->$action($c, $c->req->params);
    }
    else {
        $data = $api->_tools->{$tool}->$action($c->req->params);
    }

    # Create different actions for different tools instead of using
    #   this single catch-all action? -AD
    if ($tool eq 'tree') {
        $c->stash->{data} = $data;
    }
    else {
        for my $key (keys %$data) {
            $c->stash->{$key}=$data->{$key};
        }
    }
}


1;
