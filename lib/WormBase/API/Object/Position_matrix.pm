package WormBase::API::Object::Position_matrix;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Position_matrix

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/position_matrix

=head1 TODO

=cut

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

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/name

=head4 Response example

<div class="response-example"></div>

=cut 


sub name {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $self->_pack_obj($object);

	my $data = {
				'data'=> $data_pack,
				'description' => 'name of position matrix'
				};
	return $data;
}

=head2 description

This method will return a data structure description of the requested position matrix.

=head3 PERL API

 $data = $model->description();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/description

=head4 Response example

<div class="response-example"></div>

=cut 


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

=head2 remark

This method will return a data structure with remark re: the requested position matrix.

=head3 PERL API

 $data = $model->remark();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/remark

=head4 Response example

<div class="response-example"></div>

=cut 

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

=head2 associated_feature

This method will return a data structure with the associated feature to the requested position matrix.

=head3 PERL API

 $data = $model->associated_feature();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_feature

=head4 Response example

<div class="response-example"></div>

=cut 

sub associated_feature {
	my $self = shift;
    my $object = $self->object;
	
	my $associated_feature = $object->Associated_feature;
	my $feature_name = $associated_feature->Public_name
	my $data_pack = $self->_pack_obj($associated_feature);

	my $data = {
				'data'=> $data_pack,
				'description' => 'feature associated with motif'
				};
	return $data;	
}

=head2 associated_position_matrix

This method will return a data structure with the associated position_matrix to the requested position matrix.

=head3 PERL API

 $data = $model->associated_position_matrix();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/associated_position_matrix
=head4 Response example

<div class="response-example"></div>

=cut 

sub associated_position_matrix {
	my $self = shift;
    my $object = $self->object;
	
	my $associated_pm = $object->Associated_with_Position_Matrix;
	my $data_pack = $self->_pack_obj($associated_pm);

	my $data = {
				'data'=> $data_pack,
				'description' => 'other motif associated with motif'
				};
	return $data;
}

=head2 consensus

This method will return a data structure with the consensus sequence for the requested position matrix.

=head3 PERL API

 $data = $model->consensus();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/consensus
=head4 Response example

<div class="response-example"></div>

=cut 

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

=head2 position_data

This method will return a data structure with the position data for the requested position matrix.

=head3 PERL API

 $data = $model->position_data();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Postion_matrix ID WBPmat00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/position_data
=head4 Response example

<div class="response-example"></div>

=cut 

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