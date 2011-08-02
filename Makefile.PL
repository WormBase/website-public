#!/usr/bin/env perl

use inc::Module::Install;

name 'WormBase';

# Draw version, author, and licensing from Web.pm
all_from 'lib/WormBase/Web.pm';

# Catalyst basics
requires 'Catalyst::Runtime';                  # => '5.80014';
requires 'Catalyst::Devel';                       # REQ'D for development only
requires 'Task::Catalyst';                        # A slew of basic Catalyst Goodies
requires 'parent';

# Catalyst Plugins and extensions
requires 'Catalyst::Action::REST';           
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::RenderView::ErrorHandler';
requires 'Catalyst::Authentication::Credential::OpenID';   # will need to install Math::BigInt::GMP first 
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Controller::FormBuilder';
requires 'Catalyst::Controller::CGIBin';
requires 'Catalyst::Model::Adaptor';
requires 'Catalyst::Model::Xapian::Result';
requires 'Catalyst::Log::Log4perl';
requires 'Catalyst::Plugin::Authentication';          
requires 'Catalyst::Plugin::Authorization::Roles';          
requires 'Catalyst::Plugin::Cache';                # Cache interface
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::ErrorCatcher';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::Plugin::Scheduler';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::PerUser';
requires 'Catalyst::Plugin::Session::State';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::DBI';
requires 'Catalyst::Plugin::StackTrace';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email';
requires 'Catalyst::View::GD';

# Application dependencies
requires 'Ace'                                    => '1.92';     # Good 'ole AcePerl.
requires 'Badge::GoogleTalk';                                    # 
requires 'Bio::Perl'                              => '1.006001'; #
requires 'Bio::Graphics';                                        # 
#requires 'Bio::Graphics::Browser2::Markup';                       # Sequence Summary page
requires 'B::Hooks::EndOfScope';                                 #
requires 'Cache::Memcached::libmemcached';                       #
requires 'CGI::Simple::Cookie';                                  #
requires 'Config::General';                                      #
requires 'Crypt::SaltedHash';                                    # => '0.06';
requires 'Crypt::SSLeay'; 			                 # For openid support
requires 'CHI';                                                  # Cache
requires 'CHI::Driver::Memcached::libmemcached';                 # Cache (in memory)
requires 'CHI::Driver::File';                                    # Cache (on disk)
requires 'Class::MOP';                                           # => '1.12';
requires 'Data::Dump';                                           #
requires 'Data::OptList';                                        #
requires 'DBI';                                                  #
requires 'DBD::mysql';                                           #
requires 'DB_File::Lock';                                        #
requires 'Devel::GlobalDestruction';                             #
requires 'Devel::StackTrace';                                    #
requires 'HTML::Parser';                                         #
requires 'HTML::Entities';                                       #
requires 'Facebook::Graph';                                      #
requires 'GD';                                                   #
requires 'GD::SVG';                                              #
requires 'GO::Parser';                                           #
requires 'GO::Utils';                                            #
requires 'go-db-perl';                                           #
requires 'JSON';                                                 #
requires 'List::MoreUtils';                                      #
requires 'Log::Log4perl';                                        #
requires 'Math::BigInt::GMP';   # will need to install gmp.h header file first(on Debian/Ubuntu is the libgmp3-dev package)
requires 'Memcached::libmemcached';                              #
requires 'Module::Install';                                      #
requires 'Moose'                                 => '1.21';      #
requires 'MooseX::AbstractFactory';                              #
requires 'MooseX::NonMoose';                                     # => '0.17';
requires 'MooseX::MethodAttributes::Inheritable';                # => '0.24';
requires 'MooseX::Role::WithOverloading';                        # => '0.05';
requires 'MRO::Compat';                                          #
requires 'Net::Twitter';                                         #
requires 'Net::OAuth::Simple';                                   #
requires 'Number::Format';                                       #
requires 'namespace::clean';                                     #
requires 'namespace::autoclean';                                 #
requires 'Package::DeprecationManager'           => '0.10';      #
requires 'Package::Stash'                        => '0.21';      # 
requires 'Package::Stash::XS'                    => '0.18';      #
requires 'Params::Util';                                         #
requires 'Term::ReadLine';                                       #
requires 'Search::Xapian';                                       #
requires 'Sub::Exporter';                                        #
requires 'Sub::Install';                                         #
requires 'Sub::Identify';                                        #
requires 'SVG';                                                  #
requires 'Task::Weaken';                                         #
requires 'Template::Plugin::Time::Duration';                     #
requires 'Test::YAML::Valid';                                    #
requires 'Test::Pod::Coverage';                                  #
requires 'Text::Glob';                                           #
requires 'Text::WikiText';                                       #
requires 'Time::Duration';                                       #
requires 'WWW::Mechanize';                                       #
requires 'XML::Simple';                                          #
requires 'YAML';                                                 #

#catalyst;
# The PSGI/Plack/Starman stack
requires 'Plack::Test::Adopt::Catalyst';                         #
requires 'Task::Plack';                                          #
requires 'Catalyst::Controller::Metal';                          #
requires 'Catalyst::Engine::PSGI';                               #
requires 'Catalyst::Helper::PSGI';                               #
requires 'Starman';                                              #


install_script glob('script/*.pl');
auto_install;
WriteAll;

