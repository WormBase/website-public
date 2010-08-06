package WormBase::Web;

use Moose;
use namespace::autoclean;

# Set flags, roles, and plugins
#  -Debug
#      Activates the debug mode for very useful log messages
#  ConfigLoader
#      Loads a Config::General config file from the application root
#  Static::Simple:
#      Will serve static files from the application's root directory
# StackTrace
use Catalyst qw/-Debug
		 ConfigLoader
                 Cache
		 Session
		 Session::Store::FastMmap
	         Session::State::Cookie
		 Static::Simple
                 Unicode
	       /;

extends 'Catalyst';

use Catalyst::Log::Log4perl; 

our $VERSION      = '0.02';
our $PERL_VERSION = '5.010000';
our $CODENAME     = 'La Saladita';

# Create a log4perl instance
__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(
        __PACKAGE__->path_to( 'conf', 'log4perl.conf' )->stringify
    )
    );

# What type of installation are we: development | mirror | local | production ?
# Unfortunately, we set it here instead of in
# our configuration file that hasn't been loaded yet.
__PACKAGE__->config->{installation_type} = 'development';

# Configure the application based on the type of installation.
# Application-wide configuration is located in wormbase.conf
# which can be over-ridden by wormbase_local.conf.
__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.conf',
						 driver => { 'General' => { -InterPolateVars => 1} },
		     } ) or die "$!";

# For non-development installations, set the local configuration 
# file suffix to the name of the server. Not currently in use
# but I'm keeping it around just in case.
#if (__PACKAGE__->config->{installation_type} eq 'production') {    
#    __PACKAGE__->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix } = $ENV{SERVER_NAME};
#}


# Where will static files be located? This is a path relative to APPLICATION root
__PACKAGE__->config->{static}->{dirs} = [
    qw|css
       js
       img
       tmp
      |]; 

# Store the version and codename in the configuration object. Oh, the vanity.
__PACKAGE__->config->{version}  = $VERSION;
__PACKAGE__->config->{codename} = $CODENAME;

# Huh?  What is this?
__PACKAGE__->config->{static}->{debug} = 1;

# Which elements of the data structure should be exposed in JSON renders?
__PACKAGE__->config->{'View::JSON'} = {
    expose_stash => 'data' };

##################################################
#
#   Dynamically establish the cache backend
#
##################################################
# First, if we are a development site, we still want
# to test the caching mechanism, we just don't want 
# it to persist.
my $expires_in = (__PACKAGE__->config->{installation_type} eq 'production')
    ? '4 weeks'
    : '3 seconds';

# CHI-powered on-disk file cache: default.
if (1) {	
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
	class          => "CHI",
	driver         => 'File',
	root_dir       => '/tmp/wormbase/file_cache_chi',
	depth          => '3',
	max_key_length => '32',	
	expires_in     => $expires_in,
    };
}


# Here's a typical example for Cache::Memcached::libmemcached
if (0) {
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
	class   => "Cache::Memcached::libmemcached",
	servers => ['127.0.0.1:11211'],
	debug   => 2,
    };
}

# FastMmap. WORKS, although I'm uncertain of how well it will scale.
if (0) {
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
	class => "Cache::FastMmap",
	share_file => "/Users/todd/tmp_cache",
	cache_size => "64m",
	num_pages  => '1039',  # Should be a prime number for best hashing.
	page_size  => '128k',	
    };
}

# FastMmap as a store; Uses Catalyst::Plugin::Cache::Store::FMmap which must be loaded.
# Sets up default share_file and other params.
if (0) {
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
	store => "FastMmap",
    };
}
    


# Finally! Start the application!
__PACKAGE__->setup;



#if __PACKAGE__->config->{debug}
#$ENV{CATALYST_DEBUG_CONFIG} && print STDERR 'cat config looks like: '. dump(__PACKAGE__->config) . "\n";# . dump(%INC)."\n";


=pod

Detect if a controller request is via ajax to disable
template wrapping.

=cut

sub is_ajax {
  my $c       = shift;
  my $headers = $c->req->headers;
  return $headers->header('X-Requested-With');
}



sub get_example_object {
  my ($self,$class) = @_;
  my $api = $self->model('WormBaseAPI');

  my $ace = $api->_services->{acedb};
  # Fetch the total number of objects
  my $total = $ace->fetch(-class => ucfirst($class),
			  -name  => '*');
  
  my $object_index = 1 + int rand($total-1);

  # Fetch one object starting from the randomly determined one
  my ($object) = $ace->fetch(ucfirst($class),'*',1,$object_index);
  return $object;
}


=head1 NAME

WormBase - Catalyst based application

=head1 SYNOPSIS

    script/wormbase_server.pl

=head1 DESCRIPTION

WormBase - the WormBase web application

=head1 SEE ALSO

L<WormBase::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
