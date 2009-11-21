#!/usr/bin/env perl

use inc::Module::Install;

name 'WormBase';
all_from 'lib/WormBase/Web.pm';


requires 'Catalyst::Runtime' => '5.80007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'Config::General';

# Catalyst Extras
requires 'Catalyst::Plugin::Breadcrumbs';

# Application dependencies
requires 'Moose';
requires 'namespace::clean';
requires 'Bio::Perl' => '1.60';
requires 'Bio::Graphics';
requires 'GD';
requires 'SVG';
requires 'GD::SVG';
requires 'DBI';
requires 'DBD::mysql';

#requires 'Catalyst::Plugin::Session' => '0.19';
#requires 'Catalyst::Plugin::Session::State';
#requires 'Catalyst::Plugin::Session::State::Cookie' => '0.09';
#requires 'Catalyst::Plugin::Session::Store::FastMmap' =. '0.05';

#requires 'Catalyst::Action::REST';
#requires 'Catalyst::Log::Log4perl';
#requires 'Test::YAML::Valid';


catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;



