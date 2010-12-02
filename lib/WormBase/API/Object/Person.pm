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


### add address hash

has 'address_info' => (
	
	is => 'ro',
	isa => 'HashRef',	
	lazy => 1,
	default => sub {
	
		my $self = shift;
		my $object = $self->object;
		my %address = map {$_ => $_->right} $object->Address;
		return \%address;
	}
);

has 'address_hr' => (
	
	is => 'ro',
	isa => 'HashRef',	
	lazy => 1,
	default => sub {
	
		my $self = shift;
		my $object = $self->object;
		my %address;
		
		foreach my $address_bit ($object->Address) {
			if ($address_bit=~ m/street/i) {
			
				my @street_data = $address_bit->col;
				$address{$address_bit} = \@street_data;
			}
			elsif ($address_bit=~ m/email/i) {
			
				my @email_data = $address_bit->col;
				$address{$address_bit} = \@email_data;
			}
			elsif ($address_bit=~ m/office/i) {
			
				my @office_phone_data = $address_bit->col;
				$address{$address_bit} = \@office_phone_data;
			}
			else {
				
				$address{$address_bit} = $address_bit->right;
			}
		}
		return \%address;
	}
);


#### laboratory object

has 'lab_object' => (

	is  => 'ro',
    # isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $object = $self->object;
    	my $ao_object = $object->Laboratory;
    	
    	if ($ao_object) {
    		return $ao_object;
    	}
    	else {
    	
    		return;
    	}
  	}
);


has 'lab_info_hr' => (

	is  => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $object = $self->object;
    	my $ao_object = $object->Laboratory;
    	return $ao_object;
  	}
);






####### publication data ########

has 'publication_hr' => (

	is  => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
    	
    my $self = shift;
    my $object = $self->object;
	my %data_pack;

	#### data pull and packaging
	
	my @papers = $object->Paper;
	
	foreach my $paper (@papers) {
		
		
		my $paper_id = $paper;
		my @authors = $paper->Author;
		my $brief_citation = $paper->Brief_citation;
		my $type = 'Paper';
		
		
		my $publication_date = $paper->Publication_date; 
		my ($publication_year, $disc) = split /\-/,$publication_date;
		
		my $meeting_abstract;
		$meeting_abstract = $paper->Meeting_abstract;
		
		if ($meeting_abstract) {
		
			$type = 'Meeting_abstact';
		}
		
		my %publication_info = (
			'label' => "$brief_citation",
			'class' => 'Paper',
			'id' => "$paper_id"
		);
		
		if ($data_pack{$type}{$publication_year}) {
			
			my $pub_ar = $data_pack{$type}{$publication_year};
			push @$pub_ar, \%publication_info;
		}
		else {
		
			$data_pack{$type}{$publication_year} = [\%publication_info];
		}	
	}
	
	####

	return \%data_pack;
    
    }

);


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



## NB: include possibly publishes as

##########
# name
##########

sub first_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'Persons first name';
	my %data_pack;

	#### data pull and packaging

	my $first_name = $object->First_name;
	my $object_id = $object;

	####
	
	
	%data_pack = (
	
		'id' => "$object_id",
		'label' => "$first_name",
		'class' => "Person"
	);
	
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub last_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $last_name = $object->Last_name;
	my $object_id = $object;
	####
	
	%data_pack = (
	
		'id' => "$object_id",
		'label' => "$last_name",
		'class' => "Person"
	);	
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub standard_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $standard_name = $object->Standard_name;
	my $object_id = $object;
	
	####
	
	%data_pack = (
	
		'id' => "$object_id",
		'label' => "$standard_name",
		'class' => "Person"
	);	
	
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub full_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $full_name = $object->Full_name;
	my $object_id = $object;

	
	%data_pack = (
	
		'id' => "$object_id",
		'label' => "$full_name",
		'class' => "Person"
	);	
	
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub aka {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @akas = $object->Also_known_as;
	my $object_id = $object;
	
	foreach my $aka (@akas) {
	
		push @data_pack,{
			'label' => "$aka",
			'id' => "$object_id",
			'class' => 'Person'
		}; 
	}

	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub mapa {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	
	#### data pull and packaging

	my @mapas = $object->Possibly_publishes_as;
	
	####

	$data{'data'} = \@mapas;
	$data{'description'} = $desc;
	return \%data;
}



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

############
# ADDRESS ##
############

sub street_address {

	my $self = shift;
	my %data;
	my $address_info = $self->address_hr;
	my $street_address = $address_info->{'Street_address'};
	
	$data{'data'} = $street_address;
	$data{'description'} = 'Street address of person';
	return \%data;
}

sub country {

	my $self = shift;
	my %data;
	my $address_info = $self->address_hr;
	$data{'data'} = $address_info->{'Country'};
	$data{'description'} = 'Country of residence of person';
	
	return \%data;

}


sub institution {

	my $self = shift;
	my $address_info = $self->address_hr;
	my %data;
	$data{'data'} = $address_info->{'Institution'};
	$data{'description'} = 'Institution of person';
	return \%data;

}

sub email {

	my $self = shift;
	my $address_info = $self->address_hr;
	my %data;
	$data{'data'} = $address_info->{'Email'};
	$data{'description'} = 'email addresses of person';
	return \%data;

}


sub lab_phone {

	my $self = shift;
	my $address_info = $self->address_hr;
	my %data;
	$data{'data'} = $address_info->{'Lab_phone'};
	$data{'description'} = 'laboratory phone';
	return \%data;
}


sub office_phone {

	my %data;
	my $self = shift;
	my $address_info = $self->address_hr;
	$data{'data'} = $address_info->{'Office_phone'};
	$data{'description'} = 'office number of person';
	return \%data;
}



sub fax {	

	my %data;
	my $self = shift;
	my $address_info = $self->address_hr;
	$data{'data'} =	$address_info->{'Fax'};
	$data{'description'} = 'fax number of person';
	return \%data;
}

sub web_page {

	my %data;
	my $self = shift;
	my $address_info = $self->address_hr;
	$data{'data'} = $address_info->{'Web_page'};
	$data{'description'} = 'web page of person';
	return \%data;
}

sub other_phone {

	my %data;
	my $self = shift;
	my $address_info = $self->address_hr;
	$data{'data'} = $address_info->{'Other_phone'};
	$data{'description'} = 'other contact numbers for person';
	
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

	my %address = map {$_ => $_->right} $object->Address;


	@street_address = $address{'Street_address'}; #$object->
	$country=  $address{'Country'}; #$object->
	$institution= $address{'Institution'}; #$object->
	@emails= $address{'Email'}; # $object->
	$lab_phone= $address{'Lab_phone'}; #$object->
	$office_phone= $address{'Office_phone'}; #$object->
	$fax= $address{'Fax'}; #$object->
	$webpage= $address{'Web_page'}; #$object->

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

###############
# laboratory
###############



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

sub lab_id {

	my $self = shift;
	my $object = $self->object;
	my $lab = $self->lab_object;
	my %data;
	my %data_pack;
	
	if ($lab) {
		my $lab_label = $lab;
		
		%data_pack = (
					'id' => "$lab_label",
					'label' => "$lab_label",
					'class' => 'Laboratory'
		);
	}
	
	$data{'data'} = \%data_pack;
	$data{'description'} = 'lab id';

	return \%data;
}

sub cgc_representative {

	my $self = shift;
	my $object = $self->object;
	
	my $lab = $self->lab_object;
	my %data;
	my $cgc_rep;
	my $cgc_rep_name;
	
	if($lab) {
	
		my $cgc_rep = $lab->Representative;
		my $cgc_rep_name = $cgc_rep->Full_name;	
	}
	

	
	$data{'data'} = $cgc_rep_name;
	$data{'description'} = 'lab representative';

	return \%data;
}


sub gene_classes {

	my $self = shift;
	my $object = $self->object;
	my $lab = $self->lab_object;
	my @data_pack;
	my $desc = 'Gene classes assigned to laboratory';
	my %data;
	
	if($lab) {
		my @gene_classes = $lab->Gene_classes;
		foreach my $gene_class (@gene_classes) {
			
			my $gc_label = $gene_class;
			push @data_pack, {
									
					'label' => "$gc_label",
					'id' => "$gc_label",
					'class' => 'Gene_class'						
			};
		}
	}
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	
	return \%data;
}

sub allele_designation {

	my $self = shift;
	my $object = $self->object;
	my $lab = $self->lab_object;
	my $desc = 'allele designation assigned to laboratory';
	my %data;
	my $allele_designation;
	
	if($lab) {
	
		$allele_designation = $lab->Allele_designation;
	}

	$data{'data'} = $allele_designation;
	$data{'description'} = $desc;
	
	return \%data;

}

######################
## publications
######################


sub papers {

	my $self = shift;
	my %data;
	my $description = 'Papers by the person';
	my $publication_hg = $self->publication_hr;
	my $data_pack = $publication_hg->{'Paper'};
	
	$data{'data'} = $data_pack;
	$data{'description'} = $description;
	
	return \%data;

}


sub meeting_abstracts {

	my $self = shift;
	my %data;
	my $description = 'Meeting presentations by the person';
	my $publication_hg = $self->publication_hr;
	my $data_pack = $publication_hg->{'Meeting_abstact'};
	
	$data{'data'} = $data_pack;
	$data{'description'} = $description;
	
	return \%data;
}
sub papers_old {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @papers = $object->Paper;
	
	foreach my $paper (@papers) {
		
		
		my $paper_id = $paper;
		my @authors = $paper->Author;
		my $brief_citation = $paper->Brief_citation;
		my $type = 'Paper';
		
		
		my $publication_date = $paper->Publication_date; 
		my ($publication_year, $disc) = split /\-/,$publication_date;
		
		my $meeting_abstract;
		$meeting_abstract = $paper->Meeting_abstract;
		if ($meeting_abstract) {
		
			$type = 'Meeting_abstact';
		}
		
		my %publication_info = (
			'label' => "$brief_citation",
			'class' => 'Paper',
			'id' => "$paper_id"
		);
		
		if ($data_pack{$type}{$publication_year}) {
			
			my $pub_ar = $data_pack{$type}{$publication_year};
			push @$pub_ar, \%publication_info;
		}
		else {
		
			$data_pack{$type}{$publication_year} = [\%publication_info];
		}
		
	}
	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

###############
# LINEAGE
##############

sub supervised {

	my $self = shift;
	my $data = $self->_get_supervision_data('Supervised');
	my $desc = 'People supervised by person';
	
	my %data;
	
	$data{'data'} = $data;
	$data{'description'} = $desc;
	
	return \%data;
}


sub supervised_by {

	my $self = shift;
	my $data = $self->_get_supervision_data('Supervised_by');
	my $desc = 'People who supervised this person';
	
	my %data;
	
	$data{'data'} = $data;
	$data{'description'} = $desc;
	
	return \%data;
}

sub supervised_by_old {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	my @supervised;
	
	@supervised = $object->Supervised_by;
	
	foreach my $supervised (@supervised) {
	
		my $first_name = $supervised->First_name;
		my $last_name = $supervised->Last_name;
		my ($level, $start, $end) = $supervised->right->row;
		
		push @data_pack, {
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

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


#####################
# INTERNAL METHODS
######################

sub _get_supervision_data {

	my $self = shift;
	my $tag = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @supervised;
	
	@supervised = $object->$tag;
	
	foreach my $supervised (@supervised) {
	
		my $first_name = $supervised->First_name;
		my $last_name = $supervised->Last_name;
		my $full_name = $supervised->Full_name;
		my ($level, $start, $end) = $supervised->right->row;
		my $supervised_scalar = $supervised;
		my @end_date;
		
		if (!($end =~ m/present/i)) {
			@end_date = split /\ /,$end; 
		}
		
		my @start_date = split /\ /,$start; 
		
		my $duration = "$start_date[2]\ \-\ $end_date[2]"; 
		
		push @data_pack, {
					'person' => {
					
						'id' => "$supervised_scalar",
						'label' => "$full_name",
						'class' => 'Person'
						},
					
					'first_name' => "$first_name",
					'last_name' => "$last_name",
					'level' =>"$level",
					'supervision_start' => "$start",
					'supervision_end' => "$end",
					'duration' => "$duration"
					};
	}

	return \@data_pack;
}


1;