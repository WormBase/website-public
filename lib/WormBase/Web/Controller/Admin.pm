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
    my @users;
    if($c->check_user_roles('admin')){
	foreach my $user ($c->model('Schema::User')->search()) {
	    map { $user->{$_->role} = 1; } $user->roles;
	    push @users, $user;
	}
	$c->stash->{users}= @users ? \@users : undef;
    }  
} 


# Create a quick system status overview with admin-level information 
# (ie include names of backend servers)
sub status_overview :Path("status_overview") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/status_overview.tt2';

    # Display a general table of all of our servers.
    # server, uptime, 12, 24, 48, 72 hour status  
} 


sub status_servers :Path("status_servers") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/status_servers.tt2';

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


# Fetch the status of our reverse proxy.
# This is entirely dependent on our installation
# and really only applicable to production.
# RRD graphs of the proxy
sub status_proxy :Path("status_proxy") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/status_proxy.tt2';
} 





=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
