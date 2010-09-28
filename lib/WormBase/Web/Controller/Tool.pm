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

1;
