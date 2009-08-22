package WormBase::API::Role::Logger;

use Log::Log4perl;
use FindBin qw/$Bin/;

use Moose::Role;

=head1 ATTRIBUTES

=head2 log

Status : optional
Type   : A Log::Log4perl object

If not specified, a default Log::Log4Perl object will
be created that appends STDOUT to the screen.

=cut

has 'log' => (
    is   => 'ro',
    lazy => 1,
    builder => '_build_log'
    );

sub _build_log {
    my $self = shift;
    Log::Log4perl::init("/usr/local/wormbase/website-2.0/conf/log4perl-screen.conf");    
    my $log = Log::Log4perl::get_logger();
    return $log;
}



1;



