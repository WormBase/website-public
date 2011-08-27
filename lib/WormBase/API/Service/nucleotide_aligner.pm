package WormBase::API::Service::nucleotide_aligner;

use Bio::Graphics::Browser2::Util;
use Ace 1.51; 
use Bio::Graphics::Browser2::PadAlignment;
use LWP::Simple;
use Bio::Graphics::Browser2::Markup;
use Data::Dumper;

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

use constant TOO_BIG => 50_000;
use constant BLUMENTHAL_FACTOR => 23; # rough size of trans-spliced leader
use constant DEFAULT_ALGORITHM => "BLAT_EST_BEST";
use constant TARGET    => 0;
use constant SRC_START => 1;
use constant SRC_END   => 2;
use constant TGT_START => 3;
use constant TGT_END   => 4;

our %TYPES    = (BLAT_EST_BEST  => [qw(alignment:BLAT_EST_BEST)],
		BLAT_EST_OTHER  => [qw(alignment:BLAT_EST_OTHER)],
		BLAT_mRNA_BEST => [qw(alignment:BLAT_mRNA_BEST)],
		BRIGGSAE   => [qw(waba_alignment)]
	       );
our %LABELS   = (
	     BLAT_EST_BEST  => 'ESTs Aligned with BLAT (best)',
	     BLAT_EST_OTHER => 'ESTs aligned by BLAT (other)',
	     BLAT_mRNA_BEST => 'full-length mRNAs Aligned with BLAT (best)',
	     BRIGGSAE   => 'Briggsae Alignments (WABA)',
	     );
 
our %TRACKS   = (
	     BLAT_EST_BEST  => 'ESTB',
	     BLAT_EST_OTHER => 'ESTO',
	     BLAT_mRNA_BEST => 'mRNAB',
	     BRIGGSAE   => 'WABA',
	     );

sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}


sub run {
    my ($self,$c,$param) = @_;
    my $sequence_id = $param->{"sequence"};
 
    my @array;
    if($param->{algorithm}) {
	if (ref $param->{algorithm} eq 'ARRAY' ) {
	    @array = @{$param->{algorithm}};
	}else {
	    push @array, $param->{algorithm};
	}
    }else{
	push @array, DEFAULT_ALGORITHM;
    }
    $self->algorithms({map {$_=>1} @array});
    
    my @types = 'CG';
    foreach (sort keys %TRACKS) {
      push @types,$TRACKS{$_}  if $self->algorithms->{$_};
    }
    $self->set_tracks(\@types);

    my $api = $c->model('WormBaseAPI');

    my ($it,$res)= $api->xapian->search_exact($c, $sequence_id, 'gene');
    unless ($it->{pager}->{total_entries} == 1 ){ return; }
    my $o = @{$it->{struct}}[0] || return;
    my $service_dbh = $api->_services->{$api->default_datasource}->dbh || return 0;
    my $sequence = $service_dbh->fetch(-class => $o->get_document->get_value(0), -name => $o->get_document->get_value(1));


    return {msg=>"No such sequence ID known."} unless $sequence  ;

    $self->object($sequence);
    $sequence->db->class('Ace::Object::Wormbase');
    my $gff_dsn= $self->gff_dsn || return undef;
    $gff_dsn->ace($sequence->db);
    $gff_dsn->reconnect();
    my $dbgff =  $gff_dsn->dbh || return undef;
    $self->log->debug("GFF database:",$dbgff);
    $dbgff->add_aggregator('waba_alignment') if ($dbgff); 
    my $is_transcript = eval{$sequence->CDS} || eval {$sequence->Corresponding_CDS} || eval {$sequence->Corresponding_transcript};
    return {msg=>"Sequence is not a transcript."} unless ($is_transcript) ;
    
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
