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

    #trim out unwanted line
    my @errors;
    foreach (@{$c->error}) {
	push @errors, split /\n/, $_;
	last if $#errors >= 2 ;
    }
    $c->error(0);
    $c->error(@errors[0..2]);

    eval {
	$c->response->body($c->view('TT')->render($c,$template)); 
	};
  
    return;
}
  
1;
__END__