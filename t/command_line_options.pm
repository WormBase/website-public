
use Getopt::Long;

my $host_override;
my $port_override;

$result = GetOptions("host=s" => \$host_override,
                     "port=s" => \$port_override);

unless ($result || !($host_override && $port_override)) {
    print "Parameters: [--host <hostname> --port <port>]\n";
    print "\n";
    print "When --host and --port are given, do not start a new\n";
    print "Catalyst server, but use the one running on <hostname>:<port>.\n";

    exit 1;
}

sub command_line_options {
    return { host => $host_override, port => $port_override };
}

