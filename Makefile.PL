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
requires 'Ace';
requires 'Bio::Perl' => '1.60';
requires 'Bio::Graphics';
requires 'Bundle::CPAN';
requires 'Cache::Cache';
requires 'Cache::FileCache';
requires 'CGI';
requires 'CGI::Session';
requires 'CGI::Cache';
requires 'CGI::Toggle';
requires 'Class::Base';
requires 'Data::Stag';
requires 'Date::Calc';
requires 'Date::Manip';
requires 'DBI';
requires 'DB_File';
requires 'DBD::mysql';
requires 'Digest::MD5';
requires 'ExtUtils::MakeMaker';
requires 'Flickr::API';
requires 'Flickr::API::Simple';
requires 'GD';
requires 'GD::SVG';
requires 'GD::Graph';
requires 'GD::Graph::pie';
requires 'HTML::Entities';
requires 'HTML::TokeParser';
requires 'IO::Scalar';
requires 'IO::String';
requires 'Image::GD::Thumbnail';
requires 'Log::Log4perl';
requires 'LWP';
requires 'MIME::Lite';
requires 'Net::FTP';
requires 'Net::FTP::Recursive';
requires 'Proc::Simple';
requires 'SOAP::Lite';
requires 'Statistics::OLS';
requires 'Storable';
requires 'SVG';
requires 'SVG::Graph';
requires 'Template';
requires 'Term::ReadKey';
requires 'Test::Pod';
requires 'Text::Shellwords';
requires 'Time::Format';
requires 'WeakRef';
requires 'XML::SAX';
requires 'XML::Parser';
requires 'XML::DOM';
requires 'XML::Writer';
requires 'XML::Twig';
requires 'XML::Simple';
requires 'YAML';


#CATALYST=("Task::Catalyst
#       Catalyst::Devel
#       Catalyst::Model::DBI
#       Catalyst::Model::Adaptor
#       Catalyst::Plugin::ConfigLoader
#       Catalyst::Plugin::Session
#       Catalyst::Plugin::Session::State
#       Catalyst::Plugin::Session::State::Cookie
#       Catalyst::Plugin::Session::Store::FastMMap
#       Catalyst::Action::RenderView
#       Catalyst::Action::Rest
#       Catalyst::Log::Log4perl
#       Test::YAML::Valid
#           ")





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



