package WormBase::API::Service::nearby_genes;

use Ace; 
use Moose;
with 'WormBase::API::Role::Object'; 

has 'algorithms' => (
    is         => 'rw',
    isa        => 'HashRef',
    );

has 'tracks' => (
    is  => 'ro',
    writer => 'set_tracks',
);

# The index page.
sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}

# Running a search.
sub run {
    my ($self,$c,$param) = @_;
    my $query = $param->{name};

    my $api = $c->model('WormBaseAPI');
    my ($it,$res)= $api->xapian->search_exact($c, $query, 'gene');


    my $o = @{$it->{struct}}[0];
    my $service_dbh = $api->_services->{$api->default_datasource}->dbh || return 0;
    my $sequence = $service_dbh->fetch(-class => $o->get_document->get_value(0), -name => $o->get_document->get_value(1));


    return {msg=>"No such sequence ID known."} unless $sequence  ;

    $self->object($sequence);
    $sequence->db->class('Ace::Object::Wormbase');
    my $gff_dsn= $self->gff_dsn;
    $gff_dsn->ace($sequence->db);
    $gff_dsn->reconnect();
    my $dbgff =  $gff_dsn->dbh ;
    $self->log->debug("GFF database:",$dbgff);
    $dbgff->add_aggregator('waba_alignment') if ($dbgff); 
    my $is_transcript = eval{$sequence->CDS} || eval {$sequence->Corresponding_CDS} || eval {$sequence->Corresponding_transcript};
    return {msg=>"Sequence is not a transcript."} unless ($is_transcript) ;




    my ($chromosome,$position);
  if ($obj->class eq 'Sequence' || $obj->class eq 'CDS') {
    ($chromosome,$position) = GetInterpolatedPosition($DB,$obj);
  } elsif (eval { $obj->SNP }) {  # SNP loci are dealt with a little differently
    $chromosome = $obj->Allele->Sequence->Interpolated_gMap;
    $position   = $obj->Allele->Sequence->Interpolated_gMap(2);
  } else {
    ($chromosome) = $obj->get('Map') ;
    ($position) = $obj->get('Map'=>3);
    ($chromosome,$position) = GetInterpolatedPosition($DB,$obj) unless ($chromosome);
  }
  unless ($chromosome) {
    print p(font({-color=>'red'},
		 'No genetic mapping information is yet available for this locus or sequence.'));
    return;
  }
  
  my ($x1, $x2) ;
  $x1 = $position - $window ; $x2 = $position + $window ;
  
  my @genes = $DB->fetch(-query=>"FIND Map $chromosome ; FOLLOW Gene ; Map = $chromosome # (Position > $x1 AND HERE < $x2)",
			 -fill=>1);
  
  unless (@genes) {
    print b(font({-color=>'red'},
		 "There are no mapped loci within $window cM of $obj (position $chromosome:$position)",
		 "Try a larger window."));
    return;
  }
  
  (my $pos = $chromosome) =~ s/\./\\./g;
  $pos = "$pos.Position";

  my %positions = map { $_ => $_->get('Map')->at($pos) } @genes;

  # If this is a sequence or sequence-only gene, save it
  if ($obj->class eq 'Sequence' || eval { !$obj->CGC_name }) {
      $positions{$obj} = $position;
      push @genes,$obj;
  }
  

  foreach my $gene (sort {$positions{$a}+0 <=> $positions{$b}+0} @genes) {
      print "\n"; # for readability

      # we are at the center position but 1
      if ($gene eq $obj) {
	  print  a({-name=>"pos"}),hr;
      }

      # This is either an gene with sequence only or a sequence object
      if ($gene eq $obj && eval  { !$obj->CGC_name} ) {
	  print h3($obj->class . ($bestname ? " $bestname" : " $obj")
		   . " interpolates at position $position on map $chromosome") ;
      } else {
	  my $z =  $positions{$gene};
	  # Regular 'ol locus
	  my @clones = map { a({-href=>Url('pic',"class=Clone&name=".escape("$_")) },$_) } 
	  $gene->get('Positive_clone') ;
	  print 
	      p,
	      span({'-style'=>'font-size: 14pt'},
		   a({-href => Url('pic',"class=Locus&name=$gene") },b("$chromosome:"),$z),
		   i("locus"),span({-class=>'gene'},ObjectLink($gene->Public_name)),
		   @clones ? " mapped on clone @clones " : "");
	  
	  if (my @phs = eval { $gene->Phenotype } ) {
	      print blockquote({-class=>'description'}, $phs[$#phs]);
	  }
      }
      print hr if ($gene eq $obj);
  }
}







    
    my ($align_start,$align_end);

    #allow for offsets
    my $user_start = $param->{"start"};
    my $user_end   = $param->{"end"};
    my $flip_user  = $param->{"flip"};
    my $user_ragged =  defined $param->{"ragged"} ? $param->{"ragged"} : BLUMENTHAL_FACTOR;
    my $user_override = defined $user_start && defined $user_end && ($user_start || $user_end);
    my $hash = {	
		sequence => $sequence_id,
		size => length($param->{"sequence"})||8,
		start => $user_start,
		end => $user_end,
		flip => 0,
		factor => $user_ragged,
		algorithm => $self->algorithms,
		types	  =>\%TYPES,
		labels	=> \%LABELS,
		max_len => TOO_BIG,
      };
    if ($user_override && ($user_end - $user_start > TOO_BIG)) {
	$hash->{long}=1;
	return;
    }
    my ($seq) = $dbgff->segment(-name => $sequence,
			    $user_override ? (-start	=>	$user_start,
					      -stop	=>	$user_end) : ());
				       
    
    my  @alignments;

    foreach (sort keys %{$self->algorithms}){
      $self->log->debug("using algorithm:".$_);
      push @alignments,$seq->features(@{$TYPES{$_}});
    }

    # get the DNA for each of the alignment targets
    my %dna;
    my @missing;
    foreach (@alignments) {
      my $target = $_->target;
      next if $dna{$target};  # already got it or some reasn
      my $dna = $target->asDNA;

      unless ($dna) {
	$self->log->debug( "ALIGNER missing target = $target" );
	$dna = $dbgff->dna($target->name);
      }

      unless ($dna) {
	push @missing,$target;
# 	print p({-class=>'error'},"The DNA sequence is missing for $target.\n");
	next;
      }
      $dna{$target} = $dna;
      clean_fasta(\$dna{$target});
    }
    $hash->{missing_target} = \@missing;

    # sort the alignments by their start position -- this looks nicer
    @alignments = sort { $a->start <=> $b->start } @alignments;

    # the coding sequence is going to begin at nucleotide 1, but one or
    # more of the alignments may start at an earlier position.
    # calculate an offset, which when subtracted from the first alignment,
    # puts the first nucleotide at string position 0

    if ($user_override) {
      ($align_start,$align_end) = ($user_start,$user_end);
    } else {
      $align_start    =  $seq->start;
      $align_start    =  $alignments[0]->start
	if $alignments[0] && $alignments[0]->start < $seq->start;

      # the same thing applies to the end of the aligned area
      my @reversed_alignments = sort { $b->end <=> $a->end } @alignments;
      $align_end           = $seq->end;
      $align_end = $reversed_alignments[0]->end
	if $reversed_alignments[0] && $reversed_alignments[0]->end > $seq->end;
    }

    $self->log->debug("ALIGNER: $align_start, ...now\n");

    # FUDGE FACTOR FOR TOM BLUMENTHAL
    unless ($user_override) {
      $align_start -= BLUMENTHAL_FACTOR;
      $align_end   += BLUMENTHAL_FACTOR;
    }

    # align_length holds the full length of the alignment
    my $align_length = $align_end - $align_start + 1;

    # we're going to grow two arrays, one holding each row of the
    # sequences, and the other holding the alignments
    # The catch here is that if the cDNAs extend beyond the boundary of the
    # gene, we want to extend the genomic sequence, so we refetch the DNA
    ($align_start,$align_end) = ($align_end,$align_start) if($align_start > $align_end);
    my ($genomic) = $dbgff->segment(-name  => $sequence,
				    -start => $align_start,
				    -end   => $align_end);
    ##eval{$genomic->absolute(1)};
    # WHAT IS THIS BEING USED FOR?
    my @dnas   = ($genomic->display_name => $genomic->dna);
    # Determine if the plugin should flip the alignment
    my $calculated_flip = $genomic->abs_strand == -1 ? 1 : 0; 
     
    # Flip it by default if genomic sequence is on neg strand and request comes from outside of the page
    $calculated_flip = $flip_user if $param->{override_flip};
     #in case of flip, the image also flip orientation
    if ($calculated_flip){
      ($align_start, $align_end) = ($align_end, $align_start);
    }
     
    $hash->{start} = $align_start;
    $hash->{end} = $align_end;
    $hash->{flip}=$calculated_flip;

    # experimental -- do an image
    my @align_types;
    foreach (sort keys %{$self->algorithms}){
      push @align_types,$LABELS{$_};
    }

    
  # Link into gbrowse image using the sequence object (a gene object)
    $self->log->debug("ALIGNER: before print_image: $align_start $align_end\n");
    my $gene = $api->fetch({aceclass=> $o->get_document->get_value(0),
                          name => $o->get_document->get_value(1)}) or die "$!";

#     $hash->{picture}= $self->genomic_picture($sequence, $align_start, $align_end);
    $hash->{picture} = $gene->genomic_image;

    ##################################################
    my ($start,$end) = $align_start < $align_end ? ($align_start,$align_end) : ($align_end,$align_start);
    my $name = $genomic->ref .":$start..$end";
    my $flip_format = "Aligner.flip=" . $calculated_flip;
    my $ragged = "Aligner.ragged=". $user_ragged || "Aligner.ragged=BLUMENTHAL_FACTOR";
    my $test =  "$sequence:$start..$end";
    
    my $url_root = 'http://www.wormbase.org/db/gb2/gbrowse/c_elegans?';
    #my $plugin_url = $url_root . "name=$test;plugin=Aligner;plugin_action=Go;label=ESTB;Aligner.upcase=CDS;Aligner.align=ESTB;". $ragged . ";" . $flip_format;
    my $plugin_url = $url_root . "name=$test;plugin=Aligner;plugin_action=Go;label=ESTB;Aligner.upcase=CDS;Aligner.align=ESTB;";
   
    $plugin_url .= 'Aligner.align=ESTO;' if $self->algorithms->{BLAT_EST_OTHER};
    $plugin_url .= $ragged . ";" . $flip_format;

    $self->log->debug( "ALIGNER: URL: $plugin_url\n");
    my $content = get $plugin_url;
    return {msg=>"Couldn't get $plugin_url" } unless defined $content;
    $hash->{content}=$content;
 
    return $hash;
}
 
 
 
sub clean_fasta {
  my $stringref = shift;
  $$stringref =~ s/^>.*//;
  $$stringref =~ s/\n//g;
}

 
 


1;
