package WormBase::Web::Controller::Auth;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use Net::Twitter;
use Facebook::Graph;
use Data::Dumper;
use Crypt::SaltedHash;

__PACKAGE__->config->{namespace} = '';
 
 
sub login :Path("/login") {
     my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{'template'} = 'auth/login.tt2';
    $c->stash->{'continue'} = $c->req->params->{continue};
}

sub register :Path("/register") {
  my ( $self, $c ) = @_;
  if($c->req->params->{inline}){
    $c->stash->{noboiler} = 1;
  }else{
     $c->stash->{email}     = $c->req->body_parameters->{email};
     $c->stash->{full_name} = $c->req->body_parameters->{name};
     $c->stash->{password}  = $c->req->body_parameters->{password}; 
     $c->stash->{redirect}  = $c->req->body_parameters->{redirect}; 
  }
  $c->stash->{template} = 'auth/register.tt2';
#     $c->stash->{'continue'}=$c->req->params->{continue};
}

sub confirm :Path("/confirm") {
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

=pod
sub openid :Path("/openid") {
     my ( $self, $c ) = @_;
     $c->stash->{noboiler} = 1;
     $c->stash->{'template'}='auth/openid.tt2';
}
=cut

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
	 
	 $c->res->redirect($c->uri_for('/auth/openid')."?openid_identifier=".$c->req->params->{url}."&redirect=".$c->req->params->{redirect});
     }     
}

sub auth_login : Chained('auth') PathPart('login')  Args(0){
     my ( $self, $c) = @_;
     my $email     = $c->req->body_parameters->{email};
     my $password = $c->req->body_parameters->{password}; 

     if ( $email && $password ) {
        my $rs = $c->model('Schema::User')->search({active=>1, email=>$email, validated=>1, password => { '!=', undef }},
                {   select => [ 
                      'id',
                      'password', 
                      'username',
                    ],
                    as => [ qw/
                      id
                      password
                      username
                    /], 
                    join=>'email_address'
                });

            if ( $c->authenticate( { password => $password,
				    'dbix_class' => { resultset => $rs }
				  } ) ) {
		
                $c->log->debug('Username login was successful. '. $c->user->get("username") . $c->user->get("password"));


#                 $self->reload($c);

                $c->res->redirect($c->uri_for('/'));

#                 $c->res->redirect($c->uri_for($c->req->path));
            } else {
                $c->log->debug('Login incorrect.'.$email);
                $c->stash->{'error_notice'}='Login incorrect.';
            }
     } else {
	 # invalid form input
	 $c->stash->{'error_notice'}='Invalid username or password.';
     }
}

sub auth_wbid :Path('/auth/wbid') {
     my ( $self, $c) = @_;
    $c->stash->{redirect} = $c->req->params->{redirect};
    $c->stash->{'template'}='auth/wbid.tt2';
}

sub auth_openid : Chained('auth') PathPart('openid')  Args(0){
     my ( $self, $c) = @_;

     $c->user_session->{redirect} = $c->user_session->{redirect} || $c->req->params->{redirect};
     my $redirect = $c->user_session->{redirect};
     my $param = $c->req->params;

#      $c->user_session->{redirect_after_login} ||= $param->{'continue'};
#      $c->stash->{'template'}='auth/openid.tt2';
     
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
	 
     } else {
	# eval necessary because LWPx::ParanoidAgent
	# croaks if invalid URL is specified
	#  eval {
	# Authenticate against OpenID to get user URL
	$c->config->{user_session}->{migrate}=0;

	if ( $c->authenticate({}, 'openid' ) ) {
	    $c->stash->{'status_msg'} = 'OpenID login was successful.';

	    # Google and other OpenID sites.
	    $self->auth_local({c          => $c, 
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

    my $fb = Facebook::Graph->new({app_id  => $app_id,
				   secret  => $secret,
				   postback => $c->uri_for('/auth/facebook/')});
    return $fb;
}

sub connect_to_twitter {
    my ($self,$c) = @_;

    my $consumer_key    = $c->config->{twitter_consumer_key};
    my $consumer_secret = $c->config->{twitter_consumer_secret};

    my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], 
			       consumer_key        => $consumer_key,
			       consumer_secret     => $consumer_secret,
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
    
    $self->auth_local({c          => $c, 
		       provider   => 'facebook',		       
		       oauth_access_token   => $access_token,
		       first_name  => $user->{first_name},
		       last_name   => $user->{last_name},
		       screen_name => $user->{username},
		       email       => $email,
#		       oauth_access_token_secret => $access_token_secret,
		       auth_type     => 'oauth',
		      });        
}


# The URL users are returned to after authenticating with Twitter.
sub auth_twitter_callback : Chained('auth') PathPart('twitter')  Args(0){
    my($self, $c) = @_;
#       $c->stash->{'template'}='auth/openid.tt2';
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
#		       screen_name   => $screen_name,
		       auth_type     => 'oauth',
		      });        
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
	} elsif (($c->user && $auth_type eq 'oauth') || ($params->{provider} eq 'facebook')) {
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
	    $c->model('Schema::UserRole')->find_or_create({user_id=>$user->id,role_id=>$role->id});
	} elsif ($email && $email =~ /\@wormbase\.org/) {
	    # assigning curator role to wormbase.org domain user
	    my $role=$c->model('Schema::Role')->find({role=>"curator"}) ;
	    $c->model('Schema::UserRole')->find_or_create({user_id=>$user->id,role_id=>$role->id});
        }

	# Update the authid entry
	if ($authid) {
	    $authid->user_id($user->id);                   # Link to my user.
	    $authid->auth_type($auth_type);                # One of openid or oauth
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
        $self->reload($c) ;
#   	$c->res->redirect($c->user_session->{redirect_after_login});
    }
    else {
        $c->log->debug('Local login failed');
        $c->stash->{'error_notice'}='Local login failed.';
    }
}

sub reload {
    my ($self, $c,$logout) = @_;
  $c->stash->{operator}=0; 
  $c->stash->{logout}=0;
  $c->stash->{reload}=1;

  $c->stash->{logout}=1 if($logout);		    
  $c->stash->{operator}=1 if(!$c->check_user_roles("operator") && $c->check_any_user_role(qw/admin curator/)) ;
  return;
}

 
sub logout :Path("/logout") {
    my ($self, $c) = @_;
    # Clear the user's state
    $c->logout;
    $c->stash->{noboiler} = 1;  

    $c->stash->{'template'}='auth/login.tt2';
#     $c->response->redirect($c->uri_for('/'));
    $self->reload($c,1) ;
#     $c->session_expire_key( __user => 0 );
}


# This is the PRIVATE profile.
sub profile :Path("/profile") {
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
 

sub profile_update :Path("/profile_update") {
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
  $c->stash->{redirect} = $c->uri_for("me");
  $c->forward('WormBase::Web::View::TT');
} 


sub add_operator :Path("/add_operator") {
    my ( $self, $c) = @_;
    $c->stash->{template} = "auth/operator.tt2";
    if($c->req->params->{content}){
      (my $key= $c->req->params->{content})=~ s/.*\?tk=//;
      $key =~ s/\&amp.*//;
      $c->log->debug("get the $key");
      my $role=$c->model('Schema::Role')->find({role=>"operator"}) ;
      $c->model('Schema::UserRole')->find_or_create({user_id=>$c->user->user_id,role_id=>$role->role_id});
      $c->user->set_columns({"gtalk_key"=>$key});
      $c->user->update();
      $c->res->redirect($c->uri_for("me"));
    }else {
	 $c->stash->{error_msg} = "Adding Google Talk chatback badge not successful!";
    }
}

    



# Has the current user linked their account to Twitter?
sub is_linked_to_twitter {
    my ($self,$c) = @_;
    my $twitter = $c->model('Schema::OpenID')->find({user_id => $c->user->id,
						     provider => 'twitter' });

    # Authenticate.
    if ($twitter) {
	my $nt = $self->connect_to_twitter($c);

#	$nt->access_token($twitter->oauth_access_token);
#	$nt->access_token_secret($twitter->oauth_access_token_secret);
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
