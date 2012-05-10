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



sub registered_users :Path("registered_users") :Args(0){
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'auth/permissions.tt2';
    if($c->check_user_roles('admin')){
      $c->stash->{'template'}='admin/registered_users.tt2';
      my @users;
      if($c->assert_user_roles( qw/admin/)){
      foreach my $user ($c->model('Schema::User')->search()) {
          map { $user->{$_->role} = 1; } $user->roles;
          push @users, $user;
      }
      $c->stash->{users}= @users ? \@users : undef;
      }  
    }

} 

sub admin_widget :Path("/admin") :Args(1) {
    my ( $self, $c, $widget ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'auth/permissions.tt2';
    if($c->assert_user_roles( qw/admin/)){
      $c->stash->{template} = "admin/$widget.tt2";
    }
}



#     "status_overview"
# Create a quick system status overview with admin-level information 
# (ie include names of backend servers)
    # Display a general table of all of our servers.
    # server, uptime, 12, 24, 48, 72 hour status  



# "status_servers"
# Get the status of our server pool
# This is entirely dependent on our installation.
# Get a list of servers
# For each server, check (possibly using capistrano)
# - available disk space
# - starman status
# - cpu load
# - memory usage
# Would be nice to create RRD of each, too.


# "status_proxy"
# Fetch the status of our reverse proxy.
# This is entirely dependent on our installation
# and really only applicable to production.
# RRD graphs of the proxy





=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
