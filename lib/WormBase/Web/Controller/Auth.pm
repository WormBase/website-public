package WormBase::Web::Controller::Auth;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';

__PACKAGE__->config->{namespace} = '';
 
=pod
sub login :Path("/login") {
     my ( $self, $c ) = @_;
     $c->stash->{noboiler} = 1;
     $c->stash->{'template'}='auth/login.tt2';
}
=cut

sub openid :Path("/openid") {
     my ( $self, $c ) = @_;
     $c->stash->{noboiler} = 1;
     $c->stash->{'template'}='auth/openid.tt2';
}


sub auth : Chained('/') PathPart('auth')  CaptureArgs(0) {
     my ( $self, $c) = @_;
     $c->stash->{noboiler} = 1;  
}

sub auth_login : Chained('auth') PathPart('login')  Args(0){
     my ( $self, $c) = @_;
     
     $c->stash->{'template'}='auth/login.tt2';
     my $user     = $c->req->params->{username};
     my $password = $c->req->params->{password}; 
     if (   $user   &&  $password  )
     {
            if ( $c->authenticate( { username => $user,
                                     password => $password } ) ) {
		
                $c->stash->{'status_msg'}='Username login was successful.'. $c->user->get("firstname") ;
		$c->res->redirect($c->flash->{redirect_after_login});
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
     $c->user_session->{redirect_after_login} ||= $c->flash->{redirect_after_login} ;
     
     $c->stash->{'template'}='auth/openid.tt2';
  # eval necessary because LWPx::ParanoidAgent
  # croaks if invalid URL is specified
#  eval {
    # Authenticate against OpenID to get user URL
    $c->config->{user_session}->{migrate}=0;
    if ( $c->authenticate({}, 'openid' ) ) {
      my $email=$param->{'openid.ext1.value.email'};
      $c->stash->{'status_msg'}='OpenID login was successful.';

      # Create basic user entry unless already found
      # (or use auto_create_user: 1)	
      my ($openid,$user);
      $openid =  $c->model('Schema::OpenID')->find_or_create({ openid_url => $c->user->url });
      unless ($openid->user_id) {
	$user=$c->model('Schema::User')->find({email_address=>$email}) if($email);
	unless($user){
	    $user= $c->model('Schema::User')->create(
	    { username => $c->user->url, email_address=>$email, first_name=>$param->{'openid.ext1.value.firstname'}, last_name=>$param->{'openid.ext1.value.lastname'} 
	    });
	    my $role=$c->model('Schema::Role')->find({role=>'user'}) ;
	    $c->model('Schema::UserRole')->create({user_id=>$user->id,role_id=>$role->id});
	}
	$openid->user_id($user->id);
	$openid->update();
      }

      # Re-authenticate against local DBIx store
      $c->config->{user_session}->{migrate}=1;
      if ( $c->authenticate({ id=>$openid->user_id }, 'members') ) {
        $c->stash->{'status_msg'}='Local Login was also successful.';
	$c->res->redirect($c->user_session->{redirect_after_login});
      }
      else {
        $c->stash->{'error_msg'}='Local login failed.';
         
      }
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

sub logout :Path("/logout") {
    my ($self, $c) = @_;

    # Clear the user's state
    $c->logout;
    $c->stash->{template} = 'index.tt2';
    # Send the user to the starting point
    $c->res->redirect($c->flash->{redirect_after_login});
    
 
}

sub profile :Path("/profile") {
     my ( $self, $c ) = @_;
     $c->stash->{'template'}='auth/profile.tt2';
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
} 
=head1 AUTHOR

xiaoqi shi

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
