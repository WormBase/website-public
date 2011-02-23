package WormBase::API::Object::Position_matrix;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

#########################
## has_as
#########################

has 'data_directory' => (    
	is  => 'ro',
    lazy => 1,
    default => sub {
    
    	return "/usr/local/wormbase/databases/$version/position_matrix";
  	}
);

has 'image_directory' => (    
	is  => 'ro',
    lazy => 1,
    default => sub {
    
    	return "../../html/images/position_matrix";
  	}
);

has 'name2consensus_hr' => (
	is  => 'ro',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $data_dir = $self->data_directory;
    	my $datafile = $data_dir."/pm_id2consensus_seq.txt";
    	my %name2consensus = _build_hash($datafile);
    	
    	return \%name2consensus;
  	}
);

has 'image_pointer_file' => (
	is  => 'ro',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $data_dir = $self->data_directory;
    	my $datafile = $data_dir."/pm_id2source_pm.txt";
    	my %image_pointer = _build_hash($datafile);
    	
    	return \%image_pointer;
  	}
);


###########################
## summary
###########################


sub name {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = _pack_obj($object);

	my $data = {
				'data'=> $data_pack,
				'description' => 'name of position matrix'
				};
	return $data;
}


sub description {

	my $self = shift;
    my $object = $self->object;

	$data_pack = $object->Description;
	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the position matrix'
				};
	return $data;
}

sub remark {
	my $self 	= shift;
    my $object 	= $self->object;
	my $data_pack = $object->Remark;

	my $data = {
				'data'=> $data_pack,
				'description' => 'remarks re: position matrix'
				};
	return $data;
}

sub associated_feature {
	my $self = shift;
    my $object = $self->object;
	
	my $associated_feature = $object->Associated_feature;
	my $feature_name = $associated_feature->Public_name
	my $data_pack = _pack_obj($associated_feature);

	my $data = {
				'data'=> $data_pack,
				'description' => 'feature associated with motif'
				};
	return $data;	
}


sub associated_position_matrix {
	my $self = shift;
    my $object = $self->object;
	
	my $associated_pm = $object->Associated_with_Position_Matrix;
	my $data_pack = _pack_obj($associated_pm);

	my $data = {
				'data'=> $data_pack,
				'description' => 'other motif associated with motif'
				};
	return $data;
}

sub consensus {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->name2consensus_hr->{$object};

	my $data = {
				'data'=> $data_pack,
				'description' => 'consensus sequence for motif'
				};
	return $data;	
}

############################
## logo
############################


#############################
## position data
#############################


sub position_data {

	my $self = shift;
    my $object = $self->object;
	my $sv = $object->Site_values;

	my @row_1 = $sv->row;
	my @row_2 = $sv->down->row;
	my @row_3 = $sv->down->down->row;
	my @row_4 = $sv->down->down->down->row;

	my $base_r1 = shift @row_1;
	my $base_r2 = shift @row_2;
	my $base_r3 = shift @row_3;
	my $base_r4 = shift @row_4;

	my $data = {
		$base_r1 => \@row_1,
		$base_r2 => \@row_2,
		$base_r3 => \@row_3,
		$base_r4 => \@row_4
	};
	
	my $return = {
				'data'=> $data,
				'description' => 'data for individual positions in motif'
				};
	return $return;	
}

###########################
## internal methods
###########################

sub _build_hash{
	my ($file_name) = @_;
	open FILE, "<./$file_name" or die "Cannot open the file: $file_name\n";
	my %hash;
	foreach my $line (<FILE>) {
		chomp ($line);
		my ($key, $value) = split '=>',$line;
		$hash{$key} = $value;
	}
	return %hash;
}


1;