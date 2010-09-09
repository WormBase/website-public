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

# 

#   if ($name) {
#     print h2($name);
#     print "Fax  : " . . br if $lab->Fax;
#     print "Phone: " .  . br if $lab->Phone;
#     print "Email: " .  . br if $lab->Email;
#   }

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

	my @gene_classes;
	@gene_classes = $lab->get('Gene_classes');

	foreach my $gene_class (@gene_classes) {
	    
	  my $phenotype = $gene_class->Phenotype;
	  my $description = $gene_class->Description;

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

	  my $allele_name; # = $allele->Public_name;
  
	 $data_pack{$allele} = {
	  'ace_id' => $allele,
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