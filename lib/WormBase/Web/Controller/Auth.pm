package WormBase::Web::Controller::Auth;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use Net::Twitter;
use Data::Dumper;

__PACKAGE__->config->{namespace} = '';
 
 
sub login :Path("/login") {
     my ( $self, $c ) = @_;
     $c->stash->{noboiler} = 1;
     $c->stash->{'template'}='auth/login.tt2';
     $c->stash->{'continue'}=$c->req->params->{continue};
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
     $c->stash->{'template'}='auth/login.tt2';
}

sub auth_popup : Chained('auth') PathPart('popup')  Args(0){
     my ( $self, $c) = @_;
     if($c->req->params->{label}) {
      $c->stash->{'template'}='auth/popup.tt2';
      $c->stash->{'provider'}= $c->req->params;
    }else{
	$c->res->redirect($c->uri_for('/auth/openid')."?openid_identifier=".$c->req->params->{url});

    }
    
}

sub auth_login : Chained('auth') PathPart('login')  Args(0){
     my ( $self, $c) = @_;
    
     my $user     = $c->req->params->{username};
     my $password = $c->req->params->{password}; 
     if (   $user   &&  $password  )
     {
            if ( $c->authenticate( { username => $user,
                                     password => $password } ) ) {
		
                $c->stash->{'status_msg'}='Username login was successful.'. $c->user->get("firstname") ;
		$self->reload($c);
#  		$c->res->redirect($c->req->params->{continue});
            } else {
                $c->stash->{'status_msg'}='Login incorrect.';
            }
     }
     else {
            # invalid form input
	    $c->stash->{'status_msg'}='Invalid username or password.';
     }
}

sub auth_openid : Chained('auth') PathPart('openid')  Args(0){
     my ( $self, $c) = @_;
     my $param = $c->req->params;
#      $c->user_session->{redirect_after_login} ||= $param->{'continue'};
#      $c->stash->{'template'}='auth/openid.tt2';

     if(defined $param->{'openid_identifier'} && $param->{'openid_identifier'} =~ /twitter/i) {
	  my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], 
				    consumer_key        => "TuFZDWcjPpm2NKxUrbpLww",
				    consumer_secret     => "XPnhhewZMU1byZNKVNOP5LjR6bKlgK37hLU7H6oc3w",

	  );
	  my $url = $nt->get_authorization_url(callback => $c->uri_for('/auth/twitter'));

	  $c->response->cookies->{oauth} = {
	      value => {
		  token => $nt->request_token,
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
	    my $email=$param->{'openid.ext1.value.email'};
	    $c->stash->{'status_msg'}='OpenID login was successful.';
	    $self->auth_local($c,$c->user->url,$email,$param->{'openid.ext1.value.firstname'}, $param->{'openid.ext1.value.lastname'} );
	  
	  }
	  else {
	    $c->stash->{'error_msg'}='Failure during OpenID login';
	  }
      #  };

      #  if ($@) {
      #    $c->log->error("Failure during login: " . $@);
      #    $c->stash->{'error_msg'}='Failure during login: ' . $@;
      #  }
    }
}

sub auth_twitter : Chained('auth') PathPart('twitter')  Args(0){
      my($self, $c) = @_;
#       $c->stash->{'template'}='auth/openid.tt2';
      my %cookie = $c->request->cookies->{oauth}->value;
      my $verifier = $c->req->params->{oauth_verifier};

      my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], 
				consumer_key        => "TuFZDWcjPpm2NKxUrbpLww",
				consumer_secret     => "XPnhhewZMU1byZNKVNOP5LjR6bKlgK37hLU7H6oc3w",
				);
      $nt->request_token($cookie{token});
      $nt->request_token_secret($cookie{token_secret});

      my($access_token, $access_token_secret, $user_id, $screen_name)
          = $nt->request_access_token(verifier => $verifier);

      $self->auth_local($c,$access_token,undef,$screen_name);
}


sub auth_local {
     my ($self, $c,$id,$email,$first_name,$last_name) = @_;
      # Create basic user entry unless already found
      # (or use auto_create_user: 1)	
      my ($openid,$user);
      $openid =  $c->model('Schema::OpenID')->find_or_create({ openid_url => $id });
      unless ($openid->user_id) {
	$user=$c->model('Schema::User')->find({email_address=>$email}) if($email);
	unless($user){
	    $user= $c->model('Schema::User')->create(
	    { username => $id, email_address=>$email, first_name=>$first_name, last_name=>$last_name 
	    });
	    #assing curator role to wormbase.org domain user
	    my $role_str="user";
	    $role_str="curator" if($email && $email =~ /\@wormbase\.org/);
	    $role_str="admin" if($email && $email =~ /lincoln\.stein/);
	    my $role=$c->model('Schema::Role')->find({role=>$role_str}) ;
	    $c->model('Schema::UserRole')->create({user_id=>$user->id,role_id=>$role->id});
	}
	$openid->user_id($user->id);
	$openid->update();
      }
     $c->log->debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.');
      # Re-authenticate against local DBIx store
      $c->config->{user_session}->{migrate}=1;
      if ( $c->authenticate({ id=>$openid->user_id }, 'members') ) {
        $c->stash->{'status_msg'}='Local Login was also successful.';
	 $c->log->debug('Local Login was also successful.');
	$self->reload($c) ;
#   	$c->res->redirect($c->user_session->{redirect_after_login});
      }
      else {
	 $c->log->debug('Local login failed');
        $c->stash->{'error_msg'}='Local login failed.';
         
      }
}

sub reload {
  my ($self, $c,$logout) = @_;
  $c->stash->{operate}=0; 
  $c->stash->{logout}=0;
  $c->stash->{reload}=1;

  $c->stash->{logout}=1 if($logout);		    
  $c->stash->{operate}=1 if(!$c->check_user_roles("operator") && $c->check_any_user_role(qw/admin curator/)) ;
  return;
}

 
sub logout :Path("/logout") {
    my ($self, $c) = @_;
    # Clear the user's state
    $c->logout;
    $c->stash->{noboiler} = 1;  
    $c->stash->{'template'}='auth/login.tt2';
    $self->reload($c,1) ;
}


sub profile :Path("/profile") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{'template'}='auth/profile.tt2';
    my @array;
    if($c->check_user_roles('admin')){
      my $iter=$c->model('Schema::User') ;
      while( my $user= $iter->next){
	  my $hash = { username=>$user->username,
			email=>$user->email_address,
			first_name=>$user->first_name,
			last_name=>$user->last_name,
			id=>$user->id,
		      };
	  my @roles =$user->roles;
	    
	  map{$hash->{$_->role}=1;} @roles;
	  push @array,$hash;
      }
      
      $c->stash->{users}=\@array;
    }
  
} 
 

sub profile_update :Path("/profile_update") {
     my ( $self, $c ) = @_;
     $c->stash->{'template'}='auth/profile.tt2';
     foreach my $col (sort keys %{$c->req->params}){
	# $c->log->debug("$col ok".$c->req->params->{$col});
	 $c->user->$col($c->req->params->{$col});
      }
      $c->user->update();
      $c->stash->{'status_msg'}='User inforamtion udpated!';
      $c->res->redirect('/bench');
} 


sub add_operator :Path("/add_operator") {
    my ( $self, $c) = @_;
    $c->stash->{template} = "auth/operator.tt2";
    if($c->req->params->{content}){
      (my $key= $c->req->params->{content})=~ s/.*\?tk=//;
      $key =~ s/\&amp.*//;
      $c->log->debug("get the $key");
      my $role=$c->model('Schema::Role')->find({role=>"operator"}) ;
      $c->model('Schema::UserRole')->find_or_create({user_id=>$c->user->id,role_id=>$role->id});
      $c->user->set_columns({"gtalk_key"=>$key});
      $c->user->update();
      $c->res->redirect($c->uri_for("me"));
    }else {
	 $c->stash->{error_msg} = "Adding Google Talk chatback badge not successful!";
    }
}
=head1 AUTHOR

xiaoqi shi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
