use inc::Module::Install;

name 'WormBase';
all_from 'lib/WormBase::Web.pm';

requires 'Catalyst' => '5.7007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Session' => '0.19';
requires 'Catalyst::Plugin::Session::State';
requires 'Catalyst::Plugin::Session::State::Cookie' => '0.09';
requires 'Catalyst::Plugin::Session::Store::FastMmap' =. '0.05';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Action::REST';
requires 'Catalyst::Log::Log4perl';
requires 'Test::YAML::Valid';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
