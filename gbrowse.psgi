#!/usr/bin/env perl

# WormBase's standalone GBrowse PSGI script.
# Prereqs:
#     * All GBrowse prereqs
#     * Plack
#     * Plack::App::CGIBin
#     * Plack::Handler::FCGI
#     Recommended
#     * Plack::App::WrapCGI
#     * Plack::App::Proxy
#     * Plack::Builder

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";            # WormBase aggregators
use lib "$FindBin::Bin/../../extlib2";  # Perl libs
use Plack::App::CGIBin;
#use Plack::App::WrapCGI;
#use Plack::App::Proxy;
use Plack::Builder;

# The symbolic name of our application.
my $app      = 'production';
my $app_root = '/usr/local/wormbase/website';
$app_root = '.';
$ENV{GBROWSE_CONF}   = "$app_root/$app/conf/gbrowse";
$ENV{GBROWSE_HTDOCS} = "$app_root/$app/root/gbrowse";


# 1. WrapCGI
#my $gb2 = Plack::App::WrapCGI->new(script => "/usr/local/wormbase/website/tharris/root/gbrowse/cgi/gbrowse")->to_app;
#my $gb2 = Plack::App::WrapCGI->new(script => "/usr/local/wormbase/services/gbrowse2/current/cgi/gb2/gbrowse")->to_app;

# 2. Or CGIBin
my $gbrowse = Plack::App::CGIBin->new(
    root => "$app_root/$app/root/gbrowse/cgi",
    )->to_app;

# 3. OR just by proxy
#my $remote_gbrowse        = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/tools/genome")->to_app;
#my $remote_gbrowse_static = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/gbrowse2")->to_app;


builder {

    # Default middlewares will NOT be added.
    # Might want to add these manually.
    #my $app = WormBase::Web->apply_default_middlewares(WormBase::Web->psgi_app);
    #$app;

    # Typically running behind reverse proxy.
    enable "Plack::Middleware::ReverseProxy";

    # Add debug panels if we are a development environment.
#    if ($ENV{PSGI_DEBUG_PANELS}) {
#	enable 'Debug', panels => [ qw(DBITrace PerlConfig CatalystLog Timer ModuleVersions Memory Environment) ];
#    }

    # Gbrowse static files:
    mount '/tools/genome'  => $gbrowse;
    mount "/gbrowse-static" => Plack::App::File->new(root => "$app_root/$app/root/gbrowse");


    # Mounting GBrowse as an app
#    mount '/gb'  => $gb2;
#    mount '/cgi' => $gbrowse;


    # Plack proxying GBrowse
#    mount '/tools/genome' => $remote_gbrowse;
#    mount '/gbrowse2' => $remote_gbrowse_static;

    # THe core app.
#    mount '/'    => $wormbase;
};
