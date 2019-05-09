#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use File::Basename;
use Test::More;

use lib qw(./);

# Command Line Options module needs to be loaded first, due to some
# command line argument hackary when starting Catalyst.
require 't/command_line_options.pm';
require 't/catalyst_startup.pm';

$ENV{CATALYST_CONFIG_LOCAL_SUFFIX} = $ENV{'APP'};

my $options = command_line_options();

my $configuration;

if ($options->{'host'} && $options->{'port'}) {
    $configuration = $options;
} else {
    $configuration = start_catalyst();
}

my @tests = <t/rest_tests/*.t>;
foreach my $test (@tests) {
    next if $options->{'test'} && $options->{'test'} ne basename($test, '.t');
    require_ok($test);
    my $pkg = basename($test, '.t') . '::';
    &{$pkg->{'config'}}($configuration);
    for my $sub (keys %$pkg) {
        subtest("$pkg::$sub", \&{$pkg->{$sub}}) if $sub =~ /^test_/;
    }
}

done_testing();

stop_catalyst();

1;
