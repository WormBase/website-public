package WormBase::API::Object::<object>;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Homology_group

=head1 SYNPOSIS

Model for the Ace ?Homology_group class.

=head1 URL

http://wormbase.org/species/homology_group

=head1 TODO

=cut


###############
## Overview
###############

=head2 title

<headvar>This method will return a data structure with this Homology_groups title
=head3 PERL API

 $data = $model->title();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_006282

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_006282/title

=head4 Response example

<div class="response-example"></div>

=cut


sub title {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Title;

	my $data = {
				'data'=> $data_pack,
				'description' => 'title for this homology_group'
				};
	return $data;
}


########################################
#<todo> sub db  ### for external links?
#########################################

=head2 group_type

<headvar>This method will return a data structure with info on the group type.

=head3 PERL API

 $data = $model->group_type();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_006282

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_006282/group_type

=head4 Response example

<div class="response-example"></div>

=cut

#<todo> sub group_type {}


=head2 go_term

<headvar>This method will return a data structure for go terms related to this homology group

=head3 PERL API

 $data = $model->go_term();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_006282

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_006282/go_term

=head4 Response example

<div class="response-example"></div>

=cut

sub go_term {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @go_terms = $object->GO_term;

	foreach my $go_term (@go_terms) {
		my $gt_info = _pack_obj($go_term);
		push, @data_pack, $gt_info;
	}
	
	my $data = {
				'data'=> \@data_pack,
				'description' => 'go terms related to this homology group'
				};
	return $data;
}


=head2 protein

This method will return a data structure containing information for proteins related to this homology_group.

=head3 PERL API

 $data = $model->protein();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_006282

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_006282/protein

=head4 Response example

<div class="response-example"></div>

=cut

sub protein {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @tag_objects = $object->Protein;

	foreach my $tag_object (@tag_objects) {
		my $tag_info = _pack_obj($tag_object);
		push, @data_pack, $tag_info;
	}
	
	my $data = {
				'data'=> \@data_pack,
				'description' => 'proteins related to this homology_group'
				};
	return $data;
}

=head2 <headvar>

<headvar>This method will return a data structure.... .

=head3 PERL API

 $data = $model-><headvar>();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_006282

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_006282/<headvar>

=head4 Response example

<div class="response-example"></div>

=cut

sub remark {

	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Remark;
	my $data = {
				'data'=> $data_pack,
				'description' => 'remark re: homology group'
				};
	return $data;
}

1;