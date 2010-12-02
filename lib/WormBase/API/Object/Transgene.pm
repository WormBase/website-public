package WormBase::API::Object::Transgene;
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


sub expr_pattern {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	my $expr_pattern;
	
	$expr_pattern = $object->Expr_pattern;
	
	$data_pack{$expr_pattern} = {
								'ace_id' => $expr_pattern,
								'class' => 'Expr_pattern'
								};

	####
	
	$data{'data'} = \%data_pack;
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
									'phenotype_name'=>$phenotype_name,
									'remark'=>$remark,
									'paper_evidence'=>$paper_evidence
									};
	}
	
	return \%data_pack;
}




1;