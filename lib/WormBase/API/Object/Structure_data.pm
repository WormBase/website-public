package WormBase::API::Object::Structure_data;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Structure_data

=head1 SYNPOSIS

Model for the Ace ?Structure class.

=head1 URL

http://wormbase.org/species/structure_data

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

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


=head2 sequence

This method will return a data structure the sequence of this structure_data.

=head3 PERL API

 $data = $model->sequence();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Structure_data ID WBStructure000876

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/sequence

=head4 Response example

<div class="response-example"></div>

=cut

sub sequence {
	my $self = shift;
	my $object = $self->object;

	return {
		data => $self->_pack_obj($object->Protein, "$object"),
		description => 'sequence of structure',
	};
}

=head2 protein_homology

This method will return a data structure re: protein homologs this structure_data.

=head3 PERL API

 $data = $model->protein_homology();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Structure_data ID WBStructure000876

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/protein_homology

=head4 Response example

<div class="response-example"></div>

=cut

sub protein_homology {
	my $self = shift;
	my $object = $self->object;
	
	my @data = map {$self->_pack_obj($_)} $object->Pep_homol;
	
	return {
		data => @data ? \@data : undef,
		description => 'Protein homologs for this structure'
	};
}

=head2 homology_data

This method will return a data structure with the homology_data on this structure_data.

=head3 PERL API

 $data = $model->homology_data();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Structure_data ID WBStructure000876

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/homology_data

=head4 Response example

<div class="response-example"></div>

=cut

sub homology_data {
	my $self = shift;
	my $object = $self->object;
	my @data = map {$self->_pack_obj($_)} $object->Homol_homol;

	my $data = {
		'data'=> @data ? \@data : undef ,
		'description' => 'homology data re: this structure'
		};
	return $data;
}

=head2 status

This method will return a data structure with the status of this structure_data.

=head3 PERL API

 $data = $model->status();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Structure_data ID WBStructure000876

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/status

=head4 Response example

<div class="response-example"></div>

=cut

sub status {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Status;
	my $data = {
		'data'=> "$data_pack" || undef,
		'description' => 'status of this structure'
		};
	return $data;
}



__PACKAGE__->meta->make_immutable;

1;

