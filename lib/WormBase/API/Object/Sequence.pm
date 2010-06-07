package WormBase::API::Object::Sequence;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';
use Bio::Graphics::Browser2::Markup;

use vars qw($CHROMOSOME_TABLE_LENGTH);
$CHROMOSOME_TABLE_LENGTH = 2_000_000;

has 'type' => (
    is  => 'ro',
#     isa => 'Str',
    lazy_build => 1,
);

has 'length' => (
    is  => 'rw',
#     isa => 'Str',
);

has 'gff' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self->gff_dsn;
    }
);

has 'sequence' => (
    is  => 'ro',
#     isa => 'Ace::Object',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self ~~ 'Sequence';
    }
);

has 'method' => (
    is  => 'ro',
#     isa => 'Str',
    lazy => 1,
    default => sub {
	my $self = shift;
	return $self ~~ 'Method';
    }
);

has 'genes' => (
    is  => 'ro',,
    lazy => 1,
    default => sub {
	my $self = shift;
	my %seen;
	my @genes  = grep {!$seen{$_}++} eval { $self ~~ '@Locus' };
	return \@genes;
    }
);

has 'segments' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my @seg = $self->_get_segments;
	return \@seg;
    }
);

sub _build_type {
    my $self = shift;
    my $s = $self->object;
    # figure out where this sequence comes from
    # should rearrange in order of probability
    my $type;
    if ($s =~ /^cb\d+\.fpc\d+$/) {
	$type = 'C. briggsae draft contig'
	} elsif ($self->is_gap) {
	    $type = 'gap in genomic sequence -- for accounting purposes';
	} elsif (eval { $s->Genomic_canonical(0) }) {
	    $type = 'genomic';
	} elsif ($self->method eq 'Vancouver_fosmid') {
	    $type = 'genomic -- fosmid';
	} elsif (eval { $s->Pseudogene(0) }) {
	    $type = 'pseudogene';
	} elsif (eval { $s->RNA_Pseudogene(0) }) {
	    $type = 'RNA_pseudogene';
	} elsif (eval { $s->Locus }) {
	    $type = 'confirmed gene';
	} elsif (eval { $s->Coding }) {
	    $type = 'predicted coding sequence';
	} elsif ($s->get('cDNA')) {
	    ($type) = $s->get('cDNA');
	} elsif ($self->method eq 'EST_nematode') {
	    $type   = 'non-Elegans nematode EST sequence';
	} elsif (eval { $s->AC_number }) {
	    $type = 'external sequence';
	} elsif (is_merged($s)) {
	    $type = 'merged sequence entry';
	} elsif ($self->method eq 'NDB') {
	    $type = 'GenBank/EMBL Entry';
	    # This is going to need more robust processing to traverse object structure
	} elsif (eval { $s->RNA} ) {
	    $type = eval {$s->RNA} . ' ' . eval {$s->RNA->right};
	} else {
	    $type = eval {$s->Properties(1)};
	}
    $type ||= 'unknown';
    return $type;
}

sub common_name {
    my $data = { description => 'The public name of the sequence',
		 data        => shift ~~ 'name',
    };
    return $data;
}

############################################################
#
# The Overview widget
#
############################################################
sub identity {
   my $self = shift;
   my $print = eval{ join(', ', @{$self->genes});};
   my $iden = $self ~~ 'Brief_identification' ;
   if($iden) {
    if($print) {
	$print.=", ".$iden;
    }
    else {
      $print=$iden;
    }
   }
   return unless $print;
    my $data = { description => 'The identity of the sequence',
		 data        => "Identified as ". $print. $self->type eq 'pseudogene' ? ' (pseudogene)' : '',
    };
    return $data;
}

sub description {
    my $self = shift;
    my $title = eval {$self ~~ 'Title'} || return;
    my $data = { description => 'The description of the sequence',
		 data        => $title,
    };
    return $data;    
}

sub sequence_type {
    my $type = shift->type or return ;
    my $data = { description => 'The Sequence type of the sequence',
		 data        => $type,
    };
    return $data;    
}

sub corresponding_gene {
    my $self = shift;
    my $gene = $self ~~ 'Gene';
    my $bestname = $self->bestname($gene) || '';
    my $label;
    $label = ($self->method ne 'Coding_transcript' )
		? "$bestname ($gene)" : $bestname if($gene && $self->method ne 'Genefinder');
    return unless $label;
    my $data = { description => 'The Corresponding gene of the sequence',
		 data        => { label => $label,
				  id => $gene,
				  link => 'gene',
				},
    };
    return $data;    
}

sub corresponding_protein {
    my $protein = shift ~~ 'Corresponding_protein' or return;
    my $data = { description => 'The Corresponding protein of the sequence',
		 data        => { label => $protein,
				  id => $protein,
				  link => 'protein',
				},
    };
    return $data;    
}

sub matching_cds {
    my $cds = shift ~~ 'Matching_CDS' or return;
    my $data = { description => 'The Matching CDS of the sequence',
		 data        => $cds,
    };
    return $data;    
}

sub matching_transcript {
    my $transcript = eval {shift ~~ 'Matching_transcript'} or return;
    my $data = { description => 'The Matching Transcript of the sequence',
		 data        =>  $transcript ,
    };
    return $data;    
}
sub origin {
    my $self = shift;
    my $origin = $self ~~ 'From_Laboratory';
    return unless $origin;
    my $data = { description => 'The Origin of the sequence',
		 data        => { label => $origin->get(Mail=>1),
				  id => $origin,
				  link => 'laboratory'
				},
    };
    return $data;    
}

sub available_from {
    return unless(shift->method eq 'Vancouver_fosmid');
    my $data = { description => 'The Vancouver_fosmid source of the sequence',
		 data        => { label => 'GeneService',
				  link => 'Geneservice_fosmids',
				},
    };
    return $data;    
}

sub sequence_method {
    my $self = shift;
    return unless $self->method;
    my $data = { description => 'The Sequence method of the sequence',
		 data        => $self->method,
    };
    return $data;    
}


sub briggsae_orthologs {
    my $self = shift;
    my $object = $self->object;
    my @briggsae;
    if ($self->species =~ /briggsae/) {
	@briggsae = map {$_->[0]} grep {$_->[1] =~ /\Q$object/} $self->gff->search_notes($object);
    }
    return unless  @briggsae;
    my $data = { description => 'The Briggsae Orthologs of the sequence',
		 data        => \@briggsae,
    };
    return $data;    
}

sub orfeome_assays {
    my $self = shift;
    my (@orfeome,@pcr);
    if ($self->type =~ /gene|coding sequence|cDNA/) {
      @pcr     = map {$_->info} map { $_->features('PCR_product:GenePair_STS','structural:PCR_product') } @{$self->segments} if @{$self->segments};
      @orfeome = grep {/^mv_/} @pcr;
    }
    return unless  @orfeome;
    my %hash;
    foreach my $id (@orfeome) {
	$hash{id}= $id;
	$hash{label}= $id. " (".($id->Amplified(1) ? "PCR assay amplified" 
                                    : font({-color=>'red'},"PCR assay did NOT amplify")).")";
	$hash{link}='pcr';
    }
    my $data = { description => 'The ORFeome Assays of the sequence',
		 data        => \%hash,
    };
    return $data;    
}

sub source_clone {
    my $self = shift;
    my $clone = eval { $self ~~ 'Clone' } || eval {$self->sequence->Clone} || return ;    
    my $data = { description => 'The Source clone of the sequence',
		 data        => $clone,
    };
    return $data;    
}

sub genomic_location {
    my $self = shift;
    return unless ($self->object->Structure(0) || $self->method eq 'Vancouver_fosmid') ;
    my @a;
    for my $segment (@{$self->segments}) {
#       $segment->absolute(1);
      my $ref = $segment->ref;
      my $start = $segment->start;
      my $stop  = $segment->stop;
      next unless abs($stop-$start) > 0;
      my $url = $self->hunter_url($ref,$start,$stop);
      push @a,$url;
    }
    return unless @a;
    my $data = { description => 'The Genomic Location of the sequence',
		 data        => \@a,
    };
    return $data;    
}

sub interpolated_genetic_position {
    my $self = shift;
    return unless ($self->object->Structure(0)  || $self->method eq 'Vancouver_fosmid') ;
    my ($chrom,$pos) = $self->GetInterpolatedPosition($self->object);
    
    if ($chrom && $pos) {
      $pos= $chrom . ":$pos" ;
    }
    else { return;}
    
    my $data = { description => 'The Interpolated Genetic Position of the sequence',
		 data        => {  link => $chrom->class, #should be Map?
				   label => $pos,
				    id => $chrom,
				},
    };
    return $data;    
}

sub transcripts {
    my $self = shift;
    return unless ($self->object->Structure(0)  || $self->method eq 'Vancouver_fosmid') ;
    return unless ($self->type =~ /genomic|confirmed gene|predicted coding sequence/);
    
    my @transcripts = sort {$b cmp $a } map {$_->info} map { $_->features('Transcript:Coding_transcript') } @{$self->segments} ;
    return unless @transcripts;
    my $data = { description => 'The Transcripts in this region of the sequence',
		 data        => \@transcripts, #class Sequence
    };
    return $data;    
}

sub microarray_assays {
    my $self = shift;
    return unless ($self->object->Structure(0)  || $self->method eq 'Vancouver_fosmid') ;
    return unless ($self->type =~ /genomic|confirmed gene|predicted coding sequence/);
    
    my @microarrays = sort {$a cmp $b } map {$_->info} map { $_->features('reagent:Oligo_set') } @{$self->segments} ;
    return unless @microarrays;
    my $data = { description => 'The Microarray assays in this region of the sequence',
		 data        => \@microarrays,  #class Oligo_set
    };
    return $data;    
}

sub transgene_constructs {
    my $self = shift;
    my %seen;
    my @transgenes = grep {!$seen{$_}++} (eval { $self ~~ 'Drives_Transgene'},eval { $self ~~ 'Transgene_product' });
    return unless @transgenes;
    my $data = { description => 'The Transgene constructs of the sequence',
		 data        => \@transgenes,
    };
    return $data;    
}

############################################################
#
# The Details widget
#
############################################################
sub remarks {
    my $self = shift;
    my @remarks =map {ucfirst($_)} map { $self->object->get($_) } qw(Remark DB_remark);
    return unless @remarks;
   
    my $data = { description => 'The Remarks of the sequence',
		 data        => \@remarks,
    };
    return $data;    
}

sub genomic_picture {
    my $self = shift;
    my $seq = $self->object;
    return unless(defined $self->segments && $self->segments->[0]->length< 100_0000);
 
    my $source = $self->species;
    my $segment = $self->segments->[0];
    
    my $ref   = $segment->ref;
    my $start = $segment->start;
    my $stop  = $segment->stop;
    
    # add another 10% to left and right
    $start = int($start - 0.05*($stop-$start));
    $stop  = int($stop  + 0.05*($stop-$start));
    my @segments;
    if ($seq->class eq 'CDS' or $seq->class eq 'Transcript') {
	my $gene = eval { $seq->Gene;};
	$gene ||= $seq;
	@segments = $self->gff->segment(-class=>'Coding_transcript',-name=>$gene);
	@segments      = grep {$_->method eq 'wormbase_cds'} $self->gff->fetch_group(CDS => $seq) unless @segments;  # CB discontinuity
    }
    # In cases where more than one segment is retrieved
    # (ie with EST or OST mappings)
    # choose that which matches the original segment.
    # This is slightly bizarre but expedient fix.
    my $new_segment;
    if (@segments > 1) {
    foreach (@segments) {

	if ($_->start == $start && $_->stop == $stop) {
	  $new_segment = $_;
	  last;
	}
      }
    }
    $new_segment ||= $segments[0];
    $new_segment ||= $segment;
    return unless $segment;
     
    my $type = $source =~ /elegans/ ? "t=NG;t=CG;t=CDS;t=PG;t=PCR;t=SNP;t=TcI;t=MOS;t=CLO":"";
    my $position = (defined $start)?"$ref:$start..$stop":$ref;
    
    my $link_gb=$self->parsed_species."/?name=$position;$type;width=700";
    my $id=$self->parsed_species."/?name=$position";
    my $data = { description => 'The Inline Image of the sequence',
		 data        => {  link => 'genomic_location',
				   label => $link_gb,
				   id	=> $id,
				},
    };
     
    return $data;    
}


sub external_links {
    my $self = shift;
    my $s = $self->object;
     
    my $ac_number = find_ac($s,'NDB');
    my $ac_protein = eval { $s->Protein_id(2);};
    my $swissprot = find_swissprot($s);
    my $wormpd_id = find_wormpd($s);
    my $uniprot    = find_ac($s,'UniProt');
    my %ac_hash = %$uniprot;
    
     
    
    my %hash;
    if( keys(%{$ac_number}) > 0 ) {
      $hash{'GenBank/EMBL'}{label}=$ac_number->{GI_number};
      $hash{'GenBank/EMBL'}{id}=$ac_number->{GI_number};
      $hash{'GenBank/EMBL'}{link}='Entrez';

    } else {
      $ac_number = find_ac($s, 'EMBL');
      $ac_number = find_ac($s, 'GenBank') if( keys(%{$ac_number}) == 0 );
      if( keys(%{$ac_number}) > 0 ) {
	$hash{'GenBank/EMBL'}{label}=$ac_number->{NDB_AC};
	$hash{'GenBank/EMBL'}{id}=$ac_number->{NDB_AC};
	$hash{'GenBank/EMBL'}{link}='Entrez';
      }
    }
 
    if ($ac_protein) {
	$hash{'GenPep'}{label}=$ac_protein;
	$hash{'GenPep'}{id}=$ac_protein;
	$hash{'GenPep'}{link}='Entrezp';
    }
    if (defined $uniprot->{UniProtAcc}) {
	$hash{'Uniprot Accession number'}{label}=$uniprot->{UniProtAcc};
	$hash{'Uniprot Accession number'}{id}=$uniprot->{UniProtAcc};
	$hash{'Uniprot Accession number'}{link}='Trembl';
    }
    if (eval { $s->Coding(0) }) {
	$hash{'Intronerator'}{label}="Intronerator: $s";
	$hash{'Intronerator'}{id}=$s;
	$hash{'Intronerator'}{link}='Intronerator';
    } 
    
    if ($swissprot) {
	$hash{'SwissProt/TrEMBL'}{label}=$swissprot;
	$hash{'SwissProt/TrEMBL'}{id}=$swissprot;
	$hash{'SwissProt/TrEMBL'}{link}='Uniprot';
    } 
    if ($self->type eq 'predicted coding sequence' or $self->type eq 'confirmed gene') {
	$hash{'Eugenes'}{label}="ACEPRED:$s";
	$hash{'Eugenes'}{id}=$s;
	$hash{'Eugenes'}{link}='Meow_predicted';

	$hash{'NextDB'}{label}=$s;
	$hash{'NextDB'}{id}=$s;
	$hash{'NextDB'}{link}='Nextdb';
    } 
    if ($s =~ /^OST/) {
	$hash{'ORFeome Project'}{label}="WORFDB: $s";
	$hash{'ORFeome Project'}{id}=$s;
	$hash{'ORFeome Project'}{link}='Orfeome';
    } 
     if ($wormpd_id) {
	$hash{'WormPD (fee required)'}{label}=$wormpd_id;
	$hash{'WormPD (fee required)'}{id}="$wormpd_id.html";
	$hash{'WormPD (fee required)'}{link}='Proteome';
    } 
    
  
    
    # RSTs. Yuck.
    if ($s =~ /^RST/) {
	$hash{'RACE project page at WORFDB'}{label}=$s;
	$hash{'RACE project page at WORFDB'}{id}="";
	$hash{'RACE project page at WORFDB'}{link}='WORFDB';
	
	 
    }
 
    my $parent = $self->sequence;
    my $clone = eval { $s->Clone };
    $clone ||= eval { $parent->Clone } if $parent;  

    if ($clone && $s->From_laboratory eq 'YK') {
	$clone =~ s/YK//i;  # Strip the YK from the ID      
        $hash{'NextDB EXPRESSION'}{label}=$clone;
	$hash{'NextDB EXPRESSION'}{id}=$clone;
	$hash{'NextDB EXPRESSION'}{link}='Nextdb_EXPRESSION';
    }
    

    return unless keys %hash;
    my $data = { description => 'The External Links of the sequence',
		 data        => \%hash,
    };
    return $data;    
}

### to be written...... ####
#sub print_long_description {
#
#}


############## this is depricated? ################
sub analysis {
    my $self = shift;
	my %so_data;
	my $analysis = eval{$self ~~ 'Analysis'};
	
	if ($analysis) {
	
		$so_data{'Object'} = $analysis;
		$so_data{'Description'} = $analysis->Description;
		$so_data{'DB Info'} = $analysis->DB_info;
		$so_data{'WB Release'} = $analysis->Based_on_WB_Release;
		$so_data{'DB Release'} = $analysis->Based_on_DB_Release;	
		$so_data{'Sample'} = $analysis->Sample;
		$so_data{'Paper'} = $analysis->Reference;
		$so_data{'Conducted y'} = $analysis->Conducted_by;
		$so_data{'Url'} = $analysis->URL;
	} else {
		return ;
	}

    my $data = { description => 'The Analysis info of the sequence',
		 data        => \%so_data,
    };
    return $data;    
}
############################################################
#
# The Sequence widget
#
############################################################

sub print_link_parts {
    my $self = shift;
    
    
    my $data = { description => 'The Analysis info of the sequence',
		 data        =>  1,
    };
    return $data; 
}

sub print_sequence {
    my $self = shift;
    my $s = $self->object;
    my %hash;
    my $gff = $self->gff;
    my $seq_obj;
    if ($self->species =~ /briggsae/) {
      ($seq_obj) = sort {$b->length<=>$a->length}
	$self->type =~ /^(genomic|confirmed gene|predicted coding sequence)$/i
	  ? grep {$_->method eq 'wormbase_cds'} $gff->fetch_group(Transcript => $s),
	    : '';
    } else {
      ($seq_obj) = sort {$b->length<=>$a->length}
# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => $s);
	grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => $s);
      # BLECH!  If provided with a gene ID and alt splices are present just guess
      # and fetch the first CDS or Transcript
      # We really should display a list for all of these.
      ($seq_obj) ||= sort {$b->length<=>$a->length}
# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => "$s.a");
	grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => "$s.a");
      ($seq_obj) ||= sort {$b->length<=>$a->length}
# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => "$s.1");
	grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => "$s.1");
    }
    
    ($seq_obj) ||= $gff->fetch_group(Pseudogene => $s);
    # Haven't fetched a GFF segment? Try Ace.
    if (!$seq_obj || length($seq_obj->dna) < 2) { # miserable broken workaround
      # try to use acedb
      if (my $fasta = $s->asDNA) {
	  $hash{dna} = $fasta;
	  $self->length(length $fasta);
      } else {
	$hash{dna} =  "<p>Sequence unavailable.  If this is a cDNA, try searching for $s.5 or $s.3</p>"; 
      }
      goto END;
    }

#     print_genomic_position($s,$type);
     
    $hash{est}{id} = "name=$s;class=CDS";
    $hash{est}{link} = 'aligner';
     $hash{est}{label} = '[View EST alignments]';

    if (eval { $s->Properties eq 'cDNA'} ){
      # try to use acedb
      if (my $fasta = $s->asDNA) {
	$hash{dna}  = $fasta;
      }
      goto END;
    }

    my $unspliced = lc $seq_obj->dna;
    my $length = length($unspliced);
    if (eval { $s->Coding_pseudogene } || eval {$s->Coding} || eval {$s->Corresponding_CDS}) {
      my $markup = Bio::Graphics::Browser2::Markup->new;
      $markup->add_style('utr'  => 'FGCOLOR gray');
      $markup->add_style('cds'  => 'BGCOLOR cyan');
      $markup->add_style('cds0' => 'BGCOLOR yellow');
      $markup->add_style('cds1' => 'BGCOLOR orange');
      $markup->add_style('uc'   => 'UPPERCASE');
      $markup->add_style('newline' => "\n");
      $markup->add_style('space'   => ' ');
      my %seenit;

      my @features;
      if ($s->Species =~ /briggsae/) {
	$seq_obj->ref($seq_obj);  # local coordinates
	@features = sort {$a->start <=> $b->start}
	  grep { $_->info eq $s && !$seenit{$_->start}++ }
	    $seq_obj->features('coding_exon:curated','UTR');
      } else {
	$seq_obj->ref($seq_obj);  # local coordinates
	# Is the genefinder specific formatting cruft?
	@features =
	  sort {$a->start <=> $b->start}
	    grep { $_->info eq $s && !$seenit{$_->start}++ }
	      ($s->Method eq 'Genefinder') ?
		$seq_obj->features('coding_exon:' . $s->Method,'five_prime_UTR','three_prime_UTR')
		  :
		    $seq_obj->features(qw/five_prime_UTR:Coding_transcript exon:Pseudogene coding_exon:Coding_transcript three_prime_UTR:Coding_transcript/);
      }
      $hash{unspliced} = _print_unspliced($markup,$seq_obj,$unspliced,@features);
      $hash{spliced} = _print_spliced($markup,@features);
      $hash{protein} = _print_protein($markup,\@features) unless eval { $s->Coding_pseudogene };
    } else {
      # Otherwise we've got genomic DNA here
	$hash{dna} =  _to_fasta($s,$unspliced);
    }
    $self->length($length);

    END:
    my $data = { description => 'The Analysis info of the sequence',
		 data        => \%hash,
    };
    return $data; 
}

sub print_blast {

}


sub print_structure {

}

sub print_feature {

}

############################################################
#
# The Map position widget
#
############################################################

############################################################
#
# The Similarities widget
#
############################################################


############################################################
#
# PRIVATE METHODS
#
############################################################

sub is_gap {
    my ($self) = shift;
    return $self->object =~ /(\b|_)GAP(\b|_)/i;
}

sub is_merged {
    my $self = shift;
    return $self->object =~ /LINK|CHROMOSOME/i;
}

sub _get_segments {
  my $self    = shift;
  my $object = $self->object;
  # special case: return the union of 3' and 5' EST if possible
  if ($self->type =~ /EST/) {
      if ($object =~ /(.+)\.[35]$/) {
	  my $base = $1;
	  my ($seg_start) = $self->gff->segment(Sequence => "$base.3");
	  my ($seg_stop)  = $self->gff->segment(Sequence => "$base.5");
	  if ($seg_start && $seg_stop) {
	      my $union = $seg_start->union($seg_stop);
	      return $union if $union;
	  }
      }
  }
  return  map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object);
}

sub find_ac {
  my ($s,$node) = @_;
  my %ids;
  my @dbs = $s->Database;
  foreach (@dbs) {
    if ($_ eq $node) {
      foreach my $col ($_->col) {
	$ids{$col} = $col->right;
      }
    }
  }
  return (\%ids);
}

sub find_swissprot {
    my $s = shift;
    my @dbs = $s->Database;
    foreach (@dbs) {
      next unless $_ eq 'TREMBL' or $_ eq 'SwissProt';
      if ($_ eq 'SwissProt') {
	  my @ids = $_->col;
	  foreach (@ids) {
	      return $_->right if ($_ eq 'SwissProt_AC');
	  }
      }
      return $_->right(2);
    }

    # If there wasn't a TREMBL or SWISSPROT entry associated with
    # the main sequence, try to get it from an associated protein

    # Can I get rid of this?
    # follow the tags to the swissprot entry
    my %protein_dbs = map {$_ => $_->right(2)} eval { $s->Corresponding_protein('Database') };
    return unless $protein_dbs{'SwissProt'};
    (my $swissprot = $protein_dbs{'SwissProt'}) =~ s/\W//g;
    return $swissprot;
}

sub find_wormpd {
  my $s = shift;
  return unless eval { $s->Coding };
  my @genes = eval { $s->Locus };
  return $genes[0] if @genes; # oh well
  return $s;
}

=pod already displayed genomic location(s) in the overview widgets... is this redundent?
sub print_genomic_position {
  my $self = shift;
  my $s = $self->object;
  my ($begin,$end,$reference) = $self->find_position($s);
  my $ref = $reference;
  my %hash ;
#   my $positions = $self->find_position($self->object);
  my @array;
  if ($begin) {
    foreach (@$positions) {
      my ($begin,$end,$reference) = @$_;
      my $ref = $reference;
     
	my $subscript = ('a'..'z')[$begin/$CHROMOSOME_TABLE_LENGTH];
	(my $anchor = $s) =~ s/\..*$//;
	my $href = "$reference$subscript.html#$anchor";
	     
      my %entry;
      $entry{chrom}{link} = 'Chromosome_tables';
      $entry{chrom}{id} = $href;
      $entry{chrom}{label} = $reference;

      $entry{browse}{link} = 'genomic_location';
      $entry{browse}{id} = "?name=$s";
      $entry{browse}{label} = '[Search for this Sequence on Genome]';
      print li("$ref: $begin-$end. ",
	       a({-href=>hunter_url($reference,$begin,$end)},' [Browse map] '),
	       eval { $s->Coding } ?
	       a({-href=>Url('aligner',"name=$s;class=CDS"),-target=>"_blank"},' [View EST alignments]')
	       : ''
	      );
      push @array,$entry;
    } 
  } else {
    my %entry;
    $entry{browse}{link} = 'genomic_location';
    $entry{browse}{id} = "?name=$s";
    $entry{browse}{label} = '[Search for this Sequence on Genome]';
    push @array,$entry;
     
  }
  $hash{content} = \@array;
  return \%hash;
}
=cut

sub _print_unspliced {
  my ($markup,$seq_obj,$unspliced,@features) = @_;
  my $name = $seq_obj->info . ' (' . $seq_obj->start . '-' . $seq_obj->stop . ')';

  my $length   = length $unspliced;
  if ($length > 0) {
    # mark up the feature locations
    my $prefasta = $unspliced;
    my @markup;
    my $offset = $seq_obj->start;
    my $counter = 0;
    for my $feature (@features) {
      my $start    = $feature->start - $offset;
      my $length   = $feature->length;
      my $style = $feature->method eq 'CDS'  ? 'cds'.$counter++%2
	: $feature->method =~ /exon/ ? 'cds'.$counter++%2
		: $feature->method =~ 'UTR' ? 'utr' : '';
      push @markup,[$style,$start,$start+$length];
      push @markup,['uc',$start,$start+$length] unless $style eq 'utr';
    }
    push @markup,map {['space',10*$_]}   (1..length($prefasta)/10);
    push @markup,map {['newline',80*$_]} (1..length($prefasta)/80);
    $markup->markup(\$prefasta,\@markup);
    return ">$name (unspliced + UTR - $length bp)\n$prefasta\n";
  }
}

# Fetch and markup the spliced DNA
# markup alternative exons
sub _print_spliced {
  my ($markup,@features) = @_;
  my $spliced = join('',map {$_->dna} @features);
  my $splen   = length $spliced;
  my $last    = 0;
  my $counter = 0;
  my @markup  = ();
  my $prefasta = $spliced;
  for my $feature (@features) {
    my $length = $feature->stop - $feature->start + 1;
    my $style  = $feature->method =~ /UTR/i ? 'utr' : 'cds' . $counter++ %2;
    my $end = $last + $length;
    push @markup,[$style,$last,$end];
    push @markup,['uc',$last,$end] if $feature->method =~ /exon/;
    $last += $length;
  }
  
  push @markup,map {['space',10*$_]}   (1..length($spliced)/10);
  push @markup,map {['newline',80*$_]} (1..length($spliced)/80);
  $markup->markup(\$prefasta,\@markup);
  my $name = eval { $features[0]->refseq->name } ;
  return ">$name (spliced + UTR - $splen)\n$prefasta" if $name;
}

sub _print_protein {
  my ($markup,$features,$genetic_code) = @_;
  my @markup;
  my $trimmed = join('',map {$_->dna} grep {$_->method eq 'coding_exon'} @$features);
  return unless $trimmed;  # Hack for mRNA
  my $peptide = Bio::Seq->new(-seq=>$trimmed)->translate->seq;
  my $change  = $peptide =~/\w+\*$/ ? 1 : 0;
  my $plen = length($peptide) - $change;
  
  @markup = map {['space',10*$_]}      (1..length($peptide)/10);
  push @markup,map {['newline',80*$_]} (1..length($peptide)/80);
  $markup->markup(\$peptide,\@markup);
  $peptide =~ s/^\s+//;
  my $name = eval { $features->[0]->refseq->name };
  return ">$name (conceptual translation - $plen aa)\n$peptide";
}

##use this or template to format sequence?
sub _to_fasta {
    my ($name,$dna) = @_;
    $dna ||= '';
    my @markup;
    for (my $i=0; $i < length $dna; $i += 10) {
      push (@markup,[$i,$i % 80 ? ' ':"\n"]);
    }
    markup(\$dna,\@markup);
    $dna =~ s/^\s+//;
    $dna =~ s/\*$//;
    return "&gt;$name\n$dna";
}

1;
