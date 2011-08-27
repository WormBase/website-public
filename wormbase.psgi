#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
#use lib "$FindBin::Bin/../../extlib";
use WormBase::Web;
use Plack::Builder;


#my $app = sub { WormBase::Web->psgi_app(@_) };
#my $app = WormBase::Web->apply_default_middlewares(WormBase::Web->psgi_app);
#$app;



#WormBase::Web->setup_engine('PSGI');
#my $app = sub { WormBase::Web->run(@_) };
#my $app = WormBase::Web->psgi_app(@_);
#
builder {
    enable "Plack::Middleware::ReverseProxy";
    WormBase::Web->psgi_app;
};

#builder {
#    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
#    "Plack::Middleware::ReverseProxy";
#    $app;
#};
