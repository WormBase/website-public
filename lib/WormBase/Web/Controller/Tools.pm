package WormBase::Web::Controller::Tools;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

# TODO: blast_blat requires its own controller..
sub index :Path :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = "tools/report.tt2";
    $c->stash->{section}  = "tools";
    # get static widgets / layout info for this page
    $self->_setup_page($c);
}

sub metric_viewer :Path('metric_viewer') :Args(0) {
    my ($self, $c) = @_; 
    $c->stash->{template} = "tools/metric_viewer/index.tt2";
    $c->stash->{url} = $c->req->params->{url} || "/";
    return;
}

sub support :Path('support') :Args(0) {
    my ($self, $c) = @_; 
    $c->stash->{section}  = "tools";
    $c->stash->{template} = "feed/issue.tt2";
    $c->stash->{class} = "support";
    $c->stash->{url} = $c->req->params->{url} || "/";
    return;
}

sub comment :Path("comments") :Args(0) {
    my ( $self, $c) = @_;
    $c->stash->{template} = "feed/comment_list.tt2";
    my @comments = $c->model('Schema::Comment')->search(undef);
    $c->stash->{comments} = \@comments;
    $c->stash->{current_time}=time();
    $c->stash->{class} = "comments";
}

sub tools :Path Args {
    my ( $self, $c, @args) = @_;

    my $tool = shift @args;
    my $action= shift @args || "index";
    $c->log->debug("using $tool and running $action\n");

    if ("$tool" eq 'schema' && "$action" eq "run") {
        $tool = 'tree';
        $c->req->params->{'name'} = 'all';
    } #Since schema is identical to tree, use tree to generate content
    if ("$tool" eq 'gmap' || "$tool" eq 'epic') {
        $c->req->params->{'class'} = 'Map' unless $c->req->params->{'class'} || "$tool" eq 'epic';
        $c->req->params->{'tool'} = $tool;
        $tool = 'epic';
    } #Since gmap is identical to epic, use epic to load display


    $c->stash->{section} = "tools";
    $c->stash->{class} = $tool;
    $c->stash->{template}="tools/$tool/$action.tt2";
    $c->stash->{noboiler} = 1 if($c->req->params->{inline});
    my $api = $c->model('WormBaseAPI');
    my ($data, $cache_server);

    # Does the data already exist in the cache?
    if ($action eq 'run' && $tool =~/aligner/ && !(defined $c->req->params->{Change})) {
        my $cache_id ='tools_'.$tool.'_'.$c->req->params->{sequence};
        ($data, $cache_server) = $c->check_cache($cache_id, 'filecache');

        unless ($data) {
        $c->log->debug("not in cache, run $tool\n");
            $data = $api->_tools->{$tool}->$action($c, $c->req->params);
            $c->set_cache($cache_id => $data, 'filecache');
        }
        else {
            $c->stash->{cache} = $cache_server if($cache_server);
        }
    } elsif ($action eq 'run' && (keys %{$c->req->params} < 1)){
          $c->res->redirect($c->uri_for('/tools', $tool)->path, 307);
          return;
    } elsif ($tool =~/aligner/) {
        $data = $api->_tools->{$tool}->$action($c, $c->req->params);
    } elsif ($tool =~ /epic/ || $tool =~ /gmap/) {
        $data = $api->_tools->{$tool}->$action($c,$c->req->params);
    } elsif($api->_tools->{$tool}) {
        $data = $api->_tools->{$tool}->$action($c->req->params, $c);
    } else {
        # return 404 if the tool cannot be found
        $c->detach('/soft_404');
        return;
    }

    # Create different actions for different tools instead of using
    #   this single catch-all action? -AD
    if($data->{redirect}){
        my $url;
        if ($data->{redirect_as_is}) {
            $url = $data->{redirect};
        } else {
            $url = $c->uri_for('/search',$data->{class},$data->{name})->path."?from=".$data->{redirect}."&query=".$data->{msg};
        }
        $c->res->redirect($url, 307);
    }

    if ($tool eq 'tree' || $tool eq 'epic') { 
        $c->stash->{data} = $data; 
    } else {
        for my $key (keys %$data) {
            $c->log->debug("save in stash key $key\n");
            $c->stash->{$key}=$data->{$key};
        }
    }
}

1;
