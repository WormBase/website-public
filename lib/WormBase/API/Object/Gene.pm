package WormBase::API::Object::Gene;

use Moose;

with 'WormBase::API::Role::Object';

sub name {
    my $self = shift;
    my $ace  = $self->object;
#    $self->log->debug("here we are " . $self->ace_object);
    return $ace->name;
}


###################################################
# Methods overriding SUPER belong here.
###################################################
sub common_name {
    my $self = shift;
    my $object = $self->object;
    my $common_name = 
	$object->Public_name
	|| $object->CGC_name
	|| $object->Molecular_name
	|| eval { $object->Corresponding_CDS->Corresponding_protein }
    || $object;
    return $common_name;
}

###########################################
# Searches
#
# I think searches belong in their own class
###########################################
# This subroutine enables multi-tiered searches for Gene objects
# It returns both a Gene object, as well as a text string
# corresponding to the best name of the gene

=head1

sub search {
  my ($self,$query) = @_;  
  my $dbh = $self->ace_model;
  my (@results,%seen);
  
  # 1. Are we trying to fetch a WB* unique ID?
  if ($query =~ /^WBG.*\d+/) {
    @results = $dbh->fetch(-class=>'Gene',-name=>$query,-fill=>1);
    
    # What should the searches really be returning? This should be
    # specified in the configuration.
    # That is: I should have fields in a table, for example.
        
    # Probably no longer necessary as protein names are now Gene_name objects, too
    #    # 2. User is searching via a WormPep ID
    #  } elsif ($query =~ /^CE\d+/) {
    #    # Enable searches via a WormPep ID
    #    # allow users to type "CE12345" rather than "WP:CE12345"
    #    $query = "WP:$query" if $query =~ /^CE\d+/;
    #    if (my $protein = $DB->fetch(-class=>'Protein',-name=>$query,-fill=>1)) {
    #      my $CDS = $protein->Corresponding_CDS;
    #      # Fetch the corresponding gene for this CDS
    #      @genes = $CDS->Gene(-filled=>1) if $CDS;
    #    }
    # 3. Loci (unc-26) and Molecular IDs (R13A5.12)
    # Try searching the Gene_name class.  This should work for
    #   approved CGC names, non-approved names, genes, etc
  } elsif (my @gene_names = $dbh->fetch(-class=>'Gene_name',-name=>$query,-fill=>1)) {
    # HACK!  For cases in which a gene is assigned to more than one Public_name_for.
    @results = grep { !$seen{$_}++} map { $_->Public_name_for } @gene_names;
    
    @results = grep {!$seen{$_}++} map {$_->Sequence_name_for
					|| $_->Molecular_name_for
					  || $_->Other_name_for
					} @gene_names unless @results;
    undef @gene_names;
  } elsif (my @gene_classes = $dbh->fetch(-class=>'Gene_class',-name=>$query,-fill=>1)) {
    @results = map { $_->Genes } @gene_classes;
  } elsif (my @ests = $dbh->fetch(-class=>'Sequence',-name=>$query,-fill=>1)) {
    foreach (@ests) {
      if (my $gene = $_->Gene(-filled=>1)) {
	push @results,$gene;
      } elsif (my $cds = $_->Matching_CDS(-filled=>1)) {
	my $gene = $cds->Gene(-filled=>1);
	push @results,$gene if $gene;
      }
    }   
  } elsif (my @variations = $dbh->fetch(-class=>'Variation',-name=>$query,-fill=>1)) {
    @results = map { eval { $_->Gene} } @variations;
  }
  
  # Try finding genes using general terms
  # 1. Homology_group
  # 2. Concise_description
  # 3. Gene_class
  
  unless (@results) {
    my @homol = $dbh->fetch(-query=>qq{find Homology_group where Title=*$query*});
    @results = map { eval { $_->Protein->Corresponding_CDS->Gene } } @homol;
    push (@results,map { $_->Genes } $dbh->fetch(-query=>qq{find Gene_class where Description="*$query*"}));
    push (@results,$dbh->fetch(-query=>qq{find Gene where Concise_description=*$query*}));
  }
  
  # DEPRECATED!
  # Try fetching pseudogenes that have never been classified as loci
  # Is this still necessary?
  #  unless (@results) {
  #    my @transcripts = $dbh->fetch(-class=>'Pseudogene',-name=>$query);
  #	     my %seen;
  #    @results = map {$_->fetch} grep {!$seen{$_}++} map {$_->Gene} @transcripts;
  #  }
  
  # These may be gene predictions which remain only as CDS objects
  unless (@results) {
#    warn "CACHE: $query empty; falling through to CDS check";
    if (my $cds = $dbh->fetch(-class=>'CDS',-name=>$query)) {
      # HACK HACK HACK
      # FetchGene is called by the sequence page
      # Unfortunately, there are orphan CDSs with no attached Gene objects
      # and that are not tagged as history
      # The code below results in an endless Redirect
#      my $url = url();
#      if ($cds->Method eq 'twinscan') {
#	if ($url !~ /sequence/) {
#	  AceRedirect('sequence' => $cds);
#	} else {
#	  return $cds;
#	}
#      }
#      
#      # This could also test for the absence of a method
#      if ($url =~ /sequence/) {
#	AceRedirect('gene' => $cds) unless ($cds->Method eq 'history' || $cds->Method eq 'Genefinder' || $cds->Method eq '');
#      } else {
#	# We won't redirect to the sequence display if this is a history object
#	# In that case the Gene Page has a built in history display
#	AceRedirect('sequence'=>$cds) unless ($cds->Method eq 'history');
#      }
    }
  }
  
  # Analyze the Other_name_for of the Gene_name to see if the gene
  # corresponds to another named gene.
  my (@unique_genes);
  %seen = ();
  foreach my $gene (@results) {
    next if defined $seen{$gene};
    my $gene_name  = $gene->Public_name;
    my @other_names = eval { $gene_name->Other_name_for; };
    foreach my $other_name (@other_names) {
      if ($other_name ne $gene) {
	#warn "other: $other_name";
        #warn "gene: $gene";
#	push (@unique_genes,$other_name) unless defined $seen{$other_name};
	$seen{$other_name}++;
      }
    }


    push (@unique_genes,$gene);
    $seen{$gene}++;
  }

#  if (@unique_genes > 1 && !$suppress_multiples) {
#    MultipleChoices($query,\@unique_genes,$query);
#    exit 0;
#  }

  my $common_name = $self->common_name($unique_genes[0]);
  
  # See "searches/basic" for rational on this redirect over 
  # simply returning the object
  return unless @unique_genes > 0;
#  my $url = url();
#  my $abs = url(-query=>1);
#  if ($url =~ /gene\/gene/ && $url !~ /genetable/ && $abs !~ /details/) {
#      my $gene = $unique_genes[0];
#      redirect("/db/gene/gene?name=$gene;class=Gene");
#  } else {
  #  my @return;
  #  push @return, { public_name => $unique_genes[0]->name,
#		  description => $unique_genes[0]->Concise_description,
#		  name        => $unique_genes[0]->name,
#		};
#  return @return;

  # Store the gene for access in the template
  return \@results;
}

=cut


###########################################
# Components of the Identification widget
###########################################
# IDs are built almost entirely from the template
# This breaks REST
sub ids {
  my $self   = shift;
  return $self->object->name;
}

sub description {
  my $self   = shift;
  my $object = $self->object;  

  my %stash;
  my $description = $object->Concise_description;
  $description = eval {$object->Corresponding_CDS->Concise_description} unless $description;
  
  $description .= 
      eval { $object->Gene_class->Description } ? '' : ($description ? '' : $self->common_name($object) .' gene');
  
  # NONE OF THIS IS NECESSARY  - SHOULD BE PUSHED ONTO TEMPLATE.
  if (eval {$object->Provisional_description
		|| $object->Detailed_description
		|| $object->Corresponding_CDS->Provisional_description
		|| $object->Corresponding_CDS->Detailed_description}) {
      $stash{has_details}++;
  }
  
  $stash{text} = $description;
  return \%stash;
}

sub ncbi_kogs {
    my $self   = shift;
    my $object = $self->object;
    my $proteins = $self->_fetch_proteins($object);
    
    if (@$proteins) {
	my %seen;
	my @kogs = grep {$_->Group_type ne 'InParanoid_group' } grep {!$seen{$_}++} 
	map {$_->Homology_group} @{$proteins};
	return \@kogs if @kogs;
    }
    return undef;
}

sub reactome_knowledgebase {
    my $self     = shift;
    my $object   = $self->object;
    my $proteins = $self->_fetch_proteins($object);
    
    my $stash = $self->SUPER::reactome_knowledgebase($proteins);
    return $stash;
}

sub other_sequences {
    my $self   = shift;
    my $object = $self->object;
    return [ $object->Other_sequence ];
}

sub ncbi {
    my $self   = shift;
    my $object = $self->object;
    my ($entrez,$aceview,$refseq) = $self->_fetch_ncbi_ids($object) if $object->Corresponding_CDS;
    my %stash = (entrez => $entrez,
		 aceview => $aceview,
		 refseq     => $refseq);
    return \%stash;
}

sub gene_models {
    my $self   = shift;
    my $object = $self->object;
    my $stash  = {};
    my $sequences = $self->_fetch_sequences();
    
    my %unique_remarks;
    foreach my $sequence (sort { $a cmp $b } @$sequences) {
	# Need to fetch a variety of information from the CDS
	my $cds = ($sequence->class eq 'CDS') ? $sequence : eval { $sequence->Corresponding_CDS };
	
	# Set the confirmation status
	my ($confirm,$remark,$protein,@matching_cdna);
	if ($cds) {
	    $confirm = $cds->Prediction_status; # with or without being confirmed
	    @matching_cdna = $cds->Matching_cDNA; # with or without matching_cdna
	    $protein = $cds->Corresponding_protein(-fill=>1);
	}
	
	# Fetch all the notes for this given sequence / CDS
	my @notes = (eval {$cds->DB_remark},$sequence->DB_remark,eval {$cds->Remark},$sequence->Remark);
	
	# Track unique remarks for footnotes
	my $unique_remarks = 0;
	my (%footnotes);
	foreach (@notes) {
	    # Assign a number to each unique remark seen (or use that already assigned)
	    my $count = $unique_remarks{$_};
	    $count ||= ++$unique_remarks;
	    $unique_remarks{$_} = $count;
	    
	    # Track all notes seen for a given gene model
	    $footnotes{$sequence}->{$count}++;
	}
	
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
	} else{
	    $status = "predicted";
	}
	
	my $gff_model   = $self->dbh_gff;
	my $gff_gene    = $gff_model->fetch_gff_gene($sequence);
	
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
	
	my ($swissprot,$translated_length);
	if ($protein) {
	    $translated_length = $protein->Peptide(2);
	    
	    # ick. Specifically fetch a trembl idead
	    $swissprot = $self->_fetch_protein_ids($protein,'trembl');
	}
	
	# Assign a protein description
	my $protein_description = $self->_select_protein_description($sequence,$protein);
	
	my $footnote_string = join(',', sort { $a <=> $b } keys %{$footnotes{$sequence}});
	push @{$stash->{gene_models}},{ sequence            => $sequence,
					protein_description => $protein_description,
					length_unspliced    => $length_unspliced,
					length_spliced      => $length_spliced,
					protein             => $protein,
					translated_length   => $translated_length,
					swissprot           => $swissprot,
					status              => $status,
					footnotes           => $footnote_string,
	};
    }
    
    # Save all unique footnotes
    my %footnotes =  map { $unique_remarks{$_} => $_ } keys %unique_remarks;
    $stash->{footnotes}   = \%footnotes;
    $stash->{other_notes} = $self->_other_notes($object);
    return $stash;
}

sub cloned_by {
    my $self   = shift;
    my $object = $self->object;
    return $object->Cloned_by;
    my ($tag,$source) = eval { $object->Cloned_by->row };
    return "$tag $source";
    if ($tag && $tag =~ /(.*)_evidence/) {
	return ({evidence=>$1,source=>$source});
    }
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
    
    return unless @$sequences;
    
    my @segments = $self->_fetch_segments($sequences);
    
    # This is a kludge to handle situations where I've fetched an Ace object
    # corresponding to a Locus that has a CDS but no corresponding GFF segment. (rds-2)
    my $longest = $self->_longest_segment(\@segments);
    
    my $stash = $self->SUPER::genomic_position($longest);
    
    # Contained in an operon?
    my @operons = map {eval { $_->Contained_in_operon } } @$sequences;
    $stash->{operons} = (@operons) ? \@operons : undef;
    return $stash;
}


=head1 AWAITING DBH GFF service

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
    
    my %stash;
    my @all_ep     = $object->Expr_pattern;
    my @no_image   = grep{!$self->_pattern_thumbnail($_)} @all_ep;
    my @have_image = grep{ $self->_pattern_thumbnail($_)} @all_ep;
    
    my $s = @all_ep > 1 ? 's' : '';
    
    push @{$stash{no_image}},@no_image;
    push @{$stash{have_image}},@have_image;
    return \%stash;
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
    
    # fetch the description (phenotype) lines
    my @description = $object->Phenotype or return;
    
    my @xref = $object->Allele;
    push @xref,$object->Strain;
    
    # cross-reference laboratories
    # TODO!!
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
    return \@description;
}

# 2008.03.04: NOT COMPLETE, BUT CLOSE.  Lots of intertwined view code here.
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
		    my $dbh     = $self->ace_model;
		    $experiment = $dbh->fetch(RNAi => $experiment);
		    $phene      = $dbh->fetch(Phenotype => $phene);
		    
		    if ($evidence eq 'RNAi_primary' && $global_observed{$experiment}{$phene}) {
			my @inhibits = $experiment->Gene;
			if (@inhibits > 1) {
			    $reagents_nonspecific++;
			} else {
			    $reagents_specific++;
			}
		    }
		}
		
#	push @{$stash{$evidence}},[$c->object2link($phene,best_phenotype_name($phene)),
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
	@{$stash{not_observed}} = @not_observed ? join(", ", map {$self->best_phenotype_name($not_observed{$_})} keys %not_observed) : "";
	
	#####      @rows ? map { TR(td(\@$_)) } @rows : TR(td({-colspan=>3}, qq[No observed phenotype is found. For a list of phenotypes that were not observed,
	#####                                                                             mouseover to "Phenotype" header above. For more information, please follow the link below 
	#####                                                                             for the RNAi report of this gene.])));
    }
    
    return \%stash;
}


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
    ###		   td({-width=>'30%'},join('; ',
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
# NOT FINISHED!
sub rearrangements {
    my $self     = shift;
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
    
    my @stash;
    foreach my $protein (@$proteins) {
	my $treefam = $self->_fetch_protein_ids($protein,'treefam');
	
	# Ignore proteins that lack a Treefam ID
	next unless $treefam;
	my $id = $object->Sequence_name || $treefam;
	push @stash,[$id,$treefam];
    }
    return \@stash;
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
    return [ $object->Drives_Transgene ];
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
    my $self     = shift;
    my $object = $self->object;
    my @stash = grep {$_->Unambiguously_mapped(0) || $_->Most_three_prime(0)} $object->SAGE_tag;
    return \@stash if @stash;
}

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

# Fetch sequence-like objects for genes
sub _fetch_sequences {  
    my $self = shift;
    my $object = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $object->Corresponding_transcript;
    my @cds = $object->Corresponding_CDS;
    foreach (@cds) {
	next if defined $seen{$_};
	my @transcripts = grep {!$seen{$_}++} $_->Corresponding_transcript;
	push (@seqs,(@transcripts)? @transcripts : $_);
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
    my $dbh = $self->dbh_gff();
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
#  my $msg = $protein ? ObjectLink($protein) : $error;
    my $msg = $protein ? $protein : $error;
    return $msg;
}

# Aceview and entrez are unique to gene (although stored in CDS)
# refseq is unique to CDS - NM_* is mRNA ID.
sub _fetch_ncbi_ids {
    my ($self,$object) = @_;
    my ($aceview,$entrez,@refseq);
    # Fetch all DB IDs at once, uniquifying them
    # for genes at the same time
    my @cds = $object->Corresponding_CDS;
    foreach my $s (@cds) {
	my @dbs = $s->Database;
	foreach my $db (@dbs) {
	    foreach my $col ($db->col) {
		if ($col eq 'AceView') {
		    $aceview = $col->right;
		} elsif ($col eq 'RefSeq') {
		    push (@refseq,$col->right);
		} elsif ($col eq 'GeneID') {
		    #	} elsif ($col eq 'GI_number') {
		    $entrez = $col->right;
		}
	    }
	}
    }
    return ($entrez,$aceview,\@refseq);
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
		my $dbh = $self->ace_model;
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

=over

=item $self->common_name($object)

 Returns : Ace::Object::Gene_name
 Widget  : identification

=item $self->ids($object)

 Returns : Ace::Object::Gene
 Widget  : identification

=item $self->description($object)

 Returns : hash reference with keys of
           description and details
 Widget  : identification

=item $self->ncbi_kogs($object)

 Returns : array reference of Homology_group objects,
           InParanoid excluded.
 Widget  : identification
 TODO    : Simple list; could be generic template

=item $self->reactome_knowledgebase($object)

 Returns : Array reference of reactome IDs
 Widget  :
 TODO    : need template and config for reactome URLs (actually URL constructor)

=item $self->other_sequences($object)

 Returns : Array reference of Other_sequence objects
 Widget  : identification
 TODO    : Simple list; could be generic template

=item $self->ncbi($object)

 Returns : Hash reference keyed by names of NCBI IDs
 Widget  : identification

=item $self->gene_models($object)

 Returns : Hash reference with various entries for the gene model table
 Widget  : identification

=item $self->cloned_by($object)

 Returns : Hash reference containing keys of evidence and source
 Widget  : identification
 TODO    : This could be a suitable generic hash

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
