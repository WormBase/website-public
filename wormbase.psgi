#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
# Supplied by environment.
#use lib "$FindBin::Bin/../../extlib";
use WormBase::Web;
use Plack::Builder;



# Want to launch several variations of your app 
# on a single host? No problem!

#   use Plack::Builder;
#   builder {
#       mount '/todd'     => $todds_app;
#       mount '/abby'     => $abbys_app;
#       mount '/xshi'     => $xshis_app;
#       mount '/staging'  => $staging_app;
#   }

#my $app = sub { WormBase::Web->psgi_app(@_) };

# Default middlewares will NOT be added.
# Might want to add these manually.
#my $app = WormBase::Web->apply_default_middlewares(WormBase::Web->psgi_app);
#$app;

builder {
    enable "Plack::Middleware::ReverseProxy";
    WormBase::Web->psgi_app;
};

#builder {
#    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
#    "Plack::Middleware::ReverseProxy";
#    $app;
#};
