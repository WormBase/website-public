package WormBase::API::Object::Laboratory	;
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


##########
## details
##########

sub details {

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

####################
# genes and alleles
####################

sub gene_classes {

	my $self = shift;
	my $lab = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @genes;
	@gene_classes = $lab->get('Gene_classes');

	foreach my $gene_class (@gene_classes) {
	    
	  my $phenotype = $gene->Phenotype;
	  my $description = $gene->Description;

	  $data_pack{$gene_class} = {
	    'phenotype' => $phenotype,
	    'description' => $description
	  };
	  
	}


	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub allele_prefixes {

	my $self = shift;
    my $lab = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @alleles = $lab->get('Allele_designation');
	
	foreach my $allele (@alleles) {

	  my $allele_name = $allele->Public_name;
  
	 $data_pack{$allele} = {
	  'ace_id' => $allele,
	  'public_name' => $allele_name,
	  'class' => 'Variation'
	  }

	 }
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#####################
# lab personnel
#####################

sub current_members {

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


sub past_members {

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


1; 