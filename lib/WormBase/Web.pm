package WormBase::Web;

use Moose;
use namespace::autoclean;
use Hash::Merge;
#use Catalyst::Log::Log4perl;
use Log::Log4perl::Catalyst;
use Log::Any::Adapter;
use HTTP::Status qw(:constants :is status_message);
use Env 'API_TESTS';
use JSON;
use LWP;
use Net::FTP;

# Required for API unit tests:
use File::Basename;
use Test::More;
use threads;

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
	  Scheduler
/;

extends 'Catalyst';
our $VERSION = '0.02';

# Application-wide configuration is located in wormbase.conf
# which can be over-ridden by wormbase_local.conf.
__PACKAGE__->config( 'Plugin::ConfigLoader' => {
    file   => 'wormbase.conf',
    driver => {
        General => {
            -InterPolateVars => 1,
            -ForceArray      => 0,
            # Plugin::ConfigLoader uses Config::Any[::General]
            # which ForceArray by default. We don't want that.
        },
    },
});

__PACKAGE__->config('Plugin::Session', {
    expires           => 10000000000,
    dbi_dbh           => 'Schema',
    dbi_table         => 'sessions',
    dbi_id_field      => 'session_id',
    dbi_data_field    => 'session_data',
    dbi_expires_field => 'expires',
});

__PACKAGE__->config->{authentication} = {
    default_realm => 'default',
    realms => {
        default => {
            credential => {
                class             => 'Password',
                password_field    => 'password',
                #password_type    => 'clear'
                password_type     => 'salted_hash',
                password_salt_len => 4,
            },
            store => {
                class         => 'DBIx::Class',
                user_model    => 'Schema::User',
                role_relation => 'roles',
                role_field    => 'role',
                #  ignore_fields_in_find     => [ 'remote_name' ],
                #  use_userdata_from_session => 0,
            }
        },
        openid => {
            credential => {
                class      => 'OpenID',
                ua_class   => 'LWP::UserAgent',
                extensions => [
                    'http://openid.net/srv/ax/1.0' => {
                        mode              => 'fetch_request',
                        'type.nickname'   => 'http://axschema.org/namePerson/friendly',
                        'type.email'      => 'http://axschema.org/contact/email',
                        # 'type.fullname' => 'http://axschema.org/namePerson',
                        'type.firstname'  => 'http://axschema.org/namePerson/first',
                        'type.lastname'   => 'http://axschema.org/namePerson/last',
                        # 'type.dob'      => 'http://axschema.org/birthDate',
                        'type.gender'     => 'http://axschema.org/person/gender',
                        'type.country'    => 'http://axschema.org/contact/country/home',
                        'type.language'   => 'http://axschema.org/pref/language',
                        'type.timezone'   => 'http://axschema.org/pref/timezone',
                        required          => 'nickname,email,firstname,lastname',
                        if_available     => 'gender,country,language,timezone',
                    },
                ],
            },
        },
        members => {
            credential => {
                class          => 'Password',
                password_field => 'password',
                password_type  => 'none'
            },
            store => {
                class         => 'DBIx::Class',
                user_model    => 'Schema::User',
                role_relation => 'roles',
                role_field    => 'role',
                # use_userdata_from_session => 0,
            }
        },

    }
};

after setup_finalize => sub {
    my $c = shift;

    if ($c->config->{cache}{enabled} and $c->config->{cache}{couchdb}{enabled}) {
        # this is a hack to let the namespace be the db version which
        # is not available until after plugins are setup
        $c->cache('couchdb')->namespace(lc $c->model('WormBaseAPI')->version);
    }
};

# Start the application!
__PACKAGE__->setup;

################################################################################
#
#   Helper methods to be called after config file loads
#
################################################################################

sub finalize_config { # overriding Plugin::ConfigLoader
    my $c = shift;
    $c->next::method(@_);
    $c->_setup_species;
    $c->_setup_log4perl;
    $c->_setup_cache;
    $c->_setup_static;
};

sub _setup_species {
    my $c = shift;

    # process the species_list in conf
    my $original_species = $c->config->{sections}->{species_list};
    my $new_species = {};
    my $available_species = _get_json("/pub/wormbase/releases/WS250/species/ASSEMBLIES.WS250.json");
    foreach my $species (keys $original_species){
        if ($available_species->{$species}){
            # include a species ONLY if it is available
            $new_species->{$species} = $original_species->{$species};
        }
    }
    $c->config->{sections}->{species_list} = $new_species;

    # dynamically create ParaSite species list
    my $parasite_species_trees = _get_json("/pub/wormbase/parasite/releases/WBPS3/species_tree.json");
    my @parasite_species = _parse_parasite_species({ children => $parasite_species_trees }, '');
    $c->config->{sections}->{parasite_species_list} = \@parasite_species;

}

# helper function to get and parse species info located in JSON file on FTP site
sub _get_json {
    my ($path) = @_;
    my $ftp = Net::FTP->new("ftp.wormbase.org", Debug => 0,
                            Timeout=>5, Passive=>1)
        or die "Cannot connect to ftp.wormbase.org: $@";
    $ftp->login();

    my $stream = "";
    my $fh;
    open( $fh, '>', \$stream) || die "cannot open fh";
    my $r = $ftp->get($path, $fh);
    close $fh;

    my $parsed    = (new JSON)->allow_nonref->utf8->relaxed->decode($stream);
    return $parsed;
}

# traverse the parasite species tree to get the leaf species
sub _parse_parasite_species {
    my ($tree, $name_prefix) = @_;

    my $children = $tree->{children};
    unless ($children){
        # parse leaf species
        my $species = {
            name => lc(join('_',split(/\s+/,$name_prefix))),
            label => $name_prefix,
            bioproject => $tree->{label},
            url => $tree->{url}
        };
        return ($species);
    }
    my @species = ();
    foreach my $subtree (@$children){
        # parse parent species
        push @species, _parse_parasite_species($subtree, $tree->{label});
    }
    return @species;

}

sub _setup_log4perl {
    # Specific loggers for different environments
    my $c = shift;
#    my $path = $c->path_to('conf', 'log4perl',
#                           $c->config->{installation_type} . '.conf');
    my $path = $c->path_to('conf', 'log4perl','root.conf');
    $c->log(Log::Log4perl::Catalyst->new($path->stringify));
#    $c->log(Catalyst::Log::Log4perl->new($path->stringify));
    Log::Any::Adapter->set({ category => qr/^CHI/ }, 'Log4perl');
}

sub _setup_cache {
    my $c = shift;

    my $cacheconfig = $c->config->{cache};
    my $pluginconfig = $c->config->{'Plugin::Cache'} ||= {};

    # install a fake memory cache so that the Cache plugin is satisfied
    if ( ! $cacheconfig->{enabled} ) {
        $c->meta->superclasses(
            $c->meta->superclasses,
            'Catalyst::Plugin::Cache::Store::Memory'
        ); # ouch. my guess is that this may spontaneously break
        $pluginconfig->{backend} = { store => 'Memory' };
        return;
    }

    my $default = $cacheconfig->{default}
        or die 'Require a default cache backend in config';

    # perhaps we should look into using a main cache with
    # an L1 or mirror subcache... see CHI subcaches

    # in the future, we may just pass in the conf directly into
    # the backend hash. settings in the conf file will be immediately
    # reflected in the cache plugin without modification here

    if ($cacheconfig->{couchdb}{enabled}) {
        $pluginconfig->{backends}{couchdb} = {
            class        => 'CHI',
            driver_class => 'WormBase::CHI::Driver::Couch',
            server       => $cacheconfig->{couchdb}{server},
            host         => $cacheconfig->{couchdb}{host},
            port         => $cacheconfig->{couchdb}{port},
            # must be set up in $app->setup_finalize and pray that the
            # cache is not touched before then.
            namespace    => 'DUMMY',
        };
    }

    if ($cacheconfig->{memcached}{enabled}) {
        my $memcached_servers = $cacheconfig->{memcached}{server}
            or die 'No memcached server(s) specified';
        $memcached_servers = [$memcached_servers]
            unless ref $memcached_servers eq 'ARRAY';

        $pluginconfig->{backends}{memcached} = {
            class          => 'CHI',
            driver         => 'Memcached::libmemcached',
            servers        => $memcached_servers,
            expires_in     => $cacheconfig->{memcached}{expires},
        };
    }

    # Gah. Not possible for the filecache to be versioned.
    # I don't have access to the API until plugins are setup.
    if ($cacheconfig->{filecache}{enabled}) {
        my $cache_dir = $cacheconfig->{filecache}{root} // do {
            require File::Temp; File::Temp->newdir;
        };

        $pluginconfig->{backends}{filecache} = {
            class          => 'CHI',
            driver         => 'File',
            root_dir       => $cache_dir,
            store          => 'File',
            depth          => 3,
            max_key_length => 64,
        };
    }

    $pluginconfig->{backends}{default} = undef; # see get_cache_backend
}

# this can be very confusing if _setup_cache above sets a default
# in the plugin config... so don't do it.
sub get_cache_backend { # overriding Plugin::Cache
    my ($c, $name) = @_;

    if (my $backend = $c->_cache_backends->{$name}) {
        return $backend;
    }

    return $c->_cache_backends->{$c->config->{cache}{default}}
        if $name eq 'default';

    return;
}

# Set configuration for static files
# Force specific directories to be handled by Static::Simple.
# These should ALWAYS be served in static mode.
# In production, these directories are served by proxy.
sub _setup_static {
    my $c = shift;
    $c->config(static => {
        dirs         => [qw/ css js img tmp /],
	include_path => [
            '/usr/local/wormbase/tmp',
	    '/usr/local/wormbase/shared/tmp',
	    '/usr/local/wormbase/website-admin/html',
	    __PACKAGE__->config->{root},
	    __PACKAGE__->config->{shared_html_base},
	    ],
	    #   logging  => 1,

	       });
}

##################################################
#
#   Set headers for squid
#
##################################################

# There's a problem with c.uri_for when running behind a reverse proxy.
# We need to reset the base URL.
# We set the base URL above (which should probably be dynamic...)
# This isn't the best way of doing this as it only accounts for
# URIs generated with c.uri_for.
after prepare_path => sub {
    my $c = shift;
    if ($c->config->{base}) {
        $c->req->base(URI->new($c->config->{base}));
    }
};

sub finalize_error {
    my $c = shift;

    $c->config->{'response_status'}=$c->response->status;

    $c->config->{'Plugin::ErrorCatcher'}->{'emit_module'} = ["WormBase::Web::ErrorCatcherEmit","Catalyst::Plugin::ErrorCatcher::Email"];

#    if ($c->config->{installation_type} eq 'production') {
#	# Only server errors get emailed.
#	pop @{$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'}} unless is_server_error($c->config->{'response_status'});
#    } else {
	pop @{$c->config->{'Plugin::ErrorCatcher'}->{'emit_module'}};
#    }
    $c->maybe::next::method;
}


=pod

Detect if a controller request is via ajax to disable template wrapping.

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
  my $total = $ace->fetch(
      -class => ucfirst($class),
      -name  => '*'
  );

  my $object_index = 1 + int rand($total-1);

  # Fetch one object starting from the randomly determined one
  my ($object) = $ace->fetch(ucfirst($class),'*',1,$object_index);
  return $object;
}

########################################
#
#  Helper methods for interacting with the cache.
#
########################################

sub check_cache {
    my ($self, $key, $cache_name) = @_;

    return unless $self->config->{cache}{enabled};
    $cache_name ||= 'default';

    my $cache = $self->cache($cache_name);
    unless ($cache) {
        $self->log->error('No cache backend with name ', $cache_name);
        return;
    }

    if (my $data = $cache->get($key)) {
        if (wantarray) {
            my $data_origin = $cache_name;
            $data_origin .= ': ' . $cache->memd->get_server_for_key($key)
                if $cache_name eq 'memcached';
            return ($data, $data_origin);
        }
        return $data;
    }

    return;
}

sub set_cache {
    my ($self, $key, $data, $cache_name) = @_;

    return unless $self->config->{cache}{enabled};
    return if $self->check_any_user_role(qw/admin curator/);

    $cache_name ||= 'default';

    my $cache = $self->cache($cache_name);
    unless ($cache) {
        $self->log->error('No cache backend with name ', $cache_name);
        return;
    }

    return $cache->set($key => $data);
}

#######################################################
#
#    Helper Methods
#
#######################################################

sub secure_uri_for {
    my ($self, @args) = @_;

    my $u = $self->uri_for(@args);
    if($self->config->{enable_ssl}){
      $u->scheme('https');
    }
    return $u;
}

# override 'uri_for' => sub {
#     my ($self, @args) = @_;
#     my $u = super(@args);
#     return $u->path;
#   };

# overloaded from Per_User plugin to move saved items
sub merge_session_to_user {
   my $c = shift;

    $c->log->debug("merging guest session into per user session") if $c->debug;

    my $merge_behavior = Hash::Merge::get_behavior;
    my $clone_behavior = Hash::Merge::get_clone_behavior;

    Hash::Merge::set_behavior( $c->config->{user_session}{merge_type} );
    Hash::Merge::set_clone_behavior(0);

    my $sid = $c->sessionid;
    my $s_db = $c->model('Schema::Session')->find({session_id=>"session:$sid"});
    my $uid = $c->user->user_id;

    my @user_saved = $s_db->user_saved;

    my $user_items = $c->model('Schema::Starred')->search_rs({session_id=>"user:$uid"});

    foreach my $saved_item (@user_saved){
      unless($user_items->find({page_id=>$saved_item->page_id})){
        $saved_item->session_id("user:$uid");
      }else{
        $saved_item->delete();
      }
      $saved_item->update();
    }

    my $user_history = $c->model('Schema::History')->search_rs({session_id=>"user:$uid"});
    my @save_history = $s_db->user_history;
    foreach my $s_history (@save_history){
      my $u_history = $user_history->find({page_id=>$s_history->page_id});
      unless($u_history){
        $s_history->session_id("user:$uid");
      }else{
          $u_history->timestamp($s_history->timestamp)
            if $u_history->timestamp < $s_history->timestamp;
        $u_history->visit_count($u_history->visit_count + $s_history->visit_count);
        $s_history->delete();
        $u_history->update();
      }
      $s_history->update();
    }

    my $s    = $c->session;
    my @keys =
      grep { !/^__/ } keys %$s;    # __user, __expires, etc don't apply here

    my %right;
    @right{@keys} = delete @{$s}{@keys};

    %{ $c->user_session } =
      %{ Hash::Merge::merge( $c->user_session || {}, \%right ) };

    Hash::Merge::set_behavior($merge_behavior);
    Hash::Merge::set_clone_behavior($clone_behavior);


}


#######################################################
#
#    TEMPLATE SELECTION
#
#######################################################

sub _get_widget_fields {
    my ($self,$class,$widget) = @_;

    my $section = $self->config->{sections}{species}{$class}
               || $self->config->{sections}{resources}{$class};

    if (ref $section eq 'ARRAY') {
        die "There appears to be more than one $class section in the config file\n";
    }

    # this is here to prevent a widget section from getting added to config
    unless(defined $section->{widgets}{$widget}){ return (); }

    my $fields = $section->{widgets}{$widget}{fields} || [lc($widget)];
    my @fields = ref $fields eq 'ARRAY' ? @$fields : $fields // ();

    $self->log->debug("The $widget widget is composed of: " . join(", ",@fields));
    return @fields;
}

# Returns boolean check to see if this widget should be precached.
# Small performance tweak to prevent couchdb lookups when not warranted.
sub _widget_is_precached {
    my ($self,$class,$widget) = @_;
    my $section =
	$self->config->{sections}{species}{$class}
    || $self->config->{sections}{resources}{$class};

    # this is here to prevent a widget section from getting added to config
    unless(defined $section->{widgets}{$widget}){ return (); }
    return 1 if defined $section->{widgets}{$widget}{precache};
    return 0;
}

#######################################################
#
#    UNIT TEST SECTION
#
#######################################################

sub BUILD {
    my $self = shift;

    return unless $API_TESTS;

    threads->create('api_tests', $self);
}

sub api_tests {
    # Don't be strict on references, so that we can call subs below.
    no strict 'refs';

    # Don't check "uninitialized" variables. All variables below are initialized.
    # Perl is just claiming that $pkg has not been set, which is a lie.
    no warnings 'uninitialized';

    my $self = shift;
    my $api = $self->model('WormBaseAPI');
    my @tests = <t/api_tests/*.t>;
    foreach my $test (@tests) {
        next if $API_TESTS ne '1' && $API_TESTS ne basename($test, '.t');
        require_ok($test);
        my $pkg = basename($test, '.t') . '::';
        &{$pkg->{'config'}}($api);
        for my $sub (keys %$pkg) {
            subtest("$pkg::$sub",  sub {
                       eval { &{$pkg->{$sub}}(); 1; } || do {
                           my $err = $@;
                           fail("$err");
                       };
                   }) if $sub =~ /^test_/;
        }
    }

    done_testing();

    exit 0;
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
