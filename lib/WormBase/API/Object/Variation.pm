package WormBase::API::Object::Variation;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


############################################################
#
# The Overview widget
#
############################################################
sub name {
    my $self = shift;
    my $ace  = $self->object;
    my $data = { description => 'The object name of the variation',
		 data        => $ace->name
    };
    return $data;
}

sub common_name {
    my $self = shift;
    my $object = $self->object;
    my $name = $object->Public_name;
    my $data = { description => 'The public name of the variation',
		 data        => $name,
    };
    return $data;
}

sub cgc_name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The Caenorhabditis Genetics Center (CGC) name for the gene',
		 data        => $object->CGC_name,
    };
    return $data;
}

sub other_names {
    my $self   = shift;
    my $object = $self->object;
    my @others = $object->Other_name;
    my %others;
    foreach (@others) {
	$others{$_->name} = 'Variation';
    }
    my $data   = { description => 'other possible names for the variation',
		   data        => \%others
    };
    return $data;
}

# What broad type of allele is this? EG KO, SNP, allele, etc
sub variation_type {
    my $self = shift;
    my $object = $self->object;
    my $type;
    if ($object->KO_consortium_allele(0)) {
	$type = "Knockout Consortium allele";
    } elsif ($object->SNP(0) && $object->RFLP(0)) {
	$type = 'polymorphism; RFLP';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";       
    } elsif ($object->SNP(0) && !$object->RFLP(0)) {
	$type  = 'polymorphism';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";
    } elsif ($object->Natural_variant) {
	$type = 'natural variant';
    } else {
	$type = 'allele';
    }
    my $data = { description => 'the general type of the variation',
		 data        => $type
    };
    return $data;
}

sub remarks {
    my $self    = shift;
    my $object  = $self->object;
    my @remarks = $var->Remark;
    my $data    = { description  => 'curator remarks for the variation',
		    data         => \@remarks,
		    has_evidence => 1,
			
    };
    return $data;
}


############################################################
#
# The Molecular Details widget
#
############################################################
sub type_of_mutation {
    my $self   = shift;
    my $object = $self->object;
    my $type   = $object->Type_of_mutation;

    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
	$type = 'transposon insertion';
    }

    my $data = { description => 'the type of mutation and its molecular change',
		 data        => "$type",				  
    };
    return $data;
}    

# Returns a data structure containing
# wild type sequence - the wild type (or reference) sequence
# mutant sequence - the mutant sequence
# wild type label - the source (background) of the wild type sequence
# mutant label    - the source (background) of the mutation
sub nucleotide_change {
    my $self   = shift;
    my $object = $self->shift;

    # Nucleotide change details (from ace)
    my $variations = $self->_compile_nucleotide_changes($object);
    my $data = { description => 'raw nucleotide changes for this variation',
		 data        => $variations,
    };
    return $data;    
}
   
sub variation_coordinates {
    my $self = shift;
    my $var  = $self->object;
    my $segment = $self->_get_genomic_segment(-key => 'wt_variation');
    my ($chrom,$start,$stop) = $self->_coordinates($segment);
    my $data = { description => 'The coordinates of the variation',
		 data        => { chromosome => $chrom,
				  start      => $start,
				  stop       => $stop,
		 },
    };
    return $data;
}

sub flanking_sequences {
    my $self = shift;
    my $object = $self->object;
    my ($left_flank,$right_flank);
    my $left_flank  = $var->Flanking_sequences(1);
    my $right_flank = $var->Flanking_sequences(2);
    my $data = { description => 'probes used for CGH of deletion alleles',
		 data        => { left_flank => $left_flank,
				  right_flank => $right_flank,
		 },
    };
    return $data;    
}


sub cgh_deleted_probes {
    my $self  = shift;
    my $object = $self->object;

    my ($left_flank,$right_flank);    
    $left_flank  = $var->CGH_deleted_probes(1);
    $right_flank = $var->CGH_deleted_probes(2);       

    my $data = { description => 'probes used for CGH of deletion alleles',
		 data        => { left_flank => $left_flank,
				  right_flank => $right_flank,
		 },
    };
    return $data;
}


# Show the variation in context.
# This method contains substantive view logic.
# Oh well, it's still useful.
sub context {
    my $self   = shift;
    my $object = $self->object;

    # Display a formatted string that shows the mutation in context
    my $flank = 250;
    my ($wt,$mut,$wt_full,$mut_full,$debug)  = $data->build_sequence_strings(-with_markup => 1);
    my $data = { description => 'wildtype and mutant sequences in an expanded genomic context',
		 data        => { wildtype_fragment => $wt,
				  wildtype_full     => $wt_full,
				  mutant_fragment   => $mut,
				  mutant_full       => $mut_full,
				  wildtype_header   => "> Wild type N2, with $flank bp flanks<br>$wt_full",
				  mutant_header     => "> $var with $flank bp flanks<br>$mut_full"
		 },
    };
    return $data;
}

sub deletion_verification {
    my $self = shift;
    my $object = $self->object;
    
    my $data = { description => 'the method used to verify deletion alleles',
		 data        => $object->Deletion_verification,
    };
    return $data;
}
    


# Display the position of the variation within a number of features
# Foreach item that the variation is known to affect, display a table
# with variation coordinates relative to the feature
sub features_affected {
    my $self   = shift;
    my $object = $self->object;

    # This is mostly constructed from Molecular_change hash associated with
    # tags in Affects, with the exception of Clone and Chromosome
    my $affects = {};
    foreach my $tag (qw/Pseudogene Transcript Predicted_CDS Gene Clone Chromosome/) {
 	my @container;
 	if (my @entries = eval { $object->$tag }) {
 	    # Parse the Molecular_change hash for each feature
 	    my $parsed_data;
 	    foreach my $entry (@entries) {
 		my @data = $entry->col;
 		next unless @data;
		my $hash_data  = ParseHash(-nodes => $entry);
 		
 		# do_translation is a flag controlling whether or not
 		# we should undertake a conceptual translation for this affected feature
 		# See FormatMolecularChangeHash for details
 		my ($cells,$do_translation) = FormatMolecularChangeHash(-data => $hash_data,
 									-tag  => $tag);

 		# Um. What *exactly* is @$cells?
 		if ($cells) {
 		    foreach (@$cells) {
			push @{$affects->{$tag}->{$entry}->{affects}},map { $_ } @$_;
 		    }
 		}
 		
 		# Display a conceptual translation, but only for Missense
 		# Nonsense, and Frameshift alleles within exons
 		if ($tag eq 'Predicted_CDS' && $do_translation) {

		    # Is the amino acid change stored in Ace?
 		    my $aa_type = $self->_aa_type;
 		    if ($aa_type) {
 			my ($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug);
 			($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug) 
 			    = $self->_do_simple_conceptual_translation(-cds => $entry);
 			unless ($wt_snippet) {
 			    ($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug) 
 				= $self->_do_manual_conceptual_translation(-cds => $entry);
 			}
 	
			$affects->{$tag}->{$entry}->{wildtype_trnaslation_snippet} = $wt_snippet;
			$affects->{$tag}->{$entry}->{mutant_translation_snippet} = $mut_snippet;
			$affects->{$tag}->{$entry}->{wildtype_translation_full} = $wt_full;
			$affects->{$tag}->{$entry}->{mutant_translation_full} = $mut_full;
			
		    }
		}
	    
		# Get the coordinates in the feature
 		my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$entry);
		$affects->{$tag}->{$entry}->{abs_start} = $abs_start;
		$affects->{$tag}->{$entry}->{abs_start} = $abs_stop;
		$affects->{$tag}->{$entry}->{fstart} = $fstart;
		$affects->{$tag}->{$entry}->{fstop} = $fstop;
		$affects->{$tag}->{$entry}->{start} = $start;
		$affects->{$tag}->{$entry}->{stop} = $stop;

		# Save the class of the feature for template linking.
		$affects->{$tag}->{$entry}->{class} = $entry->class;

 	    }
 	} else {
 	    # Clone must come from the Sequence tag
 	    my @affects;
 	    if ($tag eq 'Clone') {
 		@affects = $var->Sequence if $var->Sequence;
 	    } 
 
#	    elsif ($tag eq 'Chromosome') {
#		# And fetch the chromosome from the Clone
#		my ($chrom) = eval { $var->Sequence->Interpolated_map_position(1) };
#		@affects = $chrom->name if $chrom;
#	    }

 	    foreach (@affects) {
 		
 		push @container,start_div({-style=>"background-color:$color;padding:5px;"});
 		push @container,ObjectLink($_);

		$affects->{$tag}->{$object->Sequence}->{class} = $object->Sequence->class if $object->Sequence;
 		
 		my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$_);
		$affects->{$tag}->{$entry}->{abs_start} = $abs_start;
		$affects->{$tag}->{$entry}->{abs_start} = $abs_stop;
		$affects->{$tag}->{$entry}->{fstart} = $fstart;
		$affects->{$tag}->{$entry}->{fstop} = $fstop;
		$affects->{$tag}->{$entry}->{start} = $start;
		$affects->{$tag}->{$entry}->{stop} = $stop;

 	    }
 	} 	
    }

    my $data = { description => 'genomic features affected by this variation',
		 data        => $affects,
    };
    return $data;
}


sub flanking_pcr_products {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'PCR products that flank the variation',
		 data        => { $object->PCR_product }
    };
    return $data;
}




# OOOH!  Need to handle this.
#++ 					 'variation and motif image',p(motif_picture(1,$entry)));




############################################################
#
# The Location widget
#
############################################################
sub genetic_position {
    my $self = shift;
    my $object = $self->object;

   my ($chrom,$position,$error);
   if ($object->Interpolated_map_position) {
     ($chrom,$position,$error) = $object->Interpolated_map_position(1)->row;
   } elsif ($object->Map) {
     ($chrom,undef,$position,undef,$error) = $object->Map(1)->row;
   }
    
    unless ($chrom) {
	# Try fetching from sequence
	if (my $sequence = $object->Sequence) {
	    $chrom = $sequence->Interpolated_map_position(1);
	    $position = $sequence->Interpolated_map_position(2);
	} 
    }
    
    unless $chrom {
	if (my $gene = $object->Gene) {
	    if (my $m = $gene->get('Map')) {
		($chrom,undef,$position,undef,$error) = $gene->Map(1)->row;
	    } else {
		if (my $m = $gene->get('Interpolated_map_position')) {
		    ($chrom,$position,$error) = $m->right->row;
		}
	    }
	}
    }

    # Build a link to the genome browser. Not optimal here.
    my $gb_url;

    my ($start,$stop) = ($position-0.5,$position+0.5);
    my $gb_url = 
	$position
 	  ? a({-href=>Url('pic',"name=$chrom;class=Map;map_start=$start;map_stop=$stop")},
 	      sprintf("$chrom:%2.2f +/- %2.3f cM",$position,$error))
 	  : a({-href=>Url('pic',"name=$chrom;class=Map")},
 	      $chrom);
    
    my $data = { description => 'the genetic position of the variation (if known)',
		 data        => { chromosome => $chrom,
				  position   => $position,
				  error      => $error,
				  gb_url     => $gb_url,
		 },
    };

    return $data;
}


sub genomic_position {
    my $self = shift;
    my $object = $self->object;
    my $chrom_coords = $data->chrom_coordinates(-link => 1);
    my $data = { description => 'the genomic coordinates of the variation',
		 data        => $chrom_coords
    };
    return $data;
}

# Create a genomic picture
# This is far simpler than the manual approach below but doesn't give me as much
# flexibility
sub genomic_image {
    my $self = shift;
    my $var  = $self->object;
    my $gene = $var->Gene;
    #  my $segment = $GFFDB->segment(Gene => $gene);
    my $segment;
    
    # By default, lets just center the image on the variation itself.
    # What segment should be used to determine the baseline coordinates?
    # Use a CDS segment if one is provided, else just show the genomic environs
    unless ($segment) {
	# Try fetching a generic segment
	my ($ref,$low,$high) =  $self->_chrom_coordinates;
	my $split = UNMAPPED_SPAN / 2;
	
	($segment) = $GFFDB->segment($ref,$low-$split,$low+$split);
    }
    return unless $segment;
 
   my $absref   = $segment->abs_ref;
   my $absstart = $segment->abs_start;
   my $absend   = $segment->abs_end;
   ($absstart,$absend) = ($absend,$absstart) if $absstart > $absend;
   my $length = $segment->length;
 
   # add another 10% to left and right
   my $start = int($absstart - 0.1*$length);
   my $stop  = int($absend   + 0.1*$length);
   my $db = $segment->factory;
   my ($new_segment) = $db->segment(-name=>$absref,
 				   -start=>$start,
 				   -stop=>$stop);
   $BROWSER->source('elegans');
 
   # This should contain one track for the current allele,
   # and a seperate track for additional alleles
    my $img = $BROWSER->render_panels(
 				    {
 				      segment       => $new_segment,
 				      drag_n_drop   => 0,
 				      options       => { ESTB => 2 },
 				      tracks        => [
 							'CG',
 							'Allele'
 							'TRANSPOSONS',
 							# 'CANONICAL',
 							],
 				      title  => "Genomic segment: $absref:$absstart..$absend",
 				      do_map  => 0,
 					  # Purge post WS182 - functionality provided by gBrowse now
 					  # tmpdir  => AppendImagePath('variation'),
 					  label_scale => 1
				      }
 				    );
   $img =~ s/border="0"/border="1"/;
   $img =~ s/detailed view/browse region/g;
   $img =~ s/usemap=\S+//;
 
#++   return a({-href=>HunterUrl($absref,$start,$stop)},$img);
    
    my $data = { description => 'a link to the genome browser',
		 data        => { absref => $absref,
				  start  => $start,
				  stop   => $stop,
				  img    => $img,
		 },
    };
    return $data;
    
}



############################################################
#
# PRIVATE METHODS
#
############################################################

# What is the length of the mutation?
# (Previously, this was done from the GFF itself.  This is better).
sub _compile_nucleotide_changes {
    my ($self,$var) = @_;
    my @types = eval { $var->Type_of_mutation };
    my @variations;
    
    # Some variation objects have multiple types
    foreach my $type (@types) {
	my ($mut,$wt,$mut_label,$wt_label);

	# Simple insertion?
	#     wt sequence = empty
	# mutant sequence = name of transposon or the actual insertion sequence 
	if ($type =~ /insertion/i) {
	    $wt = '';

	    # Is this a transposon insertion?
	    # mutant sequence just the name of the transposon
	    if ($var->Transposon_insertion || $var->Method eq 'Transposon_insertion') {
		$mut = $var->Transposon_insertion;
		$mut ||= 'unknown' if $var->Method eq 'Transposon_insertion';
	    } else {
		# Return the full sequence of the inertion.
		$mut = $type->right;
	    }

	} elsif ($type =~ /deletion/i) {
	# Deletion.
	#     wt sequence = the deleted sequence
	# mutant sequence = empty
	    $mut = '';

	# We need to extract the sequence from a GFF store.
	
        # Get a segment corresponding to the deletion sequence
        # WAS: $self->variation_segment;
                  # eg: sub variation_segment { re{turn shift->{segments}->{wt_variation}; }
	    my $segment = $self->_get_genomic_segment(-key => 'wt_variation');
	    if ($segment) {
		$wt  = $segment->dna;
	    }

	    # CGH tested deletions.	    
	    $type = "definite deletion" if  ($var->CGH_deleted_probes(1));


	# Substitutions
        #     wt sequence = um, the wt sequence
	# mutant sequence = the mutant sequence
	} elsif ($type =~ /substitution/i) {
	    my $change = $type->right;
	    ($wt,$mut) = eval { $change->row };

	    # Ack. Some of the alleles are still stored as A/G.
	    unless ($wt && $mut) {
		$change =~ s/\[\]//g;
		($wt,$mut) = split("/",$change);
	    }
	}

	# Set wt and mutant labels
	if ($var->SNP(0) || $var->RFLP(0)) {
	    $wt_label = 'bristol';
	    $mut_label = $var->Strain;  # CB4856, 4857, etc
	} else {
	    $wt_label  = 'wild type';
	    $mut_label = 'mutant';
	}
	
	push @variations,{ type           => $type,
			   wildtype       => $wt,
			   mutant         => $mut,
			   wildtype_label => $wt_label,
			   mutant_label   => $mut_label,
	};	
    }
    return \@variations;
}


# Genomic segment getter/setter.
# Not very Moose-like, but it's expedient.
# keys:
# This may be a segmenet spanning a single variation
# Type will be used to store the segment in the object
# Pass an object to fetch that segment
 
sub _get_genomic_segment {
    my ($self,@p) = @_;
    my ($class,$start,$stop,$refseq,$key) = rearrange([qw/CLASS START STOP REFSEQ KEY/],@p);

   
    if (my $segment = $self->{segments}->{$key}) {
	return $segment;
    }

    # Fetch the object
    my $var = $self->object;

    # Get a GFFdb handle - I'm not sure how to do this in the API.
    my $db   = $self->gff;

    my $segment;

    # Am I trying to fetch a a specific segment with start and stop coords?
    if ($refseq && $start && $stop) {
	$segment = $db->segment(-name=>$refseq,-start=>$start,-stop=>$stop);

    # Am I trying to fetch a specific segment.
    } elsif ($refseq) {
	$segment = $db->segment(-name=>$refseq,-class=>$refseq->class);

    # Otherwise, fetch a segment for the variation.
    } else {
	$class ||= $var->class;
	$segment = $db->segment($class => $var);
    }
    
    $self->{segments}->{$key} = $segment if $segment;
    return $segment;
}


# Return the genomic coordinates of a provided span
sub _coordinates {
    my ($self,$segment) = @_;
    my $abs_start = $segment->abs_start;
    my $abs_stop  = $segment->abs_stop;
    my $start     = $segment->start;
    my $stop      = $segment->stop;
    return ($abs_start,$abs_stop,$start,$stop);
}




 
# Build short strings (wild type and mutant) flanking
# the position of the mutant sequence in support of the context() method.
# If a mutation sequence (insertion or deletion) exceeds
# INDEL_DISPLAY_LIMIT, a string will be inserted unless
# the --all option is supplied.
# Options:
# --all    Don't truncate long strings: return the full flank-mutant-flank
# --boldface Boldface the mutation
# --flank amount of flank to include. Defaults to SNIPPET_LENGTH
#
# Returns (wt(+), mut(+), wt(-), mut(-));
sub _build_sequence_strings {
    my ($self,@p) = @_;
    my ($with_markup,$flank) = rearrange([qw/WITH_MARKUP FLANK/],@p);
    
    my $db         = $self->gff;
    my $var        = $self->object;
    my $segment    = $self->_get_genomic_segment(-key => 'wt_variation');
    return unless $segment;
    
    my $sourceseq  = $segment->sourceseq;
    my ($abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
    
    my $debug;
    $debug .= "VARIATION COORDS: $abs_start $abs_stop $start $stop" . br if (DEBUG_ADVANCED);
    
    # Coordinates are sometimes reported on the minus strand
    # We will report all sequence strings on the plus strand instead.
    my $strand;
    if ($abs_start > $abs_stop) {
 	($abs_start,$abs_stop) = ($abs_stop,$abs_start);
 	$strand eq '-';  # Set $strand - used for tracking
    }
    
    # Fetch a segment that spans the mutation with the appropriate flank
    # on the plus strand
    
    # The amount of flanking sequence to recover should be configurable
    # Right now, it is hardcoded for 500 bp
    my $offset = 500;
    my ($full_segment) = $db->segment(-class => 'Sequence',
				      -name  => $sourceseq,
				      -start => $abs_start - $offset,
				      -stop  => $abs_stop  + $offset);
    my $dna = $full_segment->dna;
    $debug .= "WT SNIPPET DNA FROM GFF: $dna" . br if DEBUG_ADVANCED;
    
    # Visit each variation and create a formatted string
    my ($wt_fragment,$mut_fragment,$wt_plus,$mut_plus);
    my $variations = $self->_compile_nucleotide_changes($var);
    
    foreach my $variation (@{$variations}) {
	my ($type,$wt,$mut) = @{$variation};
 	my $extracted_wt;
 	if ($type =~ /insertion/i) {
 	    $extracted_wt = '-';
 	} else {
 	    my ($seg) = $db->segment(-class => 'Sequence',
				     -name  => $sourceseq,
				     -start => $abs_start,
				     -stop  => $abs_stop);
 	    $extracted_wt = $seg->dna;
 	}
 	
 	if (DEBUG_ADVANCED) {
 	    $debug .= "WT SEQUENCE EXTRACTED FROM GFF .. : $extracted_wt" . br;
 	    $debug .= "WT SEQUENCE STORED IN ACE ....... : $wt" . br;
 	    $debug .= "MUT SEQUENCE STORED IN ACE ...... : $mut" . br;
 	    $debug .= "LENGTH OF VARIATION ............. : " . length($extracted_wt) . ' bp' . br;
 	}
	
 	# Does the sequence we have extracted match that stored in the
 	# database?  Stated another way, is the mutation reported on the
 	# plus strand?
 	
 	# Insertions will have no sequence and I should not be able to
 	# extract any either (We use logical or here to check for the
 	# $strand flag. Sometimes insertions or deletions will have no
 	# sequence.
 	
 	if ($wt eq $extracted_wt && $strand ne '-') {
 	    # Yes, it has.  Do nothing.
 	} else {
 	    $debug .= "-----> TRANSCRIPT ON - strand; revcomping" if DEBUG_ADVANCED;
 	    # The variation and flanks have been reported on the minus strand
 	    # Reverse complement the mutant sequence
 	    $strand = '-';  # Set the $strand flag if not already set.
 	    unless ($mut =~ /transposon/i) {
 		$mut = reverse $mut;
 		$mut =~ tr/[acgt]/[tgca]/;
 		
 		$wt = reverse $wt;
 		$wt =~ tr/[acgt]/[tgca]/;
 	    }
 	} 
	
	# Keep the full string of the all variations on the plus strand 
	$wt_plus  .= $wt;
	$mut_plus .= $mut;
	
	# What is the type of mutation? If deletion or insertion,
	# check the length of the partner, then format appropriately
	# Hard code the INDEL_DISPLAY_LIMIT for now
	my $INDEL_DISPLAY_LIMIT = 100;
 	if (length $mut > $INDEL_DISPLAY_LIMIT || length $wt > $INDEL_DISPLAY_LIMIT) {
 	    if ($type =~ /deletion/i) {
 		my $target = length ($wt) . " bp " . lc($type);
 		$wt_fragment  .= "[$target]";
 		$mut_fragment .= '-' x (length ($target) + 2);
 	    } elsif ($type =~ /insertion/i) {
 		my $target;
 		if ($mut =~ /transposon/i) {  # String representing transposon insertions
 		    $target = $mut;
 		} else {
 		    $target = length ($mut) . " bp " . lc($type);
 		}
 		#  $mut_fragment .= '[' . a({-href=>$href,-target=>'_blank'},$target) . ']';
 		$mut_fragment .= "[$target]";
 		#  $wt_fragment  .= '-' x (length($mut_fragment) + 2);
 		$wt_fragment  .= '-' x (length($mut_fragment));
 	    }
 	} else {
 	    # We are less than 100 bp, go ahead and use it.
 	    $wt_fragment  .= ($wt  eq '-') ? '-' x length $mut  : $wt;
 	    $mut_fragment .= ($mut eq '-') ? '-' x length $wt : $mut;
 	}
    }
    
    # Coordinates of the mutation within the segment
    my ($mutation_start,$mutation_length);
    if ($strand eq '-') {
 	# This works for e205 substition (-)
 	$mutation_start   = $offset;
 	$mutation_length   = length($wt_plus);
    } else {
	# SETTING 1 - works for:
	#   ca16 indel(+)
	#   cxP622 insertion(+)
	$mutation_start  = $offset + 1;
 	$mutation_length = length($wt_plus) - 1;
 	
 	# SETTING 2 - works for:
 	#     tm728 (indel)
 	#     ok431 (indel)
 	$mutation_start  = $offset;
 	$mutation_length = length($wt_plus) - 1;
 	
 	# SETTING 3 - works for:
 	#     cn28 (unknown transposon insertion)
 	#$mutation_start  = $offset + 2;
 	#$mutation_length = length($wt_full) - 1;
 	
 	# SETTING 4 - works for:
 	#      bm1 (indel)
 	$mutation_start  = $offset;
 	$mutation_length = length($wt_plus);
    }
     
     $flank ||= SNIPPET_LENGTH;
 
     my $insert_length = (length $wt_fragment > length $mut_fragment) ? length $wt_fragment : length $mut_fragment;
     my $flank_length = int(($flank - $insert_length) / 2);
     
     # The amount of flank to fetch is based on the middle segment
     my $left_flank  = substr($dna,$mutation_start - $flank_length,$flank_length);
     my $right_flank = substr($dna,$mutation_start + $mutation_length,$flank_length);
 
    if (DEBUG_ADVANCED) {
	#      print "right flank : $right_flank",br;
 	$debug .= "WT PLUS STRAND .................. : $wt_plus"  . br;
 	$debug .= "MUT PLUS STRAND ................. : $mut_plus" . br;
     }
 
    # Mark up the reported flanking sequences in the full sequence
    my ($reported_left_flank,$reported_right_flank) = ($var->Flanking_sequences(1),$var->Flanking_sequences(2));
    #    my $left_length = length($reported_left_flank);
    #    my $right_length = length($reported_right_flank);
    $reported_left_flank = (length $reported_left_flank > 25) ? substr($reported_left_flank,-25,25) :  $reported_left_flank;
    $reported_right_flank = (length $reported_right_flank > 25) ? substr($reported_right_flank,0,25) :  $reported_right_flank;
    
    
    # Create a full length mutant dna string so that I can mark it up.
    my $mut_dna = 
 	substr($dna,$mutation_start - 500,500)
 	. $mut_plus
 	. substr($dna,$mutation_start + $mutation_length,500);
    

    my $wt_full = $self->_do_markup($dna,$mutation_start,$wt_plus,length($reported_left_flank));
    my $mut_full = $self->_do_markup($mut_dna,$mutation_start,$mut_plus,length($reported_right_flank));
    
    # Return the full sequence on the plus strand
    if ($with_markup) {
 	my $wt_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},uc($wt_fragment)),
			  lc($right_flank));
 	my $mut_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},
 						    uc($mut_fragment)),lc($right_flank));
 	return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    } else { 
 	my $wt_seq  = lc join('',$left_flank,$wt_plus,$right_flank);
 	my $mut_seq = lc join('',$left_flank,$mut_plus,$right_flank);
 	return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    }    
}



# Markup features relative to the CDS or to raw genomic features
sub _do_markup {
    my ($self,$seq,$var_start,$variation,$flank_length,$is_peptide) = @_;
    my $object = $self->object;

    # Here, variation might be a specially formatted string (ie '----' for a deletion)
    my @markup;
    my $markup = Bio::Graphics::Browser::Markup->new;
    $markup->add_style('utr'  => 'FGCOLOR gray');
    $markup->add_style('cds0'  => 'BGCOLOR yellow');
    $markup->add_style('cds1'  => 'BGCOLOR orange');
    $markup->add_style('space' => ' ');
    $markup->add_style('substitution' => 'text-transform:uppercase; background-color: red;');
    $markup->add_style('deletion'     => 'background-color:red; text-transform:uppercase;');
    $markup->add_style('insertion'     => 'background-color:red; text-transform:uppercase;');
    $markup->add_style('deletion_with_insertion'  => 'background-color: red; text-transform:uppercase');
    if ($object->Type_of_mutation eq 'Insertion') {
 	$markup->add_style('flank' => 'background-color:yellow;font-weight:bold;text-transform:uppercase');
    } else {
	$markup->add_style('flank' => 'background-color:yellow');
    }
    # The extra space is required here when used in non-pre-formatted text!
    $markup->add_style('newline',"<br> ");
    
    my $var_stop = length($variation) + $var_start;
    
    # Substitutions start and stop at the same position
    $var_start = ($var_stop - $var_start == 0) ? $var_start - 1 : $var_start;
    
    # Markup the variation as appropriate
    push (@markup,[lc($object->Type_of_mutation),$var_start,$var_stop]);
    
    # Add spacing for peptides
    if ($is_peptide) {
	for (my $i=0; $i < length $seq; $i += 10) {
	    push @markup,[$i % 80 ? 'space' : 'newline',$i];
 	}
    } else {
	for (my $i=80; $i < length $seq; $i += 80) {
	    push @markup,['newline',$i];
 	}
#	push @markup,map {['newline',80*$_]} (1..length($seq)/80);
    }
    
    if ($flank_length) {
	push @markup,['flank',$var_start - $flank_length + 1,$var_start];
	push @markup,['flank',$var_stop,$var_stop + $flank_length];
    }
 
     $markup->markup(\$seq,\@markup);
     return $seq;
}



sub _aa_type {
    my $self = shift;
    my $var = $self->object;

     # This must be parsed from the Molecular_change hash now, specifically Predicted_CDS
     return $self->{aa_type} if $self->{aa_type};
     
    # AA type change, if known, will be located under the Predicted_CDS
    my @types     = qw/Missense Nonsense Frameshift Silent Splice_site/;
     foreach my $cds ($var->Predicted_CDS) {
 	my $data = ParseHash(-nodes => $cds);
 	foreach (@$data) {
 	    my $hash = $_->{hash};
 	    
 	    foreach (@types) {
 		return $_ if ($hash->{$_});
 	    }
 	}
     }
}



# Need to generalize this for all alleles
sub _do_simple_conceptual_translation {
    my ($self,@p) = @_;
    my ($cds) = rearrange([qw/CDS/],@p);
     
    my ($pos,$formatted_change,$type) = $self->_get_aa_position($cds);
    my $wt_protein = eval { $cds->Corresponding_protein->asPeptide };

     return unless ($pos && $formatted_change);  # Try to do a manual translation
     return unless $wt_protein;
     
    # De-FASTA
    $wt_protein =~ s/^>.*//;
    $wt_protein =~ s/\n//g;   
     
     $formatted_change =~ /(.*) to (.*)/;
     my $wt_aa  = $1;
     my $mut_aa = $2;
     
    
#    # String formatting of nonsense alleles is a bit different
#    if ($type eq 'Nonsense') {
#	$mut_aa = '*';
#    }

    # Substitute the mut_aa into the wildtype protein
    my $mut_protein = $wt_protein;
     
    substr($mut_protein,($pos-1),1,$mut_aa);
    
    # Store some data for easy accession
    # I'd like to purge this but it's deeply embedded in the logic
    # of presenting a detailed view of the sequence
    $self->{wt_aa_start} = $pos;
     
     # I should be formatting these here depending on the type of nucleotide change...
     $self->{formatted_aa_change} = $formatted_change;
     
     # Create short strings of the proteins for display
     $self->{wt_protein_fragment} = ($pos - 19)
 	. '...'
 	. substr($wt_protein,$pos - 20,19) 
 	. ' ' 
 	. b(substr($wt_protein,$pos-1,1)) 
 	. ' ' 
 	. substr($wt_protein,$pos,20) 
 	. '...'
 	. ($pos + 19);
     $self->{mut_protein_fragment} = ($pos - 19) 
 	. '...' 
 	. substr($mut_protein,$pos - 20,19) 
 	. ' ' 
 	. b(substr($mut_protein,$pos-1,1)) 
 	. ' ' 
 	. substr($mut_protein,$pos,20) 
 	.  '...' 
 	. ($pos + 19);
     
     $self->{wt_trans_length} = length($wt_protein);
     $self->{mut_trans_length} = length($mut_protein);
     
     $self->{wt_trans} = 
 	"> $cds"
 	. $self->_do_markup($wt_protein,$pos-1,$wt_aa,undef,'is_peptide');
    my $var = $self->object;
     $self->{mut_trans} = 
 	"> $cds ($var: $formatted_change)"
 	. $self->_do_markup($mut_protein,$pos-1,$mut_aa,undef,'is_peptide');
        
     my $debug;
     if (DEBUG_ADVANCED) { 
 	$debug .= "CONCEPTUAL TRANSLATION VIA SUBSTITUTION OF STORED AA" . br;
 	$debug .= "STORED WT : $wt_aa" . br;
 	$debug .= "STORED MUT: $mut_aa" . br;
     }	
     
    return ($self->{wt_protein_fragment},$self->{mut_protein_fragment},$self->{wt_trans},$self->{mut_trans},$debug);
}


    
## For missense and non_sense alleles only
## Actually, the position is ONLY stored for
## missense alleles
    sub _get_aa_position {
    my ($self,$cds) = @_;
     my @types = qw/Missense Nonsense/;
     my $data = ParseHash(-nodes => $cds);
     foreach my $entry (@$data) {
	 my $hash = $entry->{hash};
 	my $node = $entry->{node};
 	foreach my $type (@types) {
	    
 	    my $obj = $hash->{$type};
 	    my @data = eval { $obj->row };
 	    if ($obj) {
 		if ($type eq 'Missense') {
 		    my ($type,$pos,$text,$evi) = @data;
 		    return ($pos,$text,$type);
 		} 
		
#		else {
#		    my ($type,$pos,$text,$evi) = @data;
#		    return ($pos,$text,$type);
#		}
 	    }
 	}
     }
     return;
}




# Fetch the coordinates of the variation in a given feature
sub _fetch_coords_in_feature {
    my ($self,$tag,$entry) = @_;
    # Fetch the variation segment
    my $variation_segment = $self->genomic_segment('wt_variation');

    # Fetch a GFF segment of the containing feature
    my $containing_segment;
    # Kludge for chromosome    
    if ($tag eq 'Chromosome') {
 	($containing_segment) = $GFFDB->segment(-class=>'Sequence',-name=>$entry);
     } else {
 	
 	# Um, this breaks very often, returning multiple segments...
 	$containing_segment = $data->genomic_segment(-refseq=>$entry);
     }

     return unless $variation_segment && $containing_segment;
     if ($containing_segment) {
 	# Set the refseq of the variation to the containing segment
 	eval { $variation_segment->refseq($containing_segment) };
 	
 	# Debugging statements
 	warn "Contained in $tag $entry" . join(' ',$data->coordinates($variation_segment)) if DEBUG;
 	warn "Containing seg coordinates " . join(' ',$data->coordinates($containing_segment)) if DEBUG;
 	
 	my ($fabs_start,$fabs_stop,$fstart,$fstop) = $self->_coordinates($containing_segment);
 	my ($abs_start,$abs_stop,$start,$stop)     = $self->_coordinates($variation_segment);
#	      ($fstart,$fstop) = (qw/- -/) if ($tag eq 'Chromosome');
 	($start,$stop) = ($stop,$start) if ($start > $stop);
 	return ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop);
     }
}



sub _chrom_coordinates {
    my ($self,@p) = @_;
    my ($link) = rearrange([qw/LINK/],@p);
    my $segment = $self->genomic_segment('wt_variation');
    return unless $segment;
    $segment->absolute(1);
    my $abs_ref   = $segment->abs_ref;
    my $abs_start = $segment->start;
    my $abs_stop  = $segment->stop;
    ($abs_start,$abs_stop) = ($abs_stop,$abs_start) if ($abs_start > $abs_stop);
   my ($low,$high);
   if ($abs_stop - $abs_start < 100) {
     $low   = $abs_start - 50;
     $high  = $abs_stop  + 50;
   } else {
     $low = $abs_start;
     $high = $abs_stop;
   }
 
   my $ref = $segment->ref;
   $segment->absolute(0);
   if ($link) {
     my $link = "/db/seq/gbrowse/wormbase/?ref=$ref;start=$low;stop=$high;label=CG-Allele";
     my $url = a({-href=>$link},"$ref:",$abs_start.'..'.$abs_stop);
     return $url;
   } else {
     return ($abs_ref,$abs_start,$abs_stop);
   }
}




# OLD ACCESSORS deprecating
sub cgh_segment       { return shift->{segments}->{cgh_variation}; }










1;
