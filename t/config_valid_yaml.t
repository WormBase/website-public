#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;
use Test::YAML::Valid;

my @CONFIG = qw/wormbase.yml wormbase_local.yml.template/;

foreach (@CONFIG) {
  ok(-e $_, "$_ exists");
  yaml_file_ok($_ ,"$_ contains valid YAML");
}
