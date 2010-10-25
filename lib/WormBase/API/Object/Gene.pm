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
# sage_tagsf
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

# my $version = 'WS213';  

# our $gene_pheno_datadir = "/usr/local/wormbase/databases/$version/gene";
# our $rnai_details_file = "rnai_data.txt";
# our $gene_rnai_phene_file = "gene_rnai_pheno.txt";
# our $gene_variation_phene_file = "variation_data.txt";
# our $phenotype_name_file = "phenotype_id2name.txt";
# our $gene_xgene_phene_file = "gene_xgene_pheno.txt";

has 'gene_pheno_datadir' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $version = $self->ace_dsn->version;
	return $self->pre_compile->{base}.$version.$self->pre_compile->{gene};
    }
);
 
#####################
##### template ######

 
has 'all_proteins' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $cds = $self ~~ '@Corresponding_CDS';
	return undef unless $cds;
	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @$cds  ;
	return \@proteins;
    }
);
 

has 'database_ids' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my ($aceview,@refseq);
	# Fetch all DB IDs at once, uniquifying them
	# for genes at the same time
	foreach my $db (@{$self ~~ '@Database'}) {
	    foreach my $type ($db->col) {
		if ($db eq 'AceView') {
		    $aceview = $type->right->name;
		} elsif ($db eq 'RefSeq') {
		    push (@refseq,map { "$_" } eval { $type->col });
		}
	    }
	}
	return [$aceview,\@refseq];
    }
);

has 'sequences' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my @seq = $self->_fetch_sequences;
	return \@seq;
    }
);

has 'segments' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my @seg = $self->_fetch_segments;
	return \@seg;
    }
);

has 'pic_segment' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self = shift;
	my $seq = $self->object;
	return unless(defined $self->segments);
	return $self->_longest_segment($self->segments);  
    }
);

has 'tracks' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self = shift;
	my @type = $self->species =~ /elegans/ ? qw/CG CANONICAL Allele RNAi/:qw//;
	return \@type;
    }
);

has 'phen_data' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
      my $self=shift;
      my $ret = $self->_build_phen_data;
      return $ret;
    }
);



#######################################################
# The Overview (formerly Identification) Panel
#######################################################


sub name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The most commonly used name of the gene',
		 data        =>  { id    => "$object",
				           label => $self->_public_name($object),
				           class => $object->class
		 },
    };
    
    return $data;
}

sub external_links {
  my $self = shift;
  my $object = $self->object;


  my ($aceview,$refseq) = @{$self->database_ids};
  my $data = { description => 'External links',
                      data => { 'aceview'     => $aceview,
                                'ncbi_refseq' => $refseq,
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
    my ($aceview,$refseq) = @{$self->database_ids};

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
    $data{'data'} = "$description";
    return \%data;
}


# Fetch all proteins associated with a gene.
## NB: figure out the naming convention for proteins

# NOTE: this method is not used
sub proteins {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'proteins related to gene';


	#### data pull and packaging

		my @cds    = $object->Corresponding_CDS;
		my @proteins  = map { $_->Corresponding_protein } @cds;
        @proteins = map {$self->_pack_obj($_, $self->public_name($_, $_->class))} @proteins;
		
	####

	$data{'data'} = \@proteins;
	$data{'description'} = $desc;
	return \%data;
}


# Fetch all CDSs associated with a gene.
## figure out naming convention for CDs

# NOTE: this method is not used
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

# NOTE: this method is not used
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
    my @seqs = map { [$self->_pack_obj($_), "". $_->Title] } $object->Other_sequence;
    my $data = { 
	 description => 'Other sequences associated with gene',
	  data        => \@seqs
      };

    return $data;
}

# NOTE: this method is not used
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

sub legacy_information {
  my $self = shift;
  my $object = $self->object;
  my @description = $object->Legacy_information or return;
  my $data = {  description => "legacy information for the gene",
                data => \@description
            };
  return $data;
}

###########################################
# Components of the Location panel
# Note: Most of these are generic and located
# in the Model.pm
###########################################

sub genomic_position {
    my $self      = shift;
    return $self->SUPER::genomic_position($self->_longest_segment($self->segments)); 
}


sub genetic_position {

	my $self = shift;
	my $object = $self->object;
	my $LOCUS = $object->CGC_name || $object->Other_name;
	 
	my ($link_group,undef,$position,undef,$error) = eval{$object->Map(1)->row} or return;
	
	my $map_data = { class=>'locus',
			 id=>"name=$LOCUS#Mapping%20Data",
			  lable=>'[mapping data]',
			};
	 
	my $label;
	if($position == 0) {
	    $label= $link_group . sprintf(":%2.2f +/- %2.3f cM %s","0",$error) ;
	    
	} else {
	    $label=$link_group . ($position ? sprintf(":%2.2f +/- %2.3f cM %s",$position,$error): '');
	}			       
	 my $data = { description => 'The Interpolated Genetic Position of the gene',
		 data        => [	{  class => 'Map',
					   label => $label,
					   id => "name=$object;class=Gene",
					},$map_data],
	};

	return $data;    
 
}
###########################################
# Components of the Function panel
###########################################

# This has some rather complicated markup.
# Pre-process here before hitting the template
# (This could also be a function for the template)
# NOTE: this method makes no sense.
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
	my @microarray_results = $object->Microarray_results;	
	$data{'data'} = $self->_pack_objects(\@microarray_results);
	$data{'description'} = 'gene expression determined via microarray analysis';
	return \%data;
}

sub microarray_topology_map_position {

	my $self = shift;
    my $object = $self->object;

    my @sequences = $self->sequences;
    return unless @sequences;
    my @segments = $self->_fetch_segments;
    my $seg = @segments[0] or return;
    my @p = map {$_->info} $seg->features('experimental_result_region:Expr_profile');
    return unless @p;
    my %data;
    map {$data{"$_"} = $self->_pack_obj($_,eval{'Mountain '.$_->Expr_map->Mountain}||$_)} @p;

	my $data = {description =>"microarray topology map",
                data => \%data
                };
	return $data;
}


sub expression_cluster {
    my $self = shift;
    my $object = $self->object;
    my %data;
    my @expr_clusters = $object->Expression_cluster;  
    $data{'data'} = $self->_pack_objects(\@expr_clusters);
    $data{'description'} = 'expression cluster data';
    return \%data;
}



sub anatomy_function {

    my $self = shift;
    my $object = $self->object;

    my @data;
    my @anatomy_fns = $object->Anatomy_function;
    foreach my $anatomy_fn (@anatomy_fns){
      my %anatomy_fn_data;
      my $afn_bodypart_set = $anatomy_fn->Body_part;
      if($afn_bodypart_set =~ m/Not_involved/){
          next;
      }
      else{
          my $afn_phenotype = $anatomy_fn->Phenotype;
          $anatomy_fn_data{'anatomy_fn'} = $self->_pack_obj($anatomy_fn);
          $anatomy_fn_data{'phenotype'} = $self->_pack_obj($afn_phenotype, $afn_phenotype->Primary_name); #$phenotype_prime_name;
          my @afn_bodyparts = $afn_bodypart_set->col if $afn_bodypart_set;
          my @ao_terms;
          foreach my $afn_bodypart (@afn_bodyparts){
            my $ao_term_details;
            my @afn_bp_row = $afn_bodypart->row;
            my ($ao_id,$sufficiency,$description) = @afn_bp_row;
            if( ($sufficiency=~ m/Insufficient/)){
                next;
            }
            else{
                my $term = $ao_id->Term;
                $ao_term_details = $self->_pack_obj($term);
            }
            push @ao_terms,$ao_term_details;
          }
          $anatomy_fn_data{'terms'} = \@ao_terms;
      }
      push @data, \%anatomy_fn_data;
    }


    my %data;

    $data{'data'} = \@data;
    $data{'description'} = "anatomy function";
    return \%data;
}

sub _build_phen_data {
    my $self = shift;
    my $GENE = $self->object;

    my ($details,$phenotype_data) = $self->_get_phenotype_data($GENE, 1);  
    my ($variation_data, $variation_name_hr) = $self->_get_variation_data($GENE, 1); 
    my ($details_not,$phenotype_data_not) = $self->_get_phenotype_data($GENE); 
    my ($variation_data_not, $variation_name_hr_not) = $self->_get_variation_data($GENE);
    my $xgene_data = $self->_get_xgene_data($GENE, 1);
    my $xgene_data_not = $self->_get_xgene_data($GENE);

    my $phenotype_names_hr  = $self->_get_phenotype_names($phenotype_data,$variation_data);
    my $phenotype_names_not_hr  = $self->_get_phenotype_names($phenotype_data_not,$variation_data_not);

    my $pheno_table = $self->_print_phenotype_table($phenotype_data,
                        $variation_data,
                        $phenotype_names_hr,
                        $xgene_data,
                        $variation_name_hr);
    my $pheno_table_not = $self->_print_phenotype_table($phenotype_data_not,
                        $variation_data_not,
                        $phenotype_names_not_hr,
                        $xgene_data_not,
                        $variation_name_hr_not);
    my $rnai_details_table = $self->_print_rnai_details_table($details, $phenotype_names_hr);
    my $rnai_not_details_table = $self->_print_rnai_details_table($details_not,$phenotype_names_not_hr);

    my $ret = { pheno_table => $pheno_table,
                pheno_table_not => $pheno_table_not,
                rnai_details_table => $rnai_details_table,
                rnai_not_details_table => $rnai_not_details_table,
    };
}

sub phenotype {
    my $self = shift;
    my $data = { description => 'The Phenotype summary of the gene',
		 data        => { pheno=>$self->phen_data->{pheno_table},	
				  pheno_not=>$self->phen_data->{pheno_table_not},
				},
	};

    return $data;    
}

sub rnai {
    my $self = shift;
    my $data = { description => 'The RNAi summary of the gene',
         data        => { rnai=>$self->phen_data->{rnai_details_table},
                  rnai_not=>$self->phen_data->{rnai_not_details_table},
                },
    };

    return $data;    
}

sub _print_rnai_details_table {

	my ($self, $rnai_details_ar, $phene_id2name_hr) = @_;
	my @array;
	foreach my $rnai_detail (@$rnai_details_ar) {
	
		my ($rnaix,$phenes,$genotype,$ref) = split /\|/,$rnai_detail;
		my @phenes = split /\&/, $phenes;
		my $ref_obj = $self->ace_dsn->fetch(-class=>'Paper', -name=>$ref);
		my $paper = $self->wrap($ref_obj);
		my $formated_ref = $paper->authors->{data}[0]->{label};	

		my @phenotype_set;
		my @row;

		foreach my $phene (@phenes) {
			push @phenotype_set,{  class=>'phenotype',
					      id=>$phene,
					    label=>$$phene_id2name_hr{$phene},
					    };
		
		}
		
		 
		 
		push @array, {rnai=> {  class=>'rnai',
					      id=>$rnaix,
					    label=>"$rnaix"
						},
			      phenotype=>\@phenotype_set,
			      genotype=>$genotype,
			      cite=>$self->_pack_obj($ref_obj,"$formated_ref et al."),
			};
		
	}
	
	 
	return \@array;
}

sub _print_phenotype_table {

    ## get data

    my ($self,$rnai_data_ar, $var_data_ar, $phenotype_id2name_hr, $xgene_data_ar, $var_id2name_hr) = @_;

    ## build data structures

    my %rnai_data;
    foreach my $rnai_data_line (@$rnai_data_ar) {

	    my ($phenotype_id,$experiment_count) = split /\|/,$rnai_data_line;
	    $rnai_data{$phenotype_id} = $experiment_count;

    }

    my %var_data;
    foreach my $var_data_line (@$var_data_ar) {

	    my ($phenotype_id,$var_list) = split /\|/,$var_data_line;
	    $var_data{$phenotype_id} = $var_list;

    }

    my %xgene_data;
    foreach my $xgene_data_line (@$xgene_data_ar) {

	    my ($phenotype_id,$xgene_list) = split /\|/,$xgene_data_line;
	    $xgene_data{$phenotype_id} = $xgene_list;

    }
    my @data;
    ## consolidate phenotype list and get phenotype names
    foreach my $phenotype_id (keys %$phenotype_id2name_hr ){ 

	    my $phenotype_link = {  class=>'phenotype',
				    id=>$phenotype_id,
				    label=>$$phenotype_id2name_hr{$phenotype_id},
				};
	    my $supporting_evidence;
	    ## variation evidence
	  
	    my @allele_links;
	    if ($var_data{$phenotype_id}) {
		    my @allele_set = split /\&/, $var_data{$phenotype_id};
		    foreach my $allele_data (@allele_set) {
			    my ($allele, $seq_status) = split /\+/,$allele_data;
			    my $var_name = $var_id2name_hr->{$allele};
			    my $boldface = ($seq_status =~ m/sequenced/i) ;
			    push @allele_links, {  class=>'variation',
				    id=>$allele,
				    label=>$var_name,boldface=>$boldface
				}; 
		    }
	    }
		    
	    $supporting_evidence->{allele} = \@allele_links;;
	    
	    ### xgene evidence
	    my @xgene_links;
	    if ($xgene_data{$phenotype_id}) { ###
		    my @xgene_set = split /\&/, $xgene_data{$phenotype_id};
		    my @xgene_links;
		    foreach my $xgene_data (@xgene_set) {
			    my ($xgene, $seq_status) = split /\+/,$xgene_data;	
			    push @xgene_links,  {id=>$xgene, label=>$xgene, class=>'gene'};#$self->_pack_obj($xgene);    
		    }
	    }

	    $supporting_evidence->{transgene} = \@xgene_links;; 
	    if ($rnai_data{$phenotype_id}) {
		    $supporting_evidence->{rnai} = $rnai_data{$phenotype_id} ;
	    }
	    push @data, {	id => $phenotype_link,
				evidence => $supporting_evidence,
			  }
    }

    return \@data;
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
	
		my $common_name     = $self->_public_name($target);
		push @stash,{ string => $string,
			      target => $self->_pack_obj($target, $common_name),
			      gene_regulation => $self->_pack_obj($gene_reg)};
	    }
	}
    }
    my $data = { description => 'Regulation on expression level',
         data        => \@stash,
    };
    return $data;
}


sub interactions {

    my $self = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    my $desc = "interactions gene is involved in";
    
    my $version = $self->ace_dsn->version;
    my $interaction_data_dir  = "/usr/local/wormbase/databases/$version/interaction";
    my  $datafile = $interaction_data_dir."/compiled_interaction_data.txt";


    my $gene_data_lines = `grep $object $datafile`;
    my @gene_data_lines = split /\n/,$gene_data_lines;
    
    my @interaction_data;
    foreach my $dataline (@gene_data_lines){
        
        chomp $dataline;
        my @dataline_set = split /\|/,$dataline;
        push @interaction_data,$dataline_set[0];
    }

    my %interaction_ret;
    map {$interaction_ret{"$_"} = { id => "$_", class => "interaction", label => "$_" }} @interaction_data;
    
    $data{'data'} = \%interaction_ret;
    $data{'description'} = $desc;
    return \%data;

}


###########################################
# Components of the Gene Ontology panel
###########################################

sub gene_ontology {

    my $self = shift;
    my $object = $self->object;
    my %data;
    my $desc = 'notes ;
                data structure = data{"data"} = {
                }';

    my %data_pack;

    #### data pull and packaging

    #my %go_terms;
    my @go_terms = $object->GO_term;
    
    my %annotation_bases  = (
        'EXP' , 'p',
        'IDA' , 'p',
        'IPI' , 'p',
        'IMP' , 'p',
        'IGI' , 'p',
        'IEP' , 'p',
        'ND'  , 'p',
        
        'IEA' , 'x',
        'ISS' , 'x',
        'ISO' , 'x',
        'ISA' , 'x',
        'ISM' , 'x',
        'IGC' , 'x',
        'RCA' , 'x',
        'IC'  , 'x'
    );

    

    foreach my $go_term (@go_terms){
      foreach my $code ($go_term->col){
        my @row = $code->row;
        my ($evidence_code,$method,$detail) = @row;
        my $display_method = method_detail($method,$detail);
        my $term = $go_term->Term;
        my $term_type = $go_term->Type;
        my $annotation_basis =  $annotation_bases{$evidence_code};
	$display_method =~ m/.*_(.*)/;
        my %data = (
            'display_method' => $1,
            'evidence_code' => $evidence_code,
            'term' => {id=>"$go_term", label=>"$term", class=>$go_term->class}
            
            ); 
        
        my @data = ($display_method,$evidence_code,$term,$go_term); 
        my $data_line = join ";",@data;
        $data_pack{$annotation_basis}{$term_type}{$data_line} = \%data;
      }
    }
    ####

    $data{'data'} = \%data_pack;
    $data{'description'} = $desc;
    return \%data;
}



###########################################
# Components of the Alleles panel
###########################################
# This could be generic. See also Variation.


sub reference_allele {

	my $self = shift;
	my $ref_alleles = $self ~~ '@Reference_allele' ;
	return unless $ref_alleles; 
	my @array;
	foreach my $reference_allele (@{$ref_alleles}) {
	    my $flanking_sequence = eval {$reference_allele->Flanking_sequences};
	    push @array, $self->_pack_obj($reference_allele,$reference_allele->Public_name,flanking_sequence=>$flanking_sequence?1:0);
	}
	 
	 
	my $data = { description => 'The reference allele of the gene',
		 data        => \@array,
	};

	return $data;    
}


sub alleles {

    my $self = shift;
    my $ace = $self->ace_dsn;
    my @all_alleles = map {$ace->fetch(Variation => $_) } @{$self ~~ '@Allele'}; 

    my (@alleles,@snps,@rflps,@insertions);
    foreach my $allele (sort @all_alleles) {
	my $name = $allele->Public_name;
	my $var_type = $allele->Variation_type;
    	if ($var_type=~ /allele/i) {
    		my $flanking_sequence = eval {$allele->Flanking_sequences};
    		my $mutation_type = $allele->Type_of_mutation;
    		push @alleles, $self->_pack_obj($allele,$name,flanking_sequence=>$flanking_sequence?1:0,mutaion_type=>$mutation_type);	
	}
	push @snps, $self->_pack_obj($allele,$name) if $allele->SNP(0) && !$allele->RFLP(0);
	push @rflps, $self->_pack_obj($allele,$name) if $allele->RFLP(0);
	push @insertions, $self->_pack_obj($allele,$name)  if $allele->Transposon_insertion;
    }
	
    my $data = { description => 'The alleles, snps, rflps? and insertions of the gene',
		 data        => {	alleles=>\@alleles,
					snps=>\@snps,
					rflps=>\@rflps,
					insertions=>\@insertions,
				}
    };

    return $data;  
}


sub strains {

	my $self = shift;
	my $object = $self->object;
    
	my (@strains,@singletons,@cgc,@others,@both, $count);
	foreach ($object->Strain(-filled=>1)) {
      $count++;
	  my @genes = $_->Gene;
	  my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;
	 
# 	  push @singletons,$self->_pack_obj($_) if (@genes == 1 && !$_->Transgene);
# 	  push @cgc,$self->_pack_obj($_) if $cgc;
# 	  push @others,$self->_pack_obj($_);
# 
#       my $ret = $self->_pack_obj($_);
#       $ret->{singleton}=1 if (@genes == 1 && !$_->Transgene);
#       $ret->{cgc}=1 if $cgc;
# 
#       push @strains, $ret;


      if (@genes == 1 && !$_->Transgene){
        if ($cgc){
          push @both, $self->_pack_obj($_);
        }
        push @singletons, $self->_pack_obj($_);
      }elsif($cgc){
        push @cgc, $self->_pack_obj($_);
      }else{
        push @others, $self->_pack_obj($_);
      }
	}
# 	push @strains, map { $_->{boldface}=1;$_ } sort { $a->{id} cmp $b->{id} } @singletons;
# 	push @strains, map { $_->{italicized}=1;$_ } sort { $a->{id} cmp $b->{id} } @cgc;
# 	push @strains,sort { $a->{id} cmp $b->{id} } @others;

	my $data = { description => 'strains carrying gene',
		    data        => { singleton => \@singletons,
                             both => \@both,
                             cgc => \@cgc,
                             other => \@others,
                             total => $count,
                            }
	};

	return $data;  

}


sub rearrangements{

    my $self = shift;
     
    my @rearrangement;
    my $gene=$self->name;
    my $id=$gene->{data}->{id};
    my $name = $gene->{data}->{label};
    push @rearrangement, { class=>'rearrangement',id=>"$id?position=include",label=>'include'};
    push @rearrangement, { class=>'rearrangement',id=>"$id?position=exclude",label=>'exclude'};
    push @rearrangement, { class=>'rearrangement',id=>$id,label=>"either include or exclude $name"};

    my $data = { description => 'rearrangements involving this gene',
		    data        => \@rearrangement,
	};

   return $data;  
}

###########################################
# Components of the Homology panel
###########################################

sub inparanoid_groups {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'homology groups for this gene determined via inparanoid method';

	my @data_pack;

	#### data pull and packaging
	
	 
    my %seen;
    my @inp = grep {!$seen{$_}++ } grep {$_->Group_type eq 'InParanoid_group' }
    map {$_->Homology_group} @{$self->all_proteins};
    
    foreach my $cluster (@inp) {
		my %proteins;
		foreach my $protein ($cluster->Protein) {
		
	   		my $species = $protein->Species || $self->id2species($protein) || 'unknown';
			my ($class,$id);
			if($self->wb_protein($species)){
			    $class    = "protein";
			   $id = $protein;
			}else{
			   $protein =~ /(\w+):(.+)/ ;
			   $class    = $1;
			   $id = $2;
			} 
			if($class eq 'ENSEMBL') {
			      (my $sp=$species) =~ s/ /_/g;
			      $id="$sp&$id" ;
			}
	   		push @{$proteins{$species}} , {
	   								'class' => "$class",
	   								'id' => "$id" ,
	   								'label' => "$protein",
	   								};
	   								
	      }
	      push @data_pack, $self->_pack_obj($cluster,'',proteins=>\%proteins);
	}							 
  
  $data{'data'} = \@data_pack;
  $data{'description'} = $desc;
  return \%data;
 
}	


sub paralogs {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'This genes paralogs';

	my @data_pack;

	#### data pull and packaging
	
	my @paralogs = $object->Paralog;
	@data_pack = map {$self->bestname($_);} @paralogs;
	 
	 

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub orthologs {

	my $self = shift;
	    my $object = $self->object;
	my %data;
	my $desc = 'this genes orthologs';
	my @data_pack;
			  
	#### data pull and packaging

	my @orthologs = $object->Ortholog;
# 	 my @orthologs = $object->at("Gene_info.Ortholog");
	#my $data_pack = $self->basic_package(\@orthologs);
	 
	for(my $index=0; my $ortholog=shift @orthologs;$index++) {
	   
# 	  my $ortholog_name = $self->public_name($ortholog,'Gene');
	  my $species = $ortholog->right;
# 	  my @analyses = $_->right->right->col;
	  push @data_pack, {	 species=>"$species",
				 ortholog=>$self->_pack_obj($ortholog,$self->bestname($ortholog)),
				 sequence=>{ class=>'ebsyn',
					      id=>$ortholog->Sequence_name,
					      label=>'syntenic alignment',
					  },
				 evidence=>{	check=>$self->check_empty($species),
						tag=>"Ortholog",
						index=>$index,
						right=>1,
					    }
			    };
	    
	}

	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

# NOTE: this is not used in display
sub ortholog_other {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'number of other ortologs';

	my $data_pack;

	#### data pull and packaging

	my @ortholog_others = $object->Ortholog_other;
	my $ortholog_others_count = @ortholog_others;
	$data_pack = $ortholog_others_count;
  
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

	my @data_pack;

	#### data pull and packaging
	
	 

	foreach  (@{$self->all_proteins}) {
		my $treefam = $self->_fetch_protein_ids($_,'treefam');
		# Ignore proteins that lack a Treefam ID
		next unless $treefam;
		push @data_pack, $treefam;
	}			
	## end classic code ##
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

###########################################
# Components of the Similarities panel
###########################################
sub best_blastp_matches {
    my $self     = shift;
    return  $self->SUPER::best_blastp_matches($self->all_proteins) ;
}



###########################################
# Components of the Reagents panel
###########################################
sub transgenes {
    my $self       = shift;
    my $object = $self->object;
    my %data;
    
    
    my @transgenes = $object->Drives_Transgene;
    @transgenes = map {$self->_pack_obj($_)} @transgenes;
    
    my $desc = 'transgenes driven by this gene';
    
    $data{'description'} = $desc;
    $data{'data'} = \@transgenes;
    
    return \%data;
    
}

sub transgene_products {
  my $self = shift;
  my $object = $self->object;

  my @transgene_products = map {$self->_pack_obj($_)} $object->Transgene_product;

  my $data = {  description =>  "Transgenes that express this gene",
                data    =>  \@transgene_products
              };
  return $data;
}

sub orfeome_project_primers {
  my $self = shift;
  my $object = $self->object;

  my @segments = @{$self->segments};
  my @ost = map {$self->_pack_obj($_)} map {$_->info} map { $_->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome') } @segments if ($object->Corresponding_CDS || $object->Corresponding_Pseudogene);

  my $data =    {   description =>  "ORFeome Project primers and sequences",
                    data    =>  \@ost
                };
  return $data;
}

sub primer_pairs {
    my $self     = shift;
    my $object = $self->object;
    
    return unless @{$self->sequences};
    
    my @segments = @{$self->segments};
    my @primer_pairs =  map {$self->_pack_obj($_)} map {$_->info} map { $_->features('PCR_product:GenePair_STS','structural:PCR_product') } @segments;

    my $data =    {   description =>  "Primer pairs",
                      data    =>  \@primer_pairs
                  };
    return $data;
}

sub microarray_probes {
    my $self     = shift;
    my $object = $self->object;
    my %seen;

    my @oligos =  
    grep {!$seen{$_}++}
    grep {$_->Type =~ /microarray_probe/}
    map {$_->Corresponding_oligo_set} $object->Corresponding_CDS if ($object->Corresponding_CDS);
    my @stash;
    foreach (@oligos) {
      my $comment = ($_->Type =~ /GSC/) ? 'GSC' : 
      ($_->Type =~ /Agilent/ ? 'Agilent' : 'Affymetrix');
      push @stash,$self->_pack_obj($_,"$_ [$comment]");
    }
    my $data = { description => "microarray probes",
                  data => \@stash
                };
    return $data;
}

sub sage_tags {
  my $self = shift;
  my $object = $self->object;

  my @sage_tags = map {$self->_pack_obj($_)} $object->Sage_tag;

  my $data = {  description =>  "SAGE tags identified",
                data    =>  \@sage_tags
              };
  return $data;
}

# Return a list of matching cDNAs

sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %data;
    
    my %unique;
    my @mcdnas = map {$self->_pack_obj($_)} grep {!$unique{$_}++} map {$_->Matching_cDNA} $object->Corresponding_CDS;
	
	$data{'description'} = 'matching cDNAs for gene';

	$data{'data'} = \@mcdnas;
	
	return \%data;
}

sub antibodies {
  my $self = shift;
  my $object = $self->object;

  my @antibodies = map {$self->_pack_obj($_)} $object->Antibody;

  my $data = {  description =>  "antibodies",
                data    =>  \@antibodies
              };
  return $data;
}
  
#### complex transformation ####


sub protein_domains {
	my $self = shift;
    my $object = $self->object;

	 
    my %unique_motifs;
    for my $protein (@{$self->all_proteins}) {
    	my @motifs;
    	@motifs	= $protein->Motif_homol;
		foreach my $motif (@motifs) {
          $unique_motifs{$motif->Title} = $self->_pack_obj($motif, $motif->Title) unless $unique_motifs{$motif->Title};
		}
	}
    my $data = { description => "protein domains of the gene",
                 data => \%unique_motifs
                };
	return $data;
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

  my $unique_remarks = 0;
  my %unique_remarks;
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
      my $count = $unique_remarks{$_};
      unless ($count) {
        $count = ++$unique_remarks;
        $footnotes{$sequence->name}{$count}{'note'} = $_;
        $footnotes{$sequence->name}{$count}{'evidence'} = $self->_get_evidence($_);
      } else {
        $footnotes{$sequence->name}{$count}++;
      }
      $unique_remarks{$_} = $count;
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



###########################################
# Components of the Expression panel
###########################################

sub fourd_expression_movies {
    my $self   = shift;
    my $object = $self->object;

    my %data;
    my %data_pack;
    
    my @eps = $object->Expr_pattern;
    @eps = eval{grep {($_->Author =~ /Mohler/ && $_->MovieURL)} @eps};
    
    foreach my $ep (@eps) {
        $data_pack{"$ep"}{movie} = $ep->MovieURL;
        $data_pack{"$ep"}{details} = $ep->Pattern;
        $data_pack{"$ep"}{object} = $self->_pack_obj($ep);
    }
    
    $data{'description'} = 'Interactive 4D expression movies';
    
    $data{'data'} = \%data_pack;
    return \%data;
}

sub anatomic_expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my %data_pack;
    
    my @eps = $object->Expr_pattern;
    @eps = eval{grep {!($_->Author =~ /Mohler/ && $_->MovieURL)} @eps};
    
    foreach my $ep (@eps) {
        $data_pack{"$ep"}{image} = $self->_pattern_thumbnail($ep);
        my $pattern =  join '', ($ep->Pattern(-filled=>1), $ep->Subcellular_localization(-filled=>1));
        $pattern    =~ s/(.{384}).+/$1\.\.\. /;
        $data_pack{"$ep"}{details} = $pattern;
        $data_pack{"$ep"}{object} = $self->_pack_obj($ep);
    }
    
    $data{'description'} = 'expression pattern data for gene';
    
    $data{'data'} = \%data_pack;
    return \%data;
}

#### implementation is view #####



#########################################
#
#   INTERNAL METHODS
#
#########################################

sub method_detail {
    my ($method,$detail) = @_;
    my $return;
    if ($method =~ m/Paper/){
        $return = "a_Manual";
    }
    elsif($detail =~ m/phenotype/i){
        $return = "b_Phenotype to GO Mapping";
    }
    elsif($detail =~ m/interpro/i){
        $return = "c_Interpro to GO Mapping";
    }
    elsif($detail =~ m/tmhmm/i){
        $return = "d_TMHMM to GO Mapping";
    }
    else {
        $return = "z_No Method"
    }
    return $return;
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
    my ($self) = @_;
    my $sequences = $self->sequences;
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
=pod
sub _fetch_database_ids {
    my ($self) = @_;
    my ($aceview,@refseq);
    # Fetch all DB IDs at once, uniquifying them
    # for genes at the same time
    my @dbs = $self->object->Database;
    foreach my $db (@dbs) {
	foreach my $type ($db->col) {
	    if ($db eq 'AceView') {
		$aceview = $type->right->name;
	    } elsif ($db eq 'RefSeq') {
		push (@refseq,map { "$_" } eval { $type->col });
	    }
	}
    }
    return [$aceview,\@refseq];
}
=cut

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

	my ($self, $rnai_ar, $var_ar) = @_;
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
	my %fullset_phene_id2name = build_hash($self->gene_pheno_datadir.$self->pre_compile->{phenotype_name_file});
	foreach my $phene_id (keys %phene_master) {
				
		$phene_id2name{$phene_id} = $fullset_phene_id2name{$phene_id};  ## $phene_primary_name
	}
	
	return \%phene_id2name;
}

#transgene info?
sub _get_xgene_data {

	my ($self, $gene, $positive_results) = @_; ## , $phenotype_ar
	
	my $gene_xgene_data; ## = `grep $gene $gene_pheno_datadir/$gene_variation_phene_file`;
	my $gene_xgene_phene_file = $self->gene_pheno_datadir.$self->pre_compile->{gene_xgene_phene_file};
	
	if($positive_results) {
	
		$gene_xgene_data = `grep $gene  $gene_xgene_phene_file | grep -v Not `;
	
	} else {
	
		$gene_xgene_data = `grep $gene $gene_xgene_phene_file | grep Not `;
	
	}
	
	#print "$gene_variation_data\n";
	
	my @gene_xgene_data = split /\n/, $gene_xgene_data;
	
	my %phenotype_xgene;
	
	foreach my $xgene_data_line (@gene_xgene_data) {
	
		my ($gene,$xgene,$phenotype,$not,$seq_stat)  = split /\|/, $xgene_data_line;
		$xgene = $xgene . "+" . $seq_stat;
		$phenotype_xgene{$phenotype}{$xgene} = 1;
		
	}
	
	my @return_data;

	foreach my $phene (keys %phenotype_xgene) {
	
		my $xgenes_hr = $phenotype_xgene{$phene};
		my @xgenes = keys %$xgenes_hr;
		my $xgenes_line = join "&", @xgenes;
		push @return_data, "$phene\|$xgenes_line";
	}

	return \@return_data;	
}

sub _get_phenotype_data {

	my ($self,$gene,$positive_results) = @_;
	
	my %rnai_phenotypes;
	my %rnai_genotype;
	my %rnai_ref;

	my $rnai_details = $self->gene_pheno_datadir.$self->pre_compile->{rnai_details_file};
	my  $gene_rnai_phene_file = $self->gene_pheno_datadir.$self->pre_compile->{gene_rnai_phene_file};

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
	
		$gene_phenotype_data = `grep $gene $gene_rnai_phene_file | grep -v Not `;
	
	} else {
	
		$gene_phenotype_data = `grep $gene $gene_rnai_phene_file | grep Not `;
	
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

	my ($self,$gene, $positive_results) = @_; ## , $phenotype_ar
	my $gene_variation_data; ## = `grep $gene $gene_pheno_datadir/$gene_variation_phene_file`;
	 
	my $gene_variation_phene_file = $self->gene_pheno_datadir.$self->pre_compile->{gene_variation_phene_file};
    
	if($positive_results) {
	
		$gene_variation_data = `grep $gene $gene_variation_phene_file | grep -v Not `;
	
	} else {
	
		$gene_variation_data = `grep $gene $gene_variation_phene_file | grep Not `;
	
	}
	
	#print "$gene_variation_data\n";
	
	my @gene_variation_data = split /\n/, $gene_variation_data;
	
	my %phenotype_variation;
	my %variation_id2name;

	foreach my $var_data_line (@gene_variation_data) {
	
		my ($gene,$var,$phenotype,$not,$seq_stat,$var_name)  = split /\|/, $var_data_line;
		$variation_id2name{$var} = $var_name;
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
	return \@return_data, \%variation_id2name	;
	
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



# helper method, retrieve public name from objects
sub _public_name {
    
    my ($self,$object) = @_;
    my $common_name;    
    my $class = eval{$object->class} || "";
   
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
      my $index=-1;
      @nodes = map {$index++; {text=>"$_", evidence=> {tag => $type,index=>$index, check => $self->check_empty($_)}}} @nodes;
      $ret{$type} = \@nodes if (@nodes > 0);
   }
   my $data = { description => "The structural description of the gene",
                data        =>  \%ret
   };
   return $data;
}




1;
