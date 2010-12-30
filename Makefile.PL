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
requires 'Bio::Grapics::Browser2::Markup';   # Sequece Summary page
requires 'Catalyst::Devel';                  # REQ'D FOR DEVELOPMENT ONLY
requires 'Task::Catalyst';                   # A slew of basic Catalyst Goodies
requires 'Cache::Memcached::libmemcached';
requires 'Catalyst::Action::REST';           
#requires 'Catalyst::Action::RenderView::ErrorHandler';
requires 'Catalyst::Authentication::Credential::OpenID';   # will need to install Math::BigInt::GMP first 
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Controller::FormBuilder';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Log::Log4perl';
requires 'Catalyst::Plugin::Authentication';          
requires 'Catalyst::Plugin::Authorization::Roles';          
requires 'Catalyst::Plugin::Cache';          # Cache interface
requires 'Catalyst::Plugin::ErrorCatcher';          # Cache interface
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::PerUser';
requires 'Catalyst::Plugin::Session::State';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBI';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::GD';
requires 'Crypt::SaltedHash';
requires 'Crypt::SSLeay'; 					#for openid to work for (https)
requires 'CHI';                              # Cache backend
requires 'CHI::Driver::Memcached::libmemcached';                              
requires 'DBI';
requires 'DBD::mysql';
requires 'DB_File::Lock';
requires 'GD';
requires 'GD::SVG';
requires 'Badge::GoogleTalk';
requires 'Math::BigInt::GMP';				# will need to install gmp.h header file first(on Debian/Ubuntu is the libgmp3-dev package)
requires 'Module::Install';
requires 'Moose';
requires 'MooseX::AbstractFactory';
requires 'Net::Twitter';
requires 'namespace::clean';
requires 'SVG';
requires 'Task::Weaken';
requires 'Test::YAML::Valid';
requires 'Test::Pod::Coverage';
requires 'Text::Glob';
requires 'Time::Duration';
requires 'WWW::Mechanize';
requires 'YAML';

#catalyst;
# PSGI/Plack
requires 'Plack::Test::Adopt::Catalyst';
requires 'Task::Plask';
requires 'Catalyst::Controller::Metal';
requires 'Catalyst::Engine::PSGI';
requires 'Catalyst::Helper::PSGI';
requires 'Starman';


install_script glob('script/*.pl');
auto_install;
WriteAll;

