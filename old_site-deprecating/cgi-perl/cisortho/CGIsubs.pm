package CGIsubs;

$URIROOT="http://dev.wormbase.org/cisortho/";

use Exporter;
@ISA=('Exporter');
@EXPORT=qw(&PrintPage);
use CGI qw(:standard :pretty);

sub PrintPage{
 	my ($out,$html,$secs)=@_;
 	local *OUT;
 	unlink $out;
 	warn "Can't open $out" unless (open OUT,'>'.$out);
	#print OUT &header();
	if ($secs > 0) {
		print OUT
		  start_html(-title=>'Results Page: ',
					 -dtd=>['-//W3C//DTD XHTML 1.0 Strict//EN',
							'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'],
					 -style=>{-src=>$URIROOT."cisortho.css"},
					 -head=>meta({-http_equiv=>'refresh',
								  -content=>"$secs"}));
	}
	else {
		print OUT
		  start_html(-title=>'Results Page: ',
					 -dtd=>['-//W3C//DTD XHTML 1.0 Strict//EN',
							'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'],
					 -style=>{-src=>$URIROOT."cisortho.css"},
					 -head=>'');
	}
	print OUT "<body>\n$html\n";
	print OUT "<table><tr><td><hr></td></tr></table>\n";
	print OUT "</body>\n</html>\n";
	close OUT;
}

1;
