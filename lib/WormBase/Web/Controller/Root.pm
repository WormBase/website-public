package WormBase::Web::Controller::Root;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use File::Spec;
use namespace::autoclean -except => 'meta';

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in WormBase.pm
__PACKAGE__->config->{namespace} = '';

=head1 NAME

WormBase::Web::Controller::Root - Root Controller for WormBase

=head1 DESCRIPTION

Root level controller actions for the WormBase web application.

=head1 METHODS

=cut

=head2 INDEX

=cut
 
sub index :Path Args(0) {
    my ($self,$c) = @_;
    $c->stash->{template} = 'index.tt2';
    $c->log->debug('Cache servers: ',
                   join(', ', keys %{$c->config->{memcached}->{servers}}));
    my ($page) = $c->model('Schema::Page')->search({url=>"/"});
    my @widgets = $page->static_widgets if $page;
    $c->stash->{static_widgets} = \@widgets if (@widgets);
    $c->stash->{tutorial_off} = $c->req->param('tutorial_off');
}


=head2 DEFAULT

The default action is run last when no other action matches.

=cut

sub default :Path {
    my ($self,$c) = @_;
    $c->log->warn("DEFAULT: couldn't find an appropriate action");
    
    my $path = $c->request->path;

    # A user may be trying to request the top level page
    # for a class. Capturing that here saves me
    # having to create a separate index for each class.
    my ($class) = $path =~ /reports\/(.*)/;

    # Does this path exist as one of our pages?
    # This saves me from having to add an index action for
    # each class.  Each class will have a single default screen.
#     if (defined $class && $c->config->{pages}->{$class}) {
#       # Use the debug index pages.
#       if ($c->config->{debug}) {
#         $c->stash->{template} = 'debug/index.tt2';
#       } else {
#           $c->stash->{template} = 'species/report.tt2';
#           $c->stash->{path} = $c->request->path;
#       }
#     } else {
      $c->detach('/soft_404');
#     }
}

sub soft_404 :Path('/soft_404') {
    my ($self,$c) = @_;
    # 404: Page not found...
    $c->stash->{template} = 'status/404.tt2';
    $c->error('page not found');
    $c->response->status(404);
}
    

sub header :Path("/header") Args(0) {
    my ($self,$c) = @_;
    $c->stash->{noboiler}=1;
    $c->stash->{template} = 'header/default.tt2';
}

sub footer :Path("/footer") Args(0) {
      my ($self,$c) = @_;
      $c->stash->{noboiler}=1;
      $c->stash->{template} = 'footer/default.tt2';
} 

sub draw :Path("/draw") Args(1) {
    my ($self,$c,$format) = @_;
    my ($cache_source,$cached_img);
    my $params = $c->req->params;
    if ($params->{class} && $params->{id}) {
        my @keys = ('image', $params->{class}, $params->{id});
        my $uuid = join('-',@keys);
        ($cached_img,$cache_source) = $c->check_cache({
            cache_name => 'couchdb',
            uuid       => $uuid,
        });

        unless($cached_img) {  # not cached -- make new image and cache
            # the following line is a security risk
            my $source = File::Spec->catfile(
                $c->model('WormBaseAPI')->pre_compile->{$params->{class}},
                "$params->{id}.$format"
            );
            $c->log->debug("Attempt to draw image: $source");

            $cached_img = GD::Image->new($source);
            $c->set_cache({
                cache_name => 'couchdb',
                uuid       => $uuid,
                data       => $cached_img
            });
        }
    }
    else {
        $cached_img = $c->flash->{gd};
    }
    $c->stash(gd_image => $cached_img);
    $c->detach('WormBase::Web::View::Graphics');
}


sub me :Path("/me") Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'section'} = 'me';
    $c->stash->{'class'} = "me";
    $c->stash->{template} = "me.tt2";
}

#######################################################
#
#     CONFIGURATION - PROBABLY BELONGS ELSEWHERE
#
#######################################################


=head2 end
    
    Attempt to render a view, if needed.

=cut

# This is a kludge.  RenderView keeps tripping over itself
# for some Model/Controller combinations with the dynamic actions.
#  Namespace collision?  Missing templates?  I can't figure it out.

# This hack requires that the template be specified
# in the dynamic action itself. 


sub end : ActionClass('RenderView') {
  my ($self,$c) = @_;      
  
  # Forward to our view FIRST.
  # If we catach any errors, direct to
  # an appropriate error template.
  my $path = $c->req->path;
  if($path =~ /\.html/){
      $c->serve_static_file($c->path_to("root/static/$path"));
  }
  elsif (!($path =~ /cgi-?bin/i || $c->action->name eq 'draw')) {
      $c->forward('WormBase::Web::View::TT');
  }
}

# /quit, used for profiling so that NYTProf can exit cleanly.
sub quit :Global { exit(0) }


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
