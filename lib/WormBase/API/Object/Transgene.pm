package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'ao_template' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->pull;
    	return $ao_object;
  	}
);


has 'laboratory' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $laboratory = $self->Location;
    	return $laboratory;
  	}
);

has 'reference' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $reference = $self->Reference;
    	return $reference;
  	}
);


#######

sub template {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

### mainly for text data; and single layer hash ###

sub template_simple {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Tag;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


########

sub genotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'genotype of the strain';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Genotype;

	####
	

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub made_by {


	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'developer of the strain';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Made_by;

	####
	

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;


}

sub remark {


	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'remarks';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Remark;

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

	$data_pack = {
					'common_name' => $object,
					'class' => 'Strain',
					'ace_id' => $object
				};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

1;