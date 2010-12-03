package WormBase::Web;

use Moose;
use namespace::autoclean;

# Set flags, roles, and plugins
#  -Debug
#      Activates the debug mode for useful log messages
#  ConfigLoader
#      Loads a Config::General config file from the application root
#  Static::Simple
#      Will serve static files from the application's root directory
# StackTrace
use Catalyst qw/
	  ConfigLoader
	  Cache
	  Static::Simple
	  Unicode
	  ErrorCatcher

	  Authentication
	  Authorization::Roles
	  
	  Session
	  Session::PerUser
	  Session::Store::DBI
	  Session::State::Cookie
         StackTrace
           /;

extends 'Catalyst';

use Catalyst::Log::Log4perl; 
use HTTP::Status qw(:constants :is status_message);


our $VERSION = '0.02';
 

=pod

Instead of config loader, I might write my own configuration parser/loader.
I hate not being able to use logic in the configuration file
as well as having configuration tied to application setup.

Here's an example from D rolsky

use R2::Config;
use Moose;

my $Config;

BEGIN
{
    extends 'Catalyst';

    $Config = R2::Config->new();

    Catalyst->import( @{ $Config->catalyst_imports() } );
}

__PACKAGE__->config( name => 'R2',
                     %{ $Config->catalyst_config() },
    );

=cut

 

# Create a log4perl instance
__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(
        __PACKAGE__->path_to( 'conf', 'log4perl.conf' )->stringify
    )
    );


__PACKAGE__->config->{'Plugin::Session'} = {
              expires   => 3600,
	      dbi_dbh   => 'Schema', 
	      dbi_table => 'sessions',
	      dbi_id_field => 'id',
	      dbi_data_field => 'session_data',
	      dbi_expires_field => 'expires',
};

__PACKAGE__->config->{authentication} =
                    {
                        default_realm => 'default',
                        realms => {
                            default => {
                                credential => {
                                    class => 'Password',
                                    password_field => 'password',
                                    #password_type => 'clear'
                                    password_type => 'salted_hash',
				    password_salt_len => 4,
                                },
                                store => {
                                    class => 'DBIx::Class',
                                    user_model => 'Schema::User',
                                    role_relation => 'roles',
                                    role_field => 'role',
                                  #  ignore_fields_in_find => [ 'remote_name' ],
                                  #  use_userdata_from_session => 0,
                                }
                            },
			    openid => {
                                credential => {
                                    class => 'OpenID',
				    ua_class => 'LWP::UserAgent',
				    extensions => [
					  'http://openid.net/srv/ax/1.0' => {
					      mode => 'fetch_request',
					      'type.nickname' => 'http://axschema.org/namePerson/friendly',
					      'type.email' => 'http://axschema.org/contact/email',
					     # 'type.fullname' => 'http://axschema.org/namePerson',
					      'type.firstname' => 'http://axschema.org/namePerson/first',
					      'type.lastname' => 'http://axschema.org/namePerson/last',
					     # 'type.dob' => 'http://axschema.org/birthDate',
					      'type.gender' => 'http://axschema.org/person/gender',
					      'type.country' => 'http://axschema.org/contact/country/home',
					      'type.language' => 'http://axschema.org/pref/language',
					      'type.timezone' => 'http://axschema.org/pref/timezone',
					      required => 'nickname,email,firstname,lastname',
					      if_available => 'gender,country,language,timezone',
				      },
				     ],  
                                },
                            },
			    members => {
                                credential => {
                                    class => 'Password',
                                    password_field => 'password',
                                    password_type => 'none'
                                },
                                store => {
                                    class => 'DBIx::Class',
                                    user_model => 'Schema::User',
                                    role_relation => 'roles',
                                    role_field => 'role',
                                   # use_userdata_from_session => 0,
                                }
                            },
			  
			}
                    };





# Set configuration for static files
# Force specific directories to be handled by Static::Simple.
# These should ALWAYS be served in static mode.
__PACKAGE__->config(
    static => {
    dirs => [qw/ css js img tmp /],
#    include_path => [ '/tmp/wormbase',
#              __PACKAGE__->config->{root},
#        ],  
    include_path => [ '/usr/local/wormbase/shared/tmp',
              __PACKAGE__->config->{root},
        ],  
#   logging  => 1,
    });



# THIS NEEDS TO BE MANUALLY CHANGED IN PRODUCTION
# What type of installation are we: development | mirror | local | production ?
# Unfortunately, we set it here instead of in
# our configuration file since it isn't loaded until application setup.
__PACKAGE__->config->{installation_type} = 'production';

# THIS NEEDS TO BE MANUALLY CHANGED IN PRODUCTION
# Dynamically set the base URL for production; also requires the prepare_path
#if (__PACKAGE__->config->{installation_type} eq 'production') {
#    __PACKAGE__->config->{base} = 'http://www.wormbase.org:2011/';
#} else {
##    __PACKAGE__->config->{base} = '';
#}

# Conditionally set the using front end proxy flag
__PACKAGE__->config->{using_frontend_proxy} = 1;






# Configure the application based on the type of installation.
# Application-wide configuration is located in wormbase.conf
# which can be over-ridden by wormbase_local.conf.
__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.conf',
						 driver => { 'General' => { -InterPolateVars => 1,
									    -ForceArray      => 1,
							     } 
						 },
		     } ) or die "$!";



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
    : '1 day';


# CHI-powered on-disk file cache: default.
if (1) {    
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
    class          => "CHI",
    driver         => 'File',
#    root_dir       => '/tmp/wormbase/file_cache_chi',
    root_dir       => '/usr/local/wormbase/shared/cache',
    depth          => '3',
    max_key_length => '64', 
    expires_in     => $expires_in,
    };
}

if (0) {    
    __PACKAGE__->config->{'Plugin::Cache'}{backend} = {
    class          => "CHI",
    driver         => 'Memcached::libmemcached',
    servers => ['127.0.0.1:11211'], 
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
    

##################################################
#
#   Set headers for squid
#
##################################################

 


# Finally! Start the application!
__PACKAGE__->setup;

sub finalize_error {
	my $c = shift;
	$c->config->{'response_status'}=$c->response->status;
	$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'} = ["Catalyst::Plugin::ErrorCatcher::Email", "WormBase::Web::ErrorCatcherEmit"];
 	shift @{$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'}} unless(is_server_error($c->config->{'response_status'})); 
	$c->maybe::next::method; 
}
 

# There's a problem with c.uri_for when running behind a reverse proxy.
# We need to reset the base URL.
# We set the base URL above (which should probably be dynamic...)
after prepare_path => sub {
    my $c = shift;
    if ($c->config->{base}) {
    $c->req->base(URI->new($c->config->{base}));
    }
};
    

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



########################################
#
#  Helper methods for interacting 
#  with the cache.
#
########################################
sub check_cache {
    my ($self,@keys) = @_;
    
    # First get the cache
    my $cache = $self->cache;

    # Now get the database version from the cache. Heh.
    my $version;
    unless ($version = $cache->get('wormbase_version')) {
    # The version isn't cached. So on this our first
    # check of the cache, stash the database version.
    
    $version = $self->model('WormBaseAPI')->version;
    $cache->set('wormbase_version',$version);
    }
    
    # Build a cache key that includes the version.
    my $cache_id = join("_",@keys,$version);

    # Now check the cache for the data we are looking for.
    my $cached_data = $cache->get($cache_id);

    if ($cached_data) {
    $self->log->debug("CACHE: $cache_id: ALREADY CACHED; retrieving.");
    } else {
    $self->log->debug("CACHE: $cache_id: NOT PRESENT; generating widget.");
    }

    return ($cache_id,$cached_data);
}

# Provided with a pregenerated cache_id and (probably hash reference) of data,
# store it in the cache.
sub set_cache {
    my ($self,$cache_id,$data) = @_;
    $self->cache->set($cache_id,$data) or $self->log->warn("Couldn't cache data: $!");
    return;
}



#######################################################
#
#    TEMPLATE SELECTION
#
#######################################################

# Template assignment is a bit of a hack.
# Maybe I should just maintain
# a hash, where each field/widget lists its corresponding template
sub _select_template {
    my ($self,$render_target,$class,$type) = @_;

    # Normally, the template defaults to action name.
    # However, we have some shared templates which are
    # not located under root/classes/CLASS
    if ($type eq 'field') { 
    # Some templates are shared across Models
    if (defined $self->config->{common_fields}->{$render_target}) {
        return "shared/fields/$render_target.tt2";
        # Others are specific
    } else {
        return "classes/$class/$render_target.tt2";
    }
    } else {       
    # Widget template selection
    # Some widgets are shared across Models
    if (defined $self->config->{common_widgets}->{$render_target}) {
        return "shared/widgets/$render_target.tt2";
    } else {  
        return "classes/$class/$render_target.tt2"; 
    }
    }   
}



sub _get_widget_fields {
    my ($self,$class,$widget) = @_;

    my $section;
    if($self->config->{sections}->{species}->{$class}){
      $section = 'species';
    }else{
      $section = 'resources';
    }



    my @fields;
    # Widgets accessible by name
    if (ref $self->config->{sections}->{$section}->{$class}->{widgets}->{$widget}->{fields} ne "ARRAY") {
    @fields = ($self->config->{sections}->{$section}->{$class}->{widgets}->{$widget}->{fields});
    } else {
    @fields = @{ $self->config->{sections}->{$section}->{$class}->{widgets}->{$widget}->{fields} };
    }
    $self->log->debug("The $widget widget is composed of: " . join(", ",@fields));
    return @fields;
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
