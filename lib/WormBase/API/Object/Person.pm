package WormBase::API::Object::Person;
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


#######


sub name {
    my $self = shift;
    my $object = $self->object;
    my $name   = $object->name;
    my $data = { description => 'The name of the person',
		 data        =>  { id    => $name,
				   label => $object->Standard_name,
				   class => $object->class
		 },
    };
    return $data;
}

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

## NB: include possibly publishes as


sub details {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $first_name;
	my $last_name;
	my $standard_name;
	my $full_name;
	my @aka;
	my @possibly_published_as;

	$first_name = $object->First_name;
	$last_name = $object->Last_name;
	$standard_name = $object->Standard_name;
	$full_name = $object->Full_name;
	@aka = $object->Also_known_as;
	@possibly_published_as = $object->Possibly_publishes_as;

	%data_pack = (
					'ace_id' => $object,
					'first_name' => $first_name,
					'last_name' => $last_name,
					'standard_name' => $standard_name,
					'also_known_as' => \@aka,
					'possibly_published_as' => \@possibly_published_as
					);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub address {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @street_address;
	my $country;
	my $institution;
	my @emails;
	my $lab_phone;
	my $office_phone;
	my $fax;
	my $webpage;

	@street_address = $object->Street_address;
	$country= $object->Country;
	$institution= $object->Institution;
	@emails= $object->Email;
	$lab_phone= $object->Lab_phone;
	$office_phone= $object->Office_phone;
	$fax= $object->Fax;
	$webpage= $object->Web_page;

	%data_pack = (
					'street_address' => \@street_address,
					'country' => $country,
					'institution' => $institution,
					'email' => \@emails,
					'lab_phone' => $lab_phone,
					'office_phone' => $office_phone,
					'fax' => $fax,
					'webpage' => $webpage
				);


	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub laboratory {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $lab = $object->Laboratory;
	my $mail = $lab->Mail;
	my $email = $lab->Email;
	my $url = $lab->URL;
	my %address;
	my $cgc_rep = $lab->Representative;
	my $cgc_rep_name = $cgc_rep->Full_name;
	
	%data_pack = ( 
					'ace_id' => $lab, 
					'cgc_rep' => $cgc_rep_name,
					'mail' => $mail,
					'email' => $email,
					'url' => $url
					);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub papers {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @papers = $object->Paper;
	
	foreach my $paper (@papers) {
		
		my @authors = $paper->Author;
		my $brief_citation = $paper->Brief_citation;
		my $type = 'Paper';
		my $meeting_abstract;
		
		$meeting_abstract = $paper->Meeting_abstract;
		
		if ($meeting_abstract) {
		
			$type = 'Meeting_abstact';
		}
		
		
		$data_pack{$paper} = {
								'authors' => \@authors,
								'brief_citation' =>$brief_citation,
								'type' => $type
								};
	}
	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub supervised {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @supervised;
	
	@supervised = $object->Supervised;
	
	foreach my $supervised (@supervised) {
	
		my $first_name = $supervised->First_name;
		my $last_name = $supervised->Last_name;
		my ($level, $start, $end) = $supervised->right->row;
		
		$data_pack{$supervised} = {
									'ace_id' => $supervised,
									'first_name' => $first_name,
									'last_name' => $last_name,
									'class' => 'Person',
									'level' =>$level,
									'supervision_start' => $start,
									'supervision_end' => $end
									};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub supervised_by {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	my @supervised;
	
	@supervised = $object->Supervised_by;
	
	foreach my $supervised (@supervised) {
	
		my $first_name = $supervised->First_name;
		my $last_name = $supervised->Last_name;
		my ($level, $start, $end) = $supervised->right->row;
		
		$data_pack{$supervised} = {
									'ace_id' => $supervised,
									'first_name' => $first_name,
									'last_name' => $last_name,
									'class' => 'Person',
									'level' =>$level,
									'supervision_start' => $start,
									'supervision_end' => $end
									};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


1;