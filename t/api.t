#!/usr/bin/env perl

BEGIN {
    $ENV{CATALYST_SCRIPT_GEN} = 40;
}

use Test::More;

use Data::Dumper;

require 't/catalyst_startup.pm';

start_catalyst();

wait_for_catalyst();

1;

