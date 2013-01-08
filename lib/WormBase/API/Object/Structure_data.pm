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

#######################################
#
# INSTANCE METHODS
#
#######################################

# name {}
# Supplied by Role

# remarks {}
# Supplied by Role

# sequence { }
# This method will return a data structure the sequence of this structure_data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/sequence

sub sequence {
	my $self = shift;
	my $object = $self->object;

	return {
		data => $self->_pack_obj($object->Protein, "$object"),
		description => 'sequence of structure',
	};
}

# protein_homology { }
# This method will return a data structure re: protein homologs this structure_data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/protein_homology

sub protein_homology {
	my $self = shift;
	my $object = $self->object;
	
	my @data = map {$self->_pack_obj($_)} $object->Pep_homol;
	
	return {
		data => @data ? \@data : undef,
		description => 'Protein homologs for this structure'
	};
}

# homology_data { }
# This method will return a data structure with the homology_data on this structure_data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/homology_data

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

# status { }
# This method will return a data structure with the status of this structure_data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/structure_data/WBStructure000876/status

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

