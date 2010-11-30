#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use WormBase::Web;
#use MyApp::Util;

use Catalyst::Engine::PSGI;
use FCGI::ProcManager;
use Plack::Builder;
use Plack::Middleware::AccessLog;
use Plack::Middleware::Debug;

# I load configuration info from my app. you are probably not cool enough to do this
#my $config = MyApp::Util->get_config;
#my $name = $config->{server_name} or die "server_name not set in config";
#my $log_dir = MyApp::Util->log_dir or die "log_dir not set in config";
#die "log_dir $log_dir does not exist\n" unless -d $log_dir;
#die "log_dir $log_dir is not writable\n" unless -w $log_dir;

WormBase::Web->setup_engine('PSGI');
my $app = sub { WormBase::Web->run(@_) };

builder {
#    my $logfh;
#    my $access_logfile = "$log_dir/access-log-$name";
#    my $error_logfile = "$log_dir/error-log-$name";
#    open $logfh, ">>", $access_logfile or die $!;
#    open STDERR, ">>", $error_logfile or die $!;
#    $logfh->autoflush(1);
#
#    enable "AccessLog", logger => sub { print $logfh @_ };
#
#    # debug panel
#    enable 'Debug', panels => $config->{plack_debug_panel}
#    if $config->{plack_debug_panel};
#
    # if we're using perlbal, fix some request params. replace 12.34.56.78 with your public IP
    enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1'
                    || $_[0]->{REMOTE_ADDR} eq '12.34.56.78' }
    "Plack::Middleware::ReverseProxy";

    return $app;
};
