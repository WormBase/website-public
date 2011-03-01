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

###################
## Subroutines
###################

=head2 feature

This method will return a data structure re: feature related to this feature_data.

=head3 PERL API

 $data = $model->feature();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature_data ID AF031935:polyA_signal

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/<feature_data_id>/feature

=head4 Response example

<div class="response-example"></div>

=cut

sub feature {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Feature;
	my $data_pack = $self->_pack_obj($tag_object);

	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the '
				};
	return $data;
}

=head2 intron

This method will return a data structure re: intron related to this feature_data.

=head3 PERL API

 $data = $model->intron();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature_data ID <feature_data_id>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/<feature_data_id>/intron
=head4 Response example

<div class="response-example"></div>

=cut

sub intron {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Confirmed_intron;
	my $data_pack = $self->_pack_obj($tag_object);

	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the '
				};
	return $data;
}

=head2 predicted_5

This method will return a data structure re: predicted 5' intron related to this feature_data.

=head3 PERL API

 $data = $model->predicted_5();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature_data ID <feature_data_id>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/<feature_data_id>/predicted_5

=head4 Response example

<div class="response-example"></div>

=cut

sub predicted_5 {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Predicted_5;
	my $data_pack = $self->_pack_obj($tag_object);

	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the '
				};
	return $data;
}

=head2 predicted_3

This method will return a data structure re: predicted 3' intron related to this feature_data.

=head3 PERL API

 $data = $model->predicted_3();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature_data ID <feature_data_id>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/<feature_data_id>/predicted_3

=head4 Response example

<div class="response-example"></div>

=cut

sub predicted_3 {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Predicted_3;
	my $data_pack = $self->_pack_obj($tag_object);

	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the '
				};
	return $data;
}

=head2 method

This method will return a data structure re: method related to this feature_data.

=head3 PERL API

 $data = $model->method();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature_data ID <feature_data_id>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature_data/<feature_data_id>/method

=head4 Response example

<div class="response-example"></div>

=cut

#sub method {
#	my $self = shift;
#    my $object = $self->object;
#	my $tag_object = $object->Method;
#	my $data_pack = {
#		'id' => "$tag_object",
#		'label' => "$tag_object",
#		'class' => 'Method'
#		};
#
#	my $data = {
#		'data'=> $data_pack,
#		'description' => 'description of the '
#				};
#	return $data;
#}

1;