package WormBase::API::Object::Variation;

use Moose;
use Bio::Graphics::Browser2::Markup;
# I shouldn't need to use CGI here.
use CGI qw/:standard :html3/;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


# TODO:
# Mapping data
# Marked_rearrangement
has 'pic_segment' => (
    is  => 'ro',
    lazy => 1,
    default => sub { 
	my $self=shift;
	my $object  = $self->object;
	my $gene    = $object->Gene;

	# Fetch a GF handle
	my $gffdb   = $self->gff_dsn();
	my ($segment) =  $gffdb->segment(Gene => $gene);
	
	# By default, lets just center the image on the variation itself.
	# What segment should be used to determine the baseline coordinates?
	# Use a CDS segment if one is provided, else just show the genomic environs

	# TO DO: MOVE UNMAPPED_SPAN TO CONFIG
	my $UNMAPPED_SPAN = 10000;
	unless ($segment) {
	    # Try fetching a generic segment corresponding to a span flanking the variation

	    my ($ref,$abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
	    
	    # Generate a link to the genome browser
	    # This is hard-coded and needs to be cleaned up.
	    # Is the segment smaller than 100? Let's adjust
	    my ($low,$high);
	    if ($abs_stop - $abs_start < 100) {
		$low   = $abs_start - 50;
		$high  = $abs_stop  + 50;
	    } else {
		$low = $abs_start;
		$high = $abs_stop;
	    }

	    my $split = $UNMAPPED_SPAN / 2;	
	    ($segment) =   $gffdb->segment($ref,$low-$split,$low+$split);
	}
	
	return $segment;
	 
    }
);

has 'tracks' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self = shift;
	 my @tracks = qw/
		CG
		Allele
		TRANSPOSONS/;
	return \@tracks;
    }
);
 

############################################################
#
# OVERVIEW
#
############################################################
sub name {
    my $self = shift;
    my $ace  = $self->object;
    my $data = { description => 'The internal WormBase referential ID of the variation',
		 data        =>  { id    => "$ace",
				   label => $ace->Public_name->name,
				   class => $ace->class
		 },
    };
    return $data;
}

# This should be the Public name || object name
sub common_name {
    my $self = shift;
    my $object = $self->object;
    my $name = $object->Public_name;
    my $data = { description => 'The public name of the variation',
		 data        => { id    => "$name",
				  label => $name->name,
				  class => $name->class,
		 },
    };
    return $data;
}

# THIS METHOD IS PROBABLY DEPRECATED
sub cgc_name {
    my $self = shift;
    my $object = $self->object;
    my $cgc_name = $object->CGC_name || "unknown";
    my $data = { description => 'The Caenorhabditis Genetics Center (CGC) name for the variation',
		 data        => { id    => "$cgc_name",
				  label => $cgc_name->name,
				  class => $cgc_name->class,
		 },
    };
    return $data;
}

sub other_names {
    my $self   = shift;
    my $object = $self->object;
    my @others = $object->Other_name;

    my $packed = $self->_pack_objects(\@others);

    my $data   = { description => 'other possible names for the variation',
		   data        => $packed,
    };
    return $data;
}


# A unified classification of the type of variation
# general class: SNP, allele, etc
# physical class: deletion, insertion, etc
# TODO: EVidence
sub variation_type {
    my $self = shift;
    my $object = $self->object;

    my @types;
    if ($object->KO_consortium_allele(0)) {
	push @types,"Knockout Consortium allele";
    }
      
    if ($object->SNP(0) && $object->RFLP(0)) {	
	my $type = 'polymorphism; RFLP';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";       
	push @types,$type;
    }

    if ($object->SNP(0) && !$object->RFLP(0)) {
	my $type  = 'polymorphism';
	$type .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";
	push @types,$type;
    }
    
    if ($object->Natural_variant) {
	push @types, 'natural variant';
    }

    if (@types == 0) {
	push @types,'allele';
    }

    my $type = join("; ",@types);

    my $physical_type   = $object->Type_of_mutation;
    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
	$physical_type = 'transposon insertion';
    }
        
    my $data = { description => 'the general type of the variation',
		 data        => { general_class  => $type,
				  physical_class => $physical_type
		 },
    };
    return $data;
}

sub remarks {
    my $self    = shift;
    my $object  = $self->object;
    my @remarks = $object->Remark;

    # TODO: handling of Evidence nodes
    my $data    = { description  => 'curator remarks for the variation',
		    data         => \@remarks,
    };
    return $data;
}

sub status {
    my $self    = shift;
    my $object  = $self->object;
    my $status = $object->Status;
    my $data    = { description  => 'curator remarks for the variation',
		    data         => "$status",
    };
    return $data;
}


############################################################
#
# MOLECULAR_DETAILS
#
############################################################

sub sequencing_status {
    my $self = shift;
    my $object = $self->object;
    my $status = $object->SeqStatus;
    return { description => 'sequencing status of the variation',
	     data        => "$status" };
}

sub five_prime_gap {
    my $self = shift;
    my $object = $self->object;
    my $gap    = $object->FivePrimeGap || '';
    return { description => 'five prime gap',
	     data        => "$gap" };
}

sub three_prime_gap {
    my $self = shift;
    my $object = $self->object;
    my $gap     = $object->ThreePrimeGap || '';
    return { description => 'three prime gap',
	     data        => "$gap" };
}
	

# Returns a data structure containing
# wild type sequence - the wild type (or reference) sequence
# mutant sequence - the mutant sequence
# wild type label - the source (background) of the wild type sequence
# mutant label    - the source (background) of the mutation

sub nucleotide_change {
    my $self   = shift;
    my $object = $self->object;

    # Nucleotide change details (from ace)
    my $variations = $self->_compile_nucleotide_changes($object);
    my $data = { description => 'raw nucleotide changes for this variation',
		 data        => $variations,
    };
    return $data;    
}

sub flanking_sequences {
    my $self = shift;
    my $object = $self->object;
    my $left_flank  = $object->Flanking_sequences(1);
    my $right_flank = $object->Flanking_sequences(2);
    my $data = { description => 'sequences flanking the variation',
		 data        => { left_flank  => "$left_flank",
				  right_flank => "$right_flank",
		 },
    };
    return $data;    
}


sub cgh_deleted_probes {
    my $self  = shift;
    my $object = $self->object;

    my $left_flank  = $object->CGH_deleted_probes(1) || "";
    my $right_flank = $object->CGH_deleted_probes(2) || ""; 
    
    my $data = { description => 'probes used for CGH of deletion alleles',
		 data        => { left_flank  => "$left_flank",
				  right_flank => "$right_flank",
		 },
    };
    return $data;
}


# Show the variation in context.
sub context {
    my $self   = shift;
    my $object = $self->object;
    my $name   = $object->Public_name;

    # Display a formatted string that shows the mutation in context
    my $flank = 250;
    my ($wt,$mut,$wt_full,$mut_full,$debug)  = $self->_build_sequence_strings(-with_markup => 1);
    my $data = { description => 'wildtype and mutant sequences in an expanded genomic context',
		 data        => { wildtype_fragment => $wt,
				  wildtype_full     => $wt_full,
				  mutant_fragment   => $mut,
				  mutant_full       => $mut_full,
				  wildtype_header   => "> Wild type N2, with $flank bp flanks",
				  mutant_header     => "> $name with $flank bp flanks"
		 },
    };
    return $data;
}

sub deletion_verification {
    my $self = shift;
    my $object = $self->object;
    
    my $data = { description => 'the method used to verify deletion alleles',
		 data        => $object->Deletion_verification || "",
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
    
    # Clone and Chromosome are calculated, not provided in the DB.
    # Feature and Interactor are handled a bit differently.

    foreach my $tag (qw/Pseudogene Transcript Predicted_CDS Gene Clone Chromosome Feature Interactor/) {
 	my @container;
 	if (my @entries = eval { $object->$tag }) {

	    # Parse the Molecular_change hash for each feature
 	    my $parsed_data;
 	    foreach my $entry (@entries) {
 		my @data = $entry->col;

		# Save the class of the feature for template linking.
		$affects->{$tag}->{$entry}->{class} = $entry->class;
		$affects->{$tag}->{$entry}->{label} = $entry->class eq 'Gene' ? ($entry->Public_name) : "$entry";
        $affects->{$tag}->{$entry}->{id} = "$entry";
		# Genes ONLY have gene
		if ($tag eq 'Gene') {
		    $affects->{$tag}->{$entry}->{entry}++;
		    next;
		}

 		next unless @data;
		my $hash_data  = $self->_parse_hash($entry);
 		
 		# do_translation is a flag controlling whether or not
 		# we should undertake a conceptual translation for this affected feature
 		# See FormatMolecularChangeHash for details
		# $protein_effects & $location_effects contain things like missense and coding_exon, respectively.
 		my ($protein_effects,$location_effects,$do_translation) 
		    = $self->_format_molecular_change_hash({data => $hash_data,
							    tag  => $tag});
		
 		if ($protein_effects) {
		    $affects->{$tag}->{$entry}->{protein_effects} = $protein_effects;
 		}

 		if ($location_effects) {
		    $affects->{$tag}->{$entry}->{location_effects} = $location_effects;
		}
 		
 		# Display a conceptual translation, but only for Missense
 		# Nonsense, and Frameshift alleles within exons
 		if ($tag eq 'Predicted_CDS' && $do_translation) {
		    
		    # Is the amino acid change stored in Ace?
 		    my $aa_type = $self->_aa_type;
 		    if ($aa_type) {
 			my ($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug);
 			($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug) 
 			    = $self->_do_simple_conceptual_translation($entry);
# 			unless ($wt_snippet) {
# 			    ($wt_snippet,$mut_snippet,$wt_full,$mut_full,$debug) 
# 				= $self->_do_manual_conceptual_translation($entry);
# 			}

			$affects->{$tag}->{$entry}->{wildtype_conceptual_translation} = $wt_full;
			$affects->{$tag}->{$entry}->{mutant_conceptual_translation}   = $mut_full;			
		    }
		}
		
		# Get the coordinates in absolute coordinates
		# the coordinates of the containing feature,
		# and the coordinates of the variation WITHIN the feature.
 		my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$entry);
		$affects->{$tag}->{$entry}->{abs_start} = $abs_start;
		$affects->{$tag}->{$entry}->{abs_stop}  = $abs_stop;
		$affects->{$tag}->{$entry}->{fstart} = $fstart;
		$affects->{$tag}->{$entry}->{fstop} = $fstop;
		$affects->{$tag}->{$entry}->{start} = $start;
		$affects->{$tag}->{$entry}->{stop} = $stop;	       
 	    }
 	} else {
	    # Clone and Chromosome are not provided in the DB - we calculate them here.
 	    my @affects_this;   # BLECH!
 	    if ($tag eq 'Clone') {
 		@affects_this = $object->Sequence if $object->Sequence;
 	    }  elsif ($tag eq 'Chromosome') {
		# And fetch the chromosome from the Clone
		my ($chrom) = eval { $object->Sequence->Interpolated_map_position(1) };
		@affects_this = $chrom;
	    }
	    
 	    foreach (@affects_this) { 				
        next unless $_;
		$affects->{$tag}->{$_}->{class} = $_->class;
		$affects->{$tag}->{$_}->{label} = "$_";
        $affects->{$tag}->{$_}->{id} = "$_";
 		
 		my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$_);
		$affects->{$tag}->{$_}->{abs_start} = $abs_start;
		$affects->{$tag}->{$_}->{abs_start} = $abs_stop;
		$affects->{$tag}->{$_}->{fstart} = $fstart;
		$affects->{$tag}->{$_}->{fstop} = $fstop;
		$affects->{$tag}->{$_}->{start} = $start;
		$affects->{$tag}->{$_}->{stop} = $stop;
 	    }
 	} 	
    }
    
    my $data = { description => 'genomic features affected by this variation',
		 data        => $affects,
    };
    return $data;
}


sub possibly_affects {
    my $self = shift;
    my $object = $self->object;
    my $data = {  description => 'genes that may be affected by the variation but have not been experimentally tested',
		  data        => "$object->Possibly_affects" ,
    };
    return $data;
}


sub flanking_pcr_products {
    my $self = shift;
    my $object = $self->object;

    my @pcr_products = $object->PCR_product;
    my $packed = $self->_pack_objects(\@pcr_products);
    my $data = { description => 'PCR products that flank the variation',
		 data        => $packed,
    };
    return $data;
}

# TODO: Needs evidence
sub affects_splice_site {
    my $self = shift;
    my $object = $self->object;
    my $data = {};
    $data->{description} = 'does this variation affect a splice site?';
    $data->{data} = { donor    => $object->Donor,
		      acceptor => $object->Acceptor,
    };
    return $data;
}    

sub causes_frameshift {
    my $self = shift;
    my $object = $self->object;
    my $data = {};
    $data->{description} = 'does this variation affect a splice site?';
    $data->{data} = "$object->Frameshift" || "";
    return $data;
}    


sub detection_method {
    my $self = shift;
    my $object = $self->object;
    my $detection_method = $object->Detection_method || "";
    return { description => 'detection method for polymorphism',
	     data        => "$detection_method",
    };
}



############################################################
#
# POLYMORPHISM DETAILS
#
############################################################
sub polymorphism_type {
    my $self = shift;
    my $object = $self->object;

    # What type of polymorphism is this?
    my $type;
    if ($object->SNP(0) && $object->RFLP(0)) {
	$type = 'SNP and RFLP';
    } elsif ($object->SNP(0)) {
	$type = 'SNP';
    } elsif ($object->Transposon_insertion) {
	$type = $object->Transposon_insertion . ' transposon insertion';
    } else { }
    my $data = { description => 'the general class of this polymorphism',
		 data        => "$type", };
    return $data;
}
    
sub polymorphism_status {
    my $self = shift;
    my $object = $self->object;
    my $status = $object->Confirmed_SNP(0) ? 'confirmed' : 'predicted';
    my $data  = { description => 'experimental status of this polymorphism',
		  data        => "$status",		  
    };
    return $data;
}

# For polymorphisms
sub reference_strain {
    my $self   = shift;
    my $object = $self->object;
    my $strain = $object->Strain;
    my $data = { description => 'the reference strain for the polymorphism',
		 data        => $self->_pack_obj($strain),
    };
    return $data;
}



# Details related to assaying polymorphisms	       
sub polymorphism_assays {
    my $self = shift;
    my $object = $self->object;
    
    my $data = {};
    my @pcr_product = $object->PCR_product;
    
    # Ugh.  Have to access RFLP by indexing into an array! Blech!
    my @ref_enzymes = eval { $object->Reference_strain_digest->col(0) };
    my @ref_digests;
    foreach my $enz (@ref_enzymes) {
	my @bands = $enz->col;
	foreach (@bands) {
	    push (@ref_digests,[$enz,$_]);
	}
    }
    
    my @poly_enzymes = eval { $object->Polymorphic_strain_digest->col(0) };
    my @poly_digests;
    foreach my $enz (@poly_enzymes) {
	my @bands = $enz->col;
	foreach (@bands) {
	    push (@poly_digests,[$enz,$_]);
	}
    }
    
    my $index = 0;
    foreach my $pcr_product (@pcr_product) {
	# If this is an RFLP, extract digest conditions
	my $assay_table;

	# Are we an RFLP?
#	if ($object->RFLP(0) && @ref_digests) {	
	if ($object->RFLP && @ref_digests) {	
	    my ($ref_digest,$ref_bands)   = @{$ref_digests[$index]};
	    my ($poly_digest,$poly_bands) = @{$poly_digests[$index]};
	    
	    $data->{data}->{$pcr_product} = { reference_strain_digest => $ref_digest,
					      reference_strain_bands  => $ref_bands,
					      polymorphic_strain_digest => $poly_digest,
					      polymorphic_strain_bands  => $poly_bands,
					      assay_type                => 'rflp',
	    };	    	   
	} else {
	    $data->{data}->{$pcr_product}->{assay_type} = 'sequence';
	}

	my ($left_oligo,$right_oligo);
	if (my @oligos = $pcr_product->Oligo) {
	    $left_oligo  = $oligos[0]->Sequence;
	    $right_oligo = $oligos[1]->Sequence;
	}
	
	my $pcr_conditions = $pcr_product->Assay_conditions;
	
	# Fetch the sequence of the PCR_product
	my $sequence = eval { $object->Sequence };
	
	my @pcrs = eval { $sequence->PCR_product };
	my ($start,$stop,@pos);
	foreach (@pcrs) {
	    next if ($_ ne $pcr_product);
	    @pos = $_->row;
	    $start        = $pos[1];
	    $stop         = $pos[2];
	}

	my $gffdb   = $self->gff_dsn($self->parsed_species);

	my ($segment) = $gffdb->segment(-name=>$sequence,
					-offset=>$start,
					-length=>($stop-$start)) if ($start && $stop);
	my $dna   = $segment->dna if $segment;

	# TODO: Should be handled in the template
#	my $fasta = pre($data->to_fasta($sequence,$dna));
	my $fasta = $dna;

	$data->{data}->{$pcr_product}->{pcr_product} = {  id => "$pcr_product",
							  label => $pcr_product,
							  class => $pcr_product->class,
							  left_oligo => $left_oligo,
							  right_oligo => $right_oligo,
							  pcr_conditions => $pcr_conditions,
							  dna            => $fasta,
							  
	};
	$index++;
    }
    $data->{description} = 'experimental assays for detecting this polymorphism';
    return $data;
}



# OOOH!  Need to handle this.
#++ 					 'variation and motif image',p(motif_picture(1,$entry)));




############################################################
#
# LOCATION
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
    
    unless ($chrom) {
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
    my ($start,$stop) = ($position-0.5,$position+0.5);
=pod 
    my $gb_url = 
	$position
	? a({-href=>"name=$chrom;class=Map;map_start=$start;map_stop=$stop"},
	    sprintf("$chrom:%2.2f +/- %2.3f cM",$position,$error || 0))
	: a({-href=>"name=$chrom;class=Map"},
	    $chrom);
#	$position
#	? a({-href=>Url('pic',"name=$chrom;class=Map;map_start=$start;map_stop=$stop")},
#	    sprintf("$chrom:%2.2f +/- %2.3f cM",$position,$error))
#	: a({-href=>Url('pic',"name=$chrom;class=Map")},
#	    $chrom);
   
    my $data = { description => 'the genetic position of the variation (if known)',
		 data        => { chromosome => $chrom,
				  position   => $position,
				  error      => $error,
				  gb_url     => $gb_url,
		 },
    };
=cut
    my ($id,$label);
    if($position) {
	$label= sprintf("$chrom:%2.2f +/- %2.3f cM",$position,$error || 0);
	$id = "name=$chrom;map_start=$start;map_stop=$stop";
    } else {
	$label= $chrom;
	$id = "name=$chrom";
    }
     
    my $data = { description => 'the genetic position of the variation (if known)',
		 data        => {  
				  id   => $id,
				  class      => 'Map',
				  label     => $label,
		 },
    };
    return $data;
}


# The genomic position and a link to the genome browser
sub genomic_position {
    my $self = shift;
    my $segment = $self->_get_genomic_segment(-key=>'wt_variation');
    my ($chrom,$abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
    return unless $segment;
    
    # Generate a link to the genome browser
    # This is hard-coded and needs to be cleaned up.
    # Is the segment smaller than 100? Let's adjust 
    # coordinates a bit for a better GBrowse view.
    my ($low,$high);
    if ($abs_stop - $abs_start < 100) {
	$low   = $abs_start - 50;
	$high  = $abs_stop  + 50;
    } else {
	$low = $abs_start;
	$high = $abs_stop;
    }
=pod 
    my $link = "/db/seq/gbrowse/elegans/?ref=$chrom;start=$low;stop=$high;label=CG-Allele";
    my $data = { description => 'the genomic coordinates of the variation',
		 data        => { chromosome => $chrom,
				  start      => $abs_start,
				  stop       => $abs_stop,
				  gbrowse_link => $link,
		 },
    };
=cut
    my $url = $self->hunter_url($chrom,$low,$high);
    my $data = { description => 'the genomic coordinates of the variation',
		 data        => { id => $self->parsed_species."/?name=".$url,
				  class      => 'genomic_location',
				  label       => $url, 
		 },
    };
    return $data;
}

# Create a genomic picture
# This is far simpler than the manual approach below but doesn't give me as much
# flexibility
=pod
sub genomic_image {
    my $self = shift;
     
    my $object  = $self->object;
	my $gene    = $object->Gene;

	# Fetch a GF handle
	my $gffdb   = $self->gff_dsn();
	my ($segment) =  $gffdb->segment(Gene => $gene);
	
	# By default, lets just center the image on the variation itself.
	# What segment should be used to determine the baseline coordinates?
	# Use a CDS segment if one is provided, else just show the genomic environs

	# TO DO: MOVE UNMAPPED_SPAN TO CONFIG
	my $UNMAPPED_SPAN = 10000;
	unless ($segment) {
	    # Try fetching a generic segment corresponding to a span flanking the variation

	    my ($ref,$abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
	    
	    # Generate a link to the genome browser
	    # This is hard-coded and needs to be cleaned up.
	    # Is the segment smaller than 100? Let's adjust
	    my ($low,$high);
	    if ($abs_stop - $abs_start < 100) {
		$low   = $abs_start - 50;
		$high  = $abs_stop  + 50;
	    } else {
		$low = $abs_start;
		$high = $abs_stop;
	    }

	    my $split = $UNMAPPED_SPAN / 2;	
	    ($segment) =   $gffdb->segment($ref,$low-$split,$low+$split);
	}
	

    my @tracks = qw/
		CG
		Allele
		TRANSPOSONS/;
   
    my $image_data = $self->build_gbrowse_img($segment,\@tracks,undef,800);
    my $data = { description => 'a link to the genome browser',
		 data        => $segment,
    };
    return $data;   
}
=cut

############################################################
#
# PHENOTYPE
#
############################################################

sub nature_of_variation {
    my $self = shift;
    my $object = $self->object;
    my $nature = $object->Nature_of_variation || "";
    return { description => 'nature of the variation',
	     data        => "$nature",
    };
}
       
# Q: Model needs to be organized under a single Dominance tag
# Q: is this one or many?
sub dominance {
    my $self = shift;
    my $object = $self->object;
    my $dominance = $object->Recessive
	|| $object->Semi_dominant
	|| $object->Dominant
	|| eval{$object->Partially_penetrant}
	|| eval{$object->Completely_penetrant};	
	
    my $data = { description => 'dominance of the variation',
		 data => "$dominance",
    };
    return $data;
}

## || ;

sub phenotype_remark {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'phenotype remark',
		 data        => $object->Phenotype_remark || "",
    };
    return $data;
}

# TODO: needs evidence
sub temperature_sensitivity {
    my $self = shift;
    my $object = $self->object;
    my $sensitivity = $object->Cold_sensitive
	|| $object->Heat_sensitive
	|| "";
    my $data = { description => 'temperature sensitive',
		 data        => "$sensitivity",
    };
    return $data;
}

sub phenotype {

	my $self = shift;
	my $phenotype_data = $self->pull_phenotype_data('Phenotype');
	return $phenotype_data;

}

sub phenotype_not {

	my $self = shift;
	my $phenotype_data = $self->pull_phenotype_data('Phenotype_not_observed');
	return $phenotype_data;
}

sub pull_phenotype_data {
	
	my $self = shift @_;
	my $phenotype_tag = shift @_;
	my $object = $self->object;  ##shift @_;
	my %return_data;
	
	
	my @phenotype_data;   ## return data structure contains set of : not, phenotype_id; array ref for each characteristic in each element
	
	#my @phenotype_tags = ('Phenotype', 'Phenotype_not_observed');
  	#foreach my $phenotype_tag (@phenotype_tags) {
  
		my @phenotypes = $object->$phenotype_tag;

		foreach my $phenotype (@phenotypes) {
			my %p_data;   ### data holder for not, phenotype, remark, and array ref of characteristics, loaded into @phenotype_data for each phenotype related to the variation.
			my @phenotype_subtags = $phenotype->col ; ## 0
			
			my @psubtag_data;
			my @ps_data;
				
			my %tagset = (
				'Paper_evidence' => 1,
				'Remark' => 1,
	#    		'Person_evidence' => 1,
	#		  'Phenotype_assay' => 1,
	#		  'Penetrance' => 1,			
	#		  'Temperature_sensitive' => 1,
	#		  'Anatomy_term' => 1,
	#		  'Recessive' => 1,
	#		  'Semi_dominant' => 1,
	#		  'Dominant' => 1,
	#		  'Haplo_insufficient' => 1,
	# 		  'Loss_of_function' => 1,
	#		  'Gain_of_function' => 1,
	#		  'Maternal' => 1,
	#		  'Paternal' => 1
			
			); ### extra data commented out off data pull system 20090922 to simplify table build and data pull
			
			my %extra_tier = (
			
						'Phenotype_assay' => 1,
						'Temperature_sensitive' => 1
			);#'Penetrance' => 1,
			
			my %gof_set = (
				
				'Gain_of_function' => 1,
				'Maternal' => 1
				#, 'Paternal' => 1
			);
			
			my %no_details = (
				
				'Recessive' => 1,
				'Semi_dominant' => 1,
				'Dominant' => 1,
				'Haplo_insufficient' => 1,
				'Paternal' => 1
			);	 # 		, 'Loss_of_function' => 1'Gain_of_function' => 1,
			
			
			foreach my $phenotype_subtag  (@phenotype_subtags) {
			
			if (!($tagset{$phenotype_subtag})) {
				next;
			}
			else{
				
				my @ps_column = $phenotype_subtag->col;
				
				## data to be incorporated into @ps_data;
				
				my $character;
				my $remark;
				my $evidence_line;
				
				## process Penetrance data
				if ($phenotype_subtag =~ m/Penetrance/) {
				foreach my $ps_column_element (@ps_column) {
					
					
					
					if ($ps_column_element =~ m/Range/) {
					next;
					
					} 
					else {
					my ($char,$text,$evidence) = $ps_column_element->row;
					my @pen_evidence = $evidence-> col;
					$character = "$phenotype_subtag"; #\:
					$remark = $char; #$text
					
					my @pen_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @pen_evidence}; # ;
					
					$evidence_line =  join "; ", @pen_links;
					}
				}
				}
				
				## get remark
				
				
				elsif ($phenotype_subtag =~ m/Remark/) {
				
				my @remarks = $phenotype_subtag->col;
				my $remarks = join "; ", @remarks;
				my $details_url = "/db/misc/etree?name=$phenotype;class=Phenotype";
				my $details_link = a({-href=>$details_url},'[Details]');
				$remarks = "$remarks\ $details_link";
				$p_data{'remark'} = $remarks; #$phenotype_subtag->right
				next;
				
				}
				
				
				
				## get evidences
				elsif ($phenotype_subtag =~ m/Paper_evidence/) {
				
				my @phenotype_paper_evidence = $phenotype_subtag->col;
				my @phenotype_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @phenotype_paper_evidence}; #; 
				$p_data{'paper_evidence'} = join "; ", @phenotype_paper_links;
				next;
				}
				
				
				## process Anatomy_term data
				
				elsif ($phenotype_subtag =~ m/Anatomy_term/) {
				my ($char,$text,$evidence) = $phenotype_subtag ->row;
				my @at_evidence = $phenotype_subtag -> right -> right -> col;
				
				# my $at_link;
				my $at_term = $text->Term;
				my $at_url = "/db/ontology/anatomy?name=" . $text;
				my $at_link = a({-href => $at_url}, $at_term);
				
				$character = $char;
				$remark = $at_link; #$text
				
				my @at_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @at_evidence}; #;
				
				$evidence_line = join "; ", @at_links;
				
				}
				
				## process extra tier data
				
				elsif ($phenotype_subtag =~ m/Phenotype_assay/) {
				foreach my $character_detail (@ps_column) {
					my $cd_info = $character_detail->right; # right @cd_info
					my @cd_evidence = $cd_info->right->col;
					$character = "$character_detail";  #$phenotype_subtag\:
					# = $cd_info->col;
					$remark =  $cd_info; # join "; ", @cd_info;
					
					my @cd_links= eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @cd_evidence }; #  ;
					
					$evidence_line = join "; ", @cd_links;
					
					my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
					push  @ps_data, $phenotype_st_line ; 
					
				}
				next;
				}
				
				elsif ($phenotype_subtag =~ m/Temperature_sensitive/) {
				foreach my $character_detail (@ps_column) {
					my $cd_info = $character_detail->right;
					my @cd_evidence = $cd_info->right->col;
					
					my @cd_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @cd_evidence }; #  ;
					
					$character = "$character_detail";  #$phenotype_subtag\:
					$remark = $cd_info;
					$evidence_line = join "; ", @cd_links ;
					
					my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
					push  @ps_data, $phenotype_st_line ; 
				}
				
				next;
				}
				
				elsif ( $phenotype_subtag =~ m/Gain_of_function/) { # $gof_set{}
				my ($char,$text,$evidence) = $phenotype_subtag->row;
				my @gof_evidence;
				
				eval{
					@gof_evidence = $evidence-> col;
				}; 
				#\:
				$remark = $text; #$char
				
				if(!(@gof_evidence)){
					$character = $phenotype_subtag;
					$remark = '';
					$evidence_line = $p_data{'paper_evidence'};
					
					
					
				}
				#my @pen_links = map {format_reference(-reference=>$_,-format=>'short');} @pen_evidence;
				else {
					$character = $phenotype_subtag;
					$remark = $char;
					my @gof_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @gof_evidence}; #  ;
					
					$evidence_line =  join "; ", @gof_paper_links;
				}
				my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
				push  @ps_data, $phenotype_st_line ; 
				next;
				
				
				}
				
				elsif ( $phenotype_subtag =~ m/Loss_of_function/) { # $gof_set{}
				my ($char,$text,$evidence) = $phenotype_subtag->row;
				my @lof_evidence;
				
				eval{
					@lof_evidence = $evidence-> col;
				}; 
				#\:
				$remark = $text; #$char
				
				if(!(@lof_evidence)){
					$character = $phenotype_subtag;
					$remark = $text;
					$evidence_line = $p_data{'paper_evidence'};
					
					
					
				}
				#my @pen_links = map {format_reference(-reference=>$_,-format=>'short');} @pen_evidence;
				else {
					$character = $phenotype_subtag;
					$remark = $text;
					my @lof_paper_links = eval {map {format_reference(-reference=>$_,-format=>'short') if $_;} @lof_evidence}; ; #
					
					$evidence_line =  join "; ", @lof_paper_links;
				}
				my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
				push  @ps_data, $phenotype_st_line ; 
				next;
				
				}
				
				
				elsif ( $phenotype_subtag =~ m/Maternal/) { # $gof_set{}
				my ($char,$text,$evidence) = $phenotype_subtag->row;
				
				my @mom_evidence;
				
				eval {
					
					@mom_evidence = $evidence->col;
					
				};
				
				
				if(!(@mom_evidence)){
					$character = $phenotype_subtag;
					$remark = '';
					$evidence_line = $p_data{'paper_evidence'};
					
				}
				else {
					$character = $phenotype_subtag;
					$remark = '';
					my @mom_paper_links = eval{map {format_reference(-reference=>$_,-format=>'short') if $_;} @mom_evidence} ; #;
					$evidence_line =  join "; ", @mom_paper_links;
					
				}
				
				
				my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
				push  @ps_data, $phenotype_st_line ; 
				next;
				
				
				}
				
				
				## process no details data
				elsif ($no_details{$phenotype_subtag}) {
				my @nd_evidence;
				eval {
					@nd_evidence = $phenotype_subtag->right->col;
				};
				
				$character = $phenotype_subtag;
				$remark = "";
				if (@nd_evidence){
					
					my @nd_links = eval{map {format_reference(-reference=>$_,-format=>'short') if $_;} @nd_evidence ; }; # 
					
					$evidence_line = join "; ", @nd_links;
				}
				
				
				}
				
				
				my $phenotype_st_line = join "|", ($phenotype_subtag,$character,$remark,$evidence_line);
				push  @ps_data, $phenotype_st_line ;  ## let @ps_data evolve to include characteristic; remarks; and evidence line
			}
			
			}
			
			my $phenotype_name = $phenotype->Primary_name;
			#my $phenotype_url = Object2URL($phenotype);
			#my $phenotype_link = b(a({-href=>$phenotype_url},$phenotype_name));
			
			
			if ($phenotype_tag eq 'Phenotype_not_observed') {
 	
				$p_data{'not'} = 1; 		
 			}
			
			$p_data{'phenotype'} = {
			
							'id' => "$phenotype",
							'label' => "$phenotype_name",
							'class' => 'Phenotype'
			};
			
			$p_data{'ps'} = \@ps_data;
			
			
			push @phenotype_data, \%p_data;
			
		}
#	}

	$return_data{'data_pack'} = \@phenotype_data;
	$return_data{'description'} = "Phenotypes for this variation";
	
	return \%return_data;
	
	}







############################################################
#
# GENETICS
#  NEEDS: Mapping data
############################################################
# TO DO: What if it is empty or not known? Perhaps DATA
sub gene_class {
    my $self   = shift;
    my $object = $self->object;    
    my $gene_class = $object->Gene_class || "";
    return { description => 'the class of the gene the variation falls in, if any',
	     data => { id    => "$gene_class",
			      label => "$gene_class",
			      class => $gene_class,
	     },
    };
}


# This should return the CGC name, sequence name (if name), and WBGeneID...
sub corresponding_gene {
    my $self   = shift;
    my $object = $self->object;    
    my $description = 'gene in which this variation is found (if any)';
    my $gene   = $object->Gene or return { description => $description };
    return { description => $description,
	     data        => $self->_pack_obj($gene),
    };
}   

sub reference_allele {
    my $self      = shift;
    my $object    = $self->object;
    my $gene      = $object->Gene;
    my $allele    = $gene ? $gene->Reference_allele : "";
    return { description => 'the reference allele for the containing gene (if any)',	    
	     data=> { 
	     	label => 
	     		$gene->Reference_allele ? $gene->Reference_allele->Public_name->name : $allele,
            id    => $allele,
            class => 'variation' },
    };
}

sub other_alleles {
    my $self    = shift;
    my $object  = $self->object;
    my $gene    = $object->Gene;
    my $data = { };
    if ($gene) {    
	my @alleles = grep {$_ ne ($object || '')} $gene->Allele(-fill=>1);
	
	foreach (@alleles) {
        my $d = { id => "$_",
                  label => $_->Public_name->name,
                  class => 'variation', };
	    if ($_->SNP) {
			push @{$data->{data}->{polymorphisms}}, $d;
	    } else {		
			if ($_->Sequence || $_->Flanking_sequences) {
		    	push @{$data->{data}->{unsequenced_alleles}},$d;
			} else {		    
		    	push @{$data->{data}->{sequenced_alleles}},$d;
			}
	    }
	}
    }
    $data->{description} = 'other alleles of the containing gene (if known)';
    return $data;
}


sub strains {
    my $self   = shift;
    my $object = $self->object;
    my (@strains,@singletons,@cgc,@others,@both, $count);
    foreach ($object->Strain) {
      $count++;
      my @genes = $_->Gene;
      my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;
      if (@genes == 1){
        if ($cgc){push @both, $self->_pack_obj($_);}
        push @singletons, $self->_pack_obj($_);
      }elsif($cgc){
        push @cgc, $self->_pack_obj($_);
      }else{
        push @others, $self->_pack_obj($_);
      }
    }
    my $data = { description => 'strains carrying this variation',
            data        => { singleton => \@singletons,
                             both => \@both,
                             cgc => \@cgc,
                             other => \@others,
                             total => $count,
                            }
    };

    return $data;  
# 
#     my $data = {};
#     
#     foreach ($object->Strain) {
# 	my @genes = $_->Gene;
# 	my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;
# 	push @{$data->{data}->{all_strains}},$_;
# 
# 	# Some hash lookups for formatting
# 	$data->{data}->{cgc_strains}->{$_}++ if $cgc;
# 	$data->{data}->{strains_only_carrying_this_allele}->{$_}++ if (@genes == 1);	       
#     }
#     $data->{description} = 'strains carrying this variation';    
#     return $data;
}


sub rescued_by_transgene {
    my $self   = shift;
    my $object = $self->object;
    my $data = { description => 'transgenes that rescue phenotype(s) caused by this variation',
		 data        => $object->Rescued_by_Transgene || "",
    };
    return $data;
}





############################################################
#
# HISTORY
#
############################################################

sub laboratory_of_origin {
    my $self = shift;
    my $object = $self->object;
    return { description => 'the laboratory that generated the variation',
	     data        => { id => $object->Laboratory,
                          label => $object->Laboratory . ": " . $object->Laboratory->Representative->Standard_name,
                          class => 'laboratory'}};
}

sub isolated_by_author {
    my $self = shift;
    my $object = $self->object;
    return { description => 'the author credited with generating the mutation',
         data        => { id => $object->Author,
                          label => $object->Author,
                          class => 'person'}};
}

sub isolated_by {
    my $self = shift;
    my $object = $self->object;
#  my $person = join("; ",map { ObjectLink($_,$_->Full_name || $_->Standard_name) } $var->Person) if $var->Person;
#  $person ||= UNKNOWN;
#  SubSection('Person',$person);
    return { description => 'the person credited with generating the mutation',
         data        => { id => $object->Person,
                          label => $object->Person,
                          class => 'person'}};
}


sub date_isolated {
    my $self = shift;
    my $object = $self->object;
    return { description => 'date the mutation was isolated',
	     data        => $object->Date };
}


sub mutagen {
    my $self = shift;
    my $object = $self->object;
    return { description => 'mutagen used to generate the variation',
	     data        => $object->Mutagen };
}

# Q: What are the contents of this tag?
sub isolated_via_forward_genetics {
    my $self = shift;
    my $object = $self->object;
    return { description => 'was the mutation isolated by forward genetics?',
	     data        => $object->Forward_genetics };
}

# Q: what are the contents of this tag?
sub isolated_via_reverse_genetics {
    my $self = shift;
    my $object = $self->object;
    return { description => 'was the mutation isolated by reverse genetics?',
	     data        => $object->Reverse_genetics };
}

sub transposon_excision {
    my $self = shift;
    my $object = $self->object;
    return { description => 'was the variation generated by a transposon excision event, and if so, of which family?',
	     data        => $object->Transposon_excision,
    };
}

sub transposon_insertion {
    my $self = shift;
    my $object = $self->object;
    return { description => 'was the variation generated by a transposon insertion event, and if so, of which family?',
	     data        => $object->Transposon_insertion,
    };
}


# Q: How is this used? Is this used in conjunction with the various KO Consortium tags?
sub source_database {
    my $self = shift;
    my $object = $self->object;

    my $source_db = $object->Database;
    my ($remote_url,$remote_text);
    if ($source_db) {
	my $name = $source_db->Name;      
	my $id   = $object->Database(3);

	# Using the URL constructor in the database (for now)
	# TODO: Should probably pull these out and keep URLs in config
	my $url  = $source_db->URL_constructor;
	# Create a direct link to the external site

	if ($url && $id) {
	    $name =~ s/_/ /g;
	    $remote_url = sprintf($url,$id);
	    $remote_text = "$name";
	} 
    }
    my $data = { description => 'remote source database, if known',
		 data        => { remote_url => $remote_url,
				  remote_text => $remote_text,
		 }
    };
    return $data;
}	
  
sub derived_from {
    my $self = shift;
    my $object = $self->object;
    return { description => 'variation from which this one was derived',
	     data        => $object->Derived_from,
    };
}

sub derivative {
    my $self   = shift;
    my $object = $self->object;
    my @derivatives = $object->Derivative;
    return { description => 'variations derived from this variation',
	     data        => \@derivatives,
    };
}
       







############################################################
#
# PRIVATE METHODS
#
############################################################



##########################################
# MolecularChangeHash
##########################################

# Draw out what the effects are on proteins
# and where the mutation occurs.
sub _format_molecular_change_hash {   
    my ($self,$params) = @_;
    my $data = $params->{data};
    my $tag  = $params->{tag};
    
    return unless $data && eval { @$data >= 1 };   # Nothing to build a table from

    my @types     = qw/Missense Nonsense Frameshift Silent Splice_site/;
    my @locations = qw/Intron Coding_exon Noncoding_exon Promoter UTR_3 UTR_5 Genomic_neighbourhood/;
    
    # Select items that we will try and translate
    # Currently, this needs to be
    # 1. Affects Predicted_CDS
    # 2. A missense or nonsense allele
    # 3. Contained in a coding_exon
    my %parameters_seen;
    my %do_translation = map { $_ => 1 } (qw/Missense Nonsense/);
    # Under no circumstances try and translate the following
    my %no_translation = map { $_ => 1 } (qw/Frameshift Deletion Insertion/);
    
    # The following entries should be examined for the presence
    # of associated Evidence hashes
    my @with_evidence = 
	qw/
	Missense
	Silent
	Nonsense
	Splice_site
	Frameshift
	Intron
	Coding_exon
	Noncoding_exon
	Promoter
	UTR_3
	UTR_5	
	Genomic_neighbourhood
	/; 
    
    my (@protein_effects,@location_effects);
    foreach my $entry (@$data) {  
	my $hash  = $entry->{hash};
	my $node  = $entry->{node};

	# Conditionally format the data for each type of evidence
	# Curation often has the type of change and its location
	
	# What type of change is this?
	foreach my $type (@types) {
	    my $obj = $hash->{$type};
	    my @data = eval { $obj->row };
	    next unless @data;
	    my $clean_tag = ucfirst($type);
	    $clean_tag    =~ s/_/ /g;
	    $parameters_seen{$type}++;
	    
	    my ($pos,$text,$evi,$evi_method,$description);
	    if ($type eq 'Missense') {
		($type,$description,$text,$evi) = @data;
	    } elsif ($type eq 'Nonsense' || $type eq 'Splice_site') {
		($type,$description,$text,$evi) = @data;		
	    } elsif ($type eq 'Frameshift') {
		($type,$text,$evi) = @data;
	    } else { 
		($type,$text,$evi) = @data;
	    }	    

#	    # NOT DONE!  Haven't added evidence parsing yet. Should be global
#	    if ($evi) {
#		($evi_method) = GetEvidenceNew(-object => $text,
#					       -format => 'inline',
#					       -display_label => 1,
#					       );
#    	     }

	    push @protein_effects,{ effect_on_protein    => $clean_tag,
				    description => $description,
				    text        => $text,
				    evidence    => $evi_method
	    };
	}
	
	# *Where* is this change located?
	foreach my $location (@locations) {
	    my $obj = $hash->{$location};
	    my @data = eval { $obj->col };
	    next unless @data;
	    
	    $parameters_seen{$location}++;
	    
	    # NOT DONE! Need to add in evidence parsing
#	    my ($evidence) = GetEvidenceNew(-object => $obj,
#					    -format => 'inline',
#					    -display_label => 1
#					    );
	    
	    my $clean_tag = ucfirst($location);
	    $clean_tag    =~ s/_/ /g;
	    
	    my $evidence = '';
	    push @location_effects,{ location => $clean_tag,
				     evidence => $evidence,
	    };
	}
    }
    
    my $do_translation;
    foreach (keys %parameters_seen) {
	$do_translation++ if (defined $do_translation{$_}  && !defined $no_translation{$_});
    }
    return (\@protein_effects,\@location_effects,$do_translation);
}




# What is the length of the mutation?
sub _compile_nucleotide_changes {
    my ($self,$object) = @_;
    my @types = eval { $object->Type_of_mutation };
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
	    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
		$mut = $object->Transposon_insertion;
		$mut ||= 'unknown' if $object->Method eq 'Transposon_insertion';
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
	    
	    my $segment = $self->_get_genomic_segment(-key => 'wt_variation');
	    if ($segment) {
		$wt  = $segment->dna;
	    }
	    
	    # CGH tested deletions.	    
	    $type = "definite deletion" if  ($object->CGH_deleted_probes(1));
	    
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
	if ($object->SNP(0) || $object->RFLP(0)) {
	    $wt_label = 'bristol';
	    $mut_label = $object->Strain;  # CB4856, 4857, etc
	} else {
	    $wt_label  = 'wild type';
	    $mut_label = 'mutant';
	}
	
	push @variations,{ type           => "$type",
			   wildtype       => "$wt",
			   mutant         => "$mut",
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
    my ($class,$start,$stop,$refseq,$key) = $self->rearrange([qw/CLASS START STOP REFSEQ KEY/],@p);

    # We may have already fetched this segment and stashed it.
    if ($key && $self->{segments}->{$key}) {
	return $self->{segments}->{$key};
    }

    # Fetch the object
    my $object = $self->object;

    # Get a GFFdb handle - I'm not sure how to do this in the API.
    # TODO: This should probably be simplified
    my $species = $self->parsed_species;
    my $db_obj  = $self->gff_dsn($species);    # Get a WormBase::API::Service::gff object
    my $db      = $db_obj->dbh;

    my $segment;

    # Am I trying to fetch a specific segment with start and stop coords?
    if ($refseq && $start && $stop) {
	$segment = $db->segment(-name=>$refseq,-start=>$start,-stop=>$stop);

    # Am I trying to fetch a specific segment.
    } elsif ($refseq) {
	$segment = $db->segment(-name=>$refseq,-class=>$refseq->class);

    # Otherwise, fetch a segment for the variation.
    } else {
	$class ||= $object->class;
	$segment = $db->segment($class => $object);
    }
    
    $self->{segments}->{$key} = $segment if $segment && $key;
    return $segment;
}


# Return the genomic coordinates of a provided span
sub _coordinates {
    my ($self,$segment) = @_;
    
    return unless $segment;
    
    my $ref       = eval{$segment->abs_ref};
    my $start     = $segment->start;
    my $stop      = $segment->stop;
	

    $segment->absolute(1);
    my $abs_start = $segment->abs_start;
    my $abs_stop  = $segment->abs_stop;
    ($abs_start,$abs_stop) = ($abs_stop,$abs_start) if ($abs_start > $abs_stop);
    $segment->absolute(0);
    return ($ref,$abs_start,$abs_stop,$start,$stop);
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
    my ($with_markup,$flank) = $self->rearrange([qw/WITH_MARKUP FLANK/],@p);
    
    # Get a GFFdb handle - I'm not sure how to do this in the API.
    my $species = $self->parsed_species;
    my $db_obj  = $self->gff_dsn($species);    # Get a WormBase::API::Service::gff object
    my $db      = $db_obj->dbh;

    my $object     = $self->object;
    my $segment    = $self->_get_genomic_segment(-key => 'wt_variation');
    return unless $segment;
    
    my $sourceseq  = $segment->sourceseq;
    my ($chrom,$abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
    
    my $debug;
    
    # Coordinates are sometimes reported on the minus strand
    # We will report all sequence strings on the plus strand instead.
    my $strand;
    if ($abs_start > $abs_stop) {
 	($abs_start,$abs_stop) = ($abs_stop,$abs_start);
 	$strand = '-';  # Set $strand - used for tracking
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
    # MOVE INTO TEST
    # $debug .= "WT SNIPPET DNA FROM GFF: $dna" . br if DEBUG_ADVANCED;
    
    # Visit each variation and create a formatted string
    my ($wt_fragment,$mut_fragment,$wt_plus,$mut_plus);
    my $variations = $self->_compile_nucleotide_changes($object);
    
    foreach my $variation (@{$variations}) {
	my $type = $variation->{type};
	my $wt   = $variation->{wildtype};
	my $mut  = $variation->{mutant};
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
 	
	# MOVE INTO TEST
# 	if (DEBUG_ADVANCED) {
# 	    $debug .= "WT SEQUENCE EXTRACTED FROM GFF .. : $extracted_wt" . br;
# 	    $debug .= "WT SEQUENCE STORED IN ACE ....... : $wt" . br;
# 	    $debug .= "MUT SEQUENCE STORED IN ACE ...... : $mut" . br;
# 	    $debug .= "LENGTH OF VARIATION ............. : " . length($extracted_wt) . ' bp' . br;
# 	}
	
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
	    # MOVE INTO TEST
 	    # $debug .= "-----> TRANSCRIPT ON - strand; revcomping" if DEBUG_ADVANCED;

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
	
	# Keep the full string of all variations on the plus strand 
	$wt_plus  .= $wt;
	$mut_plus .= $mut;
	
	# What is the type of mutation? If deletion or insertion,
	# check the length of the partner, then format appropriately
	# TODO: The INDEL_DISPLAY_LIMIT is hard coded
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
 	$mutation_length  = length($wt_plus);
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
     
    # TODO: Make the snippet length configurable.
    my $SNIPPET_LENGTH = 100;
    $flank ||= $SNIPPET_LENGTH;
    
    my $insert_length = (length $wt_fragment > length $mut_fragment) ? length $wt_fragment : length $mut_fragment;
    my $flank_length = int(($flank - $insert_length) / 2);
    
    # The amount of flank to fetch is based on the middle segment
    my $left_flank  = substr($dna,$mutation_start - $flank_length,$flank_length);
    my $right_flank = substr($dna,$mutation_start + $mutation_length,$flank_length);
    
    # MOVE INTO TEST
#    if (DEBUG_ADVANCED) {
#	#      print "right flank : $right_flank",br;
# 	$debug .= "WT PLUS STRAND .................. : $wt_plus"  . br;
# 	$debug .= "MUT PLUS STRAND ................. : $mut_plus" . br;
#     }
 
    # Mark up the reported flanking sequences in the full sequence
    my ($reported_left_flank,$reported_right_flank) = ($object->Flanking_sequences(1),$object->Flanking_sequences(2));
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
    
    # TO DO: This markup belongs as part of the view, not here.
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
    my $markup = Bio::Graphics::Browser2::Markup->new;
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
    my $object = $self->object;
    
    # This must be parsed from the Molecular_change hash now, specifically Predicted_CDS
    return $self->{aa_type} if $self->{aa_type};
    
    # AA type change, if known, will be located under the Predicted_CDS
    my @types     = qw/Missense Nonsense Frameshift Silent Splice_site/;
    foreach my $cds ($object->Predicted_CDS) {
 	my $data = $self->_parse_hash($cds);
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
    my ($self,$cds) = @_;
     
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
    my $object = $self->object;
     $self->{mut_trans} = 
 	"> $cds ($object: $formatted_change)"
 	. $self->_do_markup($mut_protein,$pos-1,$mut_aa,undef,'is_peptide');
        
     my $debug;

    # MOVE INTO TEST
#     if (DEBUG_ADVANCED) { 
# 	$debug .= "CONCEPTUAL TRANSLATION VIA SUBSTITUTION OF STORED AA" . br;
# 	$debug .= "STORED WT : $wt_aa" . br;
# 	$debug .= "STORED MUT: $mut_aa" . br;
#     }	
     
    return ($self->{wt_protein_fragment},$self->{mut_protein_fragment},$self->{wt_trans},$self->{mut_trans},$debug);
}


    
## For missense and non_sense alleles only
## Actually, the position is ONLY stored for
## missense alleles
sub _get_aa_position {
    my ($self,$cds) = @_;
    my @types = qw/Missense Nonsense/;
    my $data = $self->_parse_hash($cds);
    foreach my $entry (@$data) {
	my $hash = $entry->{hash};
 	my $node = $entry->{node};
 	foreach my $type (@types) {
	    
 	    my $obj = $hash->{$type};
 	    my @data = eval { $obj->row };
 	    if ($obj) {
 		if ($type eq 'Missense') {
 		    my ($type,$pos,$text,$evi) = @data;
		    $self->log->warn("getting aa positiong $pos $text $type");
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
# Much in here could be generic
sub _fetch_coords_in_feature {
    my ($self,$tag,$entry) = @_;
    # Fetch the variation segment
    my $variation_segment = $self->_get_genomic_segment(-key=>'wt_variation');

    # Fetch a GFF segment of the containing feature
    my $containing_segment;

    my $species = $self->parsed_species;
    my $gffdb   = $self->gff_dsn($species);

    # Kludge for chromosome    
    if ($tag eq 'Chromosome') {
 	($containing_segment) = $gffdb->segment(-class=>'Sequence',-name=>$entry);
     } else {
 	
 	# Um, this breaks very often, returning multiple segments...
 	$containing_segment = $self->_get_genomic_segment(-refseq=>$entry);
     }

     return unless $variation_segment && $containing_segment;
     if ($containing_segment) {
 	# Set the refseq of the variation to the containing segment
 	eval { $variation_segment->refseq($containing_segment) };
 	
 	# Debugging statements
	# MOVED into the Variation.t
# 	warn "Contained in $tag $entry" . join(' ',$data->coordinates($variation_segment)) if DEBUG;
# 	warn "Containing seg coordinates " . join(' ',$data->coordinates($containing_segment)) if DEBUG;
 	
 	my ($chrom,$fabs_start,$fabs_stop,$fstart,$fstop) = $self->_coordinates($containing_segment);
 	my ($var_chrom,$abs_start,$abs_stop,$start,$stop) = $self->_coordinates($variation_segment);
 	($start,$stop) = ($stop,$start) if ($start > $stop);
 	return ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop);
     }
}


# OLD ACCESSORS deprecating
#sub cgh_segment       { return shift->{segments}->{cgh_variation}; }










1;
