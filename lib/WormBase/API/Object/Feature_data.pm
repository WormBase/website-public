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

http://wormbase.org/species/feature_data

=head1 TODO

=cut

#########################
#
# The Overview widget
#
#########################

=head2 Overview

=cut

=head3 feature

This method will return a data structure with feature associated with the feature_data.

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
    my $data_pack = $self->_pack_obj( $object->Feature ) if $object->Feature;
    return {
        'data' => $data_pack,
        'description' =>
          'description of the feature associated with this Feature_data.'
    };
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
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_pack_obj( $object->Confirmed_intron )
      if $object->Confirmed_intron;

    return {
        'data'        => $data_pack,
        'description' => 'introns associated with this Feature_data'
    };
}

=head3 predicted_5

This method will return a data structure with predicted 5' info on the feature_data.

=over

=item PERL API

 $data = $model->predicted_5();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_5

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub predicted_5 {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_pack_obj( $object->Predicted_5 )
      if $object->Predicted_5;
    return {
        'data'        => $data_pack,
        'description' => 'predicted 5\' related object of Feature_data '
    };
}

=head3 predicted_3

This method will return a data structure with predicted 3' info on the feature_data.

=over

=item PERL API

 $data = $model->predicted_3();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/CO871145:polyA_site/predicted_3

B<Response example>

<div class="response-example"></div>

=back

=back

=cut 

sub predicted_3 {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $self->_pack_obj( $object->Predicted_3 )
      if $object->Predicted_3;
    return {
        'data'        => $data_pack,
        'description' => 'predicted 3\' related object of Feature_data'
    };
}

__PACKAGE__->meta->make_immutable;

1;

