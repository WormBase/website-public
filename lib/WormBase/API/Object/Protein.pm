package WormBase::API::Object::Protein;

use Moose;
use Bio::Tools::pICalculator;
use Bio::Tools::SeqStats;
with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';
 

use vars qw(%HIT_CACHE @tags);
%HIT_CACHE=();


has 'peptide' => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	my $peptide = $self ~~ 'asPeptide';
	$peptide =~ s/^>.*//;
	$peptide =~ s/\n//g;   
	return $peptide;
    }
);

has 'cds' => (
    is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self ~~ 'Corresponding_CDS' ;
    }
);

 
############################################################
#
# The Indentification widget
#
############################################################

sub name {
    my $self = shift;
    my $data = { description => 'The object name of the protein',
		 data        =>  $self ~~ 'name',
    };
    return $data;

}

sub title {
    my $self = shift;
    my $name = eval { $self->cds->Gene->CGC_name };
    my $data = { description => 'The title of the protein',
		 data        => $name ? uc($name) : $self ~~ 'name',
    };
    return $data;
}


sub species {
    my $self = shift;
    my $data = { description => 'The species of the protein',
		 data        => $self ~~ 'Species' || eval { $self->cds->Species },
    }; 
    return $data;
}

sub homology_groups {
    my $self = shift;
    my @kogs = $self ~~ 'Homology_group' || 'not assigned';
    my $data = { description => 'The homology groups of the protein',
		 data        => \@kogs,
    }; 
    return $data;
}

sub genes {
    my $self = shift;
    my @genes = map {$_->Gene||$_}  grep{$_->Method ne 'history'}  $self->cds;
    my $data = { description => 'The genes or CDS associated with the protein',
		 data        => \@genes,
    }; 
    return $data;
}


sub transcripts {
    my $self = shift;
    my @transcripts = grep{$_->Method ne 'history'} $self->cds;
    push @transcripts, map {$_->Corresponding_transcript}  @transcripts;
    my $data = { description => 'The transcripts related with the protein',
		 data        => \@transcripts,
    }; 
    return $data;

}


sub type {
    my $self = shift;
    my $data = { description => 'The type of the protein',
		 data        =>  $self->cds->Method || 'None (see remark)' ,
    }; 
    return $data;
}


sub ortholog_genes {
    my $self = shift;
    my $data = { description => 'The orthology genes of the protein',
		 data        =>  $self ~~ 'Ortholog_gene' || 'not assigned' ,
    }; 
    return $data;
}


############################################################
#
# The Homology widget
#
############################################################

sub homology_image{
}

sub motif_homologies{}

sub best_blastp_matches{}

sub protein_sequence{
    my $self = shift;
    my $peptide = $self->peptide;
    my $data = { description => 'The peptide sequence of the protein',
		 data        => { 'seq' => $peptide ,
				  'length' => length $peptide,
				}
    }; 
}
 
 

############################################################
#
# The Protein Statistics widget
#
############################################################


sub estimated_molecular_weight{
    my $self = shift;
    my $data = { description => 'The estimated molecular weight of the protein',
		 data        =>  $self ~~ 'Molecular_weight' ,
    }; 
    return $data;
}

sub estimated_isoelectric_point{
    my $self = shift;
  
    my $pic     = Bio::Tools::pICalculator->new();
    my $selenocysteine_count =  (my $hack_seq = $self->peptide) =~ tr/Uu/Cc/;  # primaryseq doesn't like selenocysteine, so make it a cysteine
    my $seq     = Bio::PrimarySeq->new($self->peptide);
    $pic->seq($seq);
    my $iep     = $pic->iep;

    my $data = { description => 'The estimated isoelectric point of the protein',
		 data        =>  $iep,
    }; 
    return $data;
}

sub amino_acid_composition{
    my $self = shift;

    my $selenocysteine_count =  (my $hack_seq = $self->peptide) =~ tr/Uu/Cc/;  # primaryseq doesn't like selenocysteine, so make it a cysteine
    my $seq     = Bio::PrimarySeq->new($self->peptide);
    my $stats   = Bio::Tools::SeqStats->new($seq);

    my %abbrev = (A=>'Ala',R=>'Arg',N=>'Asn',D=>'Asp',C=>'Cys',E=>'Glu',
		Q=>'Gln',G=>'Gly',H=>'His',I=>'Ile',L=>'Leu',K=>'Lys',
		M=>'Met',F=>'Phe',P=>'Pro',S=>'Ser',T=>'Thr',W=>'Trp',
		Y=>'Tyr',V=>'Val',U=>'Sec<sup>*</sup>',X=>'Xaa');
    # Amino acid content
    my $composition = $stats->count_monomers;
    if ($selenocysteine_count > 0) {
      $composition->{C} -= $selenocysteine_count;
      $composition->{U} += $selenocysteine_count;
    }

    my %aminos = map {$abbrev{$_}=>$composition->{$_}} keys %$composition;
    my $data = { description => 'The amino acid composition of the protein',
		 data        =>  \%aminos ,
    }; 
    return $data;
}



############################################################
#
# The Protein History widget, this is actaully on a field level but not widget
#
############################################################
sub protein_history{
    my $self = shift;

    my $history = {};
    my @wormpep_versions = $self ~~ 'History';
     
    foreach (@wormpep_versions) {
	  my ($status,$prediction) = $_->row(1);
	  $history->{version}->{$_}=$_;
	  $history->{status}->{$_}=$status;
	  $history->{prediction}->{$_}=$prediction;
    }
    
    my $data = { description => 'The history information of the protein',
		 data        =>  $history ,
    }; 
    return $data;
}



############################################################
#
# PRIVATE METHODS
#
############################################################

sub _draw_image {
  my $self = shift;
  my $obj = shift;
  my $best_only = shift;

  # Get out the length;
  my $length = length($self->peptide);

  # Setup the panel, using the protein length to establish the box as a guide
  my $ftr = 'Bio::Graphics::Feature';
  my $segment = $ftr->new(-start=>1,-end=>$length,
			  -name=>$obj,
			  -type=>'Protein');

  my $panel = Bio::Graphics::Panel->new(-segment   =>$segment,
					-key       =>'Protein Features',
					-key_style =>'between',
					-key_align =>'left',
					-grid      => 1,
					-width     =>'650');

  # Get out the gene - will use to extract the exons, then map them
  # onto the protein backbone.
  my $gene    = $obj->cds;
  my @exons;
  
  my $gffdb = $self->gff_dsn();
  my ($seq_obj) = $gffdb->segment(CDS => $gene);
  @exons = $seq_obj->features('exon:curated') if $seq_obj;
  @exons = grep { $_->name eq $gene } @exons;

  # Translate the bp start and stop positions into the approximate amino acid
  # contributions from the different exons.
  my ($count,$end_holder);
  my @segmented_exons;
  local $^W = 0;  # kill uninitialized variable warning

  foreach my $exon (sort { $a->start <=> $b->start } @exons) {

    $count++;
    my $start = $exon->start;
    my $stop  = $exon->stop;

    # Calculate the difference of the start and stop to figure
    # to figure out how many amino acids it corresponds to
    my $length = (($stop - $start) / 3);
    
    my $end = $length + $end_holder;
    my $seg = $ftr->new(-start=>$end_holder,-end=>$end,
			-name=>"exon $count",-type=>'exon');
    push @segmented_exons,$seg;
    $end_holder = $end;
  }
  

  ## Structural motifs (this returns a list of feature types)
  my %features;
  my @features = $obj->Feature;
  # Visit each of the features, pushing into an array based on its name
  foreach my $type (@features) {
    # 'Tis dangereaux - could lose some features if the keys overlap...
    my %positions = map {$_ => $_->right(1)} $type->col;
    foreach my $start (keys %positions) {
      my $seg   = $ftr->new(-start=>$start,-end=>$positions{$start},
			    -name=>"$type",-type=>$type);
      # Create a hash of all the features, keyed by type;
      push (@{$features{'Features-' . $type}},$seg);
    }
  }
  
  ## A protein ruler
  $panel->add_track(arrow => [ $segment ],
  		    -label => 'amino acids',
		    -arrowstyle=>'regular',
		    -tick=>5,
  		    #		    -tkcolor => 'DarkGray',
  		   );
  
  ## Print the exon boundaries
  $panel->add_track(generic=>[ @segmented_exons ],
		    -glyph     => 'generic',
		    -key       => 'exon boundaries',
		    -bump      => 0,
		    -height    => 6,
		    -spacing   => 50,
		    -linewidth =>1,
		    -connector =>'none',
		   ) if @segmented_exons;

  my %glyphs = (low_complexity => 'generic',
		transmembrane   => 'generic',
		signal_peptide  => 'generic',
		tmhmm           => 'generic'
	       );
  
  my %labels   = ('low_complexity'       => 'Low Complexity',
		  'transmembrane'         => 'Transmembrane Domain(s)',
		  'signal_peptide'        => 'Signal Peptide(s)',
		  'tmhmm'                 => 'Transmembrane Domain(s)',
		  'wublastp_ensembl'      => 'BLASTP Hits on Human ENSEMBL database',
		  'wublastp_fly'          => 'BLASTP Hits on FlyBase database',
		  'wublastp_slimSwissProt'=> 'BLASTP Hits on SwissProt',
		  'wublastp_slimTrEmbl'   => 'BLASTP Hits on Uniprot',
		  'wublastp_worm'         => 'BLASTP Hits on WormPep',
		 );
  
  my %colors   = ('low_complexity' => 'blue',
		  'transmembrane'  => 'green',
		  'signalp'        => 'gray',
		  'Prosite'        => 'cyan',
		  'seg'            => 'lightgrey',
		  'Pfam'           => 'wheat',
		  'Motif_homol'    => 'orange',
		  'Pep_homol'      => 'blue'
		 );
  
  foreach ($obj->Homol) {
    my (%partial,%best);
    my @hits = $obj->get($_);
	my %motif_ranges = ();
	
    # Pep_homol data structure is a little different
    if ($_ eq 'Pep_homol') {
      my @features = wrestle_blast(\@hits,1);

      # Sort features by type.  If $best_only flag is true, then we only keep the
      # best ones for each type.
      my %best;
      for my $f (@features) {
	next if $f->name eq $obj;
	my $type = $f->type;
	if ($best_only) {
	  next if $best{$type} && $best{$type}->score > $f->score;
	  $best{$type} = $f;
	} else {
	  push @{$features{'BLASTP Homologies'}},$f;
	}
      }

      # add descriptive information for each of the best ones
      local $^W = 0; #kill uninit variable warning
      for my $feature ($best_only ? values %best : @{$features{'BLASTP Homologies'}}) {
	my $homol = $HIT_CACHE{$feature->name};
	my $description = $homol->Species;
	my $score       = sprintf("%7.3G",10**-$feature->score);
	$description    =~ s/^(\w)\w* /$1. /;
	$description   .= " ";
	$description   .= $homol->Description || $homol->Gene_name;
	$description   .= eval{$homol->Corresponding_CDS->Brief_identification}
	  if $homol->Species =~ /elegans|briggsae/;
	my $t = $best_only ? "best hit, " : '';
	$feature->desc("$description (${t}e-val=$score)") if $description;
      }

      if ($best_only) {
	for my $type (keys %best) {
	  push @{$features{'Selected BLASTP Homologies'}},$best{$type};
	}
      }

      # these are other homols
    } else {	
      for my $homol (@hits) {
	my $title = eval {$homol->Title};
	my $type  = $homol->right or next;
	my @coord = $homol->right->col;
	my $name  = $title ? "$title ($homol)" : $homol;
	
	### filter out duplicate segments ####
	foreach my $segment (@coord) {
	my ($start,$stop) = $segment->right->row;
	my $range = $start."_to_".$stop;
	

	if ($motif_ranges{$range}){
	   next;
	}
	 else{
	     my $seg  = $ftr->new(-start=>$start,
			       -end =>$stop,
			       -name =>$name,
			       -type =>$type);
	     push (@{$features{'Motifs'}},$seg);
	     # print "<pre>$range</pre>"; 
	     $motif_ranges{$range} = 1;;
	}
   }
      }
    }
  }

  ## diagnostic ####
  # print "<pre>";
#   foreach my $dmotif (@{$features{'Motifs'}}) {
#   	print "$dmotif<br>";
#   }
#   print "</pre>";
  ### end diagnostic ###
  
  
  foreach my $key (sort keys %features) {
    # Get the glyph
    my $type  = $features{$key}[0]->type;
    my $label = $labels{$key}  || $key;
    my $glyph = $glyphs{$key}  || 'graded_segments';
    my $color = $colors{$type} || 'green';
    my $connector = $key eq 'Pep_homol' ? 'solid' : 'none';
    
    $panel->add_track(segments     => $features{$key},
		      -glyph       => $glyph,
		      -label       => ($label =~ /Features/) ? 0 : 1,
		      -bump        => 1,
		      -sort_order  => 'high_score',
		      -bgcolor     => $color,
		      -font2color  => 'red',
		      -height      => 6,
		      -linewidth   => 1,
		      -description => 1,
		      -min_score   => -50,
		      -max_score   => 100,
		      -key         => $label,
		      -description => 1,
		     );
  }
  
  # turn some of the features into urls
  my $boxes = $panel->boxes;
  my $map   = '';
  foreach (@$boxes) {
    my ($feature,@coords) = @$_;
    my $name = $feature->name;
    my $url  = hit_to_url($name) or next;
    # print $url, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>br";
    my $coords    = join ',',@coords;
    $map   .= qq(<area shape="rect" target="_new" coords="$coords" href="$url" />\n);
  }

  my $gd = $panel->gd;
  my $url = AceImage($gd);
   
  # Create a url suitable for passing through squid
  # Remove protocol and host
  my ($stripped_url) = $url =~ /http:\/\/.*?(\/.*)/;
  # TODO!! Need to edit ace tmp image path so that I can
  # redirect via squid
  #  $stripped_url =~ s|/ace_images/|/ace_images/protein/|;

  return ($stripped_url,$map);

}
1;
