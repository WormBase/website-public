package WormBase::API::Role::Logger;

use Log::Log4perl;
#use FindBin qw/$Bin/;
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


# If not provided with a Log4perl object,
# create a new one during instantiation.
sub _build_log {
    my $self = shift;

    # Use the default log4perl.conf file supplied with the web app
    # This is not ideal at the moment as it is specific to t/WormBase/API/Object

    my $root  = $self->conf_dir;
    Log::Log4perl::init("$root/log4perl.conf");
    my $log = Log::Log4perl::get_logger();
    return $log;
}

1;



