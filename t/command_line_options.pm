
use Getopt::Long;

my $host_override;
my $port_override;
my $individual_test;

$result = GetOptions("host=s" => \$host_override,
                     "port=s" => \$port_override,
                     "test=s" => \$individual_test);

unless ($result || !($host_override && $port_override)) {
    print "Parameters: [--host <hostname> --port <port>] [--test <testname>]\n";
    print "\n";
    print "When --host and --port are given, do not start a new\n";
    print "Catalyst server, but use the one running on <hostname>:<port>.\n";
    print "\n";
    print "If --test is provided, then only run the named test.\n";
    print "\n";

    exit 1;
}

sub command_line_options {
    return {
        host => $host_override,
        port => $port_override,
        test => $individual_test
    };
}

