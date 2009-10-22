package WormBase::Web::Controller::REST;

use strict;
use warnings;
use parent 'Catalyst::Controller::REST';



=head1 NAME

WormBase::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 pages() pages_GET()

Return a list of all available pages and their URIs

TODO: This is currently just returning a dummy object

=cut

sub pages : Path('/rest/pages') :Args(0) :ActionClass('REST') {}

sub pages_GET {
    my ($self,$c) = @_;
    my @pages = keys %{ $c->config->{pages} };

    my %data;
    foreach my $page (@pages) {
	my $uri = $c->uri_for('/page',$page,'WBGene00006763');
	$data{$page} = "$uri";
    }

    $self->status_ok( $c, entity => { data => \%data,
				      description => 'Available (dynamic) pages at WormBase',
		      }
	);
}



######################################################
#
#   WIDGETS
#
######################################################

=head2 available_widgets(), available_widgets_GET()

For a given CLASS and OBJECT, return a list of all available WIDGETS

eg http://localhost/rest/available_widgets/gene/WBGene00006763

=cut

sub available_widgets : Path('/rest/available_widgets') :Args(2) :ActionClass('REST') {}

sub available_widgets_GET {
    my ($self,$c,$class,$name) = @_;
    my (@widgets) = @{ $c->config->{pages}->{$class}->{widget_order} };
    
    my %data;
    foreach my $widget (@widgets) {
	my $uri = $c->uri_for('/widget',$class,$name,$widget);
	$data{$widget} = "$uri";
    }
    
    $self->status_ok( $c, entity => { data => \%data,
				      description => "All widgets available for $class:$name",
		      }
	);
}



=head widget(), widget_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/widget/[CLASS]/[NAME]/[FIELD]

=cut

sub widget :Path('/rest/widget') :Args(3) :ActionClass('REST') {}

sub widget_GET {
    my ($self,$c,$class,$name,$widget) = @_;

    # Fetch our external model
    my $api = $c->model('WormBaseAPI');
 
   # Fetch the object from our driver	 
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
    $c->log->debug("The requested class is " . ucfirst($class));
    $c->log->debug("The request is " . $name);
    
    # Fetch a WormBase::API::Object::* object
    # But wait. Some methods return lists. Others scalars...
    my $object = $api->fetch({class=> ucfirst($class),
			      name => $name}) or die "$!";

    # TODO: Load up the data content. Should these be REST calls?
    my @fields = @{ $c->config->{pages}->{$class}->{widgets}->{$widget} };
    my $data = {};
    foreach my $field (@fields) {
	$data->{$_} = $object->$field;
    }
    
    # TODO: AGAIN THIS IS THE REFERENCE OBJECT
    # PERHAPS I SHOULD INCLUDE FIELDS?
    # Include the full uri to the *requested* object.
    # IE the page on WormBase where this should go.
    my $uri = $c->uri_for("/page",$class,$name);
    
    $self->status_ok($c, entity => {
	class   => $class,
	name    => $name,
	uri     => "$uri",
	$widget => $data
		     }
	);
}


######################################################
#
#   FIELDS
#
######################################################

=head2 available_fields(), available_fields_GET()

Fetch all available fields for a given WIDGET, PAGE, NAME

eg  GET /rest/fields/[WIDGET]/[PAGE]/[NAME]

# This makes more sense than what I have now
/rest/class/*/widgets  - all available widgets
/rest/class/*/widget   - the content for a given widget

/rest/class/*/widget/fields - all available fields for a widget
/rest/class/*/widget/field

=cut

sub available_fields : Path('/rest/available_fields') :Args(3) :ActionClass('REST') {}

sub available_fields_GET {
    my ($self,$c,$widget,$class,$name) = @_;
    my @fields = eval { @{ $c->config->{pages}->{$class}->{widgets}->{$widget} }; };

    my %data;
    foreach my $field (@fields) {
	my $uri = $c->uri_for('/rest/field',$class,$name,$field);
	$data{$field} = "$uri";
    }
    
    $self->status_ok( $c, entity => { data => \%data,
				      description => "All fields that comprise the $widget for $class:$name",
		      }
	);
}


=head field(), field_GET()

Provided with a class, name, and field, return its content

eg http://localhost/rest/field/[CLASS]/[NAME]/[FIELD]

=cut

sub field :Path('/rest/field') :Args(3) :ActionClass('REST') {}

sub field_GET {
    my ($self,$c,$class,$name,$field) = @_;

    # Fetch our external model
    my $api = $c->model('WormBaseAPI');
 
   # Fetch the object from our driver	 
    $c->log->debug("WormBaseAPI model is $api " . ref($api));
    $c->log->debug("The requested class is " . ucfirst($class));
    $c->log->debug("The request is " . $name);
    
    # Fetch a WormBase::API::Object::* object
    # But wait. Some methods return lists. Others scalars...
    my $object = $api->fetch({class=> ucfirst($class),
			      name => $name}) or die "$!";

    my $data = $object->$field;
    
    # Include the full uri to the *requested* object.
    # IE the page on WormBase where this should go.
    my $uri = $c->uri_for("/page",$class,$name);

    $self->status_ok($c, entity => {
	                 class  => $class,
			 name   => $name,
	                 uri    => "$uri",
			 $field => $data
		     }
	);
}











#sub genetic_position : Chained('get_params') PathPart('gene/genetic_position') CaptureArgs(1) ActionClass('REST') {}

=head1

sub genetic_position : Path('gene/genetic_position') CaptureArgs(1) ActionClass('REST') {}

sub genetic_position_GET {
  my ($self,$c,$name) = @_;
  $c->stash->{request} = $name; 

  # Instantiate the Model
  my $model = $c->model(ucfirst('Gene'));

  $c->stash->{genetic_position} = $model->genetic_position($c);
  $c->log->debug($c->stash->{genetic_position});
  $self->status_ok( $c, entity => $c->stash->{genetic_position} );
}

=cut

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
