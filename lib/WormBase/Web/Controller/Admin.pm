package WormBase::Web::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

WormBase::Web::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

WormBase::Web::Admin - Catalyst Controller for administrative
functions at WormBase.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched WormBase::Web::Controller::Admin in Admin.');
}



sub registered_users :Path("registered_users") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{'template'}='admin/registered_users.tt2';
    my @array;
    if($c->check_user_roles('admin')){
      my $iter=$c->model('Schema::User') ;
      while( my $user= $iter->next){
	  my $hash = { username   => $user->username,
		       email      => $user->email_address,
		       id         => $user->user_id,
	  };
	  
	  my @roles =$user->roles;
	  
	  map{$hash->{$_->role}=1;} @roles if(@roles);
	  push @array,$hash;
      }
      
      $c->stash->{users}=\@array;
    }  
} 

sub system_status :Path("system_status") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/system_status.tt2';

    # Get the status of our server pool
    # This is entirely dependent on our installation.

    # Get a list of servers
    # For each server, check (possibly using capistrano)
    # - available disk space
    # - starman status
    # - cpu load
    # - memory usage

    # Would be nice to create RRD of each, too.

} 





=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
