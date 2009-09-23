package WormBase::Model::Variation;

use Moose;
extends 'WormBase::Model';

use Bio::Perl;
use Bio::Graphics::Browser::Markup;

# Multi-tiered searches for variations
sub search {
  my ($self,$name) = @_;
  
#  my ($object) = $DB->fetch(-class => 'Variation',
#			    -name  => $name);

#  my $GFFDB = OpenGFFDB($DB,$var->Species);
#  # Create a package object for storing data
#  my $this = Container->new($var,$GFFDB);
#  return ($this,$var,$GFFDB);
}

###########################################
# Variation-specific components of the
# Identification widget
###########################################
sub variation_type {
  my ($self) = @_;
  my $object = $self->current_object;
  my $string;
  if ($object->KO_consortium_allele(0)) {
    $string = "Knockout Consortium allele";
  } elsif ($object->SNP(0) && $object->RFLP(0)) {
    $string = 'Polymorphism; RFLP';
    $string .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";
  } elsif ($object->SNP(0) && !$object->RFLP(0)) {
    $string = 'Polymorphism';
    $string .= $object->Confirmed_SNP(0) ? " (confirmed)" : " (predicted)";
  } else {
    $string = 'allele';
  }
  return $string;
}


###########################################
# Components of the Molecular Details widget
###########################################
sub type_of_mutation {
  my ($self) = @_;
  my $object = $self->current_object;

  # Don't bother trying to post-process variations that lack coords
  # or flanking sequences;
  if ($object->Type_of_mutation && !$self->flanking_sequences) {
    my $type = $object->Type_of_mutation;
    my $text = "$type";
    if ($type eq 'Substitution') {
      if (eval { $type->right->right }) {
	$text .= ': ' . join('->',$type->right,$type->right->right );

	# TODO: NEED TO APPEND EVIDENCE
	#	my ($evidence) = GetEvidence(-obj=>$type->right->right,-omit_label=>1,-dont_link=>1);
	#	$text .= ': ' . $evidence if $evidence;
      }
    } elsif ($type eq 'Insertion' || $type eq 'Deletion') {
      $text .= ': ' . $type->right if $type->right;
      	# TODO: NEED TO APPEND EVIDENCE
      #      my ($evidence) = GetEvidence(-obj=>$type->right,-omit_label=>1,-dont_link=>1);
      #      $text .= ': ' . $evidence if $evidence;
    } else {}
    return $text;
  }
}

sub nucleotide_change {
  my ($self) = @_;
  my $object = $self->current_object;

  # Get nucleotide change details (from ace)
  my $variations = $self->_fetch_sequence_from_ace('stringify - this needs to be migrated to template!');

  my @data;
  foreach my $variation (@{$variations}) {
    my ($type,$wt,$mut) = @{$variation};
    my ($wt_label,$mut_label);
    if ($object->SNP(0) || $object->RFLP(0)) {
      $wt_label = 'bristol';
      $mut_label = $object->Strain;  # CB4856, 4857, etc
    } else {
      $wt_label = 'wild type';
      $mut_label = 'mutant';
    }
    $type = "definite deletion" if  ($object->CGH_deleted_probes);
    push @data,{
		type      => $type,
		wt_seq    => $wt,
		mut_seq   => $mut,
		wt_label  => $wt_label,
		mut_label => $mut_label};
  }

  return \@data;
}
  

sub flanking_sequences {
  my ($self) = @_;
  my $object = $self->current_object;
  my $left_flank  = $object->Flanking_sequences(1);
  my $right_flank = $object->Flanking_sequences(2);

  # Force return of a string and not the object
  return [$left_flank->name,$right_flank->name];
}

sub cgh_flanking_sequences {
  my ($self) = @_;
  my $object = $self->current_object;
  my $flanks = $self->flanking_sequences();
  return $flanks;
}


sub cgh_deleted_probes {
  my ($self) = @_;
  my $object = $self->current_object;
  my $left_flank  = $object->CGH_deleted_probes(1);
  my $right_flank = $object->CGH_deleted_probes(2);

  return unless ($left_flank && $right_flank);
  # Force return of sequence string and not object
  return [$left_flank->name,$right_flank->name];
}

# Various length strings showing the variation
# in context in wild type and mutant
sub context {
  my ($self) = @_;
  my $data = $self->_build_sequence_strings();
  return $data;
}

# Display the position of the variation within a number of features
# Foreach item that the variation is known to affect, display a table
# with variation coordinates relative to the feature

# This is mostly constructed from Molecular_change hash associated with
# tags in Affects, with the exception of Clone and Chromosome

# Add some better markup (ie flat table looks kinda like crap)
# add conceptual translation
sub affects {
  my ($self,$tag) = @_;
  my $object = $self->current_object;  

  my $stash = {};
  foreach my $tag (qw/Pseudogene Transcript Predicted_CDS Gene Clone Chromosome/) {
    if (my @entries = eval { $object->$tag }) {    
      # Parse the Molecular_change hash for each feature
      my $parsed_data;
      foreach my $entry (@entries) {
	
	# Parse the #Molecular_change for salient details
	# do_translation is a flag controlling whether or not
	# we should undertake a conceptual translation
	# These are subfeatures like intron and exon
	my ($protein_effects,$contained_in,$do_translation) = $self->_parse_molecular_change_hash($entry,$tag);

	my %data;
	$data{affected} = $entry;

	$data{contained_in}     = $contained_in if $contained_in;
	$data{protein_effects} = $protein_effects if $protein_effects;

	# Display a conceptual translation, but only for Missense
	# Nonsense, and Frameshift alleles within exons
	if ($tag eq 'Predicted_CDS' && $do_translation) {
	  my $aa_type = $self->_aa_type();
	  if ($aa_type) {

	    my $translations = $self->_do_simple_conceptual_translation($entry);
	    unless ($translations->{wildtype_protein_fragment}) {
	      $translations = $self->_do_manual_conceptual_translation($entry);
	    }
	    $data{aa_type} = $aa_type;
	    $data{conceptual_translation} = $translations;
	    
#	    # Meld these two hashes. Silly.
#	    foreach (keys %$translations) {
#	      $data{$_} = $translations->{$_};
#	    }
	  }
	}
	
	my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$entry);
	
	$data{feature_start} = $fstart;
	$data{feature_stop}  = $fstop;
	$data{start}         = $start;
	$data{stop}          = $stop;
	push @{$stash->{$tag}},\%data;
      }
      
    } else {
      
      # Clone must come from the Sequence tag
      my @affects;
      if ($tag eq 'Clone') {
	@affects = $object->Sequence if $object->Sequence;
      }
          
      foreach (@affects) {
	my %data;
	$data{affects} = $_;	
	my ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop) = $self->_fetch_coords_in_feature($tag,$_);

	$data{feature_start} = $fstart;
	$data{feature_stop}  = $fstop;
	$data{start}         = $start;
	$data{stop}          = $stop;
	push @{$stash->{$tag}},\%data;

      }
    } 
  }
   return $stash;
}


sub flanking_pcr_products {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->PCR_product;
}


=pod

# TODO: This should probably be moved to WormBase::Model
# This was gene/variation::motif_picture.
# It is also basically used by the protein script, too,
# thus being generalized
# This is being handled a bit differently than before.
# The Motif Picture is now created only for predicted CDS.
# It produces a list of images (really, it should accept a single CDS and priduce a single image).
sub motif_picture {
  my ($self) = @_;
  my $object = $self->current_object;
  my @cds = $object->Predicted_CDS;
  my @data;

  $BROWSER ||= Bio::Graphics::Browser->new or AceError('Cannot open picture generator');
  $BROWSER->read_configuration(Configuration->Gff_conf)  or AceError("Can't read gff configuration");
  $BROWSER->source('elegans');
  $BROWSER->width(PICTURE_WIDTH);
  $BROWSER->config->set('general','empty_tracks' => 'suppress');
  $BROWSER->config->set('general','keystyle'     => 'none');
  
  foreach my $cds (@cds) {
    my $cds     = $self->_cds_segment($cds);
    
    # NOT DONE
    my $length  = $data->wt_trans_length;
    
    # Setup the panel, using the protein length to establish the box as a guide
    my $ftr = 'Bio::Graphics::Feature';
    my $base_segment = $ftr->new(-start=>1,-end=>$length,
				 -name => $cds->display_name,
				 -type => 'Protein');
    my $panel = Bio::Graphics::Panel->new(-segment   =>$base_segment,
					  -key       =>'Protein Features',
					-key_style =>'between',
					-key_align =>'left',
					-grid      => 1,
					  -width     =>PICTURE_WIDTH);
    $panel->pad_bottom(PADDING);
    $panel->pad_left(PADDING);
  $panel->pad_right(PADDING);
    $panel->pad_top(PADDING);
    
    # Fetch an ace object for the current CDS
    my ($obj) = map {$_->Corresponding_protein} grep { $_ eq $cds->display_name } $var->Predicted_CDS;
    
    my %features;
    ## Structural motifs (this returns a list of feature types)
  my @features = $obj->Feature;
  # Visit each of the features, pushing into an array based on its name
  foreach my $type (@features) {
    # 'Tis dangereaux - could lose some features if the keys overlap...
    my %positions = map {$_ => $_->right(1)} $type->col;
    foreach my $start (keys %positions) {
      my $seg   = $ftr->new(-start=>$start,-end=>$positions{$start},
			    -name=>"$type",-type=>$type);
      # Create a hash of all the features, keyed by type;
      push (@{$features{'Features-' .$type}},$seg);
    }
  }
  
  # A protein ruler
  $panel->add_track(arrow => [ $base_segment ],
		    -label => 'amino acids',
		    -arrowstyle=>'regular',
		    -tick=>5,
		    #		    -tkcolor => 'DarkGray',
		   );
  
  # Fetch and sort the exons
  my @exons = grep { $_->name eq $cds->display_name } $cds->features('exon:curated');
  
  # Translate the bp start and stop positions into the approximate amino acid
  # contributions from the different exons.
  my ($count,$end_holder);
  my @segmented_exons;
  my $total_aa;
  foreach my $exon (sort { $a->start <=> $b->start} @exons) {
    $count++;
    my $start = $exon->start;
    my $stop  = $exon->stop;
    
    # Calculate the difference of the start and stop to approximate its aa span
    my $length = (($stop - $start) / 3);
    $total_aa += $length;
    
    my $end = $length + $end_holder;
    
    my $seg = $ftr->new(-start=>$end_holder || 1,-end=>$end,
			-name=>$count,-type=>'exon');
    push @segmented_exons,$seg;
    
    # This is really the new start position
    $end_holder = $end + 1;
  }
    
    ## Print the exon boundaries
    $panel->add_track(generic=>[ @segmented_exons ],
		      -label     =>  1,  # number the exons
		      -key       => 'exon boundaries',
		      -description => 1,
		      -bump      => 0,
		      -height    => 6,
		      -spacing   => 50,
		      -linewidth =>1,
		      -connector =>'none',
		      #		  -tkcolor => $colors[rand @colors],
		      ) if @segmented_exons;
    
    
    foreach ($obj->Homol) {
	my (%partial,%best);
	my @hits = $obj->$_;
	
	# Let's not display pep_homols on this image
	next if ($_ eq 'Pep_homol');
	
	#    # Pep_homol data structure is a little different
	#    if ($_ eq 'Pep_homol') {
	#      my @features = wrestle_blast(\@hits,1);
	
	#      # Sort features by type.  If $best_only flag is true, then we only keep the
	#      # best ones for each type.
	#      my %best;
	#      for my $f (@features) {
	#	next if $f->name eq $obj;
	#    	my $type = $f->type;
	#   	if ($best_only) {
	#    	  next if $best{$type} && $best{$type}->score > $f->score;
	#    	  $best{$type} = $f;
	#    	} else {
	#    	  push @{$features{'BLASTP Homologies'}},$f;
	#    	}
	#      }
	
	#      # add descriptive information for each of the best ones
	#      local $^W = 0; #kill uninit variable warning
	#      for my $feature ($best_only ? values %best : @{$features{'BLASTP Homologies'}}) {
	#	my $homol = $HIT_CACHE{$feature->name};
	#	my $description = $homol->Species;
	#	my $score       = sprintf("%7.3G",10**-$feature->score);
	#	$description    =~ s/^(\w)\w* /$1. /;
	#	$description   .= " ";
	#	$description   .= $homol->Description || $homol->Gene_name;
	#	$description   .= eval{$homol->Corresponding_CDS->Brief_identification}
	#	  if $homol->Species =~ /elegans|briggsae/;
	#	my $t = $best_only ? "best hit, " : '';
	#	$feature->desc("$description (${t}e-val=$score)") if $description;
	#      }
	
	#      if ($best_only) {
	#	for my $type (keys %best) {
	#	  push @{$features{'Selected BLASTP Homologies'}},$best{$type};
	#	}
	#      }
	#      #
	#      #      # these are other homols
	#    } else {
	
	for my $homol (@hits) {
	    my $title = eval {$homol->Title};
	    my $type  = $homol->right or next;
	    my @coord = $homol->right->col;
	    my $name  = $title ? "$title ($homol)" : $homol;
	    for my $segment (@coord) {
		my ($start,$stop) = $segment->right->row;
		my $seg  = $ftr->new(-start=>$start,
				     -end =>$stop,
				     -name =>$name,
				     -type =>$type);
		push (@{$features{'Motifs'}},$seg);
	    }
	}
      }
  
  
  my %glyphs = $self->motif_picture_glyphs;
  my %labels = $self->motif_picture_labels;
  my %colors = $self->motif_picture_colors;
     
  foreach my $key (sort keys %features) {
    # Get the glyph
    my $type  = $features{$key}[0]->type;
    my $label = $labels{$key}  || $key;
    my $glyph = $glyphs{$key}  || 'graded_segments';
    my $color = $colors{$type} || 'green';
    my $connector = $key eq 'Pep_homol' ? 'solid' : 'none';
    
    $panel->add_track(segments   =>$features{$key},
		      -glyph    =>$glyph,
		      -label  => ($label =~ /Features/) ? 0 : 1,
		      -bump   => 1,
		      -sort_order=>'high_score',
		      -bgcolor   =>$color,
		      -font2color => 'red',
		      -height    =>6,
		      -linewidth =>1,
		      -description=>1,
		      -min_score  =>-50,
		      -max_score  =>100,
		      -key       =>$label,
		     );
  }
  
  # Add in the allele position
  # Should conditionally select the glyph
  my $var_seg  = $ftr->new(-start=>$data->wt_aa_start,
			   -end =>$data->wt_aa_start,
			   -name =>$var . "(" . $data->formatted_aa_change . ")");
  $panel->add_track(segments     =>$var_seg,
		    -glyph       =>'diamond',
		    -label       => 1,
		    -bump        => 1,
		    -bgcolor     => ($data->aa_type eq 'Missense') ? 'yellow' : 'red',
		    -font2color  => 'red',
		    -height      => 6,
		    -linewidth   => 1,
		    -description => 1,
		   );
  
  # This will not work since I do not readily have
  # The amino acid positions of alleles
  #  my @raw_alleles = grep {$_ ne $var } $gene->features('Allele:Allele','Allele:SNP');
  #  my @alleles;
  #  foreach (@raw_alleles) {
  #    print $_->start/3,br;
  #    print $_->stop/3,br;
  #    my $seg  = $ftr->new(-start=>$_->start/3,
  #			 -end  =>$_->stop/3,
  #			 -name =>$_->name,
  #			 -type =>'Other alleles');
  #    push (@alleles,$seg);
  #  }
  #  print @alleles;
  #  $panel->add_track(segments     => [@alleles],
  #		    -glyph       =>'diamond',
  #		    -label       => 1,
  #		    -bump        => 1,
  #		    -bgcolor     =>'red',
  #		    -font2color  => 'red',
  #		    -height      =>6,
  #		    -linewidth   =>1,
  #		    -description =>1,
  #		    -description => 1,
  #		   );
  
  
  # turn some of the features into urls
  my $boxes = $panel->boxes;
  my $map   = '';
  foreach (@$boxes) {
    my ($feature,@coords) = @$_;
    my $name = $feature->name;
    my $url  = hit_to_url($name) or next;
    my $coords    = join ',',@coords;
    $map   .= qq(<area shape="rect" target="_new" coords="$coords" href="$url" />\n);
  }
  
  my $gd = $panel->gd;
  my $url = AceImage($gd);
  
  my $img = img({-src    => $url,
		 -align  => 'center',
		 -usemap => '#protein_domains',
		 -border => 0
		   });
    return ($img,qq(\n<map name="protein_domains">\n),$map,qq(</map>\n));
}

=cut

sub add_track {
  my ($self,$panel,$features,$BROWSER) = @_;
  
  # Can I generalize this for a given feature instead
  $panel->add_track(segments     => [@$features],
		    -glyph       => $BROWSER->setting(Allele => 'glyph'),
		    -label       => 1,
		    -bump        => 1,
		    -bgcolor     => $BROWSER->setting(Allele => 'bgcolor'),
		    -font2color  => 'blue',
		    -height      => 6,
		    -linewidth   => 1,
		    -description => $BROWSER->setting(Allele =>'description'),
		   );
}









###########################################
# Components of the Location widget
###########################################
sub genomic_position {
  my ($self) = @_;
  my $segment = $self->_variation_segment();
  return unless $segment;
  $segment->absolute(1);
  my $coords = $self->SUPER::genomic_position($segment);
  return $coords;
}


sub genomic_environs {
  my ($self) = @_;
  my $object = $self->current_object;
  my $gene = $object->Gene;
  my $segment = $self->_variation_segment();

  # By default, lets just center the image on the variation itself.
  # What segment should be used to determine the baseline coordinates?
  # Use a CDS segment if one is provided, else just show the genomic environs
  unless ($segment) {
    # Try fetching a generic segment
    my $coords =  $self->SUPER::genomic_position($segment);
    my $ref = $coords->{chromosome};
    my ($low,$high);
    my $abs_start = $coords->{abs_start};
    my $abs_stop = $coords->{abs_stop};
    if ($abs_stop - $abs_start < 100) {
      $low   = $abs_start - 50;
      $high  = $abs_stop  + 50;
    } else {
      $low = $abs_start;
      $high = $abs_stop;
    }

    my $split = $self->{unmapped_span} / 2;   

    my $dbh = $self->dbh_gff();
    ($segment) = $dbh->segment($ref,$low-$split,$low+$split);
  }
  return unless $segment;
  
  my @tracks = (qw/CG 
		   Allele
		   TRANSPOSONS
		  /);
  
  my %options = (ESTB => 2);  
  my $data = $self->build_gbrowse_img($segment,\@tracks,\%options);
  return $data;
}



###########################################
# Components of the Genetic Information widget
###########################################
sub corresponding_gene {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Gene;
}

sub reference_allele {
  my ($self) = @_;
  my $object = $self->current_object;
  my $gene = $object->Gene;
  if ($gene) {
    return $gene->Reference_allele;
  }
}

sub alleles {
  my ($self) = @_;
  my $object = $self->current_object;
  my $gene = $object->Gene;
  if ($gene) {
    my @alleles = $gene->Allele;
    return \@alleles;
  }
}
  

###########################################
# Components of the Polymorphism details widget
###########################################
sub polymorphism_type {
  my ($self) = @_;
  my $object = $self->current_object;
  my $type;
  if ($object->SNP(0) && $object->RFLP(0)) {
    $type = 'SNP and RFLP'
  } elsif ($object->SNP(0)) {
    $type = 'SNP';
  } else {
    $type = $object->Transposon_insertion . ' transposon insertion';
  }
  return $type;
}

sub status {
  my ($self) = @_;  
  my $object = $self->current_object;
  my $string = $object->Confirmed_SNP(0) ? 'confirmed' : 'predicted';
  return $string;
}

sub polymorphism_assay {
  my ($self) = @_;
  my $object = $self->current_object;

  my @stash;
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
    
    my %data;
    if ($object->RFLP(0) && @ref_digests) {
      my ($ref_digest,$ref_bands)   = @{$ref_digests[$index]};
      my ($poly_digest,$poly_bands) = @{$poly_digests[$index]};
      
      %data = ( reference_strain_digest => $ref_digest,
		polymorphic_strain_digest => $poly_digest,
		reference_bands => $ref_bands,
		polymorphic_bands => $poly_bands,
	      );
    }
    
    $data{detectable_by_rflp} = 1 if $object->RFLP(0);  # this could be pushed to view

    # VIEW SPECIFIC
    # Heinous hack. Some SNPs listed as RFLPs have no assay conditions
    # $assay_table ||= 'SNP Assay: Detectable only by sequencing.' unless $var->RFLP(0);
        
    # Construct a string surrounding the polymorphism
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
    
    my $dbh = $self->dbh_gff();
    
    my ($segment) = $dbh->segment(-name=>$sequence,
				 -offset=>$start,
				 -length=>($stop-$start)) if ($start && $stop);
    my $dna   = $segment->dna if $segment;
        
    $data{verified_pcr_product} = $pcr_product;
    $data{left_oligo}           = $left_oligo;
    $data{right_oligo}          = $right_oligo;
    $data{pcr_conditions}       = $pcr_conditions;
    $data{dna}                  = $dna;
    push @stash,\%data;
  }
  return \@stash;
}


###########################################
# Components of the Isolation History widget
###########################################
sub source_database {
  my ($self) = @_;
  my $object = $self->current_object;
  my $source_db = $object->Database;
  if ($source_db) {
    my $name = $source_db->Name;      
    my $id   = $object->Database(3);
    my $url  = $source_db->URL_constructor;
    # Create a direct link to the external site
    my $request_link;
    if ($url && $id) {
      $name =~ s/_/ /g;
      my $href = sprintf($url,$id); 
      return { target => $name,
	       href   => $href };
    }
  }
}

sub laboratory_of_origin {
  my ($self) = @_;
  my $object = $self->current_object;
  
  my @data;
  foreach ($object->Laboratory) {
    my $name  = eval { $_->Representative->Standard_name };
    my $place = eval { $_->Mail };
    push @data, { name => $name,
		  object => $_,
		  place => $place
		};
  }
  return \@data;
}


sub date_isolated {
  my ($self) = @_;  
  my $object = $self->current_object;
  return $object->Date;
}

sub isolated_via_forward_genetics {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Forward_genetics;
}

sub isolated_via_reverse_genetics {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Reverse_genetics;
}

###########################################################
#  PHENOTYPE WIDGET
###########################################################
# This is entirely supplied by WormBase::Model





    

#########################################
#
#    PRIVATE METHODS
#
#########################################


# TODO:  Lots of view-specific code in here
# What is the length of the mutation?
# (Previously, this was done from the GFF itself.  This is better).

# Stringify does not belong here  (should be part of build string)
# need to concatenate multiple mutations
sub _fetch_sequence_from_ace {
  my ($self,$stringify) = @_;
  my $object = $self->current_object;
  my @variations;

  my @types = eval { $object->Type_of_mutation };  
  foreach my $type (@types) {
    my ($mut,$wt);
    if ($type =~ /insertion/i) {
      $mut = $type->right;
      $wt  = '-';
      if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
	$mut   = $object->Transposon_insertion;
	$mut ||= 'unknown' if $object->Method eq 'Transposon_insertion';
	$mut = "Transposon insertion: $mut" if $mut;
      } else {
	if (length($mut) > $self->indel_display_limit && $stringify) {
	  $mut  = length ($mut) . ' bp insertion';
	}
      }    
    } elsif ($type =~ /deletion/i) {
      
      # TODO: I haven't yet migrated how to fetch and store segments yet
      # Extract the full sequence of the deletion from GFF
      # (It is actually stored in the DB for some alleles)

      my $segment = $self->_variation_segment();

      if ($segment) {
	my $chrom = $segment->abs_ref;
	my $start = $segment->abs_start;
	my $stop  = $segment->abs_stop;
	$wt       = $segment->dna;

# TODO: mk_accessor methods aren't working with dynamically configured actions
#	if (length($wt) > $self->indel_display_limit && $stringify) {
#	  $wt  = length ($wt) . ' bp deletion';
#	}
	if (length($wt) > 25 && $stringify) {
	  $wt  = length ($wt) . ' bp deletion';
	}


	$mut = '-';

      }


    } elsif ($type =~ /substitution/i) {
      my $change = $type->right;
      ($wt,$mut) = eval { $change->row };
      # Ack. Some of the alleles are still A/G.
      unless ($wt && $mut) {
	$change =~ s/\[\]//g;
	($wt,$mut) = split("/",$change);
      }
    }
    push @variations,[$type,$wt,$mut];
  }
  return \@variations;
}



# Fetch a GFF segment corresponding to the variation itself
# THIS COULD/SHOULD BE GENERIC
sub _variation_segment {
  my ($self) = @_;
  my $object = $self->current_object;

  my $dbh = $self->dbh_gff();

  my $segment = $dbh->segment($object->class => $object->name);
  return $segment;
}

# Fetch a CDS segment that wraps the current variation
sub _cds_segment {
  my ($self,$cds) = @_;
  my $dbh = $self->dbh_gff();
  
  my $segment = $dbh->segment(-name=>$cds,-class=>'Transcript');
  return $segment;
}

# Generically fetch a genomic segment
# Source should be one of mutant or wild type
# This may be a segmenet spanning a single variation
# Type will be used to store the segment in the object
# Pass an object to fetch that segment

sub _genomic_segment {
  my ($self,$refseq,$class,$start,$stop,$key) = @_;
  my $dbh = $self->dbh_gff();

  my $segment;
  if ($refseq && $start && $stop) {
    $segment = $dbh->segment(-name=>$refseq,-start=>$start,-stop=>$stop);
  } elsif ($refseq) {
    $segment = $dbh->segment(-name=>$refseq,-class=>$refseq->class);
  }
  return $segment;
}

sub _wt_transcript_length  {
  my ($self) = shift;
  return $self->{wt_trans_length} if $self->{wt_trans_length};
  my $wt_trans = $self->{wt_trans};
  return length $wt_trans;
}

sub _coordinates {
  my ($self,$segment) = @_;
  return ($segment->abs_start,$segment->abs_stop,
	  $segment->start,$segment->stop);
}


# Fetch coordinates of the variation within any given feature
sub _fetch_coords_in_feature {
  my ($self,$tag,$entry) = @_;
  my $object = $self->current_object;  
  
  # Fetch the variation segment
  my $variation_segment = $self->_variation_segment();

  my $dbh = $self->dbh_gff();

  # Fetch a GFF segment of the containing feature
  my $containing_segment;
  # Kludge for chromosome
  if ($tag eq 'Chromosome') {
    ($containing_segment) = $dbh->segment(-class=>'Sequence',-name=>$entry);
  } else {
    # Um, this breaks very often, returning multiple segments...
    $containing_segment = $self->_genomic_segment($entry);
  }
  
  return unless $variation_segment && $containing_segment;
  
  if ($containing_segment) {
    # Set the refseq of the variation to the containing segment
    eval { $variation_segment->refseq($containing_segment) };
    
    # Debugging statements
    # warn "Contained in $tag $entry" . join(' ',$data->coordinates($variation_segment)) if DEBUG;
    # warn "Containing seg coordinates " . join(' ',$data->coordinates($containing_segment)) if DEBUG;
    
    my ($fabs_start,$fabs_stop,$fstart,$fstop) = $self->_coordinates($containing_segment);
    my ($abs_start,$abs_stop,$start,$stop)     = $self->_coordinates($variation_segment);
    #	      ($fstart,$fstop) = (qw/- -/) if ($tag eq 'Chromosome');
    ($start,$stop) = ($stop,$start) if ($start > $stop);
    return ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop);
  }
}





# Build short strings (wild type and mutant) flanking
# the position of the mutant sequence
# If a mutation sequence (insertion or deletion) exceeds
# INDEL_DISPLAY_LIMIT, a string will be inserted unless
# the --all option is supplied.
# Options:
# --all    Return all of the flank-mutant-flank
# --boldface Boldface the mutation
# --flank amount of flank to include. Defaults to SNIPPET_LENGTH
#
# Returns (wt(+), mut(+), wt(-), mut(-));
sub _build_sequence_strings {
  my ($self,$flank) = @_;
  my $object = $self->current_object;  
  
  my $dbh = $self->dbh_gff();

  my $segment = $self->_variation_segment();
  return unless $segment;

  my $sourceseq  = $segment->sourceseq;
  my ($abs_start,$abs_stop,$start,$stop) = $self->_coordinates($segment);
  
  my @debug;
  push @debug,"VARIATION COORDS: $abs_start $abs_stop $start $stop" if ($self->{debug});
  
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
  my ($full_segment) = $dbh->segment(-class => 'Sequence',
				     -name  => $sourceseq,
				     -start => $abs_start - $offset,
				     -stop  => $abs_stop  + $offset);
  my $dna = $full_segment->dna;
  
  push @debug,"WT SNIPPET DNA FROM GFF: $dna" if $self->{debug};
  
  # Visit each variation and create a formatted string
  my ($wt_fragment,$mut_fragment,$wt_plus,$mut_plus);
  my $variations = $self->_fetch_sequence_from_ace($object);

  foreach my $variation (@{$variations}) {
    my ($type,$wt,$mut) = @{$variation};
    my $extracted_wt;
    if ($type =~ /insertion/i) {
      $extracted_wt = '-';
    } else {
      my ($seg) = $dbh->segment(-class => 'Sequence',
				-name  => $sourceseq,
				-start => $abs_start,
				-stop  => $abs_stop);
      $extracted_wt = $seg->dna;
    }
    
    if ($self->{debug}) {
      push @debug,
	"WT SEQUENCE EXTRACTED FROM GFF .. : $extracted_wt",
	  "WT SEQUENCE STORED IN ACE ....... : $wt",
	    "MUT SEQUENCE STORED IN ACE ...... : $mut",
	      "LENGTH OF VARIATION ............. : " . length($extracted_wt) . ' bp';
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
      push @debug,"-----> TRANSCRIPT ON - strand; revcomping" if $self->{debug};
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
    
    # This isn't right. The external model should not need to know about the 
    # display parameters.  All of this processing should be moved to the view.
    my $indel_display_limit = $self->{indel_display_limit};

    # What is the type of mutation? If deletion or insertion,
    # check the length of the partner, then format appropriately
    if (length $mut > $indel_display_limit || length $wt > $indel_display_limit) {
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
	$mut_fragment .= "[$target]";
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
    #      print "On the minus strand",br if $self->{debug};
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
  
  $flank ||= $self->{snippet_length};
  
  my $insert_length = (length $wt_fragment > length $mut_fragment) ? length $wt_fragment : length $mut_fragment;
  my $flank_length = int(($flank - $insert_length) / 2);
  
  # The amount of flank to fetch is based on the middle segment
  my $left_flank  = substr($dna,$mutation_start - $flank_length,$flank_length);
  my $right_flank = substr($dna,$mutation_start + $mutation_length,$flank_length);
  
  if ($self->{debug}) {
    push @debug,
      "WT PLUS STRAND .................. : $wt_plus",
	"MUT PLUS STRAND ................. : $mut_plus";
  }
  
  # Mark up the reported flanking sequences in the full sequence
  my ($reported_left_flank,$reported_right_flank) = $self->flanking_sequences();
  #    my $left_length = length($reported_left_flank);
  #    my $right_length = length($reported_right_flank);
  $reported_left_flank = (length $reported_left_flank > 25) ? substr($reported_left_flank,-25,25) :  $reported_left_flank;
  $reported_right_flank = (length $reported_right_flank > 25) ? substr($reported_right_flank,0,25) :  $reported_right_flank;
  
  # Create a full length mutant dna string so that I can mark it up.
  my $mut_dna = 
    substr($dna,$mutation_start - 500,500)
      . $mut_plus
	. substr($dna,$mutation_start + $mutation_length,500);
  
  my $wt_full  = $self->_markup_variation($dna,$mutation_start,$wt_plus,length($reported_left_flank));
  my $mut_full = $self->_markup_variation($mut_dna,$mutation_start,$mut_plus,length($reported_right_flank));

  # Return the flanks, variations by themselves (*variation), as strings with variation replaced with more
  # meaningful formatting (*substituted*), as short genomic excerpts (*excerpt), and the same, expanded (*expanded)
  # It's a bit redundant but it gives me flexibility to format in the view.
  
  # Currently, the template reconstructs *string_brief
  my %data = (
	      context_flank      => 500 / 2,   # HARDCODED
	      left_flank         => $left_flank,
	      right_flank        => $right_flank,
	      wildtype_substituted_fragment  => $wt_fragment,
	      mutant_substituted_fragment    => $mut_fragment,
	      wildtype_variation         => $wt_plus,
	      mutant_variation           => $mut_plus,
	      wildtype_genomic_excerpt   => lc join('',$left_flank,$wt_plus,$right_flank),
	      mutant_genomic_excerpt     => lc join('',$left_flank,$mut_plus,$right_flank),
	      wildtype_genomic_expanded  => $wt_full,
	      mutant_genomic_expanded    => $mut_full,
	      debug        => \@debug,
	     );
  return \%data;
}



# TODO: The markup should be in CSS or config
# Markup features relative to the CDS or to raw genomic features
sub _markup_variation {
  my ($self,$seq,$var_start,$variation,$flank_length,$is_peptide) = @_;
  my $object = $self->current_object;  

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
  $markup->add_style('newline',"\n");
  
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
  my ($self) = @_;
  my $object = $self->current_object;  
        
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
	  return ($pos,$text,$type);
	}

#	else {
#	  my ($type,$pos,$text,$evi) = @data;
#	  return ($pos,$text,$type);
#	}
      }
    }
  }
  return;
}




# Need to generalize this for all alleles
sub _do_simple_conceptual_translation {
  my ($self,$cds) = @_;
  my $object = $self->current_object;
  
  my %stash;

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
  $stash{wt_aa_start} = $pos;
  $stash{formatted_aa_change} = $formatted_change;
  
  # Create short strings of the proteins for display
  $stash{wildtype_translation_fragment} =
    ($pos - 19)
      . '...'
	. substr($wt_protein,$pos - 20,19) 
	  . ' ' 
	    . substr($wt_protein,$pos-1,1)
	      #	      . b(substr($wt_protein,$pos-1,1)) 
	      . ' ' 		
		. substr($wt_protein,$pos,20) 
		  . '...'
		    . ($pos + 19);
  
  $stash{mutant_translation_fragment} = ($pos - 19) 
    . '...' 
      . substr($mut_protein,$pos - 20,19) 
	. ' ' 
	  #	    . b(substr($mut_protein,$pos-1,1)) 
	  . substr($mut_protein,$pos-1,1)
	    . ' ' 
	      . substr($mut_protein,$pos,20) 
		.  '...' 
		  . ($pos + 19);  
  my $wt_trans_length = length($wt_protein);
  my $mut_trans_length = length($mut_protein);
  
  $stash{wildtype_translation_complete} =
    "> $cds"
      . $self->_markup_variation($wt_protein,$pos-1,$wt_aa,undef,'is_peptide');
  
  $stash{mutant_translation_complete} =
    "> $cds ($object: $formatted_change)"
      . $self->_markup_variation($mut_protein,$pos-1,$mut_aa,undef,'is_peptide');
  
  my @debug;
  if ($self->{debug}) { 
    push @debug,
      "CONCEPTUAL TRANSLATION VIA SUBSTITUTION OF STORED AA",
	"STORED WT : $wt_aa",
	  "STORED MUT: $mut_aa";
  }
  $stash{debug} = \@debug;
  return \%stash;
}


# Need to generalize this for all alleles
sub _do_manual_conceptual_translation {
  my ($self,$cds) = @_;
  my $object = $self->current_object;

  my %stash;
  
#  my ($wt_nuc,$mut_nuc,$wt_full,$mut_full,$debug) 
  my $translations = $self->_build_sequence_strings('20');
  my $wt_nuc   = $translations->{wildtype_genomic_excerpt};
  my $mut_nuc  = $translations->{mutant_genomic_excerpt};
  my $wt_full  = $translations->{wildtype_genomic_expanded};
  my $mut_full = $translations->{mutant_genomic_expanded};
  my $debug    = $translations->{debug};

  return unless ($wt_nuc && $mut_nuc);
  
  # Now that I have the full segment, map the position of the wildtype fragment
  # It might be necessary to find the reverse complement
  # Stitch together the dna of all features
  
  my $segment = $self->_cds_segment($cds);
  # $cds_segment->refseq($segment);
  my $wt_unspliced = $segment->dna;
  
  # Save the coordinates of the exons
  my @exon_boundaries;
  my $wt_spliced;
  foreach ( sort {$a->start <=> $b->start} 
	    grep { $_->name =~ /$cds/ }
	    $segment->features('coding_exon:Coding_transcript')) {
    # 0-based indexing
    push (@exon_boundaries,[$_->start,$_->stop]);
    $wt_spliced .= $_->dna;
  }
  
  # There is apparently no consistency in strandedness of the flanking sequence
  # stored in the DB. Revcomp the flanks if we do not match
  $wt_nuc =~ s/\-//g;    # Let's ignore insertions and deletions
  $mut_nuc =~ s/\-//g;
  my @debug;
  
  if ($self->{debug}) {
    push @debug,"WT STRING ......... ............. : $wt_nuc",      
      "MUT STRING ...................... : $mut_nuc";
  }    
  
  if ($wt_unspliced =~ /$wt_nuc/i) {
  } else {
    $wt_nuc = reverse $wt_nuc;
    $wt_nuc =~ tr/[acgt]/[tgca]/;
    $mut_nuc = reverse $mut_nuc;
    $mut_nuc =~ tr/[acgt]/[tgca]/;
  }
   
  if ($self->{debug}) {
    push @debug,
      "WT STRING REVCOMPED  : $wt_nuc",
	"MUT STRING REVCOMPED : $mut_nuc";
  }
  
  # Hmmmmm.  Now, let's replace this section with the mutant sequence...
  # I need to create pseudo GFF segments for the spliced and unspliced
  my $mut_unspliced = $wt_unspliced;
  
  my $test = $mut_unspliced =~ s/$wt_nuc/$mut_nuc/i;
  
  if ($self->{debug}) {
    if ($wt_unspliced eq $mut_unspliced && !$test) {      
      push @debug,"!!! WT_UNSPLICED eq MUT_UNSPLICED --> something went wrong";
    } else {
      push @debug," ----> WT UNSPLICED SUCCESSFULLY SUBSTITUTED WITH MUT";
    }
  }
  
  # Create the mutant spliced
  # This my be incorrect if there is a splice mutant / deletion
  my $mut_spliced;
  foreach (@exon_boundaries) {
    my ($start,$stop) = @$_;
    my $dna = substr($mut_unspliced,$start-1,$stop - $start + 1);
    $mut_spliced .= $dna;
  }
  
  # Do a conceptual translation but only of allele is listed as
  # frameshift, missense, nonsense
  my $aa_type = $self->_aa_type();
  
  if ($aa_type) {
    # Create a truncated string of the translated wild type and mutant
    # Calculate the position of the amino acid change
    my $wt_trans  = translate_as_string($wt_spliced);
    my $mut_trans = translate_as_string($mut_spliced);
    if ($mut_trans eq $wt_trans && $self->{debug}) {
      push @debug,"!! MUT TRANSLATION == WT TRANSLATIONS --> something went wrong...";
    }
    
    my ($change,$pos);
    if ($aa_type eq 'Nonsense') {
      $mut_trans =~ /\*/g;
      $pos = pos($mut_trans);
      my $wt_aa = substr($wt_trans,$pos-1,1);
      $change = uc $wt_aa . $pos . 'stop';
    } elsif ($aa_type eq 'Missense') {
      # Find the amino acid that differs by comparing char by char - stoopid
      my $c = 0;
      my @mut_chars = split(//,$mut_trans);
      my @wt_chars  = split(//,$wt_trans);
      foreach (@mut_chars) {
	if ($mut_chars[$c] eq $wt_chars[$c]) {
	  $c++;
	  next;
	} else {
	  $pos = $c+1;   # 1-based
	  $change = uc $wt_chars[$c] . $pos . uc $mut_chars[$c];
	  last;
	}
      }
    }
    
    # Store some data for easy accession
    # I'd like to purge this but it's deeply embedded in the logic
    # of presenting a detailed view of the sequence
    $stash{wt_aa_start} = $pos;
    
    # I should be formatting these here depending on the type of nucleotide change...
    $stash{formatted_aa_change} = $change;
    $stash{wildtype_translation_fragment} = ($pos - 19) . '...' . 
      substr($wt_trans,$pos - 20,19) 
	. ' '
	  . substr($wt_trans,$pos-1,1)
	    . ' '
	      . substr($wt_trans,$pos,20)
		.  '...'
		  . ($pos + 19);
    $stash{mutant_translation_fragment} = ($pos - 19)
      . '...'
	. substr($mut_trans,$pos - 20,19) 
	  . ' '
	    . substr($mut_trans,$pos-1,1)
	      . ' '
		. substr($mut_trans,$pos,20)
		  .  '...'
		    . ($pos + 19);
    $stash{wildtype_spliced} = $wt_spliced;
    $stash{mutant_spliced}   = $mut_spliced;
    
    $stash{wildtype_translation_length} = length($wt_trans);
    $stash{mutant_translation_length}   = length($mut_trans);
    
    # Just assume that the length is 1 for these (postiion 3)
    $stash{wildtype_translation_complete} = 
      "> $cds"
	. $self->_markup_variation($wt_trans,$pos-1,1,undef,'is_peptide');
    
    $stash{mutant_translation_complete} = 
      "> $cds ($object: $change)"
	. $self->_markup_variation($mut_trans,$pos-1,1,undef,'is_peptide');
    
    ##	$self->{wt_trans}      = $self->to_fasta($cds,$wt_trans);
    ##	$self->{mut_trans}     = $self->to_fasta("$cds ($var: $change)",$mut_trans);
  }
  
  $stash{wildtype_unspliced}  = $wt_unspliced;
  $stash{mutant_unspliced} = $mut_unspliced;    # This should be marked up...
  $stash{debug} = \@debug;
  return \%stash;
}
  


=head1 NAME

WormBase::Model::Variation - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

I standardized the name of some sections:
   General Info -> Identification

I standardized the name of some subsections:
   Variation -> Name


Lots of things remain to be migrated for the Molecular Change Widget

DisplayPhenotypes from ElegansSubs needs to be migrated
phenotype() not done

Tons of things in the view that need to be ripped from the Model

Display of the submission forms needs to be moved to the view

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
