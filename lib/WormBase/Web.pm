package WormBase::Web;

#use strict;
#use warnings;
#use Catalyst::Runtime '5.80';
# Set flags and add application plugins
#
#         -Debug: activates the debug mode for very useful log messages
# ConfigLoader: 
#             will load the configuration from a Config::General file in the
#             application's home directory
#  Static::Simple:
#             will serve static files from the application's root directory

#use parent qw/Catalyst/;
#use Catalyst qw/-Debug
#		 ConfigLoader
#		 Static::Simple
#                 Unicode
#	       /;



use Moose;
use namespace::autoclean;

# your roles and plugins
use Catalyst qw/-Debug
		 ConfigLoader
		 Static::Simple
                 Unicode
	       /;
extends 'Catalyst';


#                 Breadcrumbs
#
#		 StackTrace
#		 Session
#		 Session::State::Cookie
#		 Session::Store::FastMmap

#NOTE: we may want to dynamically set the local config file suffix:
# * $ENV{ MYAPP_CONFIG_LOCAL_SUFFIX }
# * $ENV{ CATALYST_CONFIG_LOCAL_SUFFIX }
# * $c->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix }
# Thus, we could use different configuration files for any server or developer
# See C:Plugin::ConfigLoader for details


use Catalyst::Log::Log4perl; 

our $VERSION      = '0.01';
our $PERL_VERSION = '5.010000';
our $CODENAME     = 'Troncones';

# Configure the application.
# Default application-wide configuration is located in
# wormbase.yml.
# Defaults can be overriden in wormbase_local.yml for
# local or production deployment.


# Create a log4perl instance
__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(
        __PACKAGE__->path_to( 'conf', 'log4perl.conf' )->stringify
    )
    );

# $SIG{__WARN__} = sub { __PACKAGE__->log->fatal(@_); };

__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.conf',
						 driver => { 'General' => { -InterPolateVars => 1} },
		     } ) or die "$!";

__PACKAGE__->config->{static}->{dirs} = [
    qw|css
       js
       img
	tmp
      |]; 

__PACKAGE__->config->{static}->{debug} = 1;


#__PACKAGE__->config(
#    breadcrumbs => {
#	hide_index => 1,
#	hide_home  => 0,
##	labels     => {
##	    '/'       => 'Home label',
##	    '/foobar' => 'FooBar label',
##	    ....
##	},
#    },
#    );


# Are we in production?  If so, select the correct configuration file using the server name
# TODO: This needs to be a flag set during packaging/deployment as we haven't yet read in
# the configuration file. This is a hack for now

__PACKAGE__->config->{deployed} = 'under development';
if (__PACKAGE__->config->{deployed} eq 'production') {
    __PACKAGE__->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix } = $ENV{SERVER_NAME};
}


# Where will static files be located? This is a path relative to APPLICATION root
__PACKAGE__->config->{static}->{dirs} = ['static'];

# View debugging. On by default if system-wide debug is on, too.
# Toggle View debug messages that provide indication of our CSS nesting
# View debugging messages:
#     browser: in line
#     comment: HTML comments
#     log: logfile

__PACKAGE__->config->{version}  = $VERSION;
__PACKAGE__->config->{codename} = $CODENAME;


  
# These widgets can all use a single generic widget template.
# Note that this is still page specific since the field templates
# are included in the widget template.  This should be a variable, too.

# But this is weird. If I request a single field, the template is specified there.
# How can I access this?  Or rather, why override the specified template
# for the field in the widget template?

#####  ----->
# in other words: any widget that mixes generic and specific field templates
# CANNOT use the generic widget.  Annoying.

# As above, common_widgets are used throughout the model
  # but still require custom markup.
__PACKAGE__->config->{common_widgets} =  { map { $_ => 1 } qw/
							       references
							       remarks
							     /};

# We should aspire to make ALL widgets generic
# We will still have some custom fields however
__PACKAGE__->config->{generic_widgets} =  { map { $_ => 1 } qw/
								identification
								expression
								function
								homology
								location
								reagents
								similarities
							      /};


__PACKAGE__->config->{'View::JSON'} = {
    expose_stash => 'data' };



# In the configuration file, widgets are an ordered array.
# In order to enable fetching the contents of a widget
# by widget name, let's create a look up table.
# This will map widget name to position in the conf file.
# Not ideal, but at least this let's me keep configuration simple.
foreach (my $page_config = __PACKAGE__->config->{pages}) {    
    foreach my $page (keys %$page_config) {
	my $c = 0;
	my @widgets = @{__PACKAGE__->config->{pages}->{$page}->{widgets}->{widget}};

	foreach my $widget (@widgets) {
	    my $name = $widget->{name};
	    __PACKAGE__->config->{pages}->{$page}->{widget_index}->{$name} = $c;
	    $c++;
	}
    }
}


# Start the application
__PACKAGE__->setup;


#use
#   $ CATALYST_DEBUG_CONFIG=1 perl script/extjs_test.pl /
# to check what's in your configuration after loading
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
