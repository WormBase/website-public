package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


#### subroutines

sub details {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my $data_pack;

  #### data pull and packaging
  
  my $ao_term = $term->Term;
  my $definition = $term->Definition;
  my $synonym = $term->Synonym;
  my $remark = $term->Remark;
  my $url = $term->URL;

  $data_pack = {
  				'ace_id' =>$term,
  				'term' => $ao_term,
  				'definition' => $definition,
  				'synonym' => $synonym,
  				'remark' => $remark,
  				'url' => $url,
  				};
  ####

  $data{'data'} = $data_pack;
  $data{'description'} = $desc;
  return \%data;
}


sub expr_patterns{

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

  #### data pull and packaging

	my @eps = $object->Expr_pattern;
		
		foreach my $expr_pattern (@eps) {
		
		my $ep_gene;
		my $ep_pattern;
		my $ep_xgene;
		
		
		eval {$ep_gene= $object->Gene};
		eval {$ep_pattern= $object->Pattern};
		eval {$ep_xgene= $object->Transgene};
		
		
		my $gene_name = public_name($ep_gene);
		
		$data_pack{$expr_pattern} = {
		
									'expr_pattern' => $expr_pattern,
									'gene' => {
												'ace_id' => $ep_gene,
												'name' => $gene_name,
												'class' => 'Gene'
												},
									'pattern' => $ep_pattern,
									'transgene' =>{
													'xgene_id' => $ep_xgene,
													'class' => 'Transgene'
													}
									};
	}

  ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}



sub go_terms {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

  #### data pull and packaging

	my @go_terms = $object->GO_term;
	
	foreach my $go_term (@go_terms) {
	
	my $term = $go_term->Term;
	my $type = $go_term->Type;
	my $ao_code = $go_term->right;
	my $evidence;
	
	$data_pack{$go_term} = {
							'ace_id' => $go_term,
							'term' => $term,
							'ao_code' => $ao_code,
							'class' => 'GO_term',
							'evidence' => $evidence
							}
	};

  ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}



#sub reference {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



sub anatomy_fn {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

	my @anatomy_funtions = $object->Anatomy_function;
	
	foreach my $af (@anatomy_funtions) {
		
		my $phenotype = $af->Phenotype;
		my $phenotype_name = $phenotype->Primary_name;
		my $gene = eval{$af->Gene;};
		my $gene_name = eval{public_name($gene);};
		my $af_not;
	
		$data_pack{$af} = {
							'ace_id' => $af,
							'phenotype' => {
								 			'phenotype_id' => $phenotype,
								 			'phenotype_name' => $phenotype_name,
								 			'class' => 'phenotype'
											},
							'gene' => {
										'gene_id' => $gene,
										'gene_name' => $gene_name,
										'class' => 'Gene'
										},
							'not' => $af_not
							};
	}

	


  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}

sub expr_clusters {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;


	my @expr_clusters = $object->Expression_cluster;
	
	foreach my $ec (@expr_clusters) {
	
		my $ec_description = $ec->Description;
	
		$data_pack{$ec} = {
		
						'expr_cluster_id' => $ec,
						'class' => 'Expression_cluster',
						'description' => $ec_description
						}
	}

  $data{'data'} = \%data_pack;
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
										'label' => $common_name,
                                                                                'id' => "$object"
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
		|| eval { $object->Corresponding_CDS->Corresponding_protein}
		|| $object;
    }
    elsif ($class =~ /protein/i) {
    	$common_name = 
    	$object->Gene_name
    	|| eval { $object->Corresponding_CDS->Corresponding_protein}
    	||$object;
    }
    else {
    	$common_name = $object;
    }
	
	my $data = $common_name;
    return $data;


}


1;



