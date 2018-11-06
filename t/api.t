#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use Test::More;

use Data::Dumper;

use lib qw(./);

require 't/catalyst_startup.pm';

$ENV{CATALYST_CONFIG_LOCAL_SUFFIX} = $ENV{'APP'};

start_catalyst();

wait_for_catalyst();

1;
