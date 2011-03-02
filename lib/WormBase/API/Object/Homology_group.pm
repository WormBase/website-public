package WormBase::API::Object::Homology_group;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=head2 title

This method will return a data structure the title for the Homology_group.

=head3 PERL API

 $data = $model->title();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_000935

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/title

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

=head2 group_type

This method will return a data structure on the group_type of the Homology_group.

=head3 PERL API

 $data = $model->group_type();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_000935

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/group_type

=head4 Response example

<div class="response-example"></div>

=cut


sub group_type {
	my $self = shift;
    my $object = $self->object;
	my $homology_group = $object->Homology_group;
	my $homology_code;
	
	if ($homology_group =~ /COG/) {
		$homology_code = $object->COG_code;
	}
	my $data_pack = {
		'homology_group' => "$homology_group",
		'cog_code' => $homology_code
	};
	return {
		'data'=> $data_pack,
		'description' => 'type of homology_group'
		};
}

=head2 go_term

This method will return a data structure with the go terms for the Homology_group.

=head3 PERL API

 $data = $model->go_term();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_000935

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/go_term

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
		push @data_pack, $gt_info;
	}
	return {
		'data'=> \@data_pack,
		'description' => 'go terms related to this homology group'
	};
}

=head2 protein

This method will return a data structure with the proteins in the Homology_group.

=head3 PERL API

 $data = $model->protein();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Homology_group ID InP_Cae_000935

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/protein

=head4 Response example

<div class="response-example"></div>

=cut

sub protein {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @tag_objects = $object->Protein;

	foreach my $tag_object (@tag_objects) {
		my $tag_info = $self->_pack_obj($tag_object);
		push @data_pack, $tag_info;
	}
	
	return  {
		'data'=> \@data_pack,
		'description' => 'proteins related to this homology_group'
	};
}

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


1;
