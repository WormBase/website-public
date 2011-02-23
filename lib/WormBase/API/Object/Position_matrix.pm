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

# Provided by Object.pm, pod retained for documentation

=head2 remarks

This method will return a data structure containing
curator remarks about the transgene.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene (eg gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }

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


sub consensus {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->name2consensus_hr->{$object};

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


#sub evidence

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
