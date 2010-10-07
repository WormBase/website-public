package WormBase::Web::ErrorCatcherEmit;

use strict;
use warnings;
 
sub emit {
    my ($class, $c, $output) = @_;
    
    my $status=$c->config->{'response_status'};   
    my $template  = "error.tt2";
    $template  = "status/$status.tt2" if($status =~ /301|400|404|500|502/);
	 
    eval {
	$c->response->body($c->view('TT')->render($c,$template)); 
	};
  
    return;
}
  
1;
__END__