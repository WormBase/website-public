package WormBase::API::Object::Feature_data;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Feature_data

=head1 SYNPOSIS

Model for the Ace ?Feature_data class.

=head1 URL

http://wormbase.org/species/(feature_data

=cut


#######################################
#
# CLASS METHODS
#
#######################################

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


#########################
#
# The Overview widget
#
#########################

=head2

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

=head2 Overview

=cut

=head3 feature

This method will return a data structure with the feature associated
with the object.

=over

=item PERL API

 $data = $model->feature();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature_data id (eg CO871145:polyA_site)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/feature

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub feature {
    my $self      = shift;
    my $object    = $self->object;
    my $data      = $self->_pack_obj( $object->Feature ) if $object->Feature;
    return { data        => $data,
	     description => 'the sequence feature', };
}

=head3 intron

This method will return a data structure with introns associated with the feature_data.

=over

=item PERL API

 $data = $model->intron();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature_data id (eg CO871145:polyA_site)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/intron

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub intron {
    my $self    = shift;
    my $object  = $self->object;
    my $data    = $self->_pack_obj( $object->Confirmed_intron ) if $object->Confirmed_intron;
    return { data        => $data,
	     description => 'introns associated with this object', };
}

=head3 predicted_five_prime

This method will return a data structure 
containing objects 5' of the curent feature.

=over

=item PERL API

 $data = $model->predicted_five_prime();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature_data id (eg CO871145:polyA_site)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_five_prime

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub predicted_five_prime {
    my $self   = shift;
    my $object = $self->object;
    my $data   = $self->_pack_obj( $object->Predicted_5 ) if $object->Predicted_5;
    return { data        => $data,
	     description => 'predicted 5\' related object of the requested object' };
}

=head3 predicted_three_prime

This method will return a data structure
containing objects 3' of the requested object.

=over

=item PERL API

 $data = $model->predicted_three_prime();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Feature_data id (eg CO871145:polyA_site)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_three_prime

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub predicted_three_prime {
    my $self    = shift;
    my $object  = $self->object;
    my $data    = $self->_pack_obj( $object->Predicted_3 ) if $object->Predicted_3;
    return { data        => $data,
	     description => 'predicted 3\' related object of requested feature', };
}

__PACKAGE__->meta->make_immutable;

1;

