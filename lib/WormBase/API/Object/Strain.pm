package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

### has ###

#has 'laboratory' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $laboratory = $self->Location;
#    	return $laboratory;
#  	}
#);

#has 'reference' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $reference = $self->Reference;
#    	return $reference;
#  	}
#);

#has 'variation' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $ao_object = $self->Variation;
#    	return $ao_object;
#  	}
#);

#has 'rearrangement' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $ao_object = $self->Rearrangement;
#    	return $ao_object;
#  	}
#);


#has 'clone' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $ao_object = $self->Clone;
#    	return $ao_object;
#  	}
#);

#
#has 'transgene' => (    
#	is  => 'ro',
#    isa => 'Ace::Object',
#    lazy => 1,
#    default => sub {
#    	
#    	my $self = shift;
#    	my $ao_object = $self->Transgene;
#    	return $ao_object;
#  	}
#);



### subroutines

###########
## OVERVIEW
############
sub name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
					'label' => "$object",
					'class' => 'Strain',
					'id' => "$object"
				};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub id {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
					'label' => "$object",
					'class' => 'Strain',
					'id' => "$object"
				};
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

##############
## GENOTYPE
############

sub strain {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	

	$data_pack = {
	
		'id' =>,
		'label' =>,
		'Class' => ''
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


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
##############
## CONTAINS
############

sub gene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @genes = $object->Gene;
	foreach my $gene (@genes) {
	
		my $gene_name = public_name($gene,'Gene'); ## common_name($gene)
		push @data_pack, {
							'id' => "$gene",
							'common_name' => "$gene_name",
							'class' => 'Gene'
							};	
	}

	####
	
	$data{'data'} = \@data_pack; ## 
	$data{'description'} = $desc;
	return \%data;
}

sub allele {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	
	my $allele = $object->Variation;
	my $allele_name = $allele->Public_name;
	

	$data_pack = {
	
		'id' =>"$allele",
		'label' =>"$allele_name",
		'Class' => 'Variation'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub rearrangement {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Rearrangement;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub clone {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Clone;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub transgene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Transgene;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

##############
## PROPERTIES
############

### sub species

sub males {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Males;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub reference_strain {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $ref_strain = $object->Reference_strain;
	
	$data_pack = {
	
		'id' =>"$ref_strain",
		'label' =>"$ref_strain",
		'Class' => 'Strain'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub mutagen {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Mutagen;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub outcrossed {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Outcrossed;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub date_received {

	my $self = shift;
    my $strain = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;
	my $date;

	
	#### data pull and packaging
	
	$date   = $strain->CGC_received;
	$date =~ s/ 00:00:00$//;
	$data_pack = $date;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub properties  {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $strain;
	$strain = eval { $object->Species->name; };
	
	## phenotype data:  Basic package for now, will add details once phenotype.pm comes inline
	my @phenotypes = $object->Phenotype;
	my $phenotype_package = basic_package(\@phenotypes);
	
	$data_pack = {
	
				'species'  =>  $strain,
				'males'    => $object->Males,
				'reference_strain' => $object->Reference_strain,
				'outcrossed' => $object->Outcrossed,
				'mutagen'    => $object->Mutagen,
				'received_at_CGC' => $object->CGC_received,
				'phenotype' => %$phenotype_package
				};	
	
	
	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @phenotypes = $object->Phenotype;

	foreach my $phenotype (@phenotypes) {
	
		my $phene_name = $phenotype ; ## common_name($gene)
		
		push @data_pack, {
							'label' => "$phene_name",
							'class' => 'Phenotype',
							'id' => "$phenotype"
							};	
	}

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}



##############
## LOCATION
############

sub location {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Location;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


##############
## MADE BY
############

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

# sub remarks { }

=head2 reporter_construct

This method will return a data structure of the 
reporter construct driven by the transgene.

=head3 PERL API

 $data = $model->reporter_construct();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks {}


	

  
##############
## REFERENCE
############

### copied and pasted, need to get to work in Object.pm


sub basic_package {

	my ($self,$data_ar) = @_;
	my %package;
	
	foreach my $object (@$data_ar) {
				
				
				my $class;
				eval{$class = $object->class;};

				my $common_name = public_name($object,$class);  ## 
				$package{$object} = 	{
										'class' => $class,
										'common_name' => $common_name
										}	
	}

	return \%package;
}

sub public_name {
    
	my ($object,$class) = @_;
    my $common_name;    
   
    if ($class =~ /gene/i) {
		$common_name = 
		$object->Public_name
		|| $object->CGC_name
		|| $object->Molecular_name
		|| eval { $object->Corresponding_CDS->Corresponding_protein }
		|| $object;
    }
    elsif ($class =~ /protein/i) {
    	$common_name = 
    	$object->Gene_name
    	|| eval { $object->Corresponding_CDS->Corresponding_protein }
    	||$object;
    }
    else {
    	$common_name = $object;
    }
	
	my $data = $common_name;
    return $data;


}

sub _get_phenotype_data {}

1;
