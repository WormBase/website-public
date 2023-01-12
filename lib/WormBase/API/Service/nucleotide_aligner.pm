package WormBase::API::Service::nucleotide_aligner;

use Bio::Graphics::Browser2::Util;
use Ace 1.51;
use Bio::Graphics::Browser2::PadAlignment;
use LWP::Simple;
use Bio::Graphics::Browser2::Markup;

use Moose;
with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


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
use constant DEFAULT_ALGORITHM => "EST_BEST";
use constant TARGET    => 0;
use constant SRC_START => 1;
use constant SRC_END   => 2;
use constant TGT_START => 3;
use constant TGT_END   => 4;

our %TYPES = (
    EST_BEST  => [qw(expressed_sequence_match:BLAT_EST_BEST)],
    EST_OTHER  => [qw(expressed_sequence_match:BLAT_EST_OTHER)],
    MRNA_BEST => [qw(expressed_sequence_match:BLAT_mRNA_BEST)],
    );
our %LABELS   = (
    EST_BEST  => 'ESTs Aligned with BLAT (best)',
    EST_OTHER => 'ESTs aligned by BLAT (other)',
    MRNA_BEST => 'full-length mRNAs Aligned with BLAT (best)',
    );

our %TRACKS   = (
    EST_BEST  => 'EST_BEST',
    EST_OTHER => 'EST_OTHER',
    MRNA_BEST => 'MRNA_BEST',
    );

sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}


sub run {
    my ($self,$c,$param) = @_;

##
#     This is just until functionality can be replaced with JBrowse 2
##

    return {msg=>"This functionality currently is not available; we hope to restore it soon."};
##
#  When it ready, remove this ^^^ line
##
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

    my @types = 'GENES';
    foreach (sort keys %TRACKS) {
      push @types,$TRACKS{$_}  if $self->algorithms->{$_};
    }
    $self->set_tracks(\@types);

    my $api = $c->model('WormBaseAPI');

    my $match = $api->xapian->fetch({query => $sequence_id, class => 'gene'});
    return unless $match;
    my $service_dbh = $api->_services->{$api->default_datasource}->dbh;
    my $sequence = $service_dbh->fetch(-class => $match->{class}, -name => $match->{id});


    return {msg=>"No such sequence ID known."} unless $sequence;

    $self->object($sequence);
    $sequence->db->class('Ace::Object::Wormbase');
    my $gff_dsn = $self->gff_dsn;
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
        types      =>\%TYPES,
        labels    => \%LABELS,
        max_len => TOO_BIG,
      };
    if ($user_override && ($user_end - $user_start > TOO_BIG)) {
      $hash->{long}=1;
      return;
    }

    my ($seq) = $gff_dsn->segment($sequence);



    if($user_override){
      ($align_start,$align_end) = ($user_start,$user_end);
    } else {
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
        my ($segment) = $gff_dsn->segment($target->{seqid}, $target->start, $target->end);
        my $dna = $segment->dna;

        unless ($dna) {
          $self->log->debug( "ALIGNER missing target = $target" );
          push @missing,$target;
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
    # TODO: make sure works with GFF3 - AC
    my ($genomic) = $gff_dsn->segment($sequence);
    $self->log->debug("GENOMIC: $genomic $sequence");
          # $self->log->debug("GDNA:".$genomic->dna);

    ##eval{$genomic->absolute(1)};
    # WHAT IS THIS BEING USED FOR?
    # my @dnas   = ($genomic->display_name => $genomic->dna);
    # Determine if the plugin should flip the alignment
    my $calculated_flip = $genomic->strand == -1 ? 1 : 0;

    # Flip it by default if genomic sequence is on neg strand and request comes from outside of the page
    $calculated_flip = $flip_user if $param->{override_flip};
     #in case of flip, the image also flip orientation
    if ($calculated_flip){
      ($align_start, $align_end) = ($align_end, $align_start);
    }

    $hash->{start} = $align_start;
    $hash->{end} = $align_end;
    $hash->{flip}=$calculated_flip;

    # Link into gbrowse image using the sequence object (a gene object)
    $self->log->debug("ALIGNER: before print_image: $align_start $align_end\n");
    my $gene = $api->fetch({aceclass=> $match->{class},
                          name => $match->{id}}) or die "$!";

    $hash->{picture} = $gene->genomic_image;

    ##################################################
    my ($start,$end) = $align_start < $align_end ? ($align_start,$align_end) : ($align_end,$align_start);
    my $name = $genomic->ref .":$start..$end";
    my $flip_format = "Aligner.flip=" . $calculated_flip;
    my $ragged = "Aligner.ragged=". ($user_ragged || "BLUMENTHAL_FACTOR");

    my @db = split('_', "" . $gff_dsn->source);
    my $source = join('_', @db[0..@db-2]);

    my $plugin_url = "http://www.wormbase.org/tools/genome/gbrowse/" . $source . "/?";
    $plugin_url .= "name=$name;plugin=Aligner;plugin_action=Go;label=EST_BEST;Aligner.upcase=CDS;Aligner.align=EST_BEST;";

    $plugin_url .= 'Aligner.align=EST_OTHER;' if $self->algorithms->{EST_OTHER};
    $plugin_url .= $ragged . ";" . $flip_format;

    $self->log->debug( "ALIGNER: URL: $plugin_url\n");
    my $content = get $plugin_url;
    return {msg=>"Couldn't get $plugin_url" } unless defined $content;

    if($content =~ m/\<title\>Not Found\<\/title\>|class="error"/){
      $content = "Couldn't fetch alignment";
    }
    $hash->{content}=$content;

    return $hash;
}



sub clean_fasta {
  my $stringref = shift;
  $$stringref =~ s/^>.*//;
  $$stringref =~ s/\n//g;
}





1;
