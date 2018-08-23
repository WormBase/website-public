use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use WormBase::Web;
use Plack::App::CGIBin;
use Plack::App::Proxy;
use Plack::Builder;

# GBrowse
use Bio::Graphics::Browser2;
use Bio::Graphics::Browser2::Render::HTML;

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

# Want to launch several variations of your app
# on a single host? No problem!

#   use Plack::Builder;
#   builder {
#       mount '/todd'     => $todds_app;
#       mount '/abby'     => $abbys_app;
#   }

my $wormbase = WormBase::Web->psgi_app(@_);

my $gbrowse;
my $gbrowse_static = Plack::App::File->new(root => "$app_path/root/gbrowse");


$ENV{GBROWSE_CONF} ||= "$app_path/conf/gbrowse";
my $gbrowse_integration = $ENV{GBROWSE_INTEGRATION}
    || (WormBase::Web->config->{installation_type} eq 'development' ?
        DEV_DEFAULT_GB : '');

# Will detect development vs production server. By default, production servers
# will use reverse proxy for GB and development server will use CGI bin'd
# GB. This can be overriden with $ENV{GBROWSE_INTEGRATION}.

if ($gbrowse_integration =~ /cgi-?bin/io) {
    $gbrowse = Plack::App::CGIBin->new( # emulate CGI bin
        root    => "$app_path/root/gbrowse/cgi",
        exec_cb => sub { 1 },
    )->to_app;
}
elsif ($gbrowse_integration =~ /psgi/io) { # wrap GBrowse up like a PSGI app
    # BUG: starman crashes intermittently.

    # Ideally, GBrowse could provide a psgi_app method like
    # Bio::Graphics::Browser2->psgi_app(@_) which would do exactly this:
    # (even more ideally, a rewrite from the ground up with PSGI in mind)
    my $gb = CGI::Emulate::PSGI->handler(sub {
       use CGI;
       my $globals = Bio::Graphics::Browser2->open_globals;
       CGI::initialize_globals();
       my $render = Bio::Graphics::Browser2::Render::HTML->new($globals);
       eval { $render->run() };
       warn $@ if $@;
       $render->destroy;
    });

    my $gb_img = Plack::App::WrapCGI->new(script => "$app_path/root/gbrowse/cgi/gbrowse_img")->to_app;

    $gbrowse = builder {
        mount '/gbrowse'     => $gb;
        mount '/gbrowse_img' => $gb_img;
    };
}
else { # proxy (fallback)
    # hardcoded addresses... should be in config or env, or config files
    $gbrowse        = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/tools/genome")->to_app;
    $gbrowse_static = Plack::App::Proxy->new(remote => "http://206.108.125.173:8000/gbrowse2")->to_app;
}

builder {
    # Typically running behind reverse proxy.
    enable "Plack::Middleware::ReverseProxy";
    enable "Plack::Middleware::ServerStatus::Lite",
        path => '/server-status',
#        allow => [ '65.219.130.69','50.19.112.56', '127.0.0.1' , '0.0.0.0/0' ],
        allow => [ '0.0.0.0/0' ],
        scoreboard => "$app_path/server-status";

    # Add debug panels if we are a development environment.
    # if ($ENV{PSGI_DEBUG_PANELS}) {
    #     enable 'Debug', panels => [ qw(DBITrace PerlConfig CatalystLog Timer
    #                                    ModuleVersions Memory Environment) ];
    # }

    # GB
    mount '/tools/genome'   => $gbrowse;
    mount "/gbrowse-static" => Plack::App::File->new(root => "$app_path/root/gbrowse");
#     mount '/movies' => Plack::App::File->new(root => "/usr/local/ftp/pub/wormbase/datasets-published/fraser_2000/movies");
    # The core app.
    mount '/'    => $wormbase;
};
