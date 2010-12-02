#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../extlib";
use WormBase::Web;
use Plack::Builder;

WormBase::Web->setup_engine('PSGI');
my $app = sub { WormBase::Web->run(@_) };

builder {
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
    "Plack::Middleware::ReverseProxy";
    $app;
};
