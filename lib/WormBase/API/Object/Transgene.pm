package WormBase::API::Object::Transgene;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


##############
## Transgene
##############

sub name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	

	$data_pack = {
	
		'id' =>"$object",
		'label' =>"$object",
		'Class' => 'Transgene'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

#################
## Evidence
#################

sub evidence {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = eval{$object->Evidence;};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

###################
## Summary
###################

sub summary {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = eval{$object->Summary;};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}




##############
## Driven by
##############

sub driven_by_promoter {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	eval{$data_pack = $object->$transg->Driven_by_CDS_promoter;};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub driven_by_genes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @genes = $object->Driven_by_gene;
	
	foreach my $gene (@genes) {
	
		my $public_name = $gene->Public_name;
		
		my %data_hash = (		
			'id' => "$gene",
			'label' => "$public_name",
			'Class' => 'Gene'
		);
	
		push @data_pack, \%data_hash;
	}
	
	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


#####################
## Reporter data
#####################

sub reporter_product {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;
	my $reporter;
	my $return;
	
	#### data pull and packaging
	
	my @reporters = $transg->Reporter_product;
    $reporter = join ('',@reporters) if (@reporters);
	
	if ($reporter =~ /GFP/) {
	
      $return = shift (@reporter);
    } elsif ($reporter =~ /LacZ/) {
    
      $return = shift (@reporter);
    } elsif ($reporter =~ /Other_reporter/) {
    
      $return = $transg->Other_reporter;
    }
    
	$data_pack = $reporter;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub c_elegans_gene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $gene = $object->Gene;
	my $gene_name = $gene->Public_name;
	
	$data_pack = {
	
		'id' =>"$gene",
		'label' =>"$gene_name",
		'Class' => 'Gene'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub c_elegans_sequence {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	my $sequence;
	eval {$sequence = $object->CDS;};

	$data_pack = {
	
		'id' =>"$sequence",
		'label' =>"$sequence",
		'Class' => 'CDS'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}




##################
## Isolation
##################

sub author {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Author;

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

sub fragment {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Fragment;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub injected_into_strain {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Injected_into_CGC_strain;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub injected_into {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Injected_into;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub integrated_by {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	my $other = $transg->Integrated_by;
	
    if ($other =~ /Other_integration_method/) {
	
		$data_pack = $object->Integrated_by->right;
	} else {
		
		$data_pack = {
						'id' => "$other",
						'label' => "$other",
						'class' => "Strain"
					};
	}

	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



###################
## Location
###################



###################
## Map
###################

sub map {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Map;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


###################
## Strain
###################

sub strain {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $strain = $object->Strain;
	
	$data_pack = {
	
		'id' => "$strain",
		'label' => "$strain",
		'Class' => 'Strain'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

###################
## Mapping data
###################

sub two_point_map {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	@data_pack = map {my $genotype = $_->Genotype;
						 "$genotype"
						} $transg->get('2_point');

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub multi_point_map { 

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	@data_pack = map {
                        my $genotype = $_->Genotype;
						 "$genotype"
						} $transg->Multi_point;
						
	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}



###################
## Phenotype
###################

sub phenotype_nots {

	my $self = shift;
    my $transg = $self->object;
	my %data;
	my $desc = 'experiments where phenotype was not observed with transgene';

	my $data_pack = $self->_get_phenotype_data($transg, 1);
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub phenotypes {

	my $self = shift;
    my $transg = $self->object;
	my %data;
	my $desc = 'experiments where phenotype was observed with transgene';

	my $data_pack = $self->_get_phenotype_data($transg, 0);
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


######################
## Rescue
######################


sub rescue {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Rescue;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#####################
## Expression pattern
#####################


sub expr_pattern {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	my $expr_pattern;
	
	$expr_pattern = $object->Expr_pattern;
	
	$data_pack = {
								'id' => "$expr_pattern",
								'label' => "$expr_pattern",
								'class' => 'Expr_pattern'
								};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

####################
## Remark
#################### 

sub remark {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Remark;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


############
## Species
############

sub species {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	$species = $object->Species;
	$species_name = $species->Common_name;

	$data_pack = {
	
		'id' => "$species",
		'label' => "$species_name",
		'Class' => 'Species'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}



####################
# Internal methods
####################

sub _get_phenotype_data {

	my $self = shift;
    my $transg = shift;
    my $not = shift;

	my %data_pack;

	#### data pull and packaging

	my @phenotypes;
	my $tag;
	
	if ($not) {
	
		$tag = 'Phenotype_not_observed';
	}
	else {
	
		$tag = 'Phenotype';
	}
	
	foreach my $phenotype ($transg->$tag) {

		my $remark;
		my $phenotype_name;
		my $paper_evidence;
	
		$phenotype_name = $phenotype->Primary_name;
		$remark = $phenotype->get('Remark'); ## Remark
		# $paper_evidence = $phenotype->; ## at('Paper_evidence')
	
		$data_pack{$phenotype} = { 
									'link_data' => {
										'id' => "$phenotype",
										'label'=>"$phenotype_name",
										'Class' => "$tag"
									},
									
									'remark'=>$remark,
									'paper_evidence'=>$paper_evidence
									};
	}
	
	return \%data_pack;
}

###############
## Superceded
###############


sub isolation {

	my $self = shift;
    my $transg = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $author;
	my $clone;
	my $fragment;
	my $injected_into_cgc_strain;
	my $injected_into;
	my $integrated_by;
	my $int_by_check;
	my $other;
	
	$author = $transg->Author;
	$clone = $transg->Clone;
	eval{$fragment = transg->Fragment;};
	$injected_into_cgc_strain = $transg->Injected_into_CGC_strain;
	$injected_into = $transg->Injected_into;
	$other= $transg->Integrated_by;
	
    if ($other =~ /Other_integration_method/) {
    
    	$integrated_by = $transg->Integrated_by->right;
	} 	
	else {
	
		$integrated_by = $transg->Integrated_by;
	}

	%data_pack = (
					'Author' 	=> $author,
					'Clone' 	=> $clone,
					'Fragment'  => $fragment,
					'Injected_into_CGC_strain' => $injected_into_cgc_strain,
					'Injected_into' => $injected_into,
					'Integrated_by' => $integrated_by
				);	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub details {

	my $self = shift;
    my $transg = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $transgene_evidence;
	my $summary;
	my $driven_by;
	my $transgene_driven_by;
	my $driven_by_gene;
	my @reporter_products;
	my $gene;
	my $cds;
	my $remark;
	my $species;
	my $rescue;
	
	eval{$transgene_evidence = $transg->Evidence;};
	eval{$summary = $transg->Summary;};
	$driven_by = $transg->Driven_by_gene;
	eval{$transgene_driven_by = $transg->Driven_by_CDS_promoter;};
	$transg->Driven_by_gene;
	@reporter_products = $transg->Reporter_product;
	$gene = $transg->Gene;
	eval{$cds = $transg->CDS;};
	$remark = $transg->Remark;
	$species = $transg->Species;
	$rescue = $transg->Rescue;
	
	%data_pack = (
					'ace_id' => $transg,
					'summary' => $summary,
					'driven_by' => $driven_by,
					'transgene_driven_by' => $transgene_driven_by,
					'driven_by_gene' => $driven_by_gene,
					'reporter_products' => \@reporter_products,
					'gene' => {
								'gene_id' => $gene,
								'class' => 'Gene'
								},
					'cds' =>{
							 'cds_id' => $cds,
							 'class' => 'CDS'
							},
					'remark'=>$remark,
					'species'=>$species,
					'rescue'=>$rescue
					
					);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub phenotypes_old {

	my $self = shift;
    my $transg = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @phenotypes;
	@phenotypes = $transg->Phenotype;
	
	foreach my $phenotype (@phenotypes) {

		my $remark;
		my $not;
		my $phenotype_name;
		my $paper_evidence;
	
		$phenotype_name = $phenotype->Phenotype_name;
		$remark = $phenotype->get('Remark');
		$not = $phenotype->at('Not');
		$paper_evidence = $phenotype->at('Paper_evidence');
	
		$data_pack{$phenotype} = (
									'phenotype_name'=>$phenotype_name,
									'remark'=>$remark,
									'not'=>$not,
									'paper_evidence'=>$paper_evidence
									);
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



1;