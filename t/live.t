#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use Catalyst::ScriptRunner;
use IO::Socket::PortState qw(check_ports);
use File::Basename;
use Test::More;
use threads;

use Data::Dumper;

my $WEBSITE_HOST = 'localhost';
my $WEBSITE_PORT = 28000 + int(rand(4000));

my $configuration = {
    'host' => $WEBSITE_HOST,
    'port' => $WEBSITE_PORT
};

push(@ARGV, '-p');
push(@ARGV, $WEBSITE_PORT);

sub catalyst {
    Catalyst::ScriptRunner->run('WormBase::Web', 'Server');
}

my $catalyst_thread = threads->create('catalyst');

my $timeout = 2;
my %ports = (
        tcp => {
            $WEBSITE_PORT => {
                    name => 'Website'
                }
            }
        );

my $retries = 10;
my $retry_wait = 2; # seconds
my $open;
while ($retries > 0) {
    sleep $retry_wait;

    check_ports($WEBSITE_HOST, $timeout, \%ports);
    $open = $ports{'tcp'}{$WEBSITE_PORT}{'open'};
    last if $open == 1;

    print STDERR "Waiting for server to start...\n";
    $retries--;
}

unless ($open == 1) {
    my $delay = $retries * $retry_wait;
    print STDERR "Server did not start within $delay seconds.\n";
    exit 1;
}

my @tests = <t/live_tests/*.t>;
foreach my $test (@tests) {
    require_ok($test);
    my $pkg = basename($test, '.t') . '::';
    &{%$pkg->{'config'}}($configuration);
    for my $sub (keys %$pkg) {
        subtest("$pkg::$sub", \&{%$pkg->{$sub}}) if $sub =~ /^test_/;
    }
}

done_testing();

$catalyst_thread->detach();

1;

