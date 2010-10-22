package WormBase::API::Object::RNAi;
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


################
## IDENTIFICATION
################

sub identification {

	my $self = shift;
    my $exp = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $targets_hr;
	my $history_name;
	my @genes;
	my %targets;	
	my @reagents;
	my $sequence;
	my $assay;
	
	$targets_hr = _classify_targets($exp);
	#$history_name = $exp->History_name || $exp;
	@reagents = $exp->PCR_product;
	$sequence = $exp->Sequence_info->right	;
	$assay = ($exp->PCR_product) ? 'PCR product' : 'Sequence';

	foreach my $target_type ('Primary targets','Secondary targets') {

		@genes = eval { @{$targets_hr->{$target_type}}};
		$targets{$target_type} = \@genes;
  	}

	%data_pack = (
					'ace_id' => $exp,
					'class'  => 'RNAi',
					'targets' => \%targets,
					'reagents' => \@reagents,
					'sequence' => $sequence,
					'assay' => $assay
				);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

## development notes

sub history_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->History_name || $object;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



################
## SOURCE
################

sub remarks {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	@data_pack = $object->Remark;

	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#### test

sub laboratories {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	@data_pack = $object->Laboratory;

	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub laboratory_details {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	#	my $exp = shift;
	#  	my ($experiment_link,$experiment_url,$link_location);
	#  	# experiment URL also used to construct links to movies
	#  	my $history_name = $exp->History_name;
	#  	if ($exp->Laboratory eq 'KK' || $exp->Laboratory eq 'PF') {
	#    
	#    	($experiment_link = $history_name) =~ s/^KK://;
	#    	$experiment_url = Configuration->Rnaidb.$experiment_link;
	#    	$experiment_link = a({-href=>$experiment_url},$history_name);
	#    	$link_location = a({-href=>'http://www.rnai.org/'},'RNAiDB');
	#  	} elsif ($exp->Laboratory eq 'TH'){
	#    
	#    	# Links to PhenoBank are stored as remarks
	#    	my @remark = map {escapeHTML($_)} $exp->Remark;
	#    	($experiment_link) = "[" 
	#      	. join('; ',map { a({-href=>$_},/GeneID=(.*)&/) } grep { /phenobank/ } @remark) . ']';
	#    	$link_location = a({-href=>Configuration->Phenobank},'PhenoBank');
	#  	}
	#
	#  	my @remark = map {escapeHTML($_)} $exp->Remark;
	#  	@remark = grep { !/phenobank/ } @remark;
	#
	#  	SubSection('Laboratory',map { ObjectLink($_) } $exp->Laboratory);
	#
	#  	SubSection("Further details available at $link_location",$experiment_link);
	#
	#  	if (my @refs = $exp->Reference) {
	#    
	#    	SubSection('Reference',format_references(-references=>\@refs,-format=>'long',-pubmed_link=>'image',
	#				     -suppress_years=>1));
	#  	} else {
	#  	
	#    	my $author = join(' ',map { ObjectLink($_) } $exp->Author);
	#    
	#    	SubSection('Authors',$author);
	#    	my $date = $exp->Date;
	#    	$date =~ s/ 00:00:00$//;
	#    
	#    	SubSection('Publication date',$date);
	#  }
	#  
	#  SubSection('Remarks',@remark);
	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



################
## EXPERIMENTAL CONDITIONS
################

#sub experimental_conditions {
#
#	my $self = shift;
#    my $exp = $self->object;
#	my %data;
#	my $desc = 'notes';
#	my %data_pack;
#
#	#### data pull and packaging
#
#	my $species = $exp->Species;
#	my $genotype = $exp->Genotype;
#	my $strain = $exp->Strain;
#	my $treatment = $exp->Treatment;
#	my $life_stage = $exp->Life_stage;
#	my $delivered_by = $exp->Delivered_by;
#	
#	my $interaction = $exp->Interaction;
#	my $interactor = eval{$interaction->Interactor;};
#	
#	%data_pack = (
#					'species' => $species,
#					'genotype' => $genotype,
#					'strain' => $strain,
#					'treatment' => $treatment,
#					'life_stage' => $life_stage,
#					'delivered_by' => $delivered_by,
#					'interaction' => $interaction,
#					'interactor' => $interactor
#					);
#	####
#
#	$data{'data'} = \%data_pack;
#	$data{'description'} = $desc;
#	return \%data;
#}


###############
## PHENOTYPES
###############

sub phenotypes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @phenotypes = $object->Phenotype;

	foreach my $phenotype (@phenotypes) {
		
		my $phenotype_name = $phenotype->Primary_name;
		
		$data_pack{$phenotype} = {
									'phenotype_id' => $phenotype,
									'class' => 'Phenotype',
									'phenotype_name' => $phenotype_name,
								};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype_nots {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @phenotypes = $object->Phenotype_not_observed;

	foreach my $phenotype (@phenotypes) {
		
		my $phenotype_name = $phenotype->Primary_name;
		
		$data_pack{$phenotype} = {
									'phenotype_id' => $phenotype,
									'class' => 'Phenotype',
									'phenotype_name' => $phenotype_name,
								};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



###############
## MOVIES AND IMAGES
###############

sub movies {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	## work with XS to get precise details of data needed for images

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


###############
## GENOMIC ENVIRONS
###############


sub genomic_environs {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	## work with XS to get precise details of data needed for images

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



###############
## NOTES
###############

sub display_notes{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = 'Primary targets

	Primary targets have sequence identity to the RNAi probe of at least
	95% over a stretch of at least 100 nucleotides, identified using a
	combination of BLAST and BLAT algorithms.  These are usually the
	intended target genes of an RNAi experiment.
	
	Secondary targets
	
	Secondary targets have between 80 and 94.99% sequence identity over a
	stretch of at least 200 nucleotides to the RNAi probe. Targets (and
	overlapping genes) that satisfy these criteria may or may not be
	susceptible to an RNAi effect with the given probe and represent
	secondary (unintended) genomic targets of an RNAi experiment.';

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}
###############
## INTERNAL
###############

sub _classify_targets {

  	my $exp = shift;
  	my %seen;
  	my %categories;
	my @genes = grep { !$seen{$_->Molecular_name}++ } $exp->Gene;
  
  	push (@genes,grep {!$seen{$_}++} $exp->Predicted_gene);

  	foreach my $gene (@genes) {
  	
    	my @types = $gene->col;
    
    	foreach (@types) {
    
			my ($remark) = $_->col;
			my $status = ($remark =~ /primary/) ? 'Primary targets' : 'Secondary targets';
			push @{$categories{$status}},$gene;
    	}
  	}

	return \%categories;
}


1;