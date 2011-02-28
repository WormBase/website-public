package WormBase::API::Object::Feature;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Feature

=head1 SYNPOSIS

Model for the Ace ?Feature class.

=head1 URL

http://wormbase.org/species/feature

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


=head3 flanking_sequences

This method will return a data structure containing sequences adjacent to the feature .

=head4 PERL API

 $data = $model->flanking_sequences();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/flanking_sequences

=head5 Response example

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


# sub taxonomy { }
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


=head3 defined_by

This method will return a data structure 

=head4 PERL API

 $data = $model->defined_by();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/defined_by

=head5 Response example

<div class="response-example"></div>

=cut 

sub defined_by {
	my $self = shift;
	my $tag = shift;
    my $object = $self->object;
    my @data_pack;
	my @defining_objects = $object->$tag;
	
	foreach my $defining_object (@defining_objects) {
		my $do_data = _pack_obj($defining_object);
		push @data_pack, $do_data;
	}	
	
	my $data = {
				'data'=> \@data_pack,
				'description' => 'objects that define this feature'
				};
	return $data;
}



=head3 associations

This method will return a data structure of the 
name for the requested position matrix.

=head4 PERL API

 $data = $model->associations();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/associations

=head5 Response example

<div class="response-example"></div>

=cut

sub associations {
	my $self = shift;
	my $tag = shift;
    my $object = $self->object;
	my @associations = $object->$tag;
	my @data_pack;
	
	foreach my $association (@associations) {
		my $assoc_data = $self->_pack_obj($association);
		push @data_pack, $assoc_data;
	}
	my $data = {
		'data'=> \@data_pack,
		'description' => 'objects associated with this feature'
	};
	return $data;
}

=head3 binds_product_of_gene

This method will return a data structure containing the gene whose product binds the feature.

=head4 PERL API

 $data = $model->binds_product_of_gene();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a  Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/binds_product_of_gene

=head5 Response example

<div class="response-example"></div>

=cut 

sub binds_product_of_gene {
	my $self = shift;
    my $object = $self->object;
	my @genes = $object->Bound_by_product_of;
	my @data_pack;
	
	foreach my $gene (@genes) {
		my $gene_data = $self->pack_obj($gene);
		push @data_pack, $gene_data;
	}
	my $data = {
				'data'=> \@data_pack,
				'description' => 'product of these genes binds this feature'
				};
	return $data;
}

=head3 transcription_factor

This method will return a data structure containing the transcription factors associated with this feature.

=head4 PERL API

 $data = $model->transcription_factor();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a  Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/transcription_factor

=head5 Response example

<div class="response-example"></div>

=cut

sub transcription_factor {	
	my $self = shift;
    my $object = $self->object;
	my $transcription_factor = $object->Transcription_factor;

	my $data_pack = $self->_pack_obj($transcription_factor);

	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the position matrix'
				};
	return $data;
}

=head3 annotation

This method will return a data structure containing annotation info on the feature.

=head4 PERL API

 $data = $model->annotation();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Feature ID WBsf000753

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/annotation

=head5 Response example

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

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


1;
