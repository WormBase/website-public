package WormBase::Model::Protein;

use strict;
use Ace::Graphics::Panel;
use Bio::Tools::SeqStats;
use Bio::Graphics::Panel;
use Bio::Graphics::Feature;

use WormBase::Util::pICalculator;
use warnings;
use base 'WormBase::Model';

use constant GENPEP => 'http://www.ncbi.nlm.nih.gov/htbin-post/Entrez/query?db=p&form=1&field=Sequence+ID&term=%s';
#%EXT_LINKS = %{Configuration()->Protein_links} unless defined %EXT_LINKS;
#%HIT_CACHE = ();


=pod

# NOT YET CONVERTED.  Was get_object(), will become search();

sub search {
  my ($name,$class) = @_;

  # Search via a protein ID
  # allow users to type "CE12345" rather than "WP:CE12345"
  $name = "WP:$name" if $name =~ /^CE\d+/;
  $name = "BP:$name" if $name =~ /^CBP\d+/;
  
  # Search via a gene if provided with a WBGene ID
  # or something that looks like one
  if ($name =~ /^WBG/ || $name =~ /\w{3,4}\-\d+/i) {
      my $bestname;
      ($obj,$bestname) = FetchGene($DB,$name);
      if ($obj){
	  return undef unless $obj->Corresponding_CDS;
	  my $pro = eval { $obj->Corresponding_CDS->Corresponding_protein(-fill=>1) };
	  if ($pro){
	      param(name=>$pro);
	      param(class=>$pro->class);
	      return $pro;
	  }
	  warn $obj;
      }
  }

  # Class may be one of Protein or Wormpep (for elegans specific queries)
  if ($class eq 'Protein' || !$class) {
      $class ||= 'Protein';
      my ($obj) = $DB->fetch(-class=>$class,-name=>$name,-fill=>1);
      return $obj if $obj;
  }
 
  # Search via a gene ID. Note: This is NOT a transcript
  ($obj) = $DB->fetch(-class=>'CDS',-name=>$name,-fill=>1);
  # Try the primary transcript since there is no pan-object for a CDS
  ($obj) = $DB->fetch(-class=>'CDS',-name=>"${name}a",-fill=>1) unless ($obj);
  if ($obj){
      if ($obj->Corresponding_protein) {
	  my $pro = $obj->Corresponding_protein(-fill=>1);
	  param(name=>$pro);
	  param(class=>$pro->class);
	  return $pro;
      }
  }
}

=cut

sub homology_groups {
  my ($self) = @_;
  my $object = $self->current_object;
  my @kogs  = $object->Homology_group;
  return \@kogs;
  
  # VIEW
  #  my $kog_string = 'not assigned';
  #  my @kogs = $obj->Homology_group;
  #  if (@kogs) {
  #      $kog_string = join(br, map {$_->Group_type . ': ' . $_->Title . ' [' . 
  #			 ObjectLink($_) . ']'}  @kogs);
  #    }
}

sub genes {
  my ($self) = @_;
  my $object = $self->current_object;
  my @stash;

  foreach my $transcript ($object->Corresponding_CDS) {
    my $type         = $transcript->Method;
    next if $type eq 'history';
    my $gene     = $transcript->Gene;
    push @stash,$gene;

    # VIEW
    #    # This should link to the gene page...
    #    # Doing it manually for now since ObjectLink isn't configurable
    #    push @genes,$gene->class eq 'Gene' ? a({-href=>Object2URL($gene)},$bestname) : ObjectLink($gene);
  }
  return \@stash;
}

sub transcripts {
  my ($self) = @_;
  my $object = $self->current_object;
  my $stash = {};

  foreach my $transcript ($object->Corresponding_CDS) {
    my $type         = $transcript->Method;
    next if $type eq 'history';
    push @{$stash->{transcripts}},$transcript;
    
    # VIEW
    # push (@transcripts,a({href=>"/db/seq/sequence?name=$transcript" . ";class=CDS"}, $transcript));
  
    # Fetch out related transcripts, ignoring history objects
    my $query = $transcript;
    $query =~ s/[a-z]$//;
    my $dbh = $self->dbh_ace;
    foreach (grep {/[a-z]$/} $dbh->fetch(-class=>'CDS',-name=>"${query}*",-fill=>1)) {
      next if $_ eq $transcript;
      push @{$stash->{related_transcripts}},$_;
    }
  } 
  return $stash;
}

sub type {
  my ($self) = @_;
  my $object = $self->current_object;
  foreach my $transcript ($object->Corresponding_CDS) {
    my $type         = $transcript->Method;
    return $type if $type;
  }
}

# TODO: fasta as part of View? Model::Super?
sub protein_sequence {
  my ($self)  = @_;
  my $object  = $self->current_object;
  my $peptide = $self->_get_peptide;
  my $fasta   = $self->fasta($object->name,$peptide); 
  return $fasta;
}


sub homology_image {
  my ($self) = @_;
  my ($image_url,$map) = $self->_draw_image();
  my $img = img({-src    =>$image_url,
		 -align  =>'center',
		 -usemap =>'#protein_domains',
		 -border =>0,
		});
  # VIEW
  #  print "\n",$img,"\n";
  #  print end_td,end_TR,end_table();
  #  print qq(\n<map name="protein_domains">\n),$map,qq(</map>\n);
  return $img;
}


sub motif_homologies {
  my ($self) = @_;
  my $object = $self->current_object;

  my @homol = $object->Motif_homol;

  my (%motif);

  # TODO: handling external URLs
  # move to configuration
  #my $motif_urls = Configuration->Motif_urls;
  #my $db_urls    = Configuration->Motif_database_urls;
  #my $url   = url(-absolute=>1,-query=>1);

  my @stash;
  foreach (@homol) {
    my $title = $_->Title;
    my ($database,$description,$accession) = $_->Database->row if $_->Database;
    push @stash,[$database,$title || $_,$_];
  }

  # VIEW
  #  if (@homol) {
  #    print br();
  #    print a({-name=>'motif_homo'},'');
  #    print start_table({-border=>0,-width=>'100%'});
  #    print TR(
  #	     th({-class=>'datatitle',-colspan=>4},'Motif Summary',a({-href=>"$url;details=motif",-target=>'_blank'},'[View Details]')));
  #    print TR({-align=>'LEFT'},
  #	     th({-class=>'datatitle'},'Database'),
  #	     th({-class=>'datatitle'},'Description'),
  #	     th({-class=>'datatitle'},'Accession'));
  #    print Tr({-class=>'databody'},\@row);
  #    print end_table,br();
  #  }
  return \@stash;
}

sub reactome_knowledgebase {
  my $self = @_;
  my $object = $self->current_object;
  my $stash = $self->SUPER::reactome_knowledgebase([$object]);
  return $stash;
}

sub protein_length {
  my ($self) = @_;
  my $object = $self->current_object;
  my $length = $object->at('Peptide[2]');
  return $length if defined $length;

  my $peptide = $object->asPeptide;
  $peptide =~ s/^>.*//;
  $peptide =~ s/\n//g;
  return length $peptide;
}

sub estimated_molecular_weight {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Molecular_weight;
}

sub estimated_isoelectric_point {
  my ($self) = @_;
  my $peptide = $self->_get_peptide();
  
  my $pic     = pICalculator->new();
  my $selenocysteine_count = 
    (my $hack_seq = $peptide) =~ tr/Uu/Cc/;  # primaryseq doesn't like selenocysteine, so make it a cysteine
  my $seq = Bio::PrimarySeq->new($hack_seq);
  $pic->seq($seq);
  my $iep = $pic->iep;
  return $iep;
}

sub amino_acid_composition {
  my ($self) = @_;
  my $peptide = $self->_get_peptide();

  my $selenocysteine_count = 
    (my $hack_seq = $peptide) =~ tr/Uu/Cc/;  # primaryseq doesn't like selenocysteine, so make it a cysteine
  my $seq     = Bio::PrimarySeq->new($hack_seq);
  my $stats   = Bio::Tools::SeqStats->new($seq);

  # The obligatory hash lookups
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
  return \%aminos;
  
  # VIEW
  #  # Amino acid composition
  #  print start_table({-border=>0,-width=>'100%'});    
  #  my (@id,@count,@id_row,@count_row);
  #  foreach (sort keys %aminos) {  
  #    push (@id_row,td( $_ ));
  #    push (@count_row,td($aminos{$_}));
  #    push (@id,$_);
  #    push (@count,$aminos{$_});
  #  }
  #  print Tr({-class=>'databody'},@id_row);
  #  print Tr({-class=>'databody'},@count_row);
  #  print 
  #    Tr({-class=>'databody'},
  #       td({-align=>'LEFT',-colspan=>scalar @count_row},
  #	  "<sup>*</sup>This protein contains $selenocysteine_count selenocysteine (Sec) residues"))
  #      if $selenocysteine_count;
  #  print end_table;
}

sub object_history {
  my ($self) = @_;
  my $object = $self->current_object;
  my $stash = [];

  my @wormpep_versions = $object->History;

  # VIEW
  # print TR({-class=>'datatitle'},th('WormPep Version'),th('Event'),th('Predicted Gene'));

  for my $version (@wormpep_versions) {
    my ($status,$prediction) = $version->row(1);
    # VIEW
    #    $status =~ s/replaced by (\w+)/"replaced by ".a({-href=>Object2URL($1,'Protein')},$1)/e;
    push @{$stash},[$version,$status,$prediction]
  }
  return $stash;
# CONTROLLER / VIEW
#  unless ($obj->class eq 'CDS' || $obj->Live(0) || $obj->Species =~ /briggsae/i || $obj =~ /^BP/) {
#    print h2(font({-color=>'red'},'The protein named',$obj,'has been superseded or retired'));
#    print p('History follows');
#    print_history($obj);
#    print p('For more details see the',a
#	    ({-href=>"/db/misc/etree?name=$obj;class=Protein"},'Acedb tree representation'),
#	    'of this protein');
#  }
}




=pod

# THIS IS A BIG PAGE SHOWING DETAILS OF ALL BLAST HITS
sub blast_details {
  my $obj = shift;
  local $^W = 0;  # to avoid loads of uninit variable warnings
  
  print p({-align=>'CENTER'},b(
			       a({-href=>'#blast_table'},'[BLASTP table]'),
			       a({-href=>'#blast_diagram'},'[BLASTP diagram]'))
	 );
  
  my @homol = $obj->Pep_homol;
  
  # wrestle blast hits into a workable data structure!!
  my @hits = $self->_wrestle_blast(\@homol);
  
  # sort by score
  @hits = sort {$b->{score}<=>$a->{score} || $a->{source}<=>$b->{source}} @hits;
  my @rows;
  for my $h (@hits) {
    my $url = hit_to_url($h->{hit}) or next;
    my $method = $h->{type};

    my $species =
      $method =~ /ensembl/ ? 'Homo sapiens'
	: $method =~ /fly/ ? 'Drosophila melanogaster'
	  : $method =~ /worm/ ? 'Caenorhabditis elegans'
	    : $method =~ /briggsae/ ? 'Caenorhabditis briggsae'
	    : $h->{hit}->Species;
    $species =~ s/^(\w)\w* /$1. /;

    $species = 'C. elegans' if $h->{hit} =~ /^WP:/; # workaround for C. briggsae
    $species = 'C. briggsae' if $h->{hit} =~ /^BP:/; # workaround for C. briggsae
    
    my $description = $method =~ /worm|briggsae/ ? 
      (eval {$h->{hit}->Corresponding_CDS->Brief_identification} ||
       "gene " . $h->{hit}->Corresponding_CDS)
	: $h->{hit}->Description;	#->Title does not exist
    # warn "$h->{hit} is bad" if $method =~ /worm|briggsae/ && ! $h->{hit}->Corresponding_CDS;

    push @rows,[$h->{hit},$species,$description,$h->{score},
		$h->{source},
		$h->{target},$url];
  }

  my %cols = (
	      0 => 'Hit',
	      1 => 'Species',
	      2 => 'Description',
	      3 => 'E Value',
	      4 => 'Source Range',
	      5 => 'Target Range'
	     );

  my %widths = (0=>'25%',1=>'15%',2=>'15%',3=>'45%');

  my $sort_by    = url_param('sort');
  $sort_by = ($sort_by eq '') ? 3 : $sort_by; # Have to do it this way because of 0
  my $sort_order = (param('order') eq 'ascending') ? 'descending' : 'ascending';
  $sort_order = 'descending' if ($sort_by == 3 && param('order') eq '');

  my @sorted;
  if ($sort_by =~ /[012]/) {
    if ($sort_order eq 'ascending') {
      @sorted = sort { lc ($a->[$sort_by]) cmp lc ($b->[$sort_by]) } @rows;
    } else {
      @sorted = sort { lc ($b->[$sort_by]) cmp lc ($a->[$sort_by]) } @rows;
    }
  } else {
    if ($sort_order eq 'ascending') {
      @sorted = sort { $a->[$sort_by] <=> $b->[$sort_by] } @rows;
    } else {
      @sorted = sort { $b->[$sort_by] <=> $a->[$sort_by] } @rows;
    }
  }

  # Create column headers linked with the sort options
  print a({-name=>'blast_table'});
  print start_table({-width=>'100%'});
  my $url = url(-absolute=>1);
  $url .= "?name=" . param('name') . ';details=blast_hits;sort=';
  print TR(map {th({-class=>'dataheader',-width=>$widths{$_}},
		   a({-href=>$url . $_ . ";order=$sort_order"},
		     $cols{$_}
		     . img({-width=>17,-src=>'/images/sort.gif'})
		    ))}
	   sort {$a <=> $b} keys %cols);

  foreach (@sorted) {
    my ($hit,$species,$description,$eval,$source,$target,$url) = @$_;
    print TR(td({-class=>'datacell'},a({-href=>$url,-target=>'_blank'},$hit)),
	     td({-class=>'datacell'},i($species)),
	     td({-class=>'datacell'},$description),
	     td({-class=>'datacell'},sprintf("%7.3g",10**-$eval)),
	     td({-class=>'datacell'},$source),
	     td({-class=>'datacell'},$target));
  }
  print end_table,br;
  print a({-name=>'blast_diagram'});
  homology_image($obj);
}
  

# THIS SHOWS A SUMMARY PAGE OF ALL MOTIFS WITH THEIR POSITIONS
sub motif_details {
  my ($obj) = shift;
  my $seq   = $obj->Corresponding_CDS;
  
  my @raw_features = $obj->Feature;
  my @motif_homol = $obj->Motif_homol;

  #  return unless $obj->Feature;

  print br();
  print a({-name=>'motif_sum'}, "");

  # Summary by Motif
  my @tot_positions;

  if (@raw_features > 0 || @motif_homol > 0) {

    my %positions;
    foreach my $feature (@raw_features) {
      # Foreach motif type, map the start and stop positions into a hash
      # 'Tis dangereaux - could lose some features if the keys overlap...
      #line 525
      %positions = map {$_ => $_->right(1)} $feature->col;
      foreach my $start (sort {$a <=> $b} keys %positions) {	
		push @tot_positions, { feature => $feature,
                                         start   => $start,
                                         stop    => $positions{$start}};
      }
    }

    # Now deal with the motif_homol features
    foreach my $feature (@motif_homol) {
      my $start = $feature->right(3);
      my $stop  = $feature->right(4);
      my $type = $feature->right;
      $type  ||= 'Interpro' if $feature =~ /IPR/;
      (my $accession = $feature) =~ s/^[^:]+://;
      my $label = "$type&nbsp;$accession";
      my $link = make_ext_link($feature,$label);

      push @tot_positions, { feature => $link,
                                start   => $start,
                                stop    => $stop}};

    }

    print start_table({-border =>1, -width=>'100%'});
      print TR({-class=>'datatitle',-valign=>'top'},
	       th({-colspan=>3},'Motif Details'));

    print TR({-class=>'datatitle',-valign=>'top'},
	     th('Feature'),
	     th('Start'),
	     th('End'));
  foreach my $feature (@tot_positions) {
     print TR({-class=>'databody'},
	      td($feature->{feature},
		 $feature->{start},
		 $feature->{stop}));
   }
    print end_table;
  }
  return;
}

sub make_ext_link {
  my $name = shift;
  my $text = shift;
  return $name unless $name && $text;  # Good god, man, what is this
  $name =~ /(\w+):(.+)/ or return;
  my $prefix    = $1;
  my $accession = $2;
	# TODO
#  my $link      = $EXT_LINKS{$prefix} or return;
#  my $url       = sprintf($link,$accession);
#  return a({-href=>$url,-target=>'_new'},$text || $accession);
}

=pod





############################
# PRIVATE METHODS
############################
sub _get_peptide {
  my ($self) = @_;
  my $object = $self->current_object;
  my $peptide = $object->asPeptide;
  $peptide =~ s/^>.*//;
  $peptide =~ s/\n//g;   
  return $peptide;
}

sub _draw_image {
  my ($self) = @_;
  my $object = $self->current_object;

  # Get out the length;
  my $length = protein_length();

  # Setup the panel, using the protein length to establish the box as a guide
  my $ftr = 'Bio::Graphics::Feature';
  my $segment = $ftr->new(-start=>1,-end=>$length,
			  -name=>$object,
			  -type=>'Protein');
  
  my $panel = Bio::Graphics::Panel->new(-segment   =>$segment,
					-key       =>'Protein Features',
					-key_style =>'between',
					-key_align =>'left',
					-grid      => 1,
					-width     =>'650');
  
  # Get out the gene - will use to extract the exons, then map them
  # onto the protein backbone.
  my $gene    = $object->Corresponding_CDS;

  my @exons;
  if ($gene) {
    my $dbh = $self->dbh_gff;
    my ($seq_obj) = $dbh->segment(CDS => $gene);
    @exons = $seq_obj->features('exon:curated') if $seq_obj;
    @exons = grep { $_->name eq $gene } @exons;
  }
  
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
  my @features = $object->Feature;
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
    
  #  my (%glyphs,%colors,%labels) are all in object args

  foreach ($object->Homol) {
    my (%partial,%best);
    my @hits = $obj->get($_);
    # Pep_homol data structure is a little different
    if ($_ eq 'Pep_homol') {
      my @features = $self->_wrestle_blast(\@hits,1);

      # Sort features by type.  If $best_only flag is true, then we only keep the
      # best ones for each type.
      my %best;
      for my $f (@features) {
	next if $f->name eq $object;
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
  }
  
  foreach my $key (sort keys %features) {
    # Get the glyph
    my $type  = $features{$key}[0]->type;
    my $label = $self->{args}->{labels}->{$key}  || $key;
    my $glyph = $self->{args}->{glyphs}->{$key}  || 'graded_segments';
    my $color = $self->{args}->{colors}->{$type} || 'green';
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
    my $url  = $self->_hit_to_url($name) or next;
    # TODO!
#    my $coords    = join ',',@coords;
#    $map   .= qq(<area shape="rect" target="_new" coords="$coords" href="$url" />\n);
  }

  my $gd = $panel->gd;
  # TODO: Why is this here?
  my $url = AceImage($gd);
  
  # Create a url suitable for passing through squid
  # Remove protocol and host
  my ($stripped_url) = $url =~ /http:\/\/.*?(\/.*)/;
  return ($stripped_url,$map);
}

sub _hit_to_url {
  my ($self,$name) = @_;
  $name =~ /(\w+):(\w+)/ or return; # was $name =~ /(\w+):(.+)/ or return;
  my $prefix    = $1;
  my $accession = $2;
  # Hack for flybase IDs
  $accession =~ s/CG/00/ if ($prefix =~ /FLYBASE/);
  # TODO: EXT_LINKS?
  my $link      = $EXT_LINKS{$prefix} or next;
  my $url       = sprintf($link,$accession);
  $url;
}

sub _wrestle_blast {
  my ($self,$hits,$as_features) = @_;

  my (@hits,%cached_features);
  my %seen;
  for my $homol (@$hits) {
    for my $type ($homol->col) {
      for my $score ($type->col) {
	for my $start ($score->col) {
	  for my $end ($start->col) {
	    my ($tstart,$tend) = $end->row(1);
	    
	    next if ($seen{"$start$end$homol"}++);
	    
	    $HIT_CACHE{$homol} = $homol;
	    
	    if ($as_features) {
	      my $f = $cached_features{$type}{$homol};
	      if (!$f) {
		$f
		  = $cached_features{$type}{$homol}
		    = Bio::Graphics::Feature->new(-name     => "$homol",   # quotes and +0 stringifies ace object
						  -type     => "$type",
						  -score    => $score+0);
		push @hits,$f;
	      }
	      $f->add_segment(Bio::Graphics::Feature->new(-start => $start+0,
							  -end   => $end+0,
							  -score => $score+0,
							 ));
	    } else {
	      push @hits,{hit=>$homol,type=>$type,score=>$score,source=>"$start..$end",target=>"$tstart..$tend"};
	    }
	  }
	}
      }
    }
  }
  return @hits;
}




=head1 NAME

WormBase::Model::Protein - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Original page had two details popups that presented all motifs and all BLAST hits.

Are merged / retired proteins handled correctly?

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
