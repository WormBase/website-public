#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use File::Basename;
use Test::More;

require 't/catalyst_startup.pm';

my $configuration = start_catalyst();

my @tests = <t/rest_tests/*.t>;
foreach my $test (@tests) {
    require_ok($test);
    my $pkg = basename($test, '.t') . '::';
    &{%$pkg->{'config'}}($configuration);
    for my $sub (keys %$pkg) {
        subtest("$pkg::$sub", \&{%$pkg->{$sub}}) if $sub =~ /^test_/;
    }
}

done_testing();

stop_catalyst();

1;

