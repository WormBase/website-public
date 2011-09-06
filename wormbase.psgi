#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
# Supplied by environment.
#use lib "$FindBin::Bin/../../extlib";
use WormBase::Web;
use Plack::App::CGIBin;
#use Plack::App::WrapCGI;
#use Plack::App::Proxy;
use Plack::Builder;


# The symbolic name of our application.
my $app      = $ENV{APP};
my $app_root = $ENV{APP_ROOT};

# Want to launch several variations of your app 
# on a single host? No problem!

#   use Plack::Builder;
#   builder {
#       mount '/todd'     => $todds_app;
#       mount '/abby'     => $abbys_app;
#       mount '/xshi'     => $xshis_app;
#       mount '/staging'  => $staging_app;
#   }

# GBrowse:
# For now, nginx is proxying requests to back end machine gbrowse host.

# A better way to do this would be to wrap the GBrowse CGIs.
# Then every checked out source could have their own gbrowse instance
# without having to fiddle with webserver configuration.

# 1. WrapCGI
#my $gb2 = Plack::App::WrapCGI->new(script => "/usr/local/wormbase/website/tharris/root/gbrowse/cgi/gbrowse")->to_app;
#my $gb2 = Plack::App::WrapCGI->new(script => "/usr/local/wormbase/services/gbrowse2/current/cgi/gb2/gbrowse")->to_app;

# 2. Or CGIBin. Still hard-coded for user.
my $gbrowse = Plack::App::CGIBin->new(
    root => "$app_root/$app/root/gbrowse/cgi",
    )->to_app;

# 3. OR just by proxy
#my $remote_gbrowse        = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/tools/genome")->to_app;
#my $remote_gbrowse_static = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/gbrowse2")->to_app;


######################
# The WormBase APP
######################
my $wormbase = WormBase::Web->psgi_app(@_);


builder {

# Default middlewares will NOT be added.
# Might want to add these manually.
#my $app = WormBase::Web->apply_default_middlewares(WormBase::Web->psgi_app);
#$app;
    
    # Typically running behind reverse proxy.
    enable "Plack::Middleware::ReverseProxy";
    
    # Add debug panels if we are a development environment.
    if ($ENV{PSGI_DEBUG_PANELS}) {
	enable 'Debug', panels => [ qw(DBITrace PerlConfig CatalystLog Timer ModuleVersions Memory Environment) ];
    }

    # GBrowse CGIs and static files.
    mount '/tools/genome'   => $gbrowse;
    mount "/gbrowse-static" => Plack::App::File->new(root => "$app_root/$app/root/gbrowse");

    # Plack proxying GBrowse
#    mount '/tools/genome' => $remote_gbrowse;
#    mount '/gbrowse2' => $remote_gbrowse_static;

    # The core app.
    mount '/'    => $wormbase;
};



# Without using URLMap::mount
#builder {
#    enable "Plack::Middleware::ReverseProxy";
#    WormBase::Web->psgi_app;
#};


#builder {
#    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' }
#    "Plack::Middleware::ReverseProxy";
#    $wormbase;
#};
