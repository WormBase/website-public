package WormBase::Web::Controller::Auth;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use Net::Twitter;
use Facebook::Graph;
use Crypt::SaltedHash;
use Data::GUID;
use WormBase::Web::ThirdParty::Google;

__PACKAGE__->config->{namespace} = '';
use Data::Dumper;

sub login :Path("/login")  :Args(0){
     my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{'template'} = 'auth/login.tt2';
    $c->stash->{'continue'} = $c->req->params->{continue};
}

sub add_google :Path("/google") :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{user_exists} = $c->user;
    $c->stash->{google_account} = $c->user && $c->user->google_open_id;
    $c->stash->{'template'} = 'auth/google.tt2';
}

sub password : Chained('/') PathPart('password')  CaptureArgs(0) {
     my ( $self, $c) = @_;
     $c->stash->{template} = 'auth/password.tt2';
}

sub password_index : Chained('password') PathPart('index')  Args(0){
    my ( $self, $c ) = @_;
    if($c->stash->{token}  = $c->req->param("id")) {
	  my $user = $c->model('Schema::Password')->search({token=>$c->stash->{token} }, {rows=>1})->next;
      if(!$user || $user->expires < time() ){
          if($user){
            $user->delete();
            $user->update();
          }

          $c->stash->{template} = "shared/generic/message.tt2";
          $c->stash->{message} = "the link has expired";
      }
    }
}

sub password_email : Chained('password') PathPart('email')  Args(0){
    my ( $self, $c ) = @_;
    my $email = $c->req->param("email");
    $c->stash->{template} = "shared/generic/message.tt2";

    my @users = $c->model('Schema::Email')->search({email=>$email, validated=>1});
    if(@users){
      my $guid = Data::GUID->new;
      $c->stash->{token} = $guid->as_string;
      my $time = time() + $c->config->{password_reset_expires};
      foreach (@users){
          next unless($_->user);
          my $password = $c->model('Schema::Password')->find($_->user_id);
          if($password){
            if( time() < $password->expires ){
                $c->stash->{token} = $password->token;
            }else {
              $password->token($c->stash->{token}) ;
              $password->expires($time) ;
              $password->update();
            }
          }else{
            $password = $c->model('Schema::Password')->create({token=>$c->stash->{token}, user_id=>$_->user_id,expires=>$time});
          }
      }
      $c->stash->{noboiler} = 1;
      $c->log->debug("send out password reset email to $email");
      $c->stash->{email} = {
          to       => $email,
          from     => $c->config->{register_email},
          subject  => "WormBase Password",
          template => "auth/password_email.tt2",
      };
      $c->forward( $c->view('Email::Template') );
      $c->stash->{message} = "You should be receiving an email shortly describing how to reset your password.";
    }
    $c->stash->{message} ||= "no WormBase account is associated with this email";
    $c->stash->{noboiler} = 0;
}



sub password_reset : Chained('password') PathPart('reset')  Args(0){
    my ( $self, $c ) = @_;
    my $token = $c->req->body_parameters->{token};
    my $new_password = $c->req->body_parameters->{password};
    $c->stash->{template} = "shared/generic/message.tt2";

    my $pass = $c->model('Schema::Password')->search({token=>$token, expires => { '>', time() } }, {rows=>1})->next;
    if($pass && (my $user = $pass->user)){
      my $csh = Crypt::SaltedHash->new() or die "Couldn't instantiate CSH: $!";
      $csh->add($new_password);
      my $hash_password= $csh->generate();
      $user->password($hash_password);
      $pass->delete;
      $user->update();
      $pass->update();
      $c->stash->{message} = "Your password has been reset. Please login.";
    }
    $c->stash->{message} ||= "The link to reset your password has expired. Please try again.";
}


sub register :Path("/register")  :Args(0){
  my ( $self, $c ) = @_;
  $c->stash->{template} = 'auth/register.tt2';
  if($c->req->params->{inline}){
    $c->stash->{noboiler} = 1;
  }elsif($c->req->body_parameters){
     $c->stash->{email}     = $c->req->body_parameters->{email};
     $c->stash->{full_name} = $c->req->body_parameters->{name};
     $c->stash->{password}  = $c->req->body_parameters->{password};
     $c->stash->{redirect}  = $c->req->body_parameters->{redirect};
  }
}

sub confirm :Path("/confirm")  :Args(0){
    my ( $self, $c ) = @_;
    my $user=$c->model('Schema::User')->find($c->req->params->{u});
    my $wb = $c->req->params->{wb};

    $c->stash->{template} = "shared/generic/message.tt2";

    my $message;
    if(($user && !$user->active) || ($user && $wb && !$user->wb_link_confirm) || ( $user && ($user->valid_emails < $user->email_address))) {
      my @emails = $user->email_address;
      my $seen_email;
      foreach my $email (@emails) {
          if(Crypt::SaltedHash->validate("{SSHA}".$c->req->params->{code}, $email->email."_".$user->username)) {
	      unless(defined $user->primary_email){
		  $email->primary_email(1);
	      }
	      $email->validated(1);
	      $email->update();
	      $user->active(1);
	      $message = $message . "Your account is now activated, please login! ";
	      $seen_email = 1;
          }

          if ($wb) {
	      if(Crypt::SaltedHash->validate("{SSHA}".$wb, $email->email."_".$user->wbid)){
		  $user->wb_link_confirm(1);
		  $message = $message . "Your account is now linked to " . $user->wbid;
		  $seen_email = 1;
	      }
          }
          last if $seen_email;
      }
      $user->update();
    }

    $c->stash->{message} = $message || "This link is not valid or has already expired.";
    $c->forward('WormBase::Web::View::TT');
}

sub auth : Chained('/') PathPart('auth')  CaptureArgs(0) {
     my ( $self, $c) = @_;
     $c->stash->{noboiler} = 1;
     $c->stash->{template} = 'auth/login.tt2';
     $c->stash->{redirect} = $c->req->params->{redirect};
}

sub auth_popup : Chained('auth') PathPart('popup')  Args(0){
     my ( $self, $c) = @_;
     if($c->req->params->{label}) {
      $c->stash->{template} = 'auth/popup.tt2';
      $c->stash->{provider} = $c->req->params;
     } else {
        $c->log->debug("redirect: " . $c->uri_for('/auth/openid')
        ."?openid_identifier="
        .$c->req->params->{url}
        ."&redirect="
        .$c->req->params->{redirect});

    #    unless($c->config->{wormmine_path}){
        # WormMine redirects to this url now after it has logged in:
          $c->res->redirect($c->uri_for('/auth/openid')."?openid_identifier=".$c->req->params->{url}."&redirect=".$c->req->params->{redirect});
        # }else{
        #   # Redirect users to WormMine openID login
        #   $c->res->redirect( $c->uri_for('/') . $c->config->{wormmine_path} . '/openid?provider=Google');
        # }
     }
}

sub auth_login : Chained('auth') PathPart('login')  Args(0){
     my ( $self, $c) = @_;
     my $email     = $c->req->body_parameters->{email};
     my $password = $c->req->body_parameters->{password};

     if ( $email && $password ) {
        my $rs = $c->model('Schema::User')->search({active=>1, email=>$email, validated=>1, password => { '!=', undef }},
                {   select => [
                      'me.user_id',
                      'password',
                      'username',
                    ],
                    as => [ qw/
                      user_id
                      password
                      username
                    /],
                    join=>'email_address'
                });

        if ( $c->authenticate( { password => $password,
                                'dbix_class' => { resultset => $rs }
            } ) ) {
                $c->log->debug('Username login was successful. '. $c->user->get("username"));
                if(($c->user->google_open_id != 0) && $c->config->{wormmine_path}){
                  # Send to WormMine openid login after local login
                  $c->res->redirect($c->uri_for('/') . $c->config->{wormmine_path} . '/openid?provider=Google');
                }else{
                  $c->res->redirect($c->stash->{'continue'} || $c->uri_for('/'));
                }

            } else {
                $c->log->debug('Login incorrect.'.$email);
                $c->stash->{'error_notice'}='Login incorrect.';
            }
     } else {
       # invalid form input
       $c->stash->{'error_notice'}='Invalid username or password.';
     }
}

sub auth_wbid :Path('/auth/wbid')  :Args(0) {
     my ( $self, $c) = @_;
    $c->stash->{redirect} = $c->req->params->{redirect};
    $c->stash->{'template'}='auth/wbid.tt2';
}

sub auth_openid : Chained('auth') PathPart('openid')  Args(0){
     my ( $self, $c) = @_;

     $c->user_session->{redirect} = $c->user_session->{redirect} || $c->req->params->{redirect};
     my $redirect = $c->user_session->{redirect};
     my $param = $c->req->params;

     # Facebook: OAuth
     if (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ 'facebook') {
        my $fb = $self->connect_to_facebook($c);
        $c->response->redirect($fb->authorize->uri_as_string);

     # Mendeley: OAuth
     } elsif (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ 'mendeley') {
        my $mendeley = $c->model('Mendeley')->private_api;

        my $url = $mendeley->get_authorization_url();

        # The URL that the user will be returned to after authenticating.
        $mendeley->callback($c->uri_for('/auth/mendeley'));
        $c->response->redirect($url);

     # Twitter uses OAUTH, not openid.
     } elsif (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ /twitter/i) {
        my $nt = $self->connect_to_twitter($c);

        # Weird. I have to approve app each and every time since I can't
        # get session data appropriate for the user until I log in. Circular.

        # Are we already linked to Twitter? Are our auth tokens still good?
        #  unless ($self->check_twitter_authorization_status($c)) {

        # The URL that the user will be returned to after authenticating.
        my $url = $nt->get_authorization_url(callback => $c->uri_for('/auth/twitter'));

        # Save the current request tokens as a cookie.
        $c->response->cookies->{oauth} = {
            value => {
            token        => $nt->request_token,
            token_secret => $nt->request_token_secret,
            },
        };
        $c->response->redirect($url);
     # OpenID
    } elsif (defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ /google/i) {
        my $callback_url = $c->uri_for('auth/code/google');
        $callback_url->scheme('https') if $c->config->{installation_type} eq 'production';
        my $url = WormBase::Web::ThirdParty::Google->new()->get_authorization_url(
            redirect_uri => $callback_url->as_string,
            state => $c->sessionid,
            scope => 'email'
        );
        $c->response->redirect($url);
    } else {
        # eval necessary because LWPx::ParanoidAgent
        # croaks if invalid URL is specified
        #  eval {
        # Authenticate against OpenID to get user URL
        $c->config->{user_session}->{migrate}=0;

        if ( $c->authenticate({}, 'openid' ) ) {
            $c->stash->{'status_msg'} = 'OpenID login was successful.';

            # Google and other OpenID sites.
            $self->auth_local({ c          => $c,
                                openid_url => $c->user->url,
                                # Entirely google specific here.
                                email      => $param->{'openid.ext1.value.email'},
                                first_name => $param->{'openid.ext1.value.firstname'},
                                last_name  => $param->{'openid.ext1.value.lastname'},
                                auth_type  => 'openid',
                                provider   => 'google',
                                redirect   => $redirect });
        } else {
            $c->stash->{'error_notice'}='Failure during OpenID login';
        }
    }
}

sub connect_to_facebook {
    my ($self,$c) = @_;

    my $secret = $c->config->{facebook_secret_key};
    my $app_id = $c->config->{facebook_app_id};

    my $fb = Facebook::Graph->new({ app_id   => $app_id,
                                    secret   => $secret,
                                    postback => $c->uri_for('/auth/facebook/')});
    return $fb;
}

sub connect_to_twitter {
    my ($self,$c) = @_;

    my $consumer_key    = $c->config->{twitter_consumer_key};
    my $consumer_secret = $c->config->{twitter_consumer_secret};

    my $nt = Net::Twitter->new(traits          => [qw/API::REST OAuth/],
                               consumer_key    => $consumer_key,
                               consumer_secret => $consumer_secret,
                              );
    return $nt;
}



# The URL users are returned to after authenticating with Facebook (postback, even though it's a GET. Typical).
sub auth_facebook_callback : Chained('auth') PathPart('facebook')  Args(0){
    my ($self,$c) = @_;

    my $authorization_code = $c->req->params->{code};

    my $fb = $self->connect_to_facebook($c);

    $fb->request_access_token($authorization_code);
    my $access_token = $fb->access_token;

    # Get the user's name and email.
    # See the Facebook Graph API: http://developers.facebook.com/docs/reference/api/
    # and perldoc for Facebook::Graph.
    my $response   = $fb->query->find('me')->request;
    my $user       = $response->as_hashref;
    my $email      = $user->{email};  # can throw errors if not authorized by user

    $self->auth_local({c           => $c,
                       provider    => 'facebook',
                       oauth_access_token   => $access_token,
                       first_name  => $user->{first_name},
                       last_name   => $user->{last_name},
                       screen_name => $user->{username},
                       email       => $email,
                       auth_type   => 'oauth',
                    });
}


# The URL users are returned to after authenticating with Twitter.
sub auth_twitter_callback : Chained('auth') PathPart('twitter')  Args(0){
    my($self, $c) = @_;
    my %cookie   = $c->request->cookies->{oauth}->value;
    my $verifier = $c->req->params->{oauth_verifier};

    my $nt = $self->connect_to_twitter($c);

    $nt->request_token($cookie{token});
    $nt->request_token_secret($cookie{token_secret});

    my ($access_token, $access_token_secret, $user_id, $screen_name)
        = $nt->request_access_token(verifier => $verifier);

    $self->auth_local({c          => $c,
                       provider   => 'twitter',
                       oauth_access_token        => $access_token,
                       oauth_access_token_secret => $access_token_secret,
                       screen_name   => $screen_name,
                       auth_type     => 'oauth',
                    });
}


# The URL users are returned to after authenticating with Mendeley.
sub auth_mendeley_callback : Chained('auth') PathPart('mendeley')  Args(0){
    my($self, $c) = @_;

    my %cookie   = $c->request->cookies->{oauth}->value;
    my $verifier = $c->req->params->{oauth_verifier};

    my $mendeley = $c->model('Mendeley')->private_api;
    my ($access_token, $access_token_secret) = $mendeley->request_access_token;

    $self->auth_local({c          => $c,
                       provider   => 'mendeley',
                       oauth_access_token        => $access_token,
                       oauth_access_token_secret => $access_token_secret,
                       auth_type  => 'oauth',
                      });
}

# Authorization code callback (the first callback) from any Outh2 server
sub auth_code_callback : Chained('auth') PathPart('code')  Args(1){
    my($self, $c, $provider) = @_;

    my %params = %{$c->req->params};
    my ($state, $auth_code, $error) = @params{qw /state code error/};

    my $session_id = "session:$state";
    my $session = $c->get_session_data("$session_id");
    $error = 'unverified state, suspicious action' unless $session;
    # if the corresponding session doesn't exist, this request
    # couldn't have been from OAuth2 callback
    #$c->model('Schema::Session')->find({ session_id => "session:$sid" });

    if ($session) {
      unless ($error){
        my $redirect_uri = $c->uri_for($c->req->path);
        $redirect_uri->scheme('https') if $c->config->{installation_type} eq 'production';
        # seems any registered(!!) callback uri would work.

        # currently google specific, will change
        my $g_oauth = WormBase::Web::ThirdParty::Google->new();
        my $token_response = $g_oauth->request_token({
            code => $auth_code,
            redirect_uri => $redirect_uri});
        my $access_token = $token_response->{access_token};

        if ($access_token){
            my $user_profile = $g_oauth->get_user(access_token => $access_token);
            my %auth_args = (c  => $c,
                             %$token_response,
                             %$user_profile,
                             provider   => $provider,
                             auth_type  => 'oauth2',
                             redirect_to => $session->{redirect},
                         );

            $self->auth_local(\%auth_args);
            return;
        }else{
            $error = "Unexpected error. Please let us know.";
            $c->log->debug("Unexpected error in token retrieval with $provider.");
        }
      }

      # error handling
      $c->stash->{error_notice} = $error;
      $c->go('/rest/auth'); # hack!! to need to load a page not cached
      $c->res->redirect($session->{redirect});
    }

}

sub auth_local {
    my ($self,$params) = @_;
    my $c          = $params->{c};
    my $auth_type  = $params->{auth_type};

    # Create a new openid or oauth entry in openid. POSSIBLITY FOR DUPLICATION HERE?
    # Should echeck and see if the user is already logged in.
    # (or use auto_create_user: 1)
    my $authid;
    if ($auth_type eq 'openid') {
      $authid = $c->model('Schema::OpenID')->find_or_create({ openid_url => $params->{openid_url} });
    } elsif ($auth_type eq 'oauth') {
      $authid = $c->model('Schema::OpenID')->find_or_create({ oauth_access_token        => $params->{oauth_access_token},
                                                              oauth_access_token_secret => $params->{oauth_access_token_secret}
                                                          });
    } elsif ($auth_type eq 'oauth2'){
        # as OAuth2 token expires, shouldn't be relied on to identify accounts
        $authid = $c->model('Schema::OpenID')->find_or_create({
            auth_id_external => $params->{id},
            provider => $params->{provider}
        });
        # Note: access_token needs to be updated
        $authid->oauth_access_token($params->{access_token});
        # While refresh_token usually should NOT be updated, except when user withdraws permission
        $authid->oauth2_refresh_token($params->{refresh_token}) if $params->{refresh_token};
        $authid->update();
    }

    my $first_name = $params->{first_name};
    my $last_name  = $params->{last_name};
    my $email      = $params->{email};
    my $redirect   = $params->{redirect};

    my $user;
    # If we haven't yet associated a user_id to the new openid/oauth entry, do so now.
    unless ($authid->user_id) {

      # create a username based on
      #   * supplied first/last
      #   * extracted first/last (google)
      #   * screen name (Twitter)
      #   * or URL (really?)
      my $username;
      if ($first_name) {
        $username = $first_name . " " . $last_name;
      } elsif ($last_name) {
        $username = $last_name;
      } elsif ($params->{screen_name}) {
        $username = $params->{screen_name};
      } else {
        $username = $params->{openid_url};
      }

      # Does a user already exist for this account?  Try looking up by email.
      # This logic won't work if:
      # 1. Initially logging in using something like Twitter with doesn't provide email or first/last name.
      # 2. A user is trying to associate one of these accounts
      #    with an existing account.
      my @users = $c->model('Schema::Email')->search({email=>$email, validated=>1});
      @users = map { $_->user } @users;

      foreach (@users){
        next unless $_;
        next if( $_->active eq 0);
        $user=$_;
        last;
      }

      # We're attaching something like a new Google account association to an existing user.
      if ($email && $user) {
            $username = $user->username if ($user->username);
            $c->log->debug("adding openid to existing user $username");
            $user->set_columns({username=>$username, active=>1});
            $user->update();
      } elsif ($c->user && ( $auth_type eq 'oauth' ||
                             $auth_type eq 'oauth2' ||
                             $params->{provider} eq 'facebook')) {
            $user = $c->user unless $user;
      }

      # No user exists yet?  Let's create a new one.
      unless ($user) {
            $c->stash->{prompt_wbid} = 1;
            $c->stash->{redirect} = $redirect;
            $c->log->debug("creating new user $username, $email");
            $user=$c->model('Schema::User')->create({username=>$username, active=>1}) ;
            $c->model('Schema::Email')->find_or_create({email=>$email, validated=>1, user_id=>$user->user_id, primary_email=>1}) if $email;
      }

      # HARD-CODED!  The following people become admins automatically if they've
      # logged in with this email or openid account.
      if ($email =~ m{
                        todd\@wormbase\.org            |
                        todd\@hiline\.co               |
                        abby\@wormbase\.org            |
                        abigail\.cabunoc\@oicr\.on\.ca |
                        lincoln\.stein\@gmail\.com     |
                        me\@todd\.co                   |
                        xshi\@wormbase\.org
                       }x) {
        my $role=$c->model('Schema::Role')->find({role=>"admin"}) ;
        $c->model('Schema::UserRole')->find_or_create({user_id=>$user->user_id,role_id=>$role->id});
      } elsif ($email && $email =~ /\@wormbase\.org/) {
        # assigning curator role to wormbase.org domain user
        my $role=$c->model('Schema::Role')->find({role=>"curator"}) ;
        $c->model('Schema::UserRole')->find_or_create({user_id=>$user->user_id,role_id=>$role->id});
      }

      # Update the authid entry
      if ($authid) {
          $authid->user_id($user->id);                   # Link to my user.
          $authid->auth_type($auth_type);                # One of openid or oauth or oauth2
          $authid->provider($params->{provider});        # twitter, google, etc.
          $authid->screen_name($params->{screen_name});  # mostly only used by twitter.
          $authid->update();
      }
    }

    # Re-authenticate against local DBIx store
    $c->config->{user_session}->{migrate}=1;
    if ( $c->authenticate({ user_id=>$authid->user_id }, 'members') ) {
        $c->stash->{'status_msg'} = 'Local Login was also successful.';
        $c->log->debug('Local Login was also successful.');

        my $redirect_to = $params->{redirect_to} || $c->uri_for('/');
        # $c->res->header('Cache-Control' => 'no-cache');
        # $c->res->header('Refresh' => 0);
        $c->res->headers->expires(time);
        $c->res->redirect($redirect_to);

    }
    else {
        $c->log->debug('Local login failed');
        $c->stash->{'error_notice'}='Local login failed.';
    }

}

sub logout :Path("/logout") :Args(0){
    my ($self, $c) = @_;
    # Clear the user's state
    $c->logout;
    $c->stash->{noboiler} = 1;
    $c->stash->{'template'}='auth/login.tt2';
    if($c->config->{wormmine_path}){
      # Send to WormMine logout after
      $c->res->redirect($c->uri_for('/') . $c->config->{wormmine_path} . '/logout.do');
    }

    # return to url
    # $c->res->header('Refresh' => 0);
    $c->res->headers->expires(time);
    $c->res->redirect($c->req->params->{'redirect'});
}


# This is the PRIVATE profile.
sub profile :Path("/profile") :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;

    # This PROBABLY belongs in the model.
    # Fetch accounts that this user has linked to and key them by provider.
    # could do this with a group by constraint, too.
    my @accounts = $c->model('Schema::OpenID')->search({user_id => $c->user->id});
    foreach my $account (@accounts) {
      $c->stash->{linked_accounts}->{$account->provider} = $account;
    }

    # Twitter information
    if ($self->is_linked_to_twitter($c)) {

    }

    # Facebook information

    # Google information

    # Mendeley
    # my $mendeley = $c->model('Mendeley')->private_api;
    # $c->stash->{mendeley} = $mendeley;

    $c->stash->{template} = 'auth/profile.tt2';
}


sub profile_update :Path("/profile_update")  :Args(0) {
    my ( $self, $c ) = @_;
    my $email    = $c->req->params->{email_address};
    my $username = $c->req->params->{username};
    my $message;
    if($email){
        my $found;
        my @emails = $c->model('Schema::Email')->search({email=>$email, validated=>1});
        foreach (@emails) {
            $message="The email address <a href='mailto:$email'>$email</a> has already been registered.";
            $found = 1;
        }
        unless($found){
            $c->model('Schema::Email')->find_or_create({email=>$email, user_id=>$c->user->user_id});
            $c->controller('REST')->rest_register_email($c, $email, $c->user->username, $c->user->user_id);
            $message="An email has been sent to <a href='mailto:$email'>$email</a>. ";
        }
    }
    unless($c->user->username =~ /^$username$/){
        $c->user->username($username);
        $c->user->update();
        $message= $message . "Your name has been updated to $username";
    }

    $c->stash->{message} = $message;
    $c->stash->{template} = "shared/generic/message.tt2";
    $c->stash->{redirect} = $c->uri_for("me")->path;
    $c->forward('WormBase::Web::View::TT');
}


# Has the current user linked their account to Twitter?
sub is_linked_to_twitter {
    my ($self,$c) = @_;
    my $twitter = $c->model('Schema::OpenID')->find({user_id => $c->user->id,
                                                     provider => 'twitter' });

    # Authenticate.
    if ($twitter) {
        my $nt = $self->connect_to_twitter($c);

        $nt->access_token($twitter->access_token);
        $nt->access_token_secret($twitter->access_token_secret);

        if ( $nt->authorized ) {
            # Get the avatar URL.
            my $data = $nt->show_user($twitter->screen_name);
            $c->stash->{twitter_avatar_url} = $data->{profile_image_url};
            $c->stash->{twitter_screen_name} = $twitter->screen_name;    # Here or just in view?
        } else {
            # Privs have been revoked. Remove entry from open_id;
            $twitter->delete;
        }
    }
}


# Has the current user linked their account to Facebook?
# If so, do we still have an active token?
sub is_linked_to_facebook {

}





=head1 AUTHOR

xiaoqi shi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
