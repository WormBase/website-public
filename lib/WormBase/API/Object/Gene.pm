package WormBase::API::Object::Gene;
use Moose;

with    'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

#### passed test #####
# common_name 
# ids
# concise_description
# kogs 
# anatomic_expression_patterns 
# transgenes
# matching_cdnas
# sage_tags
# paralogs
# treefam
# rearrangements
# history
# gene_ontology
# interactions 
# other_sequences
# orthologs
# cds
# microarray_expression_data
# inparanoid_groups


#### rebuilt methods  trouble shooting #####

# genomic_position - need _fetch_sequences
# strains
# proteins
# cloned_by
# orfeome_project_primers
# microarray_topology_map_position


### on going 
# snps 
# alleles


### to do ### 

### from id


### from location
# genetic_position

### from Function
# sites_of_action
# expression_cluster
# expression

## GO

## Genetics
# reference_allele

## Homology
# similarities

## Reagents

### complex transform
# gene_models *
# protein_domains*
# rnai_phenotypes *

### for implementation in view
# fourd_expression_movies 
# anatomic_expression_patterns


#####################

### configuration items

my $version = 'WS215';	
#my $version = $self->ace_dsn->dbh->version;


our $interaction_data_dir = "/usr/local/wormbase/databases/$version/interaction";
our $datafile = $interaction_data_dir."/compiled_interaction_data.txt";
our $gene_pheno_datadir = "/usr/local/wormbase/databases/$version/gene";
our $rnai_details_file = "rnai_data.txt";
our $gene_rnai_phene_file = "gene_rnai_pheno.txt";
our $gene_variation_phene_file = "variation_data.txt";
our $phenotype_name_file = "phenotype_id2name.txt";
our $gene_xgene_phene_file = "gene_xgene_pheno.txt";


#####################
##### template ######




sub template {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#### end template #####


#######################################################
# The Overview (formerly Identification) Panel
#######################################################

# do we need public_name?  We already have name with label -AC
sub public_name {
    
	my ($self,$object,$class) = @_;
    my $common_name;    
   
    if ($class =~ /gene/i) {
		$common_name = 
		$object->Public_name
		|| $object->CGC_name
		|| $object->Molecular_name
		|| eval { $object->Corresponding_CDS->Corresponding_protein }
		|| $object;
    }
    elsif ($class =~ /protein/i) { #do we need this here?  This is the gene class... AC
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

sub name {
	
    my $self = shift;
    my $object = $self->object;
    my $cm_text = "$object";
    my $common_name = 
	$object->Public_name
	|| $object->CGC_name
	|| $object->Molecular_name
	|| eval { $object->Corresponding_CDS->Corresponding_protein }
    || $cm_text;
    

    my $data = { description => 'The most commonly used name of the gene',
		 data        =>  { id    => "$object",
				           label => "$common_name",
				           class => $object->class
		 },
    };
    return $data;
}


# A lot of stuff is repeated in here.  Like, from other methods. Do we need that? -AC
sub ids {
    my $self   = shift;
    my $object = $self->object; ## shift
    
    my %data;
     
    # Fetch external database IDs for the gene
    my ($aceview,$refseq) = $self->_fetch_database_ids($object);

    my $version = $object->Version;
    my $locus   = $object->CGC_name;
    my $common  = $object->Public_name;
    
    
    my @other_names = $object->Other_name;
    my $sequence = $object->Sequence_name;
    
    my $sequence_ret = { id => "$sequence", label => "$sequence", class=>"sequence"};
   
    my $object_data = {
    
		common_name   => "$common",
		locus_name    => "$locus",
		version       => "$version",
		aceview_id    => "$aceview",
		refseq_id     => $refseq,
		other_names	  => \@other_names,
		sequence_name => $sequence_ret

	};	

	$data{'data'} = $object_data; 
	$data{'description'} = "ID data for gene $object";

    return \%data;
    
}

sub description{
  return shift->concise_description;
}

sub concise_description {
    my $self   = shift;
    my $object = $self->object;  
    my %data;
    
    # The description, dervied from the Gene, the CDS, or the Gene_class.
    my $description = 
	$object->Concise_description
	|| eval {$object->Corresponding_CDS->Concise_description}
    || eval { $object->Gene_class->Description };
    
    # No description? Just describe it by its common name
    unless ($description) {
	$description = $self->name->{data}->{label} . ' gene';
    }

    $data{'description'} = "A manually curated description of the gene's function";
    $data{'data'} = $description;
    return \%data;
}


# Fetch all proteins associated with a gene.
## NB: figure out the naming convention for proteins

sub proteins {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'proteins related to gene';

	my %data_pack;

	#### data pull and packaging

		my @cds    = $object->Corresponding_CDS;
		my @proteins  = map { $_->Corresponding_protein } @cds if @cds;
		
		foreach my $protein (@proteins){
			
			my $public_name = $self->public_name($protein, $protein->class);
			$data_pack{$protein} = {
									'class' => 'Protein',
									'label' => $public_name,
                                                                        'id' => "$protein"
									};

									
									
		}
		
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


# Fetch all CDSs associated with a gene.
## figure out naming convention for CDs

sub cds {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'cds related to the gene';

	#### data pull and packaging
	
	my @cds = $object->Corresponding_CDS;
	my $data_pack = $self->basic_package(\@cds);
	
	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}



# Fetch Homology Group Objects for this gene.
# Each is associated with a protein and we should probably
# retain that relationship

sub kogs {
    my $self     = shift;
    my $object   = $self->object;
    my @cds    = $object->Corresponding_CDS;
    my %data;
    my %data_pack;
    
    if (@cds) {
	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds;
	if (@proteins) {
	    my %seen;
	    my @kogs = grep {$_->Group_type ne 'InParanoid_group' } grep {!$seen{$_}++} 
	         map {$_->Homology_group} @proteins;
	    if (@kogs) {
	    	
	    	$data_pack{$object} = \@kogs;
			$data{'data'} = \%data_pack;

	    } else { 
	    
	    	$data_pack{$object} = 1;
	    
	    }
	}
    } else {
		$data_pack{$object} = 1;	
    }
    
    $data{'description'} = "KOGs related to gene";
 	return \%data;
}

# should we return entire sequence obj or just linking/description info? -AC
sub other_sequences {
	my $self = shift;
    my $object = $self->object;
	my @seqs = map {$self->wrap($_)} $object->Other_sequence;
    my $data = { description => 'Other sequences associated with gene',
                 data        => \@seqs
    };
	return $data;
}

sub cloned_by {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'Personnel who cloned gene';

	my %data_pack;

	#### data pull and packaging
	
	my $cloned_by;
	my $source;
	my $name;	
	my $tag;	

	eval{$cloned_by = $object->Cloned_by;};	
	eval{($tag,$source) = $cloned_by->row ;};    
   eval{$name = $cloned_by->Full_name;};
   
    %data_pack  = {'cloned_by' => $cloned_by,
		 'full_name' => $name,
		 'tag'       => $tag,
		 'source'    => $source	    
    };	

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}
# 
# sub history {
# 
# 	my $self = shift;
#     my $object = $self->object;
# 	my %data;
# 	my $desc = 'Information on the history of the gene';
# 
# 	my %data_pack;
# 
# 	#### data pull and packaging
# 
# 	my @history = $object->History;
# 
#     # Present each history event as a separate item in the data struct
#     my $data = {};
#     foreach my $history (@history) {
# 	my $type = $history;
# 	$type =~ s/_ / /g;	
# 
# 	my @versions = $history->col;
# 		foreach my $version (@versions) {
# 				#  next unless $history eq 'Version_change';    # View Logic
# 			my ($vers,$date,$curator,$event,$action,$remark,$gene,$person);	    
# 			if ($history eq 'Version_change') {
# 			($vers,$date,$curator,$event,$action,$remark) = $version->row; 
# 			
# 				# For some cases, the remark is actually a gene object
# 				if ($action eq 'Merged_into' || $action eq 'Acquires_merge'
# 					|| $action eq 'Split_from' || $action eq 'Split_into') {
# 						$gene = $remark;
# 						$remark = undef;
# 				}
# 			} 
# 			else 
# 			{
# 					($gene) = $version->row;
# 			}	    
# 			my $cu;
# 			if($curator){
# 				$cu->{id} = "$curator";
# 				$cu->{label} = $curator->Standard_name || $curator->Full_name;
#                                 $cu->{class} = $curator->class;
# 			}
# 			my $ge;
# 			if($gene){
# 				$ge->{id} = "$gene";
# 				$ge->{label} = $gene->Public_name;
#                                 $ge->{class} = $gene->class;
# 			}
# 			$data_pack{$history}{$version} =
# 											{ type    => $type,
# 											  date    => $date,
# 											  action  => $action,
# 											  remark  => $remark,
# 											  gene	  => $ge,
# 											  curator => $cu,
# 											};
# 		}
#     }
# 
# 
# 	####
# 
# 	$data{'data'} = \%data_pack;
# 	$data{'description'} = $desc;
# 	return \%data;
# }


# Object History.  This should be suitably generic and moved to Object.pm


###########################################
# Components of the Location panel
# Note: Most of these are generic and located
# in the Model.pm
###########################################

sub genomic_position {
    my $self      = shift;
    my $object    = $self->object;
    my $sequences = $self->_fetch_sequences();
    
    my %data;
    my %data_pack;
   
    
	if(@$sequences) {
	
		my @segments = $self->_fetch_segments($sequences);
		
		# per TH: This is a kludge to handle situations where I've fetched an Ace object
    	# corresponding to a Locus that has a CDS but no corresponding GFF segment. (rds-2)
    	
    	my $longest = $self->_longest_segment(\@segments);
    	$data_pack{$longest} = $self->SUPER::genomic_position($longest);
	}
	
    else {
    
    }
    
  	$data{'description'} = 'genomic position for gene';
  	$data{'data'} = \%data_pack;
  	
    return \%data;
}


sub genetic_position {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging

	my ($link_group,undef,$position,undef,$error) = eval{$object->Map(1)->row};

	%data_pack = (
					'link_group'=>$link_group,
					'position' => $position,
					'error'=>$error
					);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}
###########################################
# Components of the Function panel
###########################################

# This has some rather complicated markup.
# Pre-process here before hitting the template
# (This could also be a function for the template)
sub pre_wormbase_information {
    my $self   = shift;
    my $object = $self->object;
    
    # Description comes from Phenotype.
    my @description = $object->Phenotype or return;
    
    my @xref = $object->Allele;
    push @xref,$object->Strain;

    my $data = $self->build_data_structure(\@description,
					   'information from C. elegans I/II');
    return $data;
}


sub microarray_expression_data {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'gene expression determined via microarray analysis';

	my $data_pack;

	#### data pull and packaging
	my @microarray_results = $object->Microarray_results;	
	$data_pack = $self->basic_package(\@microarray_results, 'Microarray_results');

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub microarray_topology_map_position {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';

	my %data_pack;

	#### data pull and packaging

	my $sequences = $self->_fetch_sequences();
    my @segments = $self->_fetch_segments($sequences);
    my $seg = $segments[0];
    my @features;
    
   	@features = eval {map {$_->info} $seg->features('experimental_result_region:Expr_profile');};

	foreach my $feature (@features) {
	
		$data_pack{$feature} = 1;
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub expression_cluster {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging

	my @expr_clusters = $object->Expression_cluster;
	
	foreach my $ec (@expr_clusters) {
	
		$data_pack{$ec} = {
							'class' => 'Expression_cluster',
							'name' => $ec
		
							};
	
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub anatomy_function {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging

	my @anatomy_fns = $object->Anatomy_function;
	
	foreach my $af (@anatomy_fns) {

    	my $afn_phenotype = $af->Phenotype;
	    my $phenotype_prime_name = $afn_phenotype->Primary_name;
	
		$data_pack{$af} = (
							'ace_id' => $af,
							'class' => 'Anatomy_function',
							'phenotype_id' => $afn_phenotype,
							'phenotype_name' => $phenotype_prime_name
		);
	
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging
	
	my ($details,$phenotype_data) = _get_phenotype_data($object, 1);  
	my $variation_data = _get_variation_data($object, 1); 
	my $phenotype_names_hr  = _get_phenotype_names($phenotype_data,$variation_data);

	foreach my $pheno_id (keys %$phenotype_names_hr) {
	
		$data_pack{$pheno_id} = {
									'phenotype' => $phenotype_names_hr->{$pheno_id},
									'class' => 'Phenotype'
									};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



# Gene regulation
sub regulation_on_expression_level {
    my $self   = shift;
    my $object = $self->object;
    return unless ($object->Gene_regulation);
    
    my @stash;

    # Explore the relationship in both directions.
    foreach my $tag (qw/Trans_regulator Trans_target/) {
	my $join = ($tag eq 'Trans_regulator') ? 'regulated by' : 'regulates';
	if (my @gene_reg = $object->$tag(-filled=>1)) {
	    foreach my $gene_reg (@gene_reg) {
		my ($string,$target);
		if ($tag eq 'Trans_regulator') {
		    $target = $gene_reg->Trans_regulated_gene(-filled=>1)
			|| $gene_reg->Trans_regulated_seq(-filled=>1)
			|| $gene_reg->Other_regulated(-filled=>1);
		} else {
		    $target = $gene_reg->Trans_regulator_gene(-filled=>1)
			|| $gene_reg->Trans_regulator_seq(-filled=>1)
			|| $gene_reg->Other_regulator(-filled=>1);
		}
		# What is the nature of the regulation?
		# If Positive_regulate and Negative_regulate are present
		# in the same gene object, then it means the localization is changed.  Go figure.
		if ($gene_reg->Positive_regulate && $gene_reg->Negative_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Changes localization of '
			: 'Localization changed by ';
		} elsif ($gene_reg->Result eq 'Does_not_regulate') {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Does not regulate '
			: 'Not regulated by ';
		} elsif ($gene_reg->Positive_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Positively regulates '
			: 'Positively regulated by ';
		} elsif ($gene_reg->Negative_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Negatively regulates '
			: 'Negatively regulated by ';
		}
		
		my $common_name     = $self->common_name($target) || $target;
		push @stash,{ string => $string,
			      target => $common_name,
			      gene_regulation => $gene_reg};
	    }
	}
    }
    return \@stash;
}


sub interactions {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my %data_pack;
	my $desc = "interactions gene is involved in";

	#### data pull and packaging
	
	my $gene_data_lines = `grep $object $datafile`;
	my @gene_data_lines = split /\n/,$gene_data_lines;
	
	my @interaction_data;
	foreach my $dataline (@gene_data_lines){
		
		chomp $dataline;
		my @dataline_set = split /\|/,$dataline;
		push @interaction_data,$dataline_set[0];
	}

	#my $data_pack = $self->basic_package(\a);

	foreach my $interaction_name (@interaction_data) {
	
			$data_pack{$interaction_name} = {
														'class' => 'Interaction',
														'common_name' => $interaction_name
			
														} 
	
	
	}


	###############################

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}


#sub print_gene_interaction_data {
#
#	my ($data,$gene_id) = @_;
#	my $gene_data_lines = `grep $gene_id $data`;
#	my @gene_data_lines = split /\n/,$gene_data_lines;
#	
#	my @interaction_data;
#	foreach my $dataline (@gene_data_lines){
#		
#		chomp $dataline;
#		#print "$dataline\n";
#		my @dataline_set = split /\|/,$dataline;
#		#print "$dataline_set[0]\n";
#		push @interaction_data,$dataline_set[0];
#	}
#
#
#	my @first_ten = @interaction_data[0 .. 9];
#	# print "@first_ten\n";
#
#	my $interaction_count = @interaction_data;  # 
#	if (@interaction_data ) { ## && ($interaction_count > 10)
#		my @truncated_interactions_list = @interaction_data[0 .. 9];
#		my $last_int_index = $interaction_count - 1;
#		my @rest_of_interactions = @interaction_data[10 .. $last_int_index];
#		
#		# SubSection("Interactions",	hr,"@truncated_interactions_list",hr);
#		my $rest_of_interactions = @rest_of_interactions;
#		my $interaction_list_url = "/db/gene/interaction?list=".$gene_id;
#		SubSection("Interactions","There are(is) ".$interaction_count." ".a({-href=>$interaction_list_url},"interaction(s)")." in which this gene is involved. ",hr);
#	}
#	else{
#		SubSection("Interactions","@interaction_data",hr);	
#	}
#}



###########################################
# Components of the Gene Ontology panel
###########################################

sub gene_ontology {

    my $self = shift;
    my $object = $self->object; 
    my %data;
    my %data_pack;
	my $desc = 'gene ontology terms to which gene is annotated';
	
	## get go terms for the gene

	my @go_terms = $object->GO_term;
	
	## get term details
	
	foreach my $go_term (@go_terms){
			
		$data_pack{$go_term}{'term'} = $go_term->Term;
		$data_pack{$go_term}{'term_type'} = $go_term->Type;
		$data_pack{$go_term}{'class'} = $go_term->class;
		
		my %evidence;
		
	  	foreach my $code ($go_term->col){
		
			my ($evidence_code,$method,$detail) = $code->row;		
			$evidence{$evidence_code}{'method'} = $method;
			$evidence{$evidence_code}{'detail'} = $detail;
			
	  	}
	  	
	  	$data_pack{'evidence'} = \%evidence;
	}
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	
	return \%data;	
}


###########################################
# Components of the Alleles panel
###########################################
# This could be generic. See also Variation.


sub alleles {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'alleles for gene';

	my $dbh = $self->ace_dsn->dbh;
	
	my %data_pack;

	#### get alleles
	## NB: datapull for classic page includes this map line: map 
    ## my @all_alleles = map {$dbh->fetch(Variation => $_) } @alleles;

    my @all_alleles = $object->Allele; 

    foreach my $allele (@all_alleles) {
    	if ($allele->CGC_name) {
    		my $available_seq = 0;
    		
    			if($allele->Flanking_sequence) {
    				$available_seq = 1;
    			} 
				
				my $class = $allele->class;
				
    			$data_pack{$allele} = {
    									'available_seq' => $available_seq,
    									'class' => $class
    									}	
    	}

	
	}
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub snps {

	my $self = shift;
	
    my $object = $self->object;
    
	my %data;
	my $desc = 'snps related to gene';

	my %data_pack;

	#### data pull and packaging
	
	


	####
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub strains {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'strains carrying gene';

	my %data_pack;

	#### data pull and packaging

	## from gene ##
	
	  my (@singletons,@cgc,@others);
	  
	  foreach my $strain ($object->Strain(-filled=>1)) {
		my @genes = $strain->Gene;
		my $cgc  = ($strain->Location eq 'CGC') ? 1 : 0;
		my $gene_alone = 0;
		my $cgc_available = 0;
		
		
		if (@genes == 1 && !$strain->Transgene) {
			
			$gene_alone = 1;
		}
		
		if ($cgc) {
			
			$cgc_available = 1;
		}
		
		if ($gene_alone || $cgc_available) {
		
			$data{'data'}{$strain} = {'class' => 'Strain',
	  												'gene_alone' => $gene_alone,
	  												'cgc_available' => $cgc_available
	  											};
		}
		else {
			
			$data{'data'}{$strain} = {'class' => 'Strain',
	  												'gene_alone' => 0,
	  												'cgc_available' => 0
	  											};
		}		
	  }
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub rearrangements{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'rearrangements involving this gene';

	my %data_pack;
	my $rearrangement = 0;

	#### data pull and packaging

	if ($object->Allele || $object->Reference_allele) {
	
		$rearrangement = 1;
	}

	%data_pack = {
					$object => {
					
								'rearrangement' => $rearrangement
								}
	
				};

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

###########################################
# Components of the Homology panel
###########################################

sub inparanoid_groups {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'homology groups for this gene determined via inparanoid method';

	my %data_pack;

	#### data pull and packaging
	
	my $proteins;

    eval{$proteins = $self->_fetch_proteins($object);};
    my %seen;
    my @inp = grep {!$seen{$_}++ } grep {$_->Group_type eq 'InParanoid_group' }
    map {$_->Homology_group} @$proteins;
    
    foreach my $cluster (@inp) {
    
		my @proteins = $cluster->Protein;
		my %proteins;
		foreach my $protein (@proteins) {
		
	   		my $species = $protein->Species || $self->id2species($protein) || 'unknown';
	   		my $common_name = public_name($protein,'Protein');
	   		$proteins{'proteins'} = {
	   								'class' => 'Protein',
	   								'common_name' => $common_name,
	   								'species' => $species
	   								};
	   								
			$data_pack{$cluster} = {
								'class' => 'Homology_group',
								'common_name' => $cluster,
								'proteins' => \%proteins
								};
	}
		
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}
}	



sub paralogs {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'This genes paralogs';

	my %data_pack;

	#### data pull and packaging
	
	my @paralogs = $object->Paralog;
	
	foreach my $paralog (@paralogs) {
	
			## upgrade code to get protein common name
			
			my $common_name = $object->Name; ##public_name($paralog,'Protein')
			$data_pack{$paralog} = {
									'common_name' => $common_name,
									'class' => 'Protein'
									};
	
	}
	
	#### end data pull ###

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub orthologs {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'this genes orthologs';
				
	#### data pull and packaging

	my @orthologs = $object->Ortholog;
	my $data_pack = $self->basic_package(\@orthologs);

	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub treefam {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'data associated with gene for rendering treefam data';

	my %data_pack;

	#### data pull and packaging
	
	my $proteins = $self->_fetch_proteins($object);

    foreach my $protein (@$proteins) {
		my $treefam = $self->_fetch_protein_ids($protein,'treefam');
	
		# Ignore proteins that lack a Treefam ID
		next unless $treefam;
		my $id = $object->Sequence_name || $treefam;
		
		$data_pack{$protein} = {
								'treefam_id' => $id
								};
	}
	## end classic code ##
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}




###########################################
# Components of the Similarities panel
###########################################
sub best_blastp_matches {
    my $self     = shift;
    my $object = $self->object;
    my $proteins = $self->_fetch_proteins($object);
    return [ $self->SUPER::best_blastp_matches($proteins) ];
}



###########################################
# Components of the Reagents panel
###########################################
sub transgenes {
    my $self       = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    
    
    my @transgenes = $object->Drives_Transgene;
    
    foreach my $transgene (@transgenes) {
    	$data_pack{$transgene} = {
    								'common_name' => $transgene,
    								'class' => 'Transgene'
    								};
    }
    
    my $desc = 'transgenes driven by this gene';
    
    $data{'description'} = $desc;
    $data{'data'} = \%data_pack;
    
    return \%data;
    
}

sub orfeome_project_primers {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{\'pack\'} = {
				}';

	my %data_pack;

	#### data pull and packaging
    my $sequences = $self->_fetch_sequences();
    
    my @segments = $self->_fetch_segments($sequences);
    
    foreach my $segment (@segments) {
    
    	my $class;
    	my $feature;
    	my $info;
   
   		eval{$class = $segment->Class;};
    	eval{$feature = $segment->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome');};
    	eval{$info = $feature->info;};
   
   		$data_pack{$segment} = {
   									'common_name' => public_name($segment,$class),
   									'class' => $class,
   									'info' => $info
   								};
    }
    
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub primer_pairs {
    my $self     = shift;
    my $object = $self->object;
    my $sequences = $self->_fetch_sequences();
    return unless @$sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    my @stash =  map {$_->info} map { $_->features('PCR_product:GenePair_STS','structural:PCR_product') } @segments;
    return \@stash if @stash;
}

sub microarray_probes {
    my $self     = shift;
    my $object = $self->object;
    my %seen;
    my @oligos = grep {!$seen{$_}++}
    grep {$_->Remark =~ /microarray\sprobe/}
    map {$_->Corresponding_oligo_set} $object->Corresponding_CDS if ($object->Corresponding_CDS);
    my @stash;
    foreach (@oligos) {
	my $comment = ($_->Remark =~ /GSC/) ? 'GSC' : 
	    ($_->Remark =~ /Agilent/ ? 'Agilent' : 'Affymetrix');
	push @stash,[$_,$comment];
    }
    return \@stash if @stash;
}

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    
    # Only include those that have been unambiguosly mapped.
    # (Actually, will safe this for the display layer)
    # my @stash = grep {$_->Unambiguously_mapped(0) || $_->Most_three_prime(0)} $object->SAGE_tag;
    my @tags = $object->SAGE_tag;

	foreach my $tag (@tags) {
	
		$data_pack{$tag} = {
							'common_name' => $tag,
							'class' => 'SAGE_tag'
							};
	}
    
    $data{'description'} = 'SAGE_tags for the gene';
    
    $data{'data'} = \%data_pack;
    
    
    return \%data;
}

# Return a list of matching cDNAs

sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    
    my %unique;
    my @mcdnas = grep {!$unique{$_}++} map {$_->Matching_cDNA} $object->Corresponding_CDS;
	
	foreach my $mcdna (@mcdnas) {
		
		$data_pack{$mcdna} = {
								'common_name' => $mcdna,
								'class' => 'Sequence'
								};
	}
	
	$data{'description'} = 'matching cDNAs for gene';

	$data{'data'} = \%data_pack;
	
	return \%data;
}

sub antibodies {
    my $self     = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
      
    foreach my $antibody ($object->Antibody) {
    
  	  	my $comment = $antibody->Summary;
    	$comment    =~ s/^(.{100}).+/$1.../ if length $comment > 100;
   		$data_pack{$antibody} = {
   									'class' => 'Antibody',
   									'comment' => $comment,
   									'common_name' => $antibody
   								};
   	}	
   	
   	$data{'description'} = '';
  	return \%data;
}
  
#### complex transformation ####

sub other_orthologs {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{\'pack\'} = {
				}';

	my %data_pack;

	#### data pull and packaging

	####
	
	## classic code ##
	
	## end classic code ##
	

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub protein_domains {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging
	my $proteins = $self->_fetch_proteins($object);
    
    for my $protein (@$proteins) {
    	my @motifs;
    	@motifs	= $protein->Motif_homol;
		foreach my $motif (@motifs) {
			
			$data_pack{$protein}{$motif} =  
								 			{
								 			'ace_id' => $motif
								  			,'class' => 'Motif'
								 			};
		}
	}
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub protein_domains_old {
    my $self     = shift;
    my $object = $self->object;
    return unless ($object->Gene_regulation);
    
    my $stash = {};
    
    # In order to associate each pfam id with a protein structure we need
    # a lookup table, which is loaded into memory at this step
    
    my %pfam2prot;
#  my $pfam2prot_table = Configuration->Wormbase . '/html/' . Configuration->Pfam_images_dir . '/pfam2prot_table';
    my $pfam2prot_table = '/pfam2prot_table';
    # THIS IS HARCODED!
    ##  open (PFAMTOPROT, "<$pfam2prot_table") or AceError("Cannot read pfam2prot table ($pfam2prot_table): $!");
    open(PFAMTOPROT,"<$pfam2prot_table");
    while (my $line = <PFAMTOPROT>) {
	chomp $line;
	my ($pfam_id, $pdb_id) = split("\t", $line);
	push @{$pfam2prot{$pfam_id}}, $pdb_id;
    }
    close PFAMTOPROT;
    
    # In this step, we load an index to memory to assign titles to structures
### THIS IS HARD_CODED!
    my %pdb_id_titles;
#  my $pdb_id_table = Configuration->Wormbase . '/html/' . Configuration->Pfam_images_dir . '/compound.idx';
    my $pdb_id_table = '/compound.idx';
    open (PDBIDS, "<$pdb_id_table"); #or AceError("Cannot read file ($pdb_id_table): $!");
    my $line;
    while ($line = <PDBIDS>) {
	chomp $line;
	my ($pdb_id, $title) = $line =~ /^([A-Z0-9]{4})\s+(.*)/;
	next unless $pdb_id;
	$pdb_id_titles{lc($pdb_id)} = $title;
    }
    close PDBIDS;
    
    # Generate a unique list of motifs instead
    my %motifs;
    
    my $proteins = $self->_fetch_proteins($object);
    
    for my $protein (@$proteins) {
	foreach my $motif ($protein->Motif_homol) {
	    
	    my ($tooltip_content,$balloon_tooltip);
	    unless (defined $motifs{$motif->Title}) {
		# Check if this is a PFAM motif, if so, select randomly an associated protein and make balloon content
		my $trimmed_motif = $motif;
		$trimmed_motif =~ s/^PFAM://;
		
		if ($motif =~ /^PF/ and $pfam2prot{$trimmed_motif}) {
		    my $random_idx = int(rand scalar(@{$pfam2prot{$trimmed_motif}}));
		    my $pdb_id = $pfam2prot{$trimmed_motif}[$random_idx];
		    my $pdb_id_image = Configuration->Pfam_images_dir . "/$pdb_id-image-thumbnail.png";
		    my $pdb_id_link  = sprintf(Configuration->Protein_links->{PFAM_WITH_PDB}, $trimmed_motif, $pdb_id);
		    my $pdb_id_title = $pdb_id_titles{$pdb_id} || '[Title not available]';
		    my $uc_pdb_id = uc($pdb_id);
		    
		    # This markup really belongs in the template
		    my $motif_title = $motif->Title;
		    $tooltip_content = qq[<table width=220 class="small">
                                     <tr>
                                       <td colspan="2"><b>$motif_title ($trimmed_motif)</b></a></td>
                                     </tr>
                                     <tr>
                                       <td colspan="2">Sample protein that contains this domain:</td>
                                     </tr>
                                     <tr>
                                       <td align="center">
                                         <img height=50 src="$pdb_id_image"/>
                                         <a href="$pdb_id_link" target="_blank">[Pfam]</a>
                                       </td>
                                       <td><b>$uc_pdb_id</b> $pdb_id_title</td>
                                     </tr>
                                   </table>
                                   ];
		    $tooltip_content = CGI::escape($tooltip_content);
		    
		    $balloon_tooltip =  ObjectLink($motif,'[more ...]');
		    $balloon_tooltip =~ s/\>/ onmouseover="balloon.showTooltip(event,'$tooltip_content', 1)">/;
#	  
#          $motif_link .= " $balloon_toolip";
		}
	    }
	    
	    # Group motifs by title
	    # We ONLY store start and stop for displaying protein motifs.  Probably unnecessary details
#      push @{$stash->{$motif->Title}},
#	{ protein => $protein,
#	  start   => $motif->right(3),
#	  stop    => $motif->right(4),
#	  balloon_tooltip => $balloon_tooltip,
#	};
	    push @{$stash->{$motif->Title}->{$motif}},$balloon_tooltip;
	}
    }
    return $stash;
}


#sub y1h_and_y2h_interactions {
#    my $self   = shift;
#    my $object = $self->object;
#    
#    # KLDUGE!   _y2h_data still needs $c. suckage.
#    my ($bait_lists,$target_lists) = $self->_y2h_data($object,3);  # Limit to three baits/targets TEMPLATE
#    
#    my @stash;
#    foreach my $entry (eval {@$bait_lists},eval {@$target_lists}) {
#	push @stash,[$object,$entry->[0],$entry->[1],eval {$entry->[1]->Author . ' (' . parse_year($entry->[1]->Year) . ')' }];
#    }
#    return \@stash;
#}


sub rnai_phenotypes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging
	
	my @rnai = $object->RNAi_result;    
    foreach my $rnai (@rnai) {
#    	print "\t$rnai\n";
		my @phenotypes = $rnai->Phenotype;
	
		foreach my $interaction ($rnai->Interaction) {
	    	my @types = $interaction->Interaction_type;
	    	foreach (@types) {
	   
			push @phenotypes,map { $_->right } grep { $_ eq 'Interaction_phenotype' } $_->col;
	    		}
		}
		#print "\t\t@phenotypes\n";
		foreach my $phenotype (@phenotypes) {
			my $not_attribute = $phenotype->right;
			my $na;
			my $phenotype_name = $phenotype->Primary_name; ### 'pn'
			if ($not_attribute =~ m/not/i){
			
				$na = $not_attribute;
			
			} else {
			
				$na = "";
			
			}
			
			#print "$object\|$rnai\|$phenotype\|$na\n";
	
		$data_pack{$rnai} = {
								'ace_id'=>$rnai,
								'phenotype'=>$phenotype,	
								'phenotype_name'=>$phenotype_name,
								'not_attribute'=>$na,		
								'class'=>'RNAi'
								};
		}	
	}


	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub variation_phenotypes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging
	
	my @variations = $object->Allele;
	foreach my $variation (@variations) {

		my $seq_status = $variation->SeqStatus;
		my $variation_name = $variation->Public_name;	
		my @phenotypes = $variation->Phenotype;
		
			foreach my $phenotype (@phenotypes) {
			    
			    my @attributes = $phenotype->col;
			    my $na = "";
			    my $phenotype_name = $phenotype->Primary_name;
			    foreach my $attribute (@attributes) {
			    
			    	if ($attribute =~ m/^not$/i){
    
				    	$na = $attribute;
  			  
			    	} else {
    					
				    next;
    
			    	}
			    }
			
			
			$data_pack{$variation} = {
										"ace_id"=>$variation,
										"phenotype"=>$phenotype,
										"not_attribute"=>$na,
										"seq_status"=>$seq_status,
										"variation_name"=>$variation_name,
										"phenotype_name"=>$phenotype_name,
										'class'=>'Variation'
										
									};
			}
	}




	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub transgene_phenotypes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging
	
	my %lines;
	
	my @xgenes = $object->Drives_Transgene;
	my @xgene_product = $object->Transgene_product;
	my @xgene_rescue = $object->Rescued_by_transgene;
	
	push @xgenes,@xgene_product;
	push @xgenes,@xgene_rescue;
	
    foreach my $xgene (@xgenes) {
    
		my @phenotypes = $xgene->Phenotype;
		foreach my $phenotype (@phenotypes) {
			my $not_attribute = $phenotype->right;
			my $phenotype_name = $phenotype->Primary_name;
			my $na;
			
			if ($not_attribute =~ m/not/i){
			
				$na = $not_attribute;
			} else {
			
				$na = "";
			}
			
			$lines{"$object\|$xgene\|$phenotype\|$na\|$phenotype_name"} = 1;
		}
	}

	foreach my $line (keys %lines) {

		my($gene,$xgene,$phenotype,$na,$phenotype_name) = split /\|/,$line;
		
		$data_pack{$xgene} = {
							
							'ace_id'=>$xgene,
							'class'=>'Transgene',
							'phenotype'=>$phenotype,
							'phenotype_name'=>$phenotype_name,
							'not_attribute'=>$na
						};
		
		
	}



	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub rnai_details {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';
				
	my %data_pack;

	#### data pull and packaging
	my %rnais;
	my @rnais  = $object->RNAi_result;   
	
	foreach my $rnai_id (@rnais) { ##keys %$rnai_phenotype_data_hr

		$rnais{$rnai_id} = $rnai_id;

	}
	
	foreach my $rnai_object (values %rnais) {
	
	#my $rnai_object = $DB->fetch(-class => 'RNAi', -name =>$unique_rnai); #, , -count => 20, -offset=>6800
	
	my $ref;
	$ref = eval{$rnai_object->Reference};
	my $genotype;
	my @experimental_details = eval{$rnai_object->Experiment};
	
	
	
	foreach my $experimental_detail (@experimental_details) {
			
		if($experimental_detail =~ m/Genotype/) {
		
			$genotype = $experimental_detail->right;
			# print "$rnai_object\|$genotype\|$ref\n";
			
			$data_pack{$rnai_object} = {
										'ace_id'=>$rnai_object,
										'class'=>'RNAi',
										'genotype'=>$genotype,
										'genotype_class'=>$experimental_detail,
										'reference'=>$ref
										};
			
			
			
		}
		
		if($experimental_detail =~ m/Strain/) {
		
			my $strain = $experimental_detail->right;
			$genotype = $strain->Genotype;
			#print "$rnai_object\|$genotype\|$ref\n";
			$data_pack{$rnai_object} = {
										'ace_id'=>$rnai_object,
										'class'=>'RNAi',
										'genotype'=>$genotype,
										'genotype_class'=>$experimental_detail,
										'reference'=>$ref
										};
		}	
	} 

	if(!($genotype)) {
		
		#print "$rnai_object\|$genotype\|$ref\n";
		$data_pack{$rnai_object} = {
										'ace_id'=>$rnai_object,
										'class'=>'RNAi',
										'genotype'=>$genotype,
										'genotype_class'=>"",
										'reference'=>$ref
										};
	
	
	} else {
	
		next;
	}
}


	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub rnai_phenotypes_old {
    my $self   = shift;
    my $object = $self->object;
    return unless $object->RNAi_result;
    
    my %stash = (common_name => $self->common_name($object));
    
    # Collate RNAi results according to
    # 1. its Evidence (primary or secondary)
    # 2. its Phenotype
    # 3. (Optional - could also collate by reference)
    
    my (%phenes,$total_experiments,%phenes2count,%phenes2total_count);
    my (@observed,@not_observed);
    my (%global_observed, %global_not_observed);
    
    foreach ($object->RNAi_result) {
	# Fetch the evidence string (RNAI_primary or secondary)
	my ($evidence) = $_->right(2);
	
	my ($author,$date,$target);
	# Preferentially draw author information from a reference
	if (my $reference = $_->Reference) {
	    $author = $reference->Author;
	    $date   = parse_year($reference->Year);
	    $target = $reference;
	} else {
	    $author = $_->Author;
	    $date   = $_->Date;
	    $date    =~ s/ 00:00:00$//;
	    $target = $_->Author;
	}
	
	# Create some lookup hashes so I can purge phenotypes that are NOT
	my @phenotypes = $_->Phenotype;
	
	# The aim of this horrible bit of code is to create an aggregated view of
	# phenotype associated with RNAi experiments.  It's scary.
	# TH: All of this logic belongs in the VIEW	
	my $data = $self->_parse_hash(\@phenotypes);
	my ($positives,$negatives) = $self->_is_NOT_phene($data);
	
	# The return value is actually a more complicated list.
	# For our purposes, we just need object names
	push @observed,map { $_->{node} } @$positives;
	push @not_observed,map { $_->{node} } @$negatives;
	
	%{$global_observed{$_}}     = map { $_->{node} => 1 } @$positives;
	%{$global_not_observed{$_}} = map { $_->{node} => 1} @$negatives;
	
	foreach my $phenotype (@phenotypes) {
	    
	    push @{$phenes{$evidence}->{$phenotype}->{$_}},"$target - $author $date";
	    $phenes2count{$evidence}{$phenotype}++ if $global_observed{$_}{$phenotype};
	    $phenes2total_count{$phenotype}++;
	}
	$total_experiments++;
    }
    
    if (%phenes) {
	my %observed     = map { $_ => 1 } @observed;
	# To be in the "not observed" category it should never have been observed across all
	# experiments, not just one
	my %not_observed = map { $_ => $_ } grep { !$observed{$_} } @not_observed;
	
	foreach my $evidence (qw/RNAi_primary RNAi_secondary/) {
	    if ($evidence eq 'RNAi_primary') {
		next unless (defined $phenes{$evidence});
	    }
	    
	    # Suppress the secondary display altogether since it's rare
	    if ($evidence eq 'RNAi_secondary') {
		# Do nothing
		next unless (defined $phenes{$evidence});
	    }
	    
	    my $display_footnotes;
	    foreach my $phene (sort { $phenes2count{$evidence}{$b}
				      <=> $phenes2count{$evidence}{$a}
			       } keys %{$phenes2count{$evidence}}) {
		next if $not_observed{$phene};  # Display those that were scored but not observed later
		
		# How many experiments scored this assigned this phenotype?
		# This should really link to a popup window that collates all of this information together
		
		my @experiments = keys %{$phenes{$evidence}->{$phene}};	  
		# ... and from which references?
		my (%references,%reagents,$reagents_specific,$reagents_nonspecific);
		foreach my $experiment  (@experiments) {
		    foreach (@{$phenes{$evidence}->{$phene}->{$experiment}}) {
			$references{$_}++;
		    }
		    
		    # Does this experiment also potentially target other genes?
		    # I THINK THAT ALL OF THIS BELONGS IN THE VIEW
#		    my $dbh = $self->service('acedb');
#		    $experiment = $dbh->fetch(RNAi => $experiment);
#		    $phene      = $dbh->fetch(Phenotype => $phene);
#		    
#		    if ($evidence eq 'RNAi_primary' && $global_observed{$experiment}{$phene}) {
#			my @inhibits = $experiment->Gene;
#			if (@inhibits > 1) {
#			    $reagents_nonspecific++;
#			} else {
#			    $reagents_specific++;
#			}
#		    }
		}
		
#	push @{$stash{$evidence}},[$c->object2link($phene,_best_phenotype_name($phene)),
		push @{$stash{$evidence}},[$phene,
					   # Link the tally of experiments to the RNAi report page
					   qq{<a href="/db/seq/rnai?name=$object;phenotype=$phene">
			       $phenes2count{$evidence}{$phene}}
					   . ' (' . ($reagents_specific || 0)
					   . ':'  . ($reagents_nonspecific || 0)
					   . ') '
					   . "/ " . $phenes2total_count{$phene} . '</a>',
					   join(', ',keys %references)];
		
	    }
	}
	@{$stash{not_observed}} = @not_observed 
	    ? join(", ", map {$self->best_phenotype_name($not_observed{$_})} keys %not_observed) : "";
    }
    
    return \%stash;
}


sub gene_models {
  my $self = shift;
  my $object = $self->object;
  my $seqs = $self->_fetch_sequences();

  my @rows;

  # $sequence could potentially be a Transcript, CDS, Pseudogene - but
  # I still need to fetch some details from sequence
  # Fetch a variety of information about all transcripts / CDS prior to printing
  # These will be stored using the following keys (which correspond to column headers)
  my %footnotes;
  my $footnote_count = 0;
  foreach my $sequence (sort { $a cmp $b } @$seqs) {
    my %data = ();
    my $model = { label => $sequence->name, class => $sequence->class, id => $sequence->name};
    my $gff = $self->fetch_gff_gene($sequence) or next;
    my $cds = ($sequence->class eq 'CDS') ? $sequence : eval { $sequence->Corresponding_CDS };

    my ($confirm,$remark,$protein,@matching_cdna);
    if ($cds) {
      $confirm = $cds->Prediction_status; # with or without being confirmed
      @matching_cdna = $cds->Matching_cDNA; # with or without matching_cdna
      $protein = $cds->Corresponding_protein(-fill=>1);
    }

    # Fetch all the notes for this given sequence / CDS
    my @notes = (eval {$cds->DB_remark},$sequence->DB_remark,eval {$cds->Remark},$sequence->Remark);
    foreach (@notes) {
      $footnotes{$sequence->name}{++$footnote_count}{'note'} = $_;
      $footnotes{$sequence->name}{$footnote_count}{'evidence'} = $self->_get_evidence($_);
    }

    if ($confirm eq 'Confirmed') {
      $data{status} = "confirmed by cDNA(s)";
    } elsif (@matching_cdna && $confirm eq 'Partially_confirmed') {
      $data{status} = "partially confirmed by cDNA(s)";
    } elsif ($confirm eq 'Partially_confirmed') {
    $data{status} = "partially confirmed";
    } elsif ($cds && $cds->Method eq 'history') {
      $data{status} = 'historical';
    } else {
      $data{status} = "predicted";
    }

    my $len_unspliced  = $gff->length;
    my $len_spliced = 0;

    for ($gff->features('coding_exon')) {

    if ($object->Species =~ /elegans/) {
        next unless $_->source eq 'Coding_transcript';
    } else {        
        next unless $_->method =~ /coding_exon/ && $_->source eq 'Coding_transcript';
    }
    next unless $_->name eq $sequence;
    $len_spliced += $_->length;
    }
#     Try calculating the spliced length for pseudogenes
    if (!$len_spliced) {
      my $flag = eval { $object->Corresponding_Pseudogene } || $cds;
      for ($gff->features('exon:Pseudogene')) {
        next unless ($_->name eq $flag);
        $len_spliced += $_->length;
      }
    }
    $len_spliced ||= '-';
    $data{nucleotides} = "$len_spliced/$len_unspliced bp"
      if $len_unspliced;

    if ($protein) {
      my $peplen = $protein->Peptide(2);
      my $aa   = "$peplen aa";
      $data{aa} = $aa if $aa;
    }
    my $protein_desc = { label => $protein->name, id => $protein->name, class=>$protein->class};
    $data{model}  = $model    if $model;
    $data{protein} = $protein_desc if $protein_desc;

    push @rows,\%data;
  }

   # data is returned in this structure for use with dataTables macro
   my $data = { description => "The gene models table info",
                data        =>  { rows => \@rows,
                                  remarks => \%footnotes
                                }
   };
   return $data;
}

sub fetch_gff_gene {
 my ($self,$transcript) = @_;

  my $trans;
  my $GFF = $self->gff_dsn();

  if ($self->object->Species =~ /briggsae/) {
      ($trans)      = grep {$_->method eq 'wormbase_cds'} $GFF->fetch_group(Transcript => $transcript);
  }
  ($trans)      = grep {$_->method eq 'full_transcript'} $GFF->fetch_group(Transcript => $transcript) unless $trans;

  # Now pseudogenes
  ($trans) = grep {$_->method eq 'pseudo'} $GFF->fetch_group(Pseudogene => $transcript) unless ($trans);

  # RNA transcripts - this is getting out of hand
  ($trans) = $GFF->segment(Transcript => $transcript) unless ($trans);
  return $trans;
}

  
##### old superceded subs ###

sub interactions_old {
    my $self   = shift;
    my $object = $self->object;
    
    my $stash = {};
    
    # This is an extremely bizarre layout - 
    # reflecting the rather bizarre nature of interaction objects
    # Each interaction is specific to one paper, NOT to an interaction pair
    my @interactions = $object->Interaction;
    return unless @interactions;
    
    # Compress interactions by type, gene-gene, references
    foreach my $interaction (@interactions) {
	
	# Create a unique key corresponding to interactors
	my @genes = $interaction->Interactor;
	my $pair  = join('-',@genes);
	
	my $paper = $interaction->Paper;
	$paper    = $paper->Merged_into if $paper->Merged_into;
	
	my $year  = parse_year($paper->Year) if $paper;
	my $type  = $interaction->Interaction_type;
	
	# Have we seen this interaction type for this pair of interactors before?
	# If so, save another paper...
#    if (defined $data{$type}->{$pair}) {
#      push @{$data{$type}->{$pair}->{paper}},$paper;
#    } else {
	$stash->{$type}->{$pair} =
	{
	    paper       => [[$paper,parse_year($year)]],
	    interactor  => $interaction,
	    interactors => [ $interaction->Interactor ],
	};
    }
    #  }
    ##  # Prioritize the display of types in the template
    ##  foreach my $type (qw/genetic regulatory predicted_interaction/) {
    ##    foreach my $pair (sort keys %{$interactions{$type}}) {
    ##     my %seen = ();
    ##      $table .= TR(td({-align=>'center'},$pair),
    ##		   td({-align=>'center'},$type),
    ##		   td({-width=>'30%'},join('; ',
    ##					   sort { $a cmp $b }
    ##					   grep { !$seen{$_}++ } 
    ##					   grep { $_ ne 'n/a' }  # Ignor empty papers
    ##					   @{$interactions{$type}{$pair}})));
    ##   }
    ##}
    return $stash;
}


sub microarray_expression_data_old {
    my $self   = shift;
    my $object = $self->object;
    
    return [ $object->Microarray_results ];
}

sub microarray_topology_map_position_old {
    my $self   = shift;
    my $object = $self->object;
    my $sequences = $self->_fetch_sequences();
    return unless $sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    
    my $seg = $segments[0] or return;
    my @stash = map {$_->info} $seg->features('experimental_result_region:Expr_profile') ;
    return \@stash;
}



sub orthologs_old {
    my $self     = shift;
    my $object = $self->object;
    return [ $object->Ortholog ];
}

sub orfeome_project_primers_old {
    my $self     = shift;
    my $object = $self->object;
    my $sequences = $self->_fetch_sequences();
    return unless @$sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    my @stash =  map {$_->info} map { $_->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome') } @segments;
    return \@stash;
}


sub treefam_old {
    my $self     = shift;
    my $object = $self->object;
    my $proteins = $self->_fetch_proteins($object);
    
    my @data;
    foreach my $protein (@$proteins) {
	my $treefam = $self->_fetch_protein_ids($protein,'treefam');
	
	# Ignore proteins that lack a Treefam ID
	next unless $treefam;
	my $id = $object->Sequence_name || $treefam;
	push @data,[$id,$treefam];
    }
    return \@data;
}


sub inparanoid_groups_old {
    my $self     = shift;
    my $object = $self->object;
    my %stash;
    my $proteins = $self->_fetch_proteins($object);
    my %seen;
    my @inp = grep {!$seen{$_}++ } grep {$_->Group_type eq 'InParanoid_group' }
    map {$_->Homology_group} @$proteins;
    
    foreach my $cluster (@inp) {
	my @proteins = $cluster->Protein;
	foreach my $protein (@proteins) {
	    my $species = $protein->Species || $self->id2species($protein) || 'unknown';
	    # Key by species
	    push @{$stash{$cluster}->{$species}},$protein;
	}
    }
    return \%stash;
}


sub history_old {
    my $self   = shift;
    my $object = $self->object;
    my @history = $object->History;

    # Present each history event as a separate item in the data struct
    my $data = {};
    foreach my $history (@history) {
	my $type = $history;
	$type =~ s/_ / /g;	

	my @versions = $history->col;
	foreach my $version (@versions) {
            #  next unless $history eq 'Version_change';    # View Logic
	    my ($vers,$date,$curator,$event,$action,$remark,$gene,$person);	    
	    if ($history eq 'Version_change') {
		($vers,$date,$curator,$event,$action,$remark) = $version->row; 
		
                # For some cases, the remark is actually a gene object
		if ($action eq 'Merged_into' || $action eq 'Acquires_merge'
		    || $action eq 'Split_from' || $action eq 'Split_into') {
		    $gene = $remark;
		    $remark = undef;
		}
	    } else {
		($gene) = $version->row;
	    }	    

	    push @{$data->{history}},
	    { type    => $type,
	      version => $version,
	      date    => $date,
	      action  => $action,
	      remark  => $remark,
	      object  => $gene    ? $self->wrap($gene) : '',
	      curator => $curator ? $self->wrap($curator) : '',
	    };
	}
    }

    $data->{description} = 'curatorial history for this gene';
    return $data;
}


sub cloned_by_old {
    my $self   = shift;
    my $object = $self->object;
    
    my $cloned_by = $object->Cloned_by;
    return 1 unless $cloned_by;
    
    my ($tag,$source) = $cloned_by->row ;
    
    my @data;
    my $name = $cloned_by->Full_name;
    my %data  = {cloned_by => "$cloned_by",
		 full_name => "$name",
		 tag       => "$tag",
		 source    => "$source",		    
    };
    
    my $data = $self->build_data_structure(\%data,
					   'the researchers noted for cloning this gene');
    
    return $data;
}


sub other_sequences_old {
    my $self   = shift;
    my $object = $self->object;

    if (my @seqs = $object->Other_sequence) {
	# Wrap these in WormBase API objects
	my @wrapped = $self->wrap(@seqs);

	my $data = { resultset => { sequences => \@wrapped } };
	return $data;
	return \@wrapped;
    } else {
	return 1;
    }
}


sub ids_complex {
    my $self   = shift;
    my $object = $self->object; ## shift
    
    my %data;
    my %data_pack;
    my %data_lists;
    
    # Fetch external database IDs for the gene
    my ($aceview,$refseq) = $self->_fetch_database_ids($object);
    
    my $version = $object->Version;
    my $locus   = $object->CGC_name;
    my $common  = $object->Public_name;
    
    my $object_data = {	
	common_name   => "$common",
	locus_name    => "$locus",
	gene_class    => $object->Gene_class,
	wormbase_id   => "$object",
	aceview_id    => "$aceview",
	refseq_id     => $refseq,
	version       => "$version",
	};
	
	my %gene2sequence_name;
	my %gene2other_name;
	
	my @other_names = $object->Other_name;
	
	foreach my $other_name (@other_names) {
	
		$gene2other_name{$object}{$other_name} = 1;
	
	}
		
	my @sequence_names = $object->Sequence_name;
	
	foreach my $sequence_name (@sequence_names) {
	
		$gene2sequence_name{$object}{$sequence_name} = 1;
	
	}

	$data_pack{$object} = $object_data;
	$data_lists{'gene2sequence_name'} = \%gene2sequence_name;
	$data_lists{'gene2other_name'} = \%gene2other_name;

	$data{'data'} = \%data_pack;
	$data{'data_lists'} = \%data_lists;
	$data{'count'} = 'complex';
	$data{'description'} = "Data for gene $object";
	
    return \%data;
}
  
sub ids_old {
    my $self   = shift;
    my $object = $self->object;
    
    # Fetch external database IDs for the gene
    my ($aceview,$refseq) = $self->_fetch_database_ids($object);
    
    my $version = $object->Version;
    my $locus   = $object->CGC_name;
    my $common  = $object->Public_name;
    
    my $data = $self->build_data_structure({	
	common_name   => "$common",
	locus_name    => "$locus",
	gene_class    => $object->Gene_class,
	other_name    => join(', ',map { "$_" } $object->Other_name),
	sequence_name => join(', ',map { "$_" } $object->Sequence_name),
	wormbase_id   => "$object",
	aceview_id    => "$aceview",
	refseq_id     => $refseq,
	version       => "$version",},
					   'various IDs that refer to this gene',	
	);
    return $data;
}

sub gene_ontology_old {
    my $self     = shift;
    my $object = $self->object; 
    
    my %stash;
    
    # Preferentially use GO_terms attached to genes, but also look for
    # those attached to CDS. Eventually, they should all propagate to
    # gene objects.
    my %seen;
    my @ontology_terms = grep {!$seen{$_}++} $object->GO_term();
    push (@ontology_terms,grep {!$seen{$_}++} map {$_->GO_term()} $object->Corresponding_CDS);
    
    return unless (@ontology_terms);
    
    foreach my $term (@ontology_terms) {
	my @evidence = $self->_go_evidence_code($term);
	my $type = $term->Type;
	push @{$stash{$type}},{ term => $term,
				title => $term->Term,
				evidence => \@evidence };
    }
    return \%stash;
}

sub alleles_old {
    my $self = shift;
    my $object = $self->object;
    if (my @vars = $object->Allele) {
	# Wrap these in WormBase API objects
	my @wrapped = $self->wrap(@vars);
	return \@wrapped;
    } else {
	return 1;
    }
}


sub rearrangements_old {
    my $self   = shift;
    my $object = $self->object;
    return unless($object->Allele || $object->Reference_allele) ;
    return 1;  # True: we have alleles and therefore *may* have rearrangements.
}

sub cds_old {
    my $self   = shift;
    my $object = $self->object;
    my @cds    = $object->Corresponding_CDS;
    
    if (@cds) {
	# Wrap these in WormBase API objects
	my @wrapped = $self->wrap(@cds);
	return \@wrapped;
    }
}

#### end old versions ###

### implementation in view ####

###########################################
# Components of the Expression panel
###########################################

sub fourd_expression_movies {
    my $self   = shift;
    my $object = $self->object;
    
    my @all_ep = $object->Expr_pattern;
    my @mohler = eval{grep {($_->Author =~ /Mohler/ && $_->MovieURL)} @all_ep};
    @all_ep = eval{grep {!($_->Author =~ /Mohler/ && $_->MovieURL)} @all_ep};
    return '' unless @all_ep || @mohler;
    return \@mohler;
}

sub anatomic_expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    
    my @eps = $object->Expr_pattern;
    
    foreach my $ep (@eps) {
    	if ($self->_pattern_thumbnail($ep)) {
    	
    		$data_pack{$ep}{'image'} = 1;
    	}
    	
    	else 
    	
    	{
    		$data_pack{$ep}{image} = 0;
    	}
    }
    
    $data{'description'} = 'expression pattern image data for gene';
    
    $data{'data'} = \%data_pack;
    return \%data;
}

#### implementation is view #####



#########################################
#
#   INTERNAL METHODS
#
#########################################

# PROTEINS HERE WILL NOT PERSIST AND NEED TO BE FETCHED EACH GO 'ROUND
# THIS ALSO WILL NOT RETURN OBJECTS - stash() treats them as hashrefs
sub _fetch_proteins {
    my ($self,$object) = @_;
    my @cds = $object->Corresponding_CDS;
    my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds if (@cds);
    return \@proteins;
}





# Fetch unique transcripts (Transcripts or Pseudogenes) for the gene
sub _fetch_transcripts {  
    my $self = shift;
    my $object = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $object->Corresponding_transcript;
    my @cds  = $object->Corresponding_CDS;
    foreach (@cds) {
	next if defined $seen{$_};
	my @transcripts = grep {!$seen{$_}++} $_->Corresponding_transcript;
	push (@seqs,(@transcripts) ? @transcripts : $_);
    }
    @seqs = $object->Corresponding_Pseudogene unless @seqs;
    return \@seqs;
}

# TODO: This could logically be moved into WormBase::Model::GFF although it is currently
# totally specific for genes and CDSs
# Provided with a gene and array of sequences, fetch an array of GFF segments
sub _fetch_segments {
    my ($self,$sequences) = @_;
    
    # Dynamically fetch a DBH for the correct species
    my $dbh = $self->gff_dsn();

#    my $dbh = $self->service('gff_c_elegans');
    my $object = $self->object;
    my $species = $object->Species;
    
    # Yuck. Still have some species specific stuff here.
    if (@$sequences && $species =~ /briggsae/) {
	my @tmp = map {$dbh->segment(CDS => "$_")} @$sequences;
	@tmp = map {$dbh->segment(Pseudogene => "$_")} @$sequences unless (@tmp);
	return @tmp;
    }
    
    my @segments = $dbh->segment(Gene => $object);
    @segments    = map { $dbh->segment(CDS => $_) } @$sequences unless (@segments > 0);
    
    # Pseudogenes (B0399.t10)
    @segments = map { $dbh->segment(Pseudogene => $_) } $object->Corresponding_Pseudogene unless @segments;
    
    # RNA transcripts (lin-4, sup-5)
    @segments = map { $dbh->segment(Transcript => $_) } $object->Corresponding_Transcript unless @segments;
    return @segments;
}

# TODO: Logically this might reside in Model::GFF although I don't know if it is used elsewhere
# Find the longest GFF segment
sub _longest_segment {
    my ($self,$segments) = @_;
    my @sorted = sort { ($b->abs_end-$b->abs_start) <=> $a->abs_end-$a->abs_start } @$segments;
    return $sorted[0];
}

sub _select_protein_description {
    my ($self,$seq,$protein) = @_;
    my %labels = (Pseudogene => 'Pseudogene; not attached to protein',
		  history     => 'historical prediction',
		  RNA         => 'non-coding RNA transcript',
		  Transcript  => 'non-coding RNA transcript',
	);
    my $error = $labels{eval{$seq->Method}};
    $error ||= eval { ($seq->Remark =~ /dead/i) ? 'dead/retired gene' : ''};
    my $msg = $protein ? $protein : $error;
    return $msg;
}

# Aceview and entrez are unique to gene (although stored in CDS)
# refseq is unique to CDS - NM_* is mRNA ID.
# DONE
sub _fetch_database_ids {
    my ($self,$object) = @_;
    my ($aceview,@refseq);
    # Fetch all DB IDs at once, uniquifying them
    # for genes at the same time
    my @dbs = $object->Database;
    foreach my $db (@dbs) {
	foreach my $type ($db->col) {
	    if ($db eq 'AceView') {
		$aceview = $type->right->name;
	    } elsif ($db eq 'RefSeq') {
		push (@refseq,map { "$_" } eval { $type->col });
	    }
	}
    }
    return ($aceview,\@refseq);
}


# This is really inefficient
sub _fetch_protein_ids {
    my ($self,$s,$tag) = @_;
    my @dbs = $s->Database;
    foreach (@dbs) {
	return $_->right(2) if (/$tag/i);
    }
    return;
}


# TODO: This could logically be moved into a template
sub _other_notes {
    my ($self,$object) = @_;
    
    my @notes;
    if ($object->Corresponding_Pseudogene) {
	push (@notes,'This gene is thought to be a pseudogene');
    }
    
    if ($object->CGC_name || $object->Other_name) {
	if (my @contained_in = $object->In_cluster) {
#####      my $cluster = join ' ',map{a({-href=>Url('gene'=>"name=$_")},$_)} @contained_in;
	    my $cluster = join(' ',@contained_in);
	    push @notes,"This gene is contained in gene cluster $cluster.\n";
	}
	
#####    push @notes,map { GetEvidence(-obj=>$_,-dont_link=>1) } $object->Remark if $object->Remark;
	push @notes,$object->Remark if $object->Remark;
    }
    
    # Add a brief remark for Transposon CDS entries
    push @notes,
    'This gene is believed to represent the remnant of a transposon which is no longer functional'
	if (eval {$object->Corresponding_CDS->Method eq 'Transposon_CDS'});
    
    foreach (@notes) {
	$_ = ucfirst($_);
	$_ .= '.' unless /\.$/;
    }
    return \@notes;
}




sub parse_year {
    my $date = shift;
    $date =~ /.*(\d\d\d\d).*/;
    my $year = $1 || $date;
    return $year;
}


sub _pattern_thumbnail {
    my ($self,$ep) = @_;
    return '' unless $self->_is_cached($ep->name);
    my $terms = join ', ', map {$_->Term} $ep->Anatomy_term;
    $terms ||= "No adult terms in the database";
    return ([$ep,$terms]);
}

# Meh. This is a view component and doesn't belong here.
sub _is_cached {
    my ($self,$ep) = @_;
    my $WORMVIEW_IMG = '/usr/local/wormbase/html/images/expression/assembled/';
    return -e $WORMVIEW_IMG . "$ep.png";
}



sub _y2h_data {
    my ($self,$object,$limit,$c) = @_;
    my %tags = ('YH_bait'   => 'Target_overlapping_CDS',
		'YH_target' => 'Bait_overlapping_CDS');
    
    my %results;
    foreach my $tag (keys %tags) {
	if (my @data = $object->$tag) {
	    
# Map baits/targets to CDSs
	    my $subtag = $tags{$tag};
	    my %seen = ();
	    foreach (@data) {
		my @cds = $_->$subtag;
		
		unless (@cds) {
		    my $try_again = ($subtag eq 'Bait_overlapping_CDS') ? 'Target_overlapping_CDS' : 'Bait_overlapping_CDS';
		    @cds = $_->$try_again;
		}
		
		unless (@cds) {
		    my $try_again = ($subtag eq 'Bait_overlapping_CDS') ? 'Bait_overlapping_gene' : 'Target_overlapping_gene';
		    my $new_gene = $_->$try_again;
		    @cds = $new_gene->Corresponding_CDS if $new_gene;
		}
		
		foreach my $cds (@cds) {
		    push @{$seen{$cds}},$_;
		}    
	    }
	    
	    my $count = 0;
	    for my $cds (keys %seen){
		my ($y2h_ref,$count);
		my $str = "See: ";
		for my $y2h (@{$seen{$cds}}) {
		    $count++;
		    # If we are limiting for the main page, append a link to "more"
		    last if ($limit && $count > $limit);
#	  $str    .= " " . $c->object2link($y2h);
		    $str    .= " " . $y2h;
		    $y2h_ref  = $y2h->Reference;
		}
		if ($limit && $count > $limit) {
#	  my $link = DisplayMoreLink(\@data,'y2h',undef,'more',1);
#	  $link =~ s/[\[\]]//g;
#	  $str .= " $link";
		}
		my $dbh = $self->service('acedb');
		my $k_cds = $dbh->fetch(CDS => $cds);
		#	push @{$results{$tag}}, [$c->object2link($k_cds) . " [" . $str ."]", $y2h_ref];
		push @{$results{$tag}}, [$k_cds . " [" . $str ."]", $y2h_ref];
	    }
	}
    }
    return (\@{$results{'YH_bait'}},\@{$results{'YH_target'}});
}



# This is one big ugly hack job
sub _go_evidence_code {
    my ($self,$term) = @_;
    my @type      = $term->col;
    my @evidence  = $term->right->col if $term->right;
    my @results;
    foreach my $type (@type) {
	my $evidence = '';
	
	for my $ev (@evidence) {
	    my $desc;
	    my (@supporting_data) = $ev->col;
	    
	    # For IMP, this is semi-formatted text remark
	    if ($type eq 'IMP' && $type->right eq 'Inferred_automatically') {
		my (%phenes,%rnai);
		foreach (@supporting_data) {
		    my @row;
		    $_ =~ /(.*) \(WBPhenotype(.*)\|WBRNAi(.*)\)/;
		    my ($phene,$wb_phene,$wb_rnai) = ($1,$2,$3);
		    $rnai{$wb_rnai}++ if $wb_rnai;
		    $phenes{$wb_phene}++ if $wb_phene;
		}
#	$evidence .= 'via Phenotype: '
#	  #		  . join(', ',map { a({-href=>ObjectLink('phenotype',"WBPhenotype$_")},$_) }
#	  . join(', ',map { a({-href=>Object2URL("WBPhenotype$_",'phenotype')},$_) }
#		 
#		 keys %phenes) if keys %phenes > 0;
		
		$evidence .= 'via Phenotype: '
		    . join(', ',		 keys %phenes) if keys %phenes > 0;
		
		$evidence .= '; ' if $evidence && keys %rnai > 0;
		
#	$evidence .= 'via RNAi: '
#	  . join(', ',map { a({-href=>Object2URL("WBRNAi$_",'rnai')},$_) } 
#		 keys %rnai) if keys %rnai > 0;
		$evidence .= 'via RNAi: '
		    . join(', ', keys %rnai) if keys %rnai > 0;
		
		next;
	    }
	    
	    my @seen;
	    
	    foreach (@supporting_data) {
		if ($_->class eq 'Paper') {  # a paper
#	  push @seen,ObjectLink($_,build_citation(-paper=>$_,-format=>'short'));
		    
		    push @seen,$_;
		} elsif ($_->class eq 'Person') {
		    #		  push @seen,ObjectLink($_,$_->Standard_name);
		    next;
		} elsif ($_->class eq 'Text' && $ev =~ /Protein/) {  # a protein
#	  push @seen,a({-href=>sprintf(Configuration->Protein_links->{NCBI},$_),-target=>'_blank'},$_);
		} else {
#	  push @seen,ObjectLink($_);
		    push @seen,$_;
		}
	    }
	    if (@seen) {
		$evidence .= ($evidence ? ' and ' : '') . "via $desc ";
		$evidence .= join('; ',@seen); 
	    }
	}
	
	
	# Return an array of arrays, containing the go evidence code (IMP, IEA) and its source (RNAi, paper, curator, etc)
	push @results,[$type,($type eq 'IEA') ? 'via InterPro' : $evidence];
    }
    #my @proteins = $term->at('Protein_id_evidence');
    return @results;
}




# NOT COMPLETE
# THIS BELONGS ELSEWHERE, MAYBE EVEN AS A COMPONENT OF THE VIEW
sub GetEvidenceNew {
    my ($self,$object,@p) = @_;
    
    my $data      = $self->_parse_hash($object);
    my $formatted = $self->_parse_evidence_hash(-data=>$data,@p);
    return $formatted;
}


# Reformat IDs and map them to correct URLs
# THIS BELONGS AS PART OF A TEMPLATE FUNCTION / CONFIGURATION
sub species2url {
    my ($self,$species,$id) = @_;
    
    # Oryza sativa
    if ($species =~ /oryza/i) {
	$id =~ s/^GR\://;
	# Plasmodium falciparum
    } elsif ($species =~ /sapiens/) {
	
    } elsif ($species =~ /pfalciparum/) {
	$id =~ s/GeneDB_Pfalciparum://g;
	# S. cervisiae
    } elsif ($species eq 'Saccharomyces cerevisiae') {
	$id =~ s/SGD\://g;
    } elsif ($id =~ /fly/i) {
	$id =~ s/FLYBASE://g;
	$id =~ s/CG//i;
	$id =~ s/GA//i;
	$id = sprintf("%07d",$id);
	# S. pombe
    } elsif ($species =~ /Schizosaccharomyces/) {
	$id =~ s/GeneDB_Spombe://g;
    } elsif ($species =~ /dictyostelium/i) {
	$id =~ s/^DDB://;
    } elsif ($id =~ /RefSeq/i) {
	$id =~ s/REFSEQ://;
	$species = 'refseq';
    } elsif ($id =~ /ENSEMBL/) {
	$id =~ s/ENSEMBL\://g;
	my $url = Configuration->Species_to_url->{ensembl};
	$species =~ s/ /_/g;
	return (sprintf($url,$species,$id));
    }
    
    my $url = Configuration->Species_to_url->{$species};
    return (sprintf($url,$id)) if $url;
}



sub _fetch_sequences {

	my $self = shift;
	my $GENE = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $GENE->Corresponding_transcript;
    my @cds = $GENE->Corresponding_CDS;
    foreach (@cds) {
	next if defined $seen{$_};
	my @transcripts = grep {!$seen{$_}++} $_->Corresponding_transcript;
	push (@seqs,(@transcripts)? @transcripts : $_);
    }
    @seqs = $GENE->Corresponding_Pseudogene unless @seqs;
    return \@seqs;
    
}



### get phenotype ids from outputs of get_phenotype_data() and get_variation_data() and provides corresponding phenotype names
### syntax: $phene_id2name_hr = get_phenotype_names(rnai_ar,var_ar)

sub _get_phenotype_names {

	my ($rnai_ar,$var_ar) = @_;
	
	my %phene_master;
	
	foreach my $rnai_phene_line (@$rnai_ar) {
	
		my ($phene_id, $disc) = split /\|/,$rnai_phene_line;
		$phene_master{$phene_id} = 1;
	}
	
	foreach my $var_phene_line (@$var_ar) {
	
		my ($phene_id, $disc) = split /\|/,$var_phene_line;	
		$phene_master{$phene_id} = 1;
	}
	
	my %phene_id2name;
	my %fullset_phene_id2name = build_hash("$gene_pheno_datadir/$phenotype_name_file");
	foreach my $phene_id (keys %phene_master) {
				
		$phene_id2name{$phene_id} = $fullset_phene_id2name{$phene_id};  ## $phene_primary_name
	}
	
	return \%phene_id2name;
}


sub _get_phenotype_data {

	my ($gene,$positive_results) = @_;
	my $rnai_details = "$gene_pheno_datadir/$rnai_details_file";
	my %rnai_phenotypes;
	my %rnai_genotype;
	my %rnai_ref;

	open RNAI_DATA, "<$rnai_details" or die "Cannot open RNAi details file: $rnai_details\n";
	
	foreach my $rnai_data_line (<RNAI_DATA>) {
	
		chomp $rnai_data_line;
		my ($rnai,$genotype,$ref) = split /\|/,$rnai_data_line;
		# print "$rnai_data_line\n";
		
		$rnai_genotype{$rnai} = $genotype;
		$rnai_ref{$rnai} = $ref;
		
	}
	
	my $gene_phenotype_data;
	
	if($positive_results) {
	
		$gene_phenotype_data = `grep $gene $gene_pheno_datadir/$gene_rnai_phene_file | grep -v Not `;
	
	} else {
	
		$gene_phenotype_data = `grep $gene $gene_pheno_datadir/$gene_rnai_phene_file | grep Not `;
	
	}
	

	#print "$gene_phenotype_data\n";
	my @gene_phenotype_data = split /\n/,$gene_phenotype_data;
	my %rnai_pheno_data;
	my %pheno_rnai_data;
	foreach my $gene_phenotype_data_line (@gene_phenotype_data) {
	
		#print "\=\>$gene_phenotype_data_line\n";
		
		my ($gene_id,$rnai_id,$pheno_id) = split /\|/,$gene_phenotype_data_line;
		
		$rnai_pheno_data{$rnai_id}{$pheno_id} = 1;
		$pheno_rnai_data{$pheno_id}{$rnai_id} = 1;
	
	}

	my @rnais  = keys %rnai_pheno_data;
	my @details;
	my @phenotype_return;
	
	foreach my $rnai (@rnais) {
	
		my $pheno_ids_hr =  $rnai_pheno_data{$rnai};
		my $pheno_ids = join "&", keys %$pheno_ids_hr;
	
		push @details, "$rnai\|$pheno_ids\|$rnai_genotype{$rnai}\|$rnai_ref{$rnai}";
	}
	
	foreach my $phenotype (keys %pheno_rnai_data) {
	
		my $rnai_ids_hr = $pheno_rnai_data{$phenotype};
		my @rnai_ids = keys %$rnai_ids_hr;
		my $rnai_id_count = @rnai_ids;
		push @phenotype_return, "$phenotype\|$rnai_id_count";
	}
	
	return \@details, \@phenotype_return;

}


### pulls variation data from file for inputed gene
### syntax: $variation_data_ar = get_variation_data('gene_id');
### array_ref for lines: phenotype_id|var1&var2&var3

sub _get_variation_data {

	my ($gene, $positive_results) = @_; ## , $phenotype_ar
	
	my $gene_variation_data; ## = `grep $gene $gene_pheno_datadir/$gene_variation_phene_file`;
	
	
	if($positive_results) {
	
		$gene_variation_data = `grep $gene $gene_pheno_datadir/$gene_variation_phene_file | grep -v Not `;
	
	} else {
	
		$gene_variation_data = `grep $gene $gene_pheno_datadir/$gene_variation_phene_file | grep Not `;
	
	}
	
	#print "$gene_variation_data\n";
	
	my @gene_variation_data = split /\n/, $gene_variation_data;
	
	my %phenotype_variation;
	
	foreach my $var_data_line (@gene_variation_data) {
	
		my ($gene,$var,$phenotype,$not,$seq_stat)  = split /\|/, $var_data_line;
		$var = $var . "+" . $seq_stat;
		$phenotype_variation{$phenotype}{$var} = 1;
		
	}
	
	my @return_data;
	
	### get appropriate phenotypes
	
# 	foreach my $phenotype_data_line (@$phenotype_ar) {
# 	
# 		my ($phene, $rnai_id_count) = split /\|/, $phenotype_data_line;
# 	
# 		my $vars_hr = $phenotype_variation{$phene};
# 		my @vars = keys %$vars_hr;
# 		my $vars_line = join "&", @vars;
# 		push @return_data, "$phene\|$vars_line";
# 	
# 	}
	
	foreach my $phene (keys %phenotype_variation) {
	
		my $vars_hr = $phenotype_variation{$phene};
		my @vars = keys %$vars_hr;
		my $vars_line = join "&", @vars;
		push @return_data, "$phene\|$vars_line";
	}
	return \@return_data;
	
}


sub build_hash{

	my ($file_name) = @_;
	open FILE, "< $file_name" or die "Cannot open the file: $file_name\n";

	my %hash;
	foreach my $line (<FILE>) {
		chomp ($line);
		my ($key, $value) = split '=>',$line;
		$hash{$key} = $value;
	}
	return %hash;
}


#######################################################
# The Details Panel (Structural Description)
#######################################################

sub structured_description {
   my $self = shift;
   my %ret;
   my @types = qw(Provisional_description Other_description Sequence_features Functional_pathway Functional_physical_interaction Molecular_function Sequence_features Biological_process Expression Detailed_description);
   foreach my $type (@types){
      my $node = $self->object->$type or next;
      my @nodes = $self->object->$type;
      @nodes = map { {text => "$_", evidence => { flag => $self->check_empty($node), tag => $type }}} @nodes;
      $ret{$type} = \@nodes if (@nodes > 0);
   }
   my $data = { description => "The structural description of the gene",
                data        =>  \%ret
   };
   return $data;
}



1;
