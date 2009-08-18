package WormBase;

use Log::Log4perl;
use FindBin qw/$Bin/;
use Moose;


has 'log' => (
    is   => 'ro',
    lazy => 1,
    builder => '_build_log'
    );




sub _build_log {
    my $self = shift;
    Log::Log4perl::init("$Bin/../conf/log4perl-screen.conf");    
    my $log = Log::Log4perl::get_logger();
    return $log;
}



1;



