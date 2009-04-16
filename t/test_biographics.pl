#!/usr/bin/perl

use strict;
use Bio::Graphics::Browser;
use Bio::DB::GFF;


my %config = ( elegans       => {-adaptor     => 'dbi::mysqlace',
				 -aggregator   => ['processed_transcript{coding_exon,5_UTR,3_UTR/CDS}',
						   'full_transcript{coding_exon,five_prime_UTR,three_prime_UTR/Transcript}',
#						   'transposon{coding_exon,five_prime_UTR,three_prime_UTR}',
#						   'clone',
#						   'alignment',
#						   'waba_alignment',
#						   'coding{coding_exon}',
#						   'pseudo{exon:Pseudogene/Pseudogene}',
#						   'rna{exon/Transcript}'
						  ],
				},
);

# TEMPORARY KLUDGE UNTIL I CAN GET THIS RESOLVED
my $gff_args = $config{'elegans'};
$gff_args->{-user} = 'root';
$gff_args->{-pass} = '';
$gff_args->{-dsn}  = "dbi:mysql:database=elegans;host=" . 'localhost';

my $dbh     = Bio::DB::GFF->new(%$gff_args);
my $segment = $dbh->segment(Gene => 'WBGene00006763');

my (@tracks,%options);

# Yuck. Species-specific junk.
  #    @tracks = (qw/NG
  #		  CG
  #		  CANONICAL
  #		  MOTIFS
  #		  Allele
  #		  RNAi
  #		 /);
  @tracks = (qw/CG/);


my $data = build_gbrowse_img($segment,\@tracks,\%options);




sub build_gbrowse_img {
  my ($segment,$tracks,$options,$width) = @_;
   
  # open the browser for drawing pictures
  my $BROWSER = Bio::Graphics::Browser->new or die;
  
  $BROWSER->read_configuration('/Users/todd/projects/wormbase/website/trunk/conf/gbrowse.conf');
  $BROWSER->source('elegans');
  $BROWSER->width($width || '500');
  
  $BROWSER->config->set('general','empty_tracks' => 'suppress');
  $BROWSER->config->set('general','keystyle'     => 'none');
  
  print "$BROWSER\n";
  foreach (keys %{$BROWSER->{conf}}) {
    print "$_ $BROWSER->{conf}->{$_}\n";
  }

  my $absref   = $segment->abs_ref;
  my $absstart = $segment->abs_start;
  my $absend   = $segment->abs_end;
  ($absstart,$absend) = ($absend,$absstart) if $absstart>$absend;
  my $length = $segment->length;
  
  # add another 10% to left and right
  my $start = int($absstart - 0.1*$length);
  my $stop  = int($absend   + 0.1*$length);
  my $db    = $segment->factory;

  my ($new_segment) = $db->segment(-name=>$absref,
				   -start=>$start,
				   -stop=>$stop);
  print "$absstart $absend $absref $length $db\n";
  print "$new_segment\n";
  print @$tracks;
  my ($img,$junk) =  $BROWSER->render_panels({segment     => $new_segment,
					      -options      => \%$options,
					      labels      => \@$tracks,
					      -title       => "Genomic segment: $absref:$absstart..$absend",
					      -do_map      => 0,
					      #drag_n_drop => 0,
					     }); # && print "render_panels failed: $!\n";
  print "img is $img\n";
  print "junk is $junk\n";
  return;
  my ($img,$junk) = $BROWSER->render_panels({segment     => $new_segment,
					     options     => \%$options,
					     tracks      => $tracks,
					     title       => "Genomic segment: $absref:$absstart..$absend",
					     keystyle    => 'between',
					     do_map      => 0,
					     drag_n_drop => 0,
					    });

  $img =~ s|/Users/todd/Documents/projects/wormbase/website/trunk/root||g;
  $img =~ s/border="0"/border="1"/;
  $img =~ s/detailed view/browse region/g;
  $img =~ s/usemap=\S+//;
  
  my %data = (
	      img     => $img,
	      start   => $start,
	      stop    => $stop,
	      chromosome => $absref);
  return \%data;
}
