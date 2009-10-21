package WormBase::Web::Controller::Gene;

use strict;
use warnings;
use parent 'Catalyst::Controller';


=head1 NAME

WormBase::Web::Controller::Gene - Controller for the Gene Class

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# This could/should be created dynamically...
# All it does is stash the current requested object so that I can
# format my URLs as I choose.
sub get_params : Chained('/') :PathPart('gene') :CaptureArgs(1) {
    my ($self,$c,$name) = @_;
    $c->stash->{request} = $name;
}



=pod

# Report should probably be a generic action.
# It fetches available widgets (or user selected widgets)
# and then renders them.

# It also needs access to pages(), widgets(), and fields()

sub report : Chained('fetch') PathPart('report') Args(1) {
    my ( $self, $c, $view_type ) = @_;

	my $page = 'gene';

	# How to get the page/class?
	my @widgets = $self->widgets( $page, $c );
	
    $c->stash->{view}  = $view_type;
    $c->stash->{title} = "$page Summary";

    # Dynamically building a page from available widgets - unbuffered
    # Each widget is rendered in turn.
    if ( $view_type eq 'unbuffered' ) {

        # We'll render the page template-by-template instead of all at once.
        # This means that we have to break away from full-page wrapping.
        # Instead, each section will be rendered and wrapped into a widget
        # and/or loaded by ajax.
        $c->stash->{unbuffer} = 1;

        $c->finalize_headers();

        $c->write(
            $c->view('TT')->render( $c, "boilerplate/html_start", $c->stash ) );

        foreach my $widget (@widgets) {
            $c->log->info("Building the $widget widget...");

            # Save the name of the widget for formatting
            $c->stash->{widget} = $widget;

			# Fetch the fields for each widget
			my @fields = $self->fields( $page, $widget, $c );
            foreach my $field (@fields) {
                $c->log->debug("adding the $field field to the $widget widget");
                if ( $widget eq 'references' ) {

                    #		$c->forward($c->uri_for('/references', 'Gene','unc-26'));
                    #			$c->forward("/references/Gene/unc-26");
                    $c->forward( "/references/"
                          . $c->stash->{object} . "/"
                          . $c->stash->{object}->class );
                }
                else {
                    $c->forward($_);
                }
            }

            my $template =
              ( $widget eq 'references' )
              ? 'paper/references.tt2'
              : "gene/widgets/$widget.tt2";

            # Render and wrap the widget
            $c->write( $c->view('TT')->render( $c, $template, $c->stash ) );
        }
    }
    else {

        # Available options include: "tabs, lazy_tabs, sidebar, portlets"
        $c->stash->{widgets}  = \@widgets;
        $c->stash->{template} = 'report.tt2';
    }
}

=cut







=cut

=head1 AUTHOR

Todd W. Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
