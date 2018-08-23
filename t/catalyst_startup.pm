#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use Catalyst::ScriptRunner;
use IO::Socket::PortState qw(check_ports);
use LWP::Simple qw(get);
use threads;

my $WEBSITE_HOST = 'localhost';
my $WEBSITE_PORT = 28000 + int(rand(4000));

my $configuration = {
    'host' => $WEBSITE_HOST,
    'port' => $WEBSITE_PORT
};

my $catalyst_thread;

push(@ARGV, '-p');
push(@ARGV, $WEBSITE_PORT);

push(@ARGV, '-d');
push(@ARGV, 1);

sub catalyst {
    Catalyst::ScriptRunner->run('WormBase::Web', 'Server');
}

sub start_catalyst {
    $catalyst_thread = threads->create('catalyst');

    my $timeout = 2;
    my %ports = (
            tcp => {
                $WEBSITE_PORT => {
                        name => 'Website'
                    }
                }
            );

    my $retries = 10;   # number of times that we check whether the Catalyst port is open
    my $retry_wait = 2; # number of seconds to wait between checks

    my $open;
    my $retry = $retries;
    while ($retry > 0) {
        sleep $retry_wait;

        check_ports($WEBSITE_HOST, $timeout, \%ports);
        $open = $ports{'tcp'}{$WEBSITE_PORT}{'open'};
        last if $open == 1;

        print STDERR "Waiting for server to start...\n";
        $retry--;
    }

    unless ($open == 1) {
        my $delay = $retries * $retry_wait;
        print STDERR "Server did not start within $delay seconds.\n";
        exit 1;
    }

    my $url = "http://$WEBSITE_HOST:$WEBSITE_PORT/rest/widget/fireup-Web.pm";
    get($url);

    return $configuration;
}

sub stop_catalyst {
    $catalyst_thread->detach() if $catalyst_thread;
}

sub wait_for_catalyst {
    $catalyst_thread->join();
}

1;
