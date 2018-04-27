package WormBase::Web::Controller::Root;

use strict;
use warnings;
use parent 'WormBase::Web::Controller';
use parent 'Catalyst::Controller::REST';
use JSON;
use File::Spec;
use namespace::autoclean -except => 'meta';

require LWP::Simple;


__PACKAGE__->config(
    'default'          => 'text/x-yaml',
    'stash_key'        => 'rest',
    'map'              => {
        'text/x-yaml'      => 'YAML',
        'text/html'        => [ 'View', 'TT' ], #'YAML::HTML',
        'text/xml'         => 'XML::Simple',
        'application/json' => 'JSON',
    }
);

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
    $self->_setup_page($c);
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

    my $headers = $c->req->headers;
    my $content_type
        = $headers->content_type
        || $c->req->params->{'content-type'}
        || 'text/html';
    $c->response->header( 'Content-Type' => $content_type );

    $c->stash->{template} = 'status/404.tt2';

    $self->status_not_found(
      $c,
      message => "Page not found"
    );
}


sub header :Path("/header") Args(0) {
    my ($self,$c) = @_;
    $c->stash->{noboiler}=1;
    $c->stash->{template} = 'header/default.tt2';
    $c->stash->{section} = 'tools';
    $c->response->headers->expires(time);
}

sub footer :Path("/footer") Args(0) {
      my ($self,$c) = @_;
      $c->stash->{noboiler}=1;
      $c->stash->{template} = 'footer/default.tt2';
}

# everything processed by webpack
sub static :LocalRegex('^(\d+\.)?static\/.+') {
    my ($self,$c,@path_parts) = @_;
    my $path = $c->request->path;
    my $dev_server_url = $c->config->{webpack_dev_server};
    if ($dev_server_url && LWP::Simple::head($dev_server_url)) {
        $c->response->redirect("$dev_server_url/$path");
    } else {
        $c->serve_static_file("client/build/$path");
    }
}

sub hot_update_json :LocalRegex('^.*\.hot-update\.js(on)?$') {
    my ($self,$c,@path_parts) = @_;
    my $path = $c->request->path;

    my $dev_server_url = $c->config->{webpack_dev_server};
    if ($dev_server_url && LWP::Simple::head($dev_server_url)) {
        $c->response->redirect("$dev_server_url/$path");
    }
}

sub me :Path("/me") Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{'section'} = 'me';
    $c->stash->{'class'} = "me";
    $c->stash->{template} = "me.tt2";
    $c->response->headers->expires(time);
}

# Action added for Elsevier linking - issue #2086
# Returns WormBase logo if paper with corresponding doi is located
# Otherwise returns transparent png
sub elsevier :Path("/elsevier/wblogo.png") Args(0) {
    my ( $self, $c ) = @_;
    my $doi = $c->req->param('doi');
    my $path = "transparent";

    if($doi){
      my $api = $c->model('WormBaseAPI');
      my $object = $api->xapian->fetch({id => $doi, class => 'paper', label => 1});
      if($object->{id} =~ /WBPaper\d{8}/){
        $object = $api->fetch({ class => 'Paper', name => $object->{id}})
          or die "Could not fetch object";
        $path = "wblogo" if $object->doi->{data} =~ /$doi/;
      }
    }

    $c->serve_static_file("root/img/buttons/$path.png");
}

# create a permanent link for mapping micropublication DOI
# issue #4043
sub micropub :Path("/micropub") Args(0) {
    my ( $self, $c ) = @_;
    my $wbid = $c->req->param('id');
    my $class = $c->req->param('class');
    $c->req->param('name', $wbid);

    $c->go('get');
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
  elsif (!($path =~ /cgi-?bin/i || $c->action->name eq 'draw' || $path =~ /\.(png|js|css)/)) {
      $c->forward('WormBase::Web::View::TT');
  }
}


# This kills our app if anyone visits this action...
# /quit, used for profiling so that NYTProf can exit cleanly.
# sub quit :Global { exit(0) }


=head2 get

  GET report pages
  URL space: /get
  Params: name and class

Provided with a class and name via the classic /db/get script,
redirect to the correct report page.

Caveat: currently assumes Ace class is given. Requires
name & class to correspond exactly to an object in AceDB
or the lower case Ace class

=cut

sub get :Local Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'species/report.tt2';

    my $doi             = $c->req->param('doi');
    my $requested_class = $c->req->param('class') || ($doi && 'paper') || 'all';
    my $name            = $c->req->param('name') || $doi;

    my $carryover_params = {};
    while (my ($key,$value) = each %{$c->req->params}) {
        if ($key ne 'doi' && $key ne 'class' && $key ne 'name') {
            $carryover_params->{$key} = $value;
        }
    }

    $name =~ s/^\s+|\s+$//g;

    my $api    = $c->model('WormBaseAPI');
    my $ACE2WB = $api->modelmap->ACE2WB_MAP->{class};

    # hack for locus (legacy):
    $requested_class = 'Gene' if lc $requested_class eq 'locus';

    # TOTAL HACK!
    # Some legacy links to Anatomy_term are weird:
    # /db/get?name=[Anatomy_name_object];class=Anatomy_term
    # so searches fail. We need to map the Anatomy_name object
    # to the correct Anatomy_term object.

    # Wow. Legacy of legacy of legacy. Incroyable.  The once mighty Cell_group class before
    # all the confusion began.
    if (($requested_class eq 'Anatomy_term' || $requested_class eq 'Anatomy_name' || $requested_class eq 'Cell_group' || $requested_class eq 'Cell') && $name !~ /^WBbt/) {
      my $api = $c->model('WormBaseAPI');
      my $temp_object = $api->fetch({
          class => 'Anatomy_name',
          name  => $name,
        }) or warn "Couldn't fetch an Anatomy_name object: $!";
      if ($temp_object) {
        $name = $temp_object->Synonym_for_anatomy_term || $temp_object->Name_for_anatomy_term;
      }
      # Reset the class for Cell_group and Cell searches; unknown to API.
      $requested_class = 'Anatomy_term';
    }


    # there may be input (perhaps external, hand-typed input or even automated
    # input from a non-WB tool) which specifies a class in the incorrect casing
    # but is otherwise legitimate (e.g. Go_term, which should be GO_term). this
    # could be a problem in those kinds of input.
    my $class = $ACE2WB->{$requested_class}
             || $ACE2WB->{lc $requested_class} # canonical Ace class
             || 'all'
             or $c->detach('/soft_404');

    my $normed_class = lc $class;

    my $search_engine = $api->get_search_engine();
    my $match;
    if ($normed_class && $normed_class ne 'all') {
        $match = $search_engine->fetch({
            query => $name,
            class => $normed_class,
        });
    } else {
        $match = $search_engine->fetch({
            query => $name,
        });
    }

    my $matched_class = $match->{class} if $match;
    if ($match && ($matched_class eq $normed_class || $normed_class eq 'all')) {
        my $url = (exists $c->config->{sections}->{species}->{$matched_class}) ?
            $c->uri_for('/species', $match->{taxonomy}, $matched_class, $match->{id}, $carryover_params)->as_string :
            $c->uri_for('/resources', $matched_class, $match->{id}, $carryover_params)->as_string;
        $c->res->redirect($url);
    } else {
        $c->res->redirect("/search/all/$name");
    }
}

# TODO: POD

# if there are enough of these, a GBrowse controller might be warranted
sub gbrowse_popup :Path('gbrowse_popup') :Args(0) {
    my ($self, $c) = @_;

    my $name  = $c->req->params->{name}  || '';
    my $class = $c->req->params->{class} || '';
    my $type  = $c->req->params->{type}  || '';

    my $description;

    my $api = $c->model('WormBaseAPI');

    # WARNING: quickly hacked together code ahead with View and Model code!
    # consider making a proper model and view for this GBrowse popup data
    if ($type eq 'GENES') {
        if (my $ace = $api->fetch({aceclass => $class, name => $name})) {
            $ace = $ace->object;
            my $gene = eval { $ace->Corresponding_CDS->Gene } || eval { $ace->Gene };
            $description = join(' ', eval { $gene->Concise_description }
                                  || eval { $gene->Detailed_description }
                                  || eval { $gene->Provisional_description }
                                  || eval { $gene->Sequence_features }
                                  || eval { $gene->Molecular_function }
                                  || eval { $gene->Biological_process }
                                  || eval { $gene->Functional_pathway }
                                  || eval { $gene->Functional_physical_interaction }
                                  || eval { $gene->Expression }
                                  || eval { $gene->Other_description }
                                  || eval { $gene->Remarks }
                                  || eval { $ace->Corresponding_CDS->DB_Remark }
                              );
        }
    }
    elsif ($type eq 'EXPR_PATTERN') {
        if (my $pattern = $api->fetch({class => 'Expr_pattern', name => $name})) {
            # IMAGE
            # TODO: cartoon image generated by legacy /db/gene/expression if no expr image
            if (my $cimg = $pattern->curated_images->{data}) {
                # arbitrarily select a curated image... maybe we should get rid
                # of this and just use the virtual worm image if possible
                my ($groupname, $imgs) = each %$cimg;
                my $img_data = $imgs->[0]->{draw};

                $c->stash(expr_image => $img_data->{class}.'/'.name =>$img_data->{name}.".".$img_data->{format}
			);
            }
            else {
                $c->stash(expr_image => $pattern->expression_image->{data}

			);
            }

            # TEXT
            if ($description = $pattern ~~ 'Pattern') { # nasty
                $description =~ s/;/,/g;
                $description =~ s/,$//;
            }

            my $label = $pattern->name->{data}->{label}; # "Expression pattern for ..."

            if (my $types = eval {$pattern->experimental_details->{data}->{types}}) {
                $label =~ s/Expression pattern //; # "for ..."
                $c->stash(title => "$types->[0]->[0] $label");
            }
            else {
                $c->stash(title => $label);
            }
        }
    }

    $c->stash(
        desc     => $description,
        template => 'gbrowse/gbrowse_popup.tt2',
        noboiler => 1,
    );
}

=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
