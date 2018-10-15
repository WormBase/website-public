use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use WormBase::Web;
use Plack::App::CGIBin;
use Plack::App::Proxy;
use Plack::Builder;

use constant DEV_DEFAULT_GB => 'cgi-bin';

# The symbolic name of our application, used for configuration only.
my $app      = $ENV{APP};
my $app_root = $ENV{APP_HOME};
my $app_path;

if ($app_root) {
    $app_path = ( $app ? "$app_root" : "$app_root/wormbase" );
}
else { # no app[root] provided; use catalyst to figure it out
    $app_path = WormBase::Web->path_to('/');
}

my $wormbase = WormBase::Web->psgi_app(@_);

builder {
    # Typically running behind reverse proxy.
    enable "Plack::Middleware::ReverseProxy";
    # The core app.
    mount '/'    => $wormbase;
};
