package WormBase::API::Object::Gene;

use Moose;

with    'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


###########################################
# Searches
#
# I think searches belong in their own class
###########################################
# This subroutine enables multi-tiered searches for Gene objects
# It returns both a Gene object, as well as a text string
# corresponding to the best name of the gene


#### rebuilt methods #####
# common_name
# ids
# concise_description
# kogs
# genomic_position
# anatomic_expression_patterns
# transgenes

#######################################################
# The Overview (formerly Identification) Panel
#######################################################
sub common_name {

	my %data;
	my %data_pack;
	
    my $self = shift;
    my $object = $self->object;
    my $common_name = 
	$object->Public_name
	|| $object->CGC_name
	|| $object->Molecular_name
	|| eval { $object->Corresponding_CDS->Corresponding_protein }
    || $object;
    
    $data_pack{$object} = $common_name;
    
    my $desc = 'The most commonly used name of the gene';
    
    
    $data{'desc'} = $desc;
    $data{'$data_pack'} = \%data_pack;
    
    return \%data;
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

	$data{'data_pack'} = \%data_pack;
	$data{'data_lists'} = \%data_lists;
	$data{'count'} = 'complex';
	$data{'desc'} = "Data for gene $object";
	
    return \%data;
}


sub ids {
    my $self   = shift;
    my $object = $self->object; ## shift
    
    my %data;
    my %data_pack;
     
    # Fetch external database IDs for the gene
    my ($aceview,$refseq) = $self->_fetch_database_ids($object);

    my $version = $object->Version;
    my $locus   = $object->CGC_name;
    my $common  = $object->Public_name;
    
   
    
    my @other_names = $object->Other_name;
    my @sequence_names = $object->Sequence_name;
    
    my @other_names_str = map {$_ = "$_"} @other_names;
    my @sequence_names_str = map {$_ = "$_"} @sequence_names;
    
    my $object_data = {
    
		common_name   => "$common",
		locus_name    => "$locus",
		version       => "$version",
		aceview_id    => "$aceview",
		refseq_id     => $refseq,
		version       => "$version",
		other_names	  => \@other_names,
		sequence_names => \@sequence_names

	};	
	
	$data_pack{$object} = $object_data;
	$data{'data_pack'} = \%data_pack; 
	$data{'desc'} = "Data for gene $object";

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

sub concise_description {

    my $self   = shift;
    my $object = $self->object;  
    my %data;
    my %data_pack;
    
    # The description, dervied from the Gene, the CDS, or the Gene_class.
    my $description = 
	$object->Concise_description
	|| eval {$object->Corresponding_CDS->Concise_description}
    || eval { $object->Gene_class->Description };
    
    # No description? Just describe it by its common name
    unless ($description) {
	my $common_name_dp = $self->common_name;
	$description = $common_name_dp->{data_pack}->{$object} . ' gene';
    }

    $data{'desc'} = "A manually curated description of the gene's function";
	$data_pack{$object} = $description;
	$data{'data_pack'} = \%data_pack;
    return \%data;
}


# Fetch all proteins associated with a gene.
## NB: figure out the naming convention for proteins

sub proteins {
    my $self   = shift;
    my $object = $self->object;
    my @cds    = $object->Corresponding_CDS;
    if (@cds) {
	my @proteins  = map { $_->Corresponding_protein } @cds;
	my @wrapped = $self->wrap(@proteins);
	return \@wrapped;
    }
}



# Fetch all CDSs associated with a gene.
## figure out naming convention for CDs

sub cds {
    my $self   = shift;
    my $object = $self->object;
    my @cds    = $object->Corresponding_CDS;
    
    if (@cds) {
	# Wrap these in WormBase API objects
	my @wrapped = $self->wrap(@cds);
	return \@wrapped;
    }
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
			$data{'data_pack'} = \%data_pack;

	    } else { 
	    
	    	$data_pack{$object} = 1;
	    
	    }
	}
    } else {
		$data_pack{$object} = 1;	
    }
    
    $data{'desc'} = "KOGs related to gene; data_pack->{gene_name} = array_ref of related KOGs or 1 indicating absence of data";
 	return \%data;
}




sub other_sequences {
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



# Build up the Gene Models data structure
# This is kind of a mess
sub gene_models {
    my $self   = shift;
    my $object = $self->object;
    my $data = {};

    my $sequences = $self->_fetch_transcripts();
    foreach my $sequence (@$sequences) {

	# We're going to fetch a bunch of information from the CDS
	# Is this transcript a CDS? It might be (althought it shouldn't be)
	my $cds = ($sequence->class eq 'CDS') ? $sequence : eval { $sequence->Corresponding_CDS };
	
	# Set the confirmation status
	my ($confirm,$remark,$protein,@matching_cdna);
	if ($cds) {
	    $confirm       = $cds->Prediction_status; # with or without being confirmed
	    @matching_cdna = $cds->Matching_cDNA; # with or without matching_cdna
	    $protein       = $cds->Corresponding_protein;
	}
	
	# Fetch all the notes for this given sequence / CDS
	my @notes = (eval {$cds->DB_remark},$sequence->DB_remark,eval {$cds->Remark},$sequence->Remark);
	
	# This would be better placed in a template, but it needs
	# so much convoluted processing to select the correct
	# I think I will leave it here for now.
	my $status;
	if ($confirm eq 'Confirmed') {
	    ####      $status = "confirmed by " .a({-href=>"#Reagents"}, "cDNA(s)");
	    $status = "confirmed by cDNA(s)";
	} elsif (@matching_cdna && $confirm eq 'Partially_confirmed'){
	    ####      $status = "partially confirmed by ".a({-href=>"#Reagents"}, "cDNA(s)");
	    $status = "partially confirmed by cDNA(s)";
	} elsif ($cds && $cds->Method eq 'history') {
	    $status = 'historical';
	} else {
	    $status = "predicted";
	}
	
	# Calculate the length of spliced/unspliced.
	# Maybe I should just return the sequence in the data structure, too.
#	my $species = $self->Species;	

	my $gff_service = $self->gff_dsn('c_elegans');
	my $gff_gene    = $gff_service->fetch_gff_gene($sequence);
	
	my ($length_unspliced,$length_spliced);
	if ($gff_gene) {
	    $length_unspliced = $gff_gene->length;
	    
	    for ($gff_gene->features('coding_exon')) {
		next unless $_->source eq 'Coding_transcript';
		next unless $_->name eq $sequence;
		$length_spliced += $_->length;
	    }
	    
	    # Try calculating the spliced length for pseudogenes
	    if (!$length_spliced) {
		my $flag = eval { $object->Corresponding_Pseudogene } || $cds;
		for ($gff_gene->features('exon:Pseudogene')) {
		    next unless ($_->name eq $flag);
		    $length_spliced += $_->length;
		}
	    }
	    $length_spliced ||= '-';
	}
	
	my ($translated_length,$protein_description);
	if ($protein) {
	    $translated_length = $protein->Peptide(2);
	    
	    # Assign a protein description. Does this belong here?
#	    $protein_description = $self->_select_protein_description($sequence,$protein);
	}

	push @{$data->{gene_models}},
	{
	    sequence => $sequence ? $self->wrap($sequence) : '' ,
	    notes    => \@notes,
	    status   => $status,
	    protein  => $protein ? $self->wrap($protein) : '',
#	    protein_description => $protein_description,
	    length_translated   => $translated_length || '',
	    length_unspliced    => $length_unspliced,
	    length_spliced      => $length_spliced,
	};
    }
    
    $data->{description} = 'gene model summary for the gene';
    return $data;
}

sub cloned_by {
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




# Object History.  This should be suitably generic and moved to Object.pm
sub history {
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
    
  	$data{'desc'} = 'genomic position for gene; structure data{\'data_pack\'}{longest_segment_id} = genomic position for longest segment';
  	$data{'data_pack'} = \%data_pack;
  	
    return \%data;
}


=head1 AWAITING DBH GFF serviceßß

sub genomic_environs {
    my $self   = shift;
    my $object = $self->object;
    
    my $sequences = $self->_fetch_sequences();
    my @segments = $self->_fetch_segments($sequences);
    
    my $longest = $self->_longest_segment(\@segments);
    return unless @$sequences;
    return unless $longest;
    
    my $species = $self->parsed_species($object);
    my (@tracks,%options);
    
    # Yuck. Species-specific junk.
    my $tracks;
    if ($species =~ /briggsae/) {
	$tracks = [qw/WBG/];  # Track names should be standardized
	%options = (ESTB => 2);
    } else {
	$tracks = $self->{image_tracks};   # Specified in the wormbase.yml
    }
    
    return ($self->build_gbrowse_img($longest,$tracks,\%options));
}

=cut


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
    
    $data{'desc'} = 'expression pattern image data for gene; structure data_pack{\'expression_pattern_id\'}{\'image\'} = 1 or 0 depending on availability of image.'. 
    
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

# TODO: Create a template (or javascript) that marks up arbitrary text
# with arbitrary symbols
    
#  foreach my $d (@description) {
#    $d =~ s/;\s+([A-Z]{2})(?=[;\]])
#      /"; ".$c->object2linkmanual($1,'Laboratory')
#	/exg;
#
#    # cross-reference genes
#    $d =~ s/\b([a-z]+-\d+)\b
#      /$c->object2linkmanual($1,'Locus')
#	/exg;
#    
#    # cross-reference other stuff
#    my %xref = map {$_=>$_} @xref;
#    $d =~ s/\b(.+?)\b/$xref{$1} ? $c->object2link($xref{$1}) : $1/gie;
#  }
    my $data = $self->build_data_structure(\@description,
					   'information from C. elegans I/II');
    return $data;
}



sub rnai_phenotypes {
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

# TEMPORARY - I think this logic ALL belongs in the view
#sub _parse_hash {
#  my ($self,$nodes) = @_;
#  
#  # Mimic the passing of an array reference. Blech.
#  $nodes = [$nodes] unless ref $nodes eq 'ARRAY';
#  
#  # The data structure - a hash of hashes, each pointing to an array
#  my $data = [];
#  
#  # Collect all the hashes available for each node
#  foreach my $node (@$nodes) {
#    # Save all the top level tags as keys in a perl
#    # hash for easier parsing and formatting
#    my %hash = map { $_ => $_ } eval { $node->col };
#    my $is_not = 1 if (defined $hash{Not});  # Keep track if this is a Not Phene annotation
#    push @{$data},{ node => $node,
#		    hash => \%hash,
#		    is_not => $is_not || 0,
#		  };
#  }
#  return $data;
#}


# Determine which of a list of Phenotypes are NOTs
# Return a sorted list of positive/not positive phenotypes
#sub _is_NOT_phene {
#  my ($self,$data) = @_;
#  my $positives = [];
#  my $negatives = [];
#  
#  foreach my $entry (@$data) {
#    if ($entry->{is_not}) {
#      push @$negatives,$entry;
#    } else {
#      push @$positives,$entry;
#    }
#    
#  }
#  return ($positives,$negatives);
#}

# Return the best name for a phenotype object.  This is really common_name...
# Pick the best display new for new Phenotype-ontology objects
# and append a short name if one exists
#sub _best_phenotype_name {
#    my ($self,$phenotype) = @_;
#    my $name = ($phenotype =~ /WBPheno.*/) ? $phenotype->Primary_name : $phenotype;
#    $name =~ s/_/ /g;
#    $name .= ' (' . $phenotype->Short_name . ')' if $phenotype->Short_name;
#    return $name;
#}



sub y1h_and_y2h_interactions {
    my $self   = shift;
    my $object = $self->object;
    
    # KLDUGE!   _y2h_data still needs $c. suckage.
    my ($bait_lists,$target_lists) = $self->_y2h_data($object,3);  # Limit to three baits/targets TEMPLATE
    
    my @stash;
    foreach my $entry (eval {@$bait_lists},eval {@$target_lists}) {
	push @stash,[$object,$entry->[0],$entry->[1],eval {$entry->[1]->Author . ' (' . parse_year($entry->[1]->Year) . ')' }];
    }
    return \@stash;
}


sub interactions {
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


sub microarray_expression_data {
    my $self   = shift;
    my $object = $self->object;
    
    return [ $object->Microarray_results ];
}


sub microarray_topology_map_position {
    my $self   = shift;
    my $object = $self->object;
    my $sequences = $self->_fetch_sequences();
    return unless $sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    
    my $seg = $segments[0] or return;
    my @stash = map {$_->info} $seg->features('experimental_result_region:Expr_profile') ;
    return \@stash;
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


sub protein_domains {
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




###########################################
# Components of the Gene Ontology panel
###########################################
sub gene_ontology {
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

###########################################
# Components of the Alleles panel
###########################################
# This could be generic. See also Variation.
sub alleles {
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




sub rearrangements {
    my $self   = shift;
    my $object = $self->object;
    return unless $object->Allele || $object->Reference_allele;
    return 1;  # True: we have alleles and therefore *may* have rearrangements.
}


###########################################
# Components of the Homology panel
###########################################
sub inparanoid_groups {
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


sub orthologs {
    my $self     = shift;
    my $object = $self->object;
    return [ $object->Ortholog ];
}


sub treefam {
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
    
    my $desc = 'transgenes driven by this gene; data_pack{transgene_id} = {\'common_name\' => transgene_id, \'class\' => \'Transgene\'}';
    
    $data{'desc'} = $desc;
    $data{'data_pack'} = \%data_pack;
    
    return \%data;
    
}

sub orfeome_project_primers {
    my $self     = shift;
    my $object = $self->object;
    my $sequences = $self->_fetch_sequences();
    return unless @$sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    my @stash =  map {$_->info} map { $_->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome') } @segments;
    return \@stash;
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
    
    $data{'desc'} = 'SAGE_tags for the gene; data_pack{tag_id} = {\'common_name\'=>tag_id, \'class\' => \'SAGE_tag\'}';
    
    $data{'data_pack'} = \%data_pack;
    
    
    return \%data;
}

# Return a list of matching cDNAs
sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %unique;
    my @stash = grep {!$unique{$_}++} map {$_->Matching_cDNA} $object->Corresponding_CDS;
    return \@stash if @stash;
}

sub antibodies {
    my $self     = shift;
    my $object = $self->object;
    my @stash;
    foreach my $antibody ($object->Antibody) {
    my $comment = $antibody->Summary;
    $comment    =~ s/^(.{100}).+/$1.../ if length $comment > 100;
    push @stash,[$antibody,$comment];
  }
  return \@stash;
}


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
#    my $dbh = $self->dbh_gff();
    my $dbh = $self->service('gff_c_elegans');
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


=head1 NAME
    
    WormBase::Model::Gene - Catalyst Model
    
=head1 DESCRIPTION
    
    Catalyst Model for the AceDB Gene class
    
=head1 METHODS

=head2 The Overview Panel

=over

=item $gene->common_name()

Returns:

  { common_name => W::API::O::Gene_name }

=item $gene->ids();

This is largely a convenience method that collects commonly used
IDs for a gene in one place. Each is accesible individually.
 
 Returns : { ids => { common_name => 'string',
                      name        => 'WBGene ID',
                      version     => Int,
                      refseq      => \@ of refseq IDs,
                      aceview     => 'string, aceview ID',
                    }
            }

=item $gene->concise_description()

 Returns : { concise_description => 'string' }

=item $gene->proteins()

 Returns : array reference of WB::API::Object::Protein objects
           corresponding to the gene

=item $gene->cds()

 Returns : array reference of WB::API::Object::CDS objects
           corresponding to the gene

=item $gene->kogs()

 Returns : array reference of WB::API::Object::Homolog_group objects
           for the gene, InParanoid excluded.

=item $gene->other_sequences()

 Returns : array reference of WB::API::Object::Sequence objects
           not always of the same species.

=item $gene->gene_models()

 Returns : array reference, each item a hash for a transcript
    {       sequence => WB::API::O::Sequence object,
	    notes    => \@notes,
	    status   => 'gene model status',
	    protein  => WB::API::O::Protein,
	    length_translated   => 'int',
	    length_unspliced    => 'int',
	    length_spliced      => 'int',
	};

=item $gene->cloned_by()

 Returns : { cloned_by => WB::API::Object::Author,
             tag       => 'string',
             source    => 'string'  }

=item $gene->history()

Returns : array reference, each item a hash of a history entry
  	    { type    => 'history event',
	      version => int,
	      date    => $date,
	      action  => 'history action',
	      remark  => $remarkk,
	      gene    => W::A::O::Gene if appropriate
	      curator => W::A::O::Person if appropriate
	    };
  









=item $self->reactome_knowledgebase($object)

 Returns : Array reference of reactome IDs
 Widget  :
 TODO    : need template and config for reactome URLs (actually URL constructor)






=item $self->genomic_position($object)

 Returns : Hash reference containing keys of:
             chromosome
             start
             stop
             operons (as an array ref)
 Widget  : location
 TODO    : This should probably become a generic template and perhaps method (current version is quite gene specific)

=item $self->genomic_environs($object)

 Returns : Hash reference containing keys of:
             img
             start
             stop
             species    -- for linking image
             chromosome -- for linking image 
 Widget  : location
 TODO    : This could reasonably be a generic tempalte and method,
           configurable based on the reference object or range
           There are also some hard-coded values that should be placed in configuration.
           Are temporary paths working as expected?

=item $self->fourd_expression_movies($object)

 Returns : array reference of 4-D expression patterns
 Widget  : expression
 TODO    : The template needs to link to the movies correctly.

=item $self->anatomic_expression_patterns($object)

 Returns : hash of arrays of expression patterns with images or without
           keys:
               have_image
               no_image
 Widget  : expression

=item $self->pre_wormbase_information($object)

 Returns : Array reference of pre-wormbase legacy descriptions
 Widget  : function
 TODO    : Need to markup genes, alleles, etc

=item $self->rnai_phenotypes($object)

 Returns : A big complicated data structure as a hash ref
 Widget  : function
 TODO    : Properly describe the return value. Check template.

=item $self->y1h_and_y2h_interactions($object)

 Returns : An array reference corresponding to a table of interactions.
 Widget  : function
 TODO    : Fold in Payan's new code; move parse year to a template function?
            Purge the need for $c from _y2_interactions

=item $self->interactions($object)

 Returns : 
 Widget  : function
 TODO    : Fold in Payan's new code; move parse year to a template function?

=item $self->microarray_expression_data($object)

 Returns : Array reference of microarray_results objects
 Widget  : function
 TODO    : Check template.  Could be suitably generic. Just a table.

=item $self->expression_cluster($object)

 Returns : Array reference of expression_cluster objects
 Widget  : function
 TODO    : Check template.  Could be suitably generic. Just a table.

=item $self->microarray_topology_map_position($object)

 Returns : Array reference corresponding to a list of experimental_result_regions from the GFF.
 Widget  : function
 TODO    : Check template.

=item $self->regulation_on_expression_level($object)

 Returns : Array of hashes
             keys:
                  string
                  target
                  Gene_regulation object
 Widget  : function
 TODO    : Check template.

=item $self->protein_domains($object)

 Returns : RETURN VALUE IN FLUX FOR NOW
 Widget  : function
 TODO    : TONS to do here.  Need to b=purge formatting and javascript. Move paths to configuration.

=head1 MIGRATION NOTES

=head1 AUTHOR

Todd W. Harris, Ph.D. (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut






1;
