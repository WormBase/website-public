package WormBase::API::Object::Person;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'address_data' => (
    is   => 'ro',
    isa  => 'HashRef',	
    lazy => 1,
    default => sub {	
	my $self = shift;
	my $object = $self->object;
	my %address;
	
	foreach my $tag ($object->Address) {
	    if ($tag =~ m/street|email|office/i) {		
		my @data = map { $_->name } $tag->col;
		$address{lc($tag)} = \@data;
	    } else {
		$address{lc($tag)} =  $tag->right->name;
	    }
	}
	return \%address;
    }
    );


####### publication data ########

has 'publication_hr' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
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



#######################################
#
# The Overview Widget
#
#######################################
sub name {
    my $self   = shift;
    my $object = $self->object;
    my $name   = $object->name;
    my $data   = { description => 'full (standard) name of the person',
		   data        =>  { id    => $name,
				     label => $object->Standard_name,
				     class => $object->class
		   },
    };
    return $data;
}

sub id {
    my $self   = shift;
    my $object = $self->object;
    my $data   = {  description => 'the WormBase ID of the person',
		    data        =>  $object->name };
    return $data;
}


sub street_address {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { data        => $address->{street_address} || undef,
		 description => 'street address of the person'}; 
    return $data;
}

sub country {    
    my $self = shift;
    my $address = $self->address_data;
    my $data    = { description => 'country of residence of person, if known',
		    data        => $address->{country} || undef };
    return $data;
}

sub institution {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'the institutional affiliation of the person',
		 data        => $address->{institution} || undef };
    return $data;
}

sub email {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'email addresses of the person',
		 data        => $address->{email} || undef };
    return $data;
}

sub lab_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'laboratory phone of the person',
		 data        => $address->{lab_phone} || undef };
    return $data;
}

sub office_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'office phone of the person',
		 data        => $address->{office_phone} || undef };
    return $data;
}

# Not displayed
sub other_phone {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'other contact numbers for of the person',
		 data        => $address->{other_phone} || undef };
    return $data;
}

sub fax {
    my $self    = shift;
    my $address = $self->address_data;
    my $data = { description => 'fax number(!) of the person',
		 data        => $address->{fax} || undef };
    return $data;   
}

sub web_page {
    my $self    = shift;
    my $address = $self->address_data;
    my $url = $address->{web_page};
    $url =~ s/HTTP\:\/\///;
    
    my $data = { description => 'web address of the person',
		 data        => $url || undef };
    return $data;   
}

# NOT DONE: Objects need to be packed prior to return
# Or is Possibly_publishes a string?
sub possibly_publishes_as {
    my $self = shift;
    my $object = $self->object;
    
    my @names = $object->Possibly_publishes_as;
    my $data = { description => 'other names that the person might publish under',
		 data        => \@names };
    return $data;
}




#######################################
#
# The Laboratory Widget
#
#######################################
sub laboratory {
    my $self   = shift;
    my $object = $self->object;
    
    my $lab   = $object->Laboratory;
    $lab = $self->_pack_obj($lab) if $lab;
    
    my $data = { description => 'laboratory affiliation of the person',
		 data        => $lab || undef};
    return $data;		     
}


sub previous_laboratories {
    my $self   = shift;
    my $object = $self->object;
    
    my @labs  = $object->Old_laboratory;
    my @data;
    foreach (@labs) {
	my $representative = $_->Representative;
	my $name = $representative->Standard_name; 
	my $rep = $self->_pack_obj($representative,$name);
	push @data,[ $self->_pack_obj($_),$rep ];
    }
       
    my $data = { description => 'previous laboratory affiliations',
		 data        => (@data > 0) ? \@data : undef};
    return $data;		     
}

sub strain_designation {
    my $self   = shift;
    my $object = $self->object;
       
    my $lab   = $object->Laboratory;
    $lab = $self->_pack_obj($lab) if $lab;
       
    my $data = { description => 'strain designation of the affiliated lab',
		 data        => $lab || undef };
    return $data;		     
}

sub allele_designation {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;
    my $allele_designation = ($lab) ? $lab->Allele_designation->name : undef;
    my $data = { description => 'allele designation of the affiliated laboratory',
		 data        => $allele_designation };
    return $data;
}


sub lab_representative {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;
    
    my $rep;
    if ($lab) { 
	my $representative = $lab->Representative;
	my $name = $representative->Standard_name; 
	$rep = $self->_pack_obj($representative,$name);
    }
    
    my $data = { description => 'official representative of the laboratory',
		 data        => $rep || undef };
    return $data;
}

sub gene_classes {
    my $self   = shift;
    my $object = $self->object;
    my $lab    = $object->Laboratory;

    my @gene_classes = $lab ? $lab->Gene_classes : undef;
    @gene_classes = map { $self->_pack_obj($_) } @gene_classes;
    
    my $data = { description => 'gene classes assigned to laboratory',
		 data        => \@gene_classes };
    return $data;
}



#######################################
#
# The Publications widget
#
#######################################
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



#######################################
#
# The Overview Widget
#
#######################################
sub supervised {    
    my $self = shift;
    my $data = $self->_get_supervision_data('Supervised');
    my $data = { description => 'people supervised by this person',
		 data        => $data };
    return $data;
}

sub supervised_by {
    my $self = shift;
    my $data = $self->_get_supervision_data('Supervised_by');       
    my $data = { description => 'people who supervised this person',
		 data        => $data };
    return $data;    
}

sub worked_with {
    my $self = shift;
    my $object = $self->object;
    
    my %data;
    my $desc = 'people with whom this person worked';
    my @data_pack;
    
    my @worked_with = $object->Worked_with;	
    foreach my $ww (@worked_with) {
	
	my $ww_id = $ww;
	my $ww_label = $ww->Full_name;
	
	my %ww = (	    
	    'id' => "$ww_id",
	    'label' => "$ww_label",
	    'class' => 'Person'
	    );
	
	push @data_pack, \%ww;
    }
    
    my $data = { description => 'people with whom this person worked',
		 data        => 
    };
    
    return $data;	
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

#################
# VERIFICATION
#################


sub status {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Status;

	####

	$data{'data'} = $data_pack; ##\%data_pack
	$data{'description'} = $desc;
	return \%data;

}

sub last_verified {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Last_verified;
	
	my @date = split /\ /, $data_pack;
	my $date = join " ", @date[0 .. 2];

	####

	$data{'data'} = $date; ## \%data_pack
	$data{'description'} = $desc;
	return \%data;

}





#######################################
#
# Name variations at finer granularity
# Provided for external API users; not displayed on Person Summary
#
#######################################
sub first_name {
    my $self = shift;
    my $object     = $self->object;
    my $first_name = $object->First_name;    
    my $data = { description => 'first name of the person',
		 data        => "$first_name" || undef };
    return $data;
}

sub last_name {
    my $self = shift;
    my $object = $self->object;
    my $last_name = $object->Last_name;    
    my $data = { description => 'last name of the person',
		 data        => "$last_name" || undef };
    return $data;
}

sub standard_name {
    my $self = shift;
    my $object = $self->object;
    my $standard_name = $object->Standard_name;    
    my $data = { description => '"standard" name of the person',
		 data        => "$standard_name" || undef };
    return $data;
}    

sub full_name {
    my $self = shift;
    my $object    = $self->object;
    my $full_name = $object->Full_name;    
    my $data = { description => 'full name of the person',
		 data        => "$full_name" || undef };
    return $data;
}

# Probably don't need to be packed, just displayed as strings
sub aka {
    my $self = shift;
    my $object = $self->object;
    my @aka = $object->Also_known_as;    
    @aka = map { $self->_pack_obj($_) } @aka;
    my $data = { description => 'aliases of the person',
		 data        => \@aka || undef };
    return $data;
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
