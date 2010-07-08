#!/usr/bin/env perl

use inc::Module::Install;

name 'WormBase';

# Draw version, author, and licensing from Web.pm
all_from 'lib/WormBase/Web.pm';

requires 'Catalyst::Runtime' => '5.80014';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'parent';

# We're using Config::General format
requires 'Config::General';

# Application dependencies
requires 'Ace';
requires 'Bio::Perl';                        # This should be 1.60 or greater
requires 'Bio::Graphics';
requires 'Catalyst::Devel';                  # REQ'D FOR DEVELOPMENT ONLY
requires 'Task::Catalyst';                   # A slew of basic Catalyst Goodies
requires 'Catalyst::Action::REST';           
requires 'Catalyst::Action::RenderView::ErrorHandler';
requires 'Catalyst::Controller::FormBuilder';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Log::Log4perl';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::View::JSON';
requires 'DBI';
requires 'DBD::mysql';
requires 'GD';
requires 'GD::SVG';
requires 'Module::Install';
requires 'Moose';
requires 'MooseX::AbstractFactory';
requires 'namespace::clean';
requires 'SVG';
requires 'Task::Weaken';
requires 'Test::YAML::Valid';
requires 'Test::Pod::Coverage';
requires 'WWW::Mechanize';
requires 'YAML';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

