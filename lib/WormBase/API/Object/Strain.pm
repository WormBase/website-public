package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

### has ###

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

has 'variation' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->Variation;
    	return $ao_object;
  	}
);

has 'rearrangement' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->Rearrangement;
    	return $ao_object;
  	}
);


has 'clone' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->Clone;
    	return $ao_object;
  	}
);


has 'transgene' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->Transgene;
    	return $ao_object;
  	}
);



### subroutines

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



sub gene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @genes = $object->Gene;
	foreach my $gene (@genes) {
	
		my $gene_name = public_name($gene,'Gene'); ## common_name($gene)
		$data_pack{$gene} = {
							'common_name' => $gene_name,
							'class' => 'Gene'
							};	
	}

	####
	
	$data{'data'} = \%data_pack; ## 
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @phenotypes = $object->Phenotype;

	foreach my $phenotype (@phenotypes) {
	
		my $phene_name = $phenotype ; ## common_name($gene)
		$data_pack{$phenotype} = {
							'common_name' => $phene_name,
							'class' => 'Phenotype'
							};	
	}

	####
	
	$data{'data'} = %data_pack;
	$data{'description'} = $desc;
	return \%data;
}

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



1;