package WormBase::API::Object::Position_matrix;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


###########################
## summary
###########################

    $data{'name'} = $position_matrix_object;
	$data{'desc'} = $position_matrix_object->Description;
	$data{'remark'} = $position_matrix_object->Remark;	
	$data{'paper_evidence'} = $position_matrix_object->Paper_evidence;
	$data{'associated_feature'} = $position_matrix_object->Associated_feature;
	$data{'associated_pm'} = $position_matrix_object->Associated_with_Position_Matrix;

sub name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	$data_pack = _pack_obj($object);

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub description {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Description;

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub remark {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Remark;

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub associated_feature {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $associated_feature;
	my $feature_name;
	
	$associated_feature = $object->Associated_feature;
	$feature_name = $associated_feature->Public_name

	$data_pack = {
	
		'id' =>"$associated_feature",
		'label' =>"$feature_name",
		'Class' => 'Feature'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub associated_position_matrix {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $associated_pm;
	$associated_pm = $object->Associated_with_Position_Matrix;

	$data_pack = _pack_obj($associated_pm);

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

#sub evidence

#sub consensus


############################
## logo
############################



#############################
## position data
#############################


sub position_data {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data;

	#### data pull and packaging

		my $sv = $object->Site_values;
		my @row_1 = $sv->row;
		my @row_2 = $sv->down->row;
		my @row_3 = $sv->down->down->row;
		my @row_4 = $sv->down->down->down->row;
		# my %data;
		my $base_r1 = shift @row_1;
		my $base_r2 = shift @row_2;
		my $base_r3 = shift @row_3;
		my $base_r4 = shift @row_4;
		my $data = {$base_r1 => \@row_1,
			$base_r2 => \@row_2,
			$base_r3 => \@row_3,
			$base_r4 => \@row_4
		};

	####

	$data{'data'} = $data;
	$data{'description'} = $desc;
	return \%data;
}

1;