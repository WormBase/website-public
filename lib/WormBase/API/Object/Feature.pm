package WormBase::API::Object::Feature;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod 

=head1 NAME

WormBase::API::Object::Feature

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/feature

=head1 TODO

=cut


##################
## Details
##################

=head2 name

This method will return a data structure of the 
name for the requested position matrix.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/name

=head4 Response example

<div class="response-example"></div>

=cut 

sub name {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $self->_pack_obj($object);
	my $data = {
				'data'=> $data_pack,
				'description' => 'name of the feature'
				};
	return $data;
}

=head2 id

This method will return a data structure for the feature's id

=head3 PERL API

 $data = $model->id();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/id

=head4 Response example

<div class="response-example"></div>

=cut 

sub id {
	my $self = shift;
    my $object = $self->object;

	my $data_pack = {
		'id' =>"$object",
		'label' =>"$object",
		'Class' => 'Feature'
	};

	my $data = {
				'data'=> $data_pack,
				'description' => 'id of the feature'
				};
	return $data;
}

=head2 flanking_sequences

This method will return a data structure containing sequences adjacent to the feature .

=head3 PERL API

 $data = $model->flanking_sequences();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/flanking_sequences

=head4 Response example

<div class="response-example"></div>

=cut }


sub flanking_sequences {
	my $self = shift;
    my $object = $self->object;
	my @sequences = $object->Flanking_sequences;
	my @data_pack;
	
	foreach my $sequence (@sequences) {
		my $seq_data = $self->_pack_obj($sequence);
		push @data_pack, $seq_data;
	}

	my $data = {
				'data'=> \@data_pack,
				'description' => 'sequences flanking feature'
				};
	return $data;
}

=head2 species

This method will return a data structure containing the species in which the feature was observed

=head3 PERL API

 $data = $model->species();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/species

=head4 Response example

<div class="response-example"></div>

=cut 

sub species {
	my $self = shift;
    my $object = $self->object;
	my $species = $object->Species;

	my $data_pack = $self->_pack_obj($species);
	my $data = {
				'data'=> $data_pack,
				'description' => 'species in which feature was observed'
				};
	return $data;

}

=head2 description

This method will return a data structure with the description of the feature

=head3 PERL API

 $data = $model->description();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/description

=head4 Response example

<div class="response-example"></div>

=cut 

sub description {	
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Description;
	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the feature'
				};
	return $data;
}

#### <todo> what defined by association should be set up?
## sub defined_by
######################

sub associations {

}

=head2 binds_product_of_gene

This method will return a data structure containing the gene whose product binds the feature.

=head3 PERL API

 $data = $model->binds_product_of_gene();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a  Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/binds_product_of_gene

=head4 Response example

<div class="response-example"></div>

=cut 

sub binds_product_of_gene {
	my $self = shift;
    my $object = $self->object;
	my $gene = $object->Bound_by_product_of;
	my $data_pack = $self->_pack_obj($gene);

	my $data = {
				'data'=> $data_pack,
				'description' => 'product of this gene binds this feature'
				};
	return $data;
}

## <todo> ##

sub transcription_factor {

}

=head2 annotation

This method will return a data structure containing annotation info on the feature.

=head3 PERL API

 $data = $model->annotation();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Feature ID <headvar><object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/<headvar>/annotation

=head4 Response example

<div class="response-example"></div>

=cut 

sub annotation {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Annotation;

	my $data = {
				'data'=> $data_pack,
				'description' => 'annotation of the feature'
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

a <headvar> <Object> ID <object_instance>

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/<headvar>

=head4 Response example

<div class="response-example"></div>

=cut 

sub remark {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Remark;
	
	my $data = {
				'data'=> $data_pack,
				'description' => 'remark re: the feature'
				};
	return $data;
}

1;