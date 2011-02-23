package WormBase::API::Object::Laboratory	;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod 

=head1 NAME

WormBase::API::Object::Laboratory

=head1 SYNPOSIS

Model for the Ace ?Laboratory class.

=head1 URL

http://wormbase.org/resource/laboratory

=head1 TODO

=head1 METHODS

=cut




=head2 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head4 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}



sub id {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
	
		'id' => "$object",
		'label' => "$object",
		'class' => 'Laboratory'
	
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}
sub phone {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Phone;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub fax {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Fax;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub email {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Email;
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub web_site {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->URL;
	my ($disc, $url) = split '://', $data_pack;

	####
	
	$data{'data'} = $url;
	$data{'description'} = $desc;
	return \%data;
}


##########
## details
##########

sub details {

	my $self = shift;
	my $lab = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my ($institution,@address)    = $lab->Address(2);
	my $fax =  $lab->Fax;  
	my $phone =  $lab->Phone;
	my $email =  $lab->Email;

	%data_pack = (

	  'name' => "$lab",
	  'instituion' => $institution,
	  'fax' => $fax,
	  'phone' => $phone,
	  'email' => $email
	  );

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub representative {

      my $self = shift;
      my $lab = $self->object;
      my %data;
      my $desc = 'notes';
      my $data_pack;

      #### data pull and packaging
    
      my $rep = $lab->Representative;

		my $name = $rep->Standard_name;


		$data_pack = {
	      'id' => "$rep",
	      'label' => "$name",
	      'class' => 'Person'
	  	};



	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;


}

sub representatives {

      my $self = shift;
      my $lab = $self->object;
      my %data;
      my $desc = 'notes';
      my %data_pack;

      #### data pull and packaging
    
      my @representatives = $lab->Representative;

   	foreach my $rep (@representatives) {
		my $name = $rep->Standard_name;
		my $laboratory = $rep->Laboratory;
		my @a   = $rep->Address(2);
		foreach (@a) {
	  		$_ = $_->right if $_->right;  # AtDB damnation
		}

		my $email = $rep->get('Email' => 1);
		$email = eval{$email->right if $email->right;};

		$data_pack{$rep} = {
	      'ace_id' => $rep,
	      'name' => $name,
	      'laboratory' => $laboratory,
	      'class' => 'Person',
	      'address' => \@a,
	      'email' => $email
	  	};

	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


####################
# genes and alleles
####################

sub gene_class {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack = [];

	#### data pull and packaging

	my @gene_classes;
	@gene_classes = $object->get('Gene_classes');	

	foreach my $gene_class (@gene_classes) {
	
	push @data_pack, {
	
						'id' => "$gene_class",
						'label' => "$gene_class",
						'class' => 'Gene_class'
						};
	}

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub allele_designation {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Allele_designation;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub strain_designation {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Strain_designation;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub allele_designation {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Allele_designation;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;



}

sub alleles {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @alleles = $object->Alleles;

	foreach my $allele (@alleles) {
	
		my $allele_name = $allele->Public_name;
	
		push @data_pack, {
		
			'id' => "$allele",
			'label' => "$allele_name",
			'class' => 'Variation'
		
		};
	}

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub gene_classes {

	my $self = shift;
	my $lab = $self->object;
	my @data_pack;
	my $desc = 'Gene classes assigned to laboratory';
	my %data;
	
	my @gene_classes = $lab->Gene_classes;
		
	foreach my $gene_class (@gene_classes) {
			
		my $gc_label = $gene_class;
		push @data_pack, {
									
					'label' => "$gc_label",
					'id' => "$gc_label",
					'class' => 'Gene_class'						
		};
	}

	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	
	return \%data;
}

#####################
# lab personnel
#####################

sub current_member {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @current_members = $object->Registered_lab_members;
	
	foreach my $current_member (@current_members) {
	
		my $cm_name = $current_member->Full_name;
		my $cm_last_name = $current_member->Last_name;
		
		$data_pack{$cm_last_name} =  {
		
			'id' => "$current_member",
			'label' => "$cm_name",
			'class' => 'Person'
		};
	}
	
	####
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub former_member {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @former_members = $object->Past_lab_members;
	
	foreach my $former_member (@former_members) {
	
		my $fm_name = $former_member->Full_name;
		my $fm_last_name = $former_member->Last_name;
		
		$data_pack{$fm_last_name} = {
		
			'id' => "$former_member",
			'label' => "$fm_name",
			'class' => 'Person'
		};
	}
	

	####
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


1; 
