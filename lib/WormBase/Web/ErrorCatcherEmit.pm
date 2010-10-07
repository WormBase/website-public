package WormBase::Web::ErrorCatcherEmit;

use strict;
use warnings;
 
sub emit {
    my ($class, $c, $output) = @_;
    
    my $status=$c->config->{'response_status'};   
    my $template  = "status/$status.tt2";
     
    unless(-e $c->config->{root}."/templates/$template") {  
      $template  = "status/error.tt2";
    }
	 
    eval {
	$c->response->body($c->view('TT')->render($c,$template)); 
	};
  
    return;
}
  
1;
__END__