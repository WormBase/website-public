package WormBase::API::Service::rnaseq_plot;

use Moose;
with 'WormBase::API::Role::Object';

use strict;
use GD;
# use Getopt::Long;
use List::Util qw(max sum);
use File::Path qw(make_path);
use File::Spec::Functions qw(catfile catdir);
use Digest::MD5 qw(md5);
#use lib $ENV{CVS_DIR};

use namespace::autoclean -except => 'meta';

has 'plot_dir_base' => (
    is          => 'ro',
    default     => sub {
      return catdir(WormBase::Web->config->{shared_content_dir},
                    WormBase::Web->config->{rnaseq_plot_url_suffix});
    },
);

has 'display_suffix' => (
    is          => 'ro',
    default     => sub {
      return WormBase::Web->config->{rnaseq_plot_url_suffix};
    },
);

has 'number_subdirs' => (
    is          => 'ro',
    default     => sub {
      return WormBase::Web->config->{rnaseq_n_subdir};
    },
);

sub subdir_out_path {
    my ($self, $filekey) = @_;
    my $subdir_path = catdir($self->plot_dir_base, $self->_get_subdir($filekey));

    my $umask_old = umask '007'; #relax owner and group permission
    make_path($subdir_path, { mode => 0777 });
    umask $umask_old;
    return $subdir_path;
}

sub subdir_display_path {
    my ($self, $filekey) = @_;
    my $subdir_path = catdir($self->display_suffix, $self->_get_subdir($filekey));
    return $subdir_path;
}

# If sub-dir usage is configured to spread image files over multiple directories
sub _get_subdir {
    my ($self, $filekey) = @_;
    my $subdir;

    if ($self->number_subdirs) {
        $subdir = unpack('L', md5($filekey)) % $self->number_subdirs;
    }else{
        $subdir = '';
    }

    return $subdir;
}


# The embryo times
# mapping the EE_50-* life stages to WBls terms
# Remark "Library 'EE_50-0' Illumina sequencing of C. elegans N2 early
# embryo EE_50-0 polyA+ RNAseq random fragment library Make eggs hatch
# in the absence of food to get them all in L1 arrest add food and wait
# 50 hours. Eggs are then harvested from the adults -- just a few have
# an egg or two. Then the eggs are incubated for 0 to 720
# minutes. Synchronization was only approximate with a distribution of
# embryo ages. Sample may include multiple embryonic stages since
# mothers maintain eggs until the 30-cell stage leaving a possible 150
# minute range of ages (in this case 0-150m post-fertilization or -40 to
# 110 mins post-cleavage)."
#  knock off 40 mins and add 110 mins to get the range of ages post cleavage (used by WormBase)
#  add 150 to get the range post fertilization
#  My approximate mapping table from EE_50 time to WB life stage
# EE_50 time   range    approximate life-stage
# 0     -40-110   WBls:0000004
# 30    -10-140   WBls:0000004
# 60    20-170    WBls:0000004
# 90    50-200   WBls:0000004
# 120   80-270   WBls:0000010
# 150   110-300  WBls:0000010
# 180   140-290  WBls:0000010
# 210   170-320  WBls:0000013
# 240   200-350  WBls:0000013
# 270   230-380  WBls:0000014
# 300   260-410  WBls:0000014
# 330   290-440  WBls:0000014
# 360   320-470  WBls:0000014
# 390   350-500  WBls:0000015
# 420   380-530  WBls:0000015
# 450   410-560  WBls:0000015
# 480   440-590  WBls:0000015
# 510   470-620  WBls:0000015
# 540   500-650  WBls:0000020
# 570   530-680  WBls:0000020
# 600   560-710  WBls:0000020
# 630   590-740  WBls:0000021
# 660   620-770  WBls:0000021
# 690   650-800  WBls:0000021
# 720   680-830  WBls:0000021
#  life stage    time post cleavage
# WBls:0000004 = 0-350min        proliferating embryo Ce
# WBls:0000010 = 100-290min      gastrulating embryo Ce
# WBls:0000013 = 290-350min      enclosing embryo Ce
# WBls:0000014 = 210-350min      late cleavage stage embryo Ce
# WBls:0000015 = 350-620min      elongating embryo Ce
# WBls:0000019 = 460-520min      2-fold embryo Ce
# WBls:0000020 = 520-620min      3-fold embryo Ce
# WBls:0000021 = 620-800min      fully-elongated embryo Ce
# Embryo
# WBls:0000003
# embryo Ce
# 4 cell embryo
# WBls:0000008

my @etimes = (
	      "0",
	      "30",
	      "60",
	      "90",
	      "120",
	      "150",
	      "180",
	      "210",
	      "240",
	      "270",
	      "300",
	      "330",
	      "360",
	      "390",
	      "420",
	      "450", # e.g. SRX1022654 "embryo sampled at 450 minutes"
	      "480",
	      "510",
	      "540",
	      "570",
	      "600",
	      "660",
	      "690",
	      "720",
	    );

# The classical time points;
my @ctimes = (
	      "EE",
	      "LE",
	      "L1",
	      "L2",
	      "L3",
	      "L4",
	      "YA",
	      "Dauer entry",
	      "Dauer",
	      "Dauer exit",
	      "Male L4",
	      "Soma L4"
	     );


# the RNASeq SRP000401 experiments - excluding tissue-specific ones, and ribomins ones and mutants and anything else Julie doesn't like
my %experiments = (
		 SRX092477 => ['0','polyA', 'N2_EE_50-0'],
		 SRX092478 => ['0','polyA', 'N2_EE_50-0'],
		 SRX099902 => ['0','polyA', 'N2_EE_50-0'],
		 SRX099901 => ['0','polyA', 'N2_EE_50-0'],
		 SRX103649 => ['0','polyA', 'N2_EE_50-0'],
		 SRX1022600 => ['0','ribozero', '20120411_EMB-0'],
		 SRX1020637 => ['0','ribozero', '20120223_EMB-0'],
		 SRX1020636 => ['0','ribozero', '20120223_EMB-0'],

		 SRX092371 => ['30','polyA', 'N2_EE_50-30'],
		 SRX092372 => ['30','polyA', 'N2_EE_50-30'],
		 SRX099908 => ['30','polyA', 'N2_EE_50-30'],
		 SRX099907 => ['30','polyA', 'N2_EE_50-30'],
		 SRX103650 => ['30','polyA', 'N2_EE_50-30'],
		 SRX1020634 => ['30','ribozero', '20120223_EMB-30'],
		 SRX1022610 => ['30','ribozero', '20120419_EMB-30'],
		 SRX1020635 => ['30','ribozero', '20120223_EMB-30'],

		 SRX085112 => ['60','polyA', 'N2_EE_50-60'],
		 SRX085111 => ['60','polyA', 'N2_EE_50-60'],
		 SRX1022599 => ['60','ribozero', '20120411_EMB-60'],
		 SRX1020638 => ['60','ribozero', '20120223_EMB-60'],
		 SRX1020639 => ['60','ribozero', '20120223_EMB-60'],

		 SRX092480 => ['90','polyA', 'N2_EE_50-90'],
		 SRX092479 => ['90','polyA', 'N2_EE_50-90'],
		 SRX099915 => ['90','polyA', 'N2_EE_50-90'],
		 SRX103651 => ['90','polyA', 'N2_EE_50-90'],
		 SRX1022605 => ['90','ribozero', '20120411_EMB-90'],
		 SRX1020640 => ['90','ribozero', '20120223_EMB-90'],
		 SRX1020641 => ['90','ribozero', '20120223_EMB-90'],
		 SRX1022611 => ['90','ribozero', '20120419_EMB-90'],

		 SRX085217 => ['120','polyA', 'N2_EE_50-120'],
		 SRX085218 => ['120','polyA', 'N2_EE_50-120'],
		 SRX1022602 => ['120','ribozero', '20120411_EMB-120'],
		 SRX1022645 => ['120','ribozero', '20120419_EMB-120'],
		 SRX1020630 => ['120','ribozero', '20120223_EMB-120'],
		 SRX1020631 => ['120','ribozero', '20120223_EMB-120'],

		 SRX099995 => ['150','polyA', 'N2_EE_50-150'],
		 SRX1022601 => ['150','ribozero', '20120411_EMB-150'],
		 SRX1020632 => ['150','ribozero', '20120223_EMB-150'],
		 SRX1020633 => ['150','ribozero', '20120223_EMB-150'],
		 SRX1022646 => ['150','ribozero', '20120419_EMB-150'],

		 SRX099985 => ['180','polyA', 'N2_EE_50-180'],
		 SRX1022603 => ['180','ribozero', '20120411_EMB-180'],
		 SRX1022584 => ['180','ribozero', '20120223_EMB-180'],
		 SRX1022585 => ['180','ribozero', '20120223_EMB-180'],
		 SRX1022647 => ['180','ribozero', '20120419_EMB-180'],

		 SRX099996 => ['210','polyA', 'N2_EE_50-210'],
		 SRX099997 => ['210','polyA', 'N2_EE_50-210'],
		 SRX099998 => ['210','polyA', 'N2_EE_50-210'],
		 SRX103652 => ['210','polyA', 'N2_EE_50-210'],
		 SRX1022570 => ['210','ribozero', '20120223_EMB-210'],
		 SRX1022571 => ['210','ribozero', '20120223_EMB-210'],

		 SRX099986 => ['240','polyA', 'N2_EE_50-240'],
		 SRX099987 => ['240','polyA', 'N2_EE_50-240'],
		 SRX103653 => ['240','polyA', 'N2_EE_50-240'],
		 SRX1022604 => ['240','ribozero', '20120411_EMB-240'],
		 SRX1022566 => ['240','ribozero', '20120223_EMB-240'],
		 SRX1022567 => ['240','ribozero', '20120223_EMB-240'],
		 SRX1022648 => ['240','ribozero', '20120419_EMB-240'],

		 SRX099999 => ['270','polyA', 'N2_EE_50-270'],
		 SRX100000 => ['270','polyA', 'N2_EE_50-270'],
		 SRX100001 => ['270','polyA', 'N2_EE_50-270'],
		 SRX103677 => ['270','polyA', 'N2_EE_50-270'],
		 SRX1022568 => ['270','ribozero', '20120223_EMB-270'],
		 SRX1022569 => ['270','ribozero', '20120223_EMB-270'],
		 SRX1022649 => ['270','ribozero', '20120419_EMB-270'],

		 SRX100819 => ['300','polyA', 'N2_EE_50-300'],
		 SRX1022580 => ['300','ribozero', '20120223_EMB-300'],
		 SRX1022581 => ['300','ribozero', '20120223_EMB-300'],
		 SRX1022608 => ['300','ribozero', '20120411_EMB-300'],
		 SRX1022650 => ['300','ribozero', '20120419_EMB-300'],

		 SRX099980 => ['330','polyA', 'N2_EE_50-330'],
		 SRX1022572 => ['330','ribozero', '20120223_EMB-330'],
		 SRX1022573 => ['330','ribozero', '20120223_EMB-330'],
		 SRX1022651 => ['330','ribozero', '20120419_EMB-330'],

		 SRX099981 => ['360','polyA', 'N2_EE_50-360'],
		 SRX1022574 => ['360','ribozero', '20120223_EMB-360'],
		 SRX1022575 => ['360','ribozero', '20120223_EMB-360'],
		 SRX1022607 => ['360','ribozero', '20120411_EMB-360'],
		 SRX1022652 => ['360','ribozero', '20120419_EMB-360'],

		 SRX099982 => ['390','polyA', 'N2_EE_50-390'],
		 SRX099983 => ['390','polyA', 'N2_EE_50-390'],
		 SRX1022576 => ['390','ribozero', '20120223_EMB-390'],
		 SRX1022577 => ['390','ribozero', '20120223_EMB-390'],

		 SRX099984 => ['420','polyA', 'N2_EE_50-420'],
		 SRX1022578 => ['420','ribozero', '20120223_EMB-420'],
		 SRX1022579 => ['420','ribozero', '20120223_EMB-420'],
		 SRX1022653 => ['420','ribozero', '20120419_EMB-420'],

		 SRX100002 => ['450','polyA', 'N2_EE_50-450'],
		 SRX1022582 => ['450','ribozero', '20120223_EMB-450'],
		 SRX1022583 => ['450','ribozero', '20120223_EMB-450'],
		 SRX1022654 => ['450','ribozero', '20120419_EMB-450'],

		 SRX099988 => ['480','polyA', 'N2_EE_50-480'],
		 SRX099989 => ['480','polyA', 'N2_EE_50-480'],
		 SRX099990 => ['480','polyA', 'N2_EE_50-480'],
		 SRX103672 => ['480','polyA', 'N2_EE_50-480'],
		 SRX1022586 => ['480','ribozero', '20120223_EMB-480'],
		 SRX1022587 => ['480','ribozero', '20120223_EMB-480'],

		 SRX100003 => ['510','polyA', 'N2_EE_50-510'],
		 SRX100004 => ['510','polyA', 'N2_EE_50-510'],
		 SRX100005 => ['510','polyA', 'N2_EE_50-510'],
		 SRX103673 => ['510','polyA', 'N2_EE_50-510'],
		 SRX1022588 => ['510','ribozero', '20120223_EMB-510'],
		 SRX1022589 => ['510','ribozero', '20120223_EMB-510'],

		 SRX099991 => ['540','polyA', 'N2_EE_50-540'],
		 SRX099992 => ['540','polyA', 'N2_EE_50-540'],
		 SRX099993 => ['540','polyA', 'N2_EE_50-540'],
		 SRX103669 => ['540','polyA', 'N2_EE_50-540'],
		 SRX1022592 => ['540','ribozero', '20120223_EMB-540'],
		 SRX1022593 => ['540','ribozero', '20120223_EMB-540'],

		 SRX099973 => ['570','polyA', 'N2_EE_50-570'],
		 SRX099974 => ['570','polyA', 'N2_EE_50-570'],
		 SRX103671 => ['570','polyA', 'N2_EE_50-570'],
		 SRX1022597 => ['570','ribozero', '20120223_EMB-570'],
		 SRX1022598 => ['570','ribozero', '20120223_EMB-570'],

		 SRX099975 => ['600','polyA', 'N2_EE_50-600'],
		 SRX099976 => ['600','polyA', 'N2_EE_50-600'],
		 SRX099977 => ['600','polyA', 'N2_EE_50-600'],
		 SRX103670 => ['600','polyA', 'N2_EE_50-600'],
		 SRX1022596 => ['600','ribozero', '20120223_EMB-600'],
		 SRX1022595 => ['600','ribozero', '20120223_EMB-600'],
		 SRX1022609 => ['600','ribozero', '20120411_EMB-600'],

		 SRX099978 => ['630','polyA', 'N2_EE_50-630'],

		 SRX099979 => ['660','polyA', 'N2_EE_50-660'],

		 SRX099994 => ['690','polyA', 'N2_EE_50-690'],

		 SRX100006 => ['720','polyA', 'N2_EE_50-720'],

		 SRX004863 => ['EE','polyA', 'EE_ce0128_rw005'],
		 SRX004864 => ['EE','polyA', 'EE_ce1003_rw005'],
		 SRX037186 => ['EE','polyA', 'N2_EE-2'],
		 SRX004866 => ['EE','polyA', 'EE_ce0129_rw006'], # checked with LaDeana - she says this is an early embryo
		 SRX145660 => ['EE','ribozero', 'N2_EE_RZ-54'],
		 SRX190369 => ['EE','ribozero', 'N2_EE_RZ-54'],

		 SRX004865 => ['LE','polyA', 'LE_ce0129_rw006'],
		 SRX047446 => ['LE','polyA', 'N2_LE-1'],

		 SRX004867 => ['L1','polyA', 'L1_ce0132_rw007'], # fastq files downloaded again because they were in an odd format - all ok now
		 SRX037288 => ['L1','polyA', 'N2_L1-1'],

		 SRX001872 => ['L2','polyA', 'L2_ce0109_rw001'],
		 SRX047653 => ['L2','polyA', 'N2_L2-4'],
		 SRX190370 => ['L2','ribozero', 'N2_L2_RZ-53'],
		 SRX145661 => ['L2','ribozero', 'N2_L2_RZ-53'],

		 SRX001875 => ['L3','polyA', 'L3_ce0120_rw002'],
		 SRX036881 => ['L3','polyA', 'N2_L3-1'],

		 SRX008144 => ['L4','polyA', 'L4_ce1009_rw1001'],
		 SRX001874 => ['L4','polyA', 'L4_ce0121_rw003'],

		 SRX001873 => ['YA','polyA', 'YA_ce0122_rw004'],
		 SRX047787 => ['YA','polyA', 'N2_Yad-1'],
		 SRX103986 => ['YA','ribozero', 'N2_YA_RZ-1'],
		 SRX103987 => ['YA','ribozero', 'N2_YA_RZ-1'],
		 SRX103988 => ['YA','ribozero', 'N2_YA_RZ-1'],
		 SRX103989 => ['YA','ribozero', 'N2_YA_RZ-1'],

		 SRX011569 => ['Male EM','polyA', 'EmMalesHIM8_ce1005_rw1001'],
		 SRX037198 => ['Male EM','polyA', 'EmMalesHIM8-2'],

		 SRX004868 => ['Male L4','polyA', 'L4_ce1001_rw1001'],
		 SRX047469 => ['Male L4','polyA', 'L4MALE5'],

		 SRX014010 => ['Soma L4','polyA', 'L4JK1107soma_ce1014_rw1001'],
		 SRX037200 => ['Soma L4','polyA', 'L4JK1107soma-2'],

		 SRX008139 => ['Dauer entry','polyA', 'DauerEntryDAF2_ce1007_rw1001'],
		 SRX047470 => ['Dauer entry','polyA', 'DauerEntryDAF2-2'],
		 SRX103273 => ['Dauer entry','polyA', 'DauerEntryDAF2-1-1'],
		 SRX103274 => ['Dauer entry','polyA', 'DauerEntryDAF2-1-1'],
		 SRX103275 => ['Dauer entry','polyA', 'DauerEntryDAF2-1-1'],
		 SRX103276 => ['Dauer entry','polyA', 'DauerEntryDAF2-1-1'],
		 SRX103277 => ['Dauer entry','polyA', 'DauerEntryDAF2-4-1'],

		 SRX008138 => ['Dauer','polyA', 'DauerDAF2_ce1006_rw1001'],
		 SRX103983 => ['Dauer','polyA', 'DauerDAF2-2-1'],
		 SRX103984 => ['Dauer','polyA', 'DauerDAF2-2'],
		 SRX103985 => ['Dauer','polyA', 'DauerDAF2-5-1'],

		 SRX008140 => ['Dauer exit','polyA', 'DauerExitDAF2_ce1008_rw1001'],
		 SRX037199 => ['Dauer exit','polyA', 'DauerExitDAF2-2'],
		 SRX103269 => ['Dauer exit','polyA', 'DauerExitDAF2-3-1'],
		 SRX103270 => ['Dauer exit','polyA', 'DauerExitDAF2-3-1'],
		 SRX103271 => ['Dauer exit','polyA', 'DauerExitDAF2-3-1'],
		 SRX103272 => ['Dauer exit','polyA', 'DauerExitDAF2-3-1'],
		 SRX103278 => ['Dauer exit','polyA', 'DauerExitDAF2-6-1'],
		 SRX103281 => ['Dauer exit','polyA', 'DauerExitDAF2-6-1'],
		 SRX103280 => ['Dauer exit','polyA', 'DauerExitDAF2-6-1'],
		 SRX103279 => ['Dauer exit','polyA', 'DauerExitDAF2-6-1'],

		);

my %libraries;
foreach my $experiment (keys %experiments) {
  my ($stage, $type, $library) = @{$experiments{$experiment}};
  if (! exists $libraries{$library}) {
    push @{$libraries{$library}}, ($stage, $type);
  }
}



##################################

sub draw_graph {
  my ($self, $type, $data, $name, $gene_id) = @_;

  # type of ace object - 'gene', 'cds', 'trans', 'pseud'
  # ref to hash of data points to plot, keyed by library name
  # title = name to display at top or ''
  # gene_id

  # graph data
  my $points = 2; # points width
  my $histogram = 8; # wistogram bar width
  my $male = 1;
  my $soma_L4 = 1;
  my $dauer = 1;
  my $mean_or_median = 0;

  my $pad = 10; # 10 pixels pad space around graph and just above x-axis
  my $title_row_height = 30; # space for the title
  my $x_axis_space = 50; # height taken up by the x-axis
  my $y_axis_space = 50; # width taken up by the y-axis
  my $axis_thickness = 3; # width of axis lines

  # get height of image
  my $max_FPKM = max(values %{$data}); # maximum y-axis data FPKM value in this gene
  my $max_y; # max FPKM y axis value for graphs to have comparable sizes - maximum y value label

  # the y-axis scales we use
  my @y_sizes = (10, 15, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000, 15000, 20000, 30000, 40000, 50000, 75000, 100000, 150000, 200000, 300000, 400000, 500000, 750000, 1000000, 1500000, 2000000, 3000000, 4000000, 5000000, 7500000);
  foreach my $i (@y_sizes) {if ($max_FPKM <= $i) {$max_y = $i; last}}
  if (!defined $max_y) {die "max_y is not defined\n"}
  print "max_y = $max_y\n";
  my $column_height = 400; # largely determines the height of the image
  my $scale = $column_height / $max_y; # number of y-axis pixels per 1 data point
  my $img_height = $pad + $title_row_height + $column_height + $pad + $x_axis_space + $pad;

  # get width of image - the classical stages are displayed with 5 times the width of the embryonic time series
  # we have several potential parts of the x-axis:
  # embryonic time series 0-720 minutes
  # classical stages (EE, LE, L1-4, YA)
  # Male EM, L4 stage
  # Soma
  # Dauer entry/exit = optional dauer stages
  my $graph_separation = 20; # distance between any two graphs
  my $column_data_width = $histogram ? $histogram : 8;
  my $column_separator = 4;
  my $column_width = $column_separator + $column_data_width;
  my $no_embryo_cols = 25; # 4-cell to 720 mins
  my $classical_multiplier = 4; # have the classical stages 4 times the width of the embronic time series
  my $no_classic_stage_cols = 5;
  # start and end positions of the x-axis sections
  my $embryo_series_start;
  my $embryo_series_end;
  my $embryo_start;
  my $embryo_end;
  my $classic_stages_start;
  my $classic_stages_end;
  my $dauer_start;
  my $dauer_end;
  my $soma_start;
  my $soma_end;
  my $male_start;
  my $male_end;
  my $x_axis_start = $pad + $y_axis_space + $pad; # overall start and end
  my $x_axis_end = $x_axis_start;

  $embryo_series_start = $x_axis_end; $embryo_series_end = $embryo_series_start + ($column_width * 25); $x_axis_end = $embryo_series_end + $graph_separation;
  $classic_stages_start = $x_axis_end; $classic_stages_end = $classic_stages_start + ($column_width * $classical_multiplier * 7); $x_axis_end = $classic_stages_end + $graph_separation;
  if ($male) {$male_start = $x_axis_end; $male_end = $male_start + ($column_width * $classical_multiplier * 2); $x_axis_end = $male_end + $graph_separation}
  if ($soma_L4) {$soma_start = $x_axis_end; $soma_end = $soma_start + ($column_width * $classical_multiplier); $x_axis_end = $soma_end + $graph_separation}
  if ($dauer) {$dauer_start = $x_axis_end; $dauer_end = $dauer_start + ($column_width * $classical_multiplier * 3); $x_axis_end = $dauer_end + $graph_separation}

  my $img_width = $x_axis_end + $pad;

  # image and colours
  my $img = GD::Image->newTrueColor($img_width, $img_height);
  my $white = $img->colorAllocate(255, 255, 255);
  my $black = $img->colorAllocate(0,0,0);
  my $blue = $img->colorAllocate(0,0,255);
  my $red = $img->colorAllocate(255, 0, 0);
  my $pale_green = $img->colorAllocate(0, 128, 0);
  my $bright_green = $img->colorAllocate(0, 255, 0);
  my $green = $img->colorAllocate(32, 204, 32);
  my $grey= $img->colorAllocate(204, 204, 204);

  #$img->transparent($white);
  $img->filledRectangle(0,0,$img_width-1,$img_height-1, $white);
  $img->interlaced('true');

  # boundary
  $img->rectangle(0,0,$img_width-1,$img_height-1, $grey);

  # title
  my $desc = "$type '$name'   polyA+ = green, ribozero = blue";
  $img->string(gdLargeFont, $pad, $pad, $desc, $black); # 16 pixels high

  # y axis
  $img->setThickness($axis_thickness);
  my $y_axis_x = $pad + $y_axis_space;
  my $y_axis_y = $pad + $title_row_height + $column_height; # y end of y axis
  $img->line($y_axis_x, $pad + $title_row_height, $y_axis_x, $y_axis_y, $black);

  # y axis labels
  my $font_width = gdMediumBoldFont->width;
  my $font_height = gdMediumBoldFont->height;
  $img->setThickness(1);
  for (my $number=0; $number <= $max_y; $number += $max_y / 5 ) {
    my $label = sprintf("%5d", $number);
#    my $label = sprintf("%.5g", $number); # if we use a scale that can be < 1.0 then this might be better
    my $label_y = $y_axis_y - ($number * $scale) - ($font_height / 2);
    my $label_x = $y_axis_x - ($font_width * 5) - ($font_width / 2); # allowing for a maximum label length of 5 characters and add a little space at the end
    $img->string(gdMediumBoldFont, $label_x, $label_y, $label, $black);
    # guide line
    my $guide_y = $y_axis_y - ($number * $scale);
    $img->line($pad + $y_axis_space + 2, $guide_y, $x_axis_end, $guide_y, $grey) # start just after the y-axis line, so +2
  }
  my $label_x = $pad;
  my $label_y =  ($y_axis_y / 2) + ($font_width * 8); # put label halfway up y axis
  $img->stringUp(gdMediumBoldFont, $label_x, $label_y, 'Expression (FPKM)', $black);

  # x axis
  $img->setThickness($axis_thickness);
  my $x_axis_y = $pad + $title_row_height + $column_height + $pad; # y end of x axis plus a small space


  # x axis sections

  my %x_position;

  $img->line($embryo_series_start, $x_axis_y, $embryo_series_end, $x_axis_y, $black);
  $img->line($embryo_series_start, $x_axis_y-2, $embryo_series_start, $x_axis_y+2, $black); # end-tick
  $img->line($embryo_series_end, $x_axis_y-2, $embryo_series_end, $x_axis_y+2, $black); # end-tick

  my $embryo_x_length = $embryo_series_end - $embryo_series_start;
  my $embryo_x_scale = $embryo_x_length / 800;
  $label_x = $embryo_series_start;
  $label_y = $x_axis_y + ($font_height / 2); # allow half a character's height space above the label
  foreach my $label ('0', '200', '400', '600', '800') {
    my $full_length = (length $label) * $font_width;
    my $half_length = $full_length / 2;
    $img->string(gdMediumBoldFont, $label_x - $half_length +2 , $label_y, $label, $black); # small adjustment to get the label displayed nicely centred
    $img->line($label_x, $x_axis_y, $label_x, $x_axis_y+3, $black); # tick
    $label_x += $embryo_x_scale * 200;
  }
  # label
  my $label = 'Embryo time (mins)';
  $label_x = $embryo_series_start  + ($embryo_x_length/2) - ((length $label) * $font_width)/2; # centre the label
  $img->string(gdMediumBoldFont, $label_x, $x_axis_y + $font_height*2, $label, $black);

  # get positions for points
  foreach my $t (@etimes) {
    my $offset = $embryo_x_scale * $t;
    $x_position{$t} = $embryo_series_start + $offset;
  }


  # classic stages
  $img->line($classic_stages_start, $x_axis_y, $classic_stages_end, $x_axis_y, $black);
  $img->line($classic_stages_start, $x_axis_y-2, $classic_stages_start, $x_axis_y+2, $black); # end-tick
  $img->line($classic_stages_end, $x_axis_y-2, $classic_stages_end, $x_axis_y+2, $black); # end-tick
  my $offset = ($column_width * $classical_multiplier)/2;
  $x_position{'EE'} = $classic_stages_start + $offset;
  $x_position{'LE'} = $x_position{'EE'} + ($column_width * $classical_multiplier);
  $x_position{'L1'} = $x_position{'LE'} + ($column_width * $classical_multiplier);
  $x_position{'L2'} = $x_position{'L1'} + ($column_width * $classical_multiplier);
  $x_position{'L3'} = $x_position{'L2'} + ($column_width * $classical_multiplier);
  $x_position{'L4'} = $x_position{'L3'} + ($column_width * $classical_multiplier);
  $x_position{'YA'} = $x_position{'L4'} + ($column_width * $classical_multiplier);
  foreach my $label ('EE','LE','L1','L2','L3','L4','YA') {
    my $full_length = (length $label) * $font_width;
    my $half_length = $full_length / 2;
    $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y, $label, $black); # small adjustment to get the label displayed nicely centred
  }

  if ($male) {
    $img->line($male_start, $x_axis_y, $male_end, $x_axis_y, $black);
    $img->line($male_start, $x_axis_y-2, $male_start, $x_axis_y+2, $black); # end-tick
    $img->line($male_end, $x_axis_y-2, $male_end, $x_axis_y+2, $black); # end-tick
    my $offset = ($column_width * $classical_multiplier)/2;
    $x_position{'Male EM'} = $male_start + $offset;
    $x_position{'Male L4'} = $x_position{'Male EM'} + ($column_width * $classical_multiplier);
    foreach my $label ('Male EM','Male L4') {
      my $full_length = (length 'Male') * $font_width;
      my $half_length = $full_length / 2;
      $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y, 'Male', $black); # small adjustment to get the label displayed nicely centred

      $full_length = (length 'him-8') * $font_width;
      $half_length = $full_length / 2;
      $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y + $font_height, 'him-8', $black); # small adjustment to get the label displayed nicely centred

      my ($label2) = ($label =~ /\S+\s(\S+)/);
      if (! defined $label2) {$label2 = ''}
      $full_length = (length $label2) * $font_width;
      $half_length = $full_length / 2;
      $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y + ($font_height*2), $label2, $black); # small adjustment to get the label displayed nicely centred
    }
  }


  if ($soma_L4) {
    $img->line($soma_start, $x_axis_y, $soma_end, $x_axis_y, $black);
    $img->line($soma_start, $x_axis_y-2, $soma_start, $x_axis_y+2, $black); # end-tick
    $img->line($soma_end, $x_axis_y-2, $soma_end, $x_axis_y+2, $black); # end-tick
    my $offset = ($column_width * $classical_multiplier)/2;
    $x_position{'Soma L4'} = $soma_start + $offset;
    my $label = 'Soma L4';
    my $full_length = (length $label) * $font_width;
    my $half_length = $full_length / 2;
    $img->string(gdMediumBoldFont, $x_position{'Soma L4'} - $half_length +2 , $label_y, $label, $black); # small adjustment to get the label displayed nicely centred
  }


 if ($dauer) {
    $img->line($dauer_start, $x_axis_y, $dauer_end, $x_axis_y, $black);
    $img->line($dauer_start, $x_axis_y-2, $dauer_start, $x_axis_y+2, $black); # end-tick
    $img->line($dauer_end, $x_axis_y-2, $dauer_end, $x_axis_y+2, $black); # end-tick
    my $offset = ($column_width * $classical_multiplier)/2;
    $x_position{'Dauer entry'} = $dauer_start + $offset;
    $x_position{'Dauer'} = $x_position{'Dauer entry'} + ($column_width * $classical_multiplier);
    $x_position{'Dauer exit'} = $x_position{'Dauer'} + ($column_width * $classical_multiplier);
    foreach my $label ('Dauer entry','Dauer','Dauer exit') {
      my $full_length = (length 'Dauer') * $font_width;
      my $half_length = $full_length / 2;
      $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y, 'Dauer', $black); # small adjustment to get the label displayed nicely centred
      my ($label2) = ($label =~ /\S+\s(\S+)/);
      if (! defined $label2) {$label2 = ''}
      $full_length = (length $label2) * $font_width;
      $half_length = $full_length / 2;
      $img->string(gdMediumBoldFont, $x_position{$label} - $half_length +2 , $label_y + $font_height, $label2, $black); # small adjustment to get the label displayed nicely centred
    }
  }



  # get values by stage
  my %stages;
  foreach my $library (keys %{$data}) {
    my $fpkm_value = $data->{$library};
    my ($stage, $type) = @{$libraries{$library}};
    #print "$library $stage, $type\n";
    push @{$stages{$stage}}, [$fpkm_value, $type];
  }


  # make histograms
  my %mid_x_points; # x position of the middle x position of each stage
  foreach my $stage (keys %stages) {
    my @flist;
    my $median;
    my $mean;
    foreach my $value (@{$stages{$stage}}) {
      my ($fpkm, $type) = @{$value};
      push @flist, $fpkm;
    }
    $median = median(@flist);
    $mean = mean(@flist);
    my $histogram_top;
    if ($mean_or_median) {
      $histogram_top = $y_axis_y-($mean * $scale);
    } else {
      $histogram_top = $y_axis_y-($median * $scale);
    }
    my $x_pos; # middle of histogram bar
    my $stage_histo_width = $histogram*$classical_multiplier; # histogram width of stages except for the embryo time series
    my $x_offset = ($column_separator * $classical_multiplier) / 2; # slight indent to center the histogram in stages

    if ($dauer && ($stage =~ /^Dauer/)) {
      $x_pos = $dauer_start + $x_offset;
      if ($stage eq 'Dauer') {$x_pos += ($column_width*$classical_multiplier)}
      if ($stage eq 'Dauer exit') {$x_pos += ($column_width*$classical_multiplier*2)}
      $img->filledRectangle($x_pos, $y_axis_y, $x_pos+($stage_histo_width), $histogram_top, $grey);
      $mid_x_points{$stage} = $x_pos + ($stage_histo_width/2);
    } elsif ($soma_L4 && $stage eq 'Soma L4') {
      $x_pos = $soma_start + $x_offset;
      $img->filledRectangle($x_pos, $y_axis_y, $x_pos+($stage_histo_width), $histogram_top, $grey);
      $mid_x_points{$stage} = $x_pos + ($stage_histo_width/2);
    } elsif ($male && ($stage =~ /^Male/)) {
      $x_pos = $male_start + $x_offset;
      if ($stage eq 'Male L4') {$x_pos += ($column_width*$classical_multiplier)}
      $img->filledRectangle($x_pos, $y_axis_y, $x_pos+($stage_histo_width), $histogram_top, $grey);
      $mid_x_points{$stage} = $x_pos + ($stage_histo_width/2);
    } elsif ($stage =~ /^\d+$/) { # embryo time series
      $x_pos = $embryo_series_start + ($embryo_x_scale * $stage); # stage is the time in minutes
      $img->filledRectangle($x_pos, $y_axis_y, $x_pos+($histogram), $histogram_top, $grey);
      $mid_x_points{$stage} = $x_pos + ($histogram/2);
    } else { # classic stages
      $x_pos = $classic_stages_start + $x_offset; # EE
      if ($stage eq 'LE') {$x_pos += ($column_width*$classical_multiplier)}
      if ($stage eq 'L1') {$x_pos += ($column_width*$classical_multiplier*2)}
      if ($stage eq 'L2') {$x_pos += ($column_width*$classical_multiplier*3)}
      if ($stage eq 'L3') {$x_pos += ($column_width*$classical_multiplier*4)}
      if ($stage eq 'L4') {$x_pos += ($column_width*$classical_multiplier*5)}
      if ($stage eq 'YA') {$x_pos += ($column_width*$classical_multiplier*6)}
      $img->filledRectangle($x_pos, $y_axis_y, $x_pos+($stage_histo_width), $histogram_top, $grey);
      $mid_x_points{$stage} = $x_pos + ($stage_histo_width/2);
    }
    if (!defined $x_pos) {print "xpos not defined for $stage\n";}
  }



  # plot points
  # $y_axis_y is the zero position of the y axis
  # $scale is the number of y-axis pixels per 1 data point
  foreach my $library (keys %{$data}) {
    my $fpkm_value = $data->{$library};
    my ($stage, $type) = @{$libraries{$library}};
    my $x_pos = $mid_x_points{$stage};
    #print "$library $stage, $type\n";

    if (!defined $x_pos) {print "xpos really not defined for $stage\n";}

    my $y_pos = $y_axis_y - ($fpkm_value * $scale);

    if ($type eq 'polyA') { # +
      $img->line($x_pos-$points, $y_pos, $x_pos+$points, $y_pos, $green);
      $img->line($x_pos, $y_pos-$points, $x_pos, $y_pos+$points, $green);
    } else { # point
      $img->filledRectangle($x_pos-$points, $y_pos-$points, $x_pos+$points, $y_pos+$points, $blue);
    }
  }




  my $filename = "$name\_$type.png";
  my $outfile = catfile($self->subdir_out_path($gene_id), $filename);
  my $display_path = catfile($self->subdir_display_path($gene_id), $filename);

  my $old_umask = umask '007';  #relax owner and group permission
  open (P, ">$outfile") || die "can't open $outfile\n";
  binmode P;
  print P $img->png;
  close P;
  umask $old_umask;
  return $display_path;
}

############################################################################
# my ($name, %data) = get_gene_data($gene);
# Args: $gene - ace object of gene to process

sub get_gene_data {
  my ($self, $gene) = @_;

  my @CDS =  $gene->Corresponding_CDS;
  my @Transcript = $gene->Corresponding_transcript;
  my @Pseudogene = $gene->Corresponding_pseudogene;

  my %sources = (
      'Gene' => [$gene],
      'CDS' => \@CDS,
      'Transcript' => \@Transcript,
      'Pseudogene' => \@Pseudogene
  );

  my %data = ();
  foreach my $type (keys %sources){
      my ($d) = $self->get_data($type, @{ $sources{$type} });
      $data{$type} = $d;
  }

  return %data;
}

############################################################################
# my ($name, $data) = get_data('gene', $gene);
# Args: type of ace object - 'gene', 'cds', 'trans', 'pseud'
#       @objs - array of ace objects of gene to process
# Return: ref to hash (keyed by object name) of objects' expression values (hash keyed by library name containing FPKM values)
#

sub get_data {
  my ($self, $type, @objs) = @_;
  my %data;

  foreach my $obj (@objs) {
    my %objdata;
    my %data_by_library;
    my $dummy;
    my $name;

    if (lc($type) eq 'gene') {
      $name = $obj->Public_name->name;
    } else {
      $name = $obj->name;
    }

    my @FPKM = $obj->RNASeq_FPKM;
    my $prev_value = '';
#    print ">>>>>START $type $name\n";
    foreach my $F (@FPKM) {
      my $ace_text = $F->asAce;
      my @lines = split /\n/, $ace_text;
      foreach my $line (@lines) {
	chomp $line;
	$line =~ s/\t$//; # some lines end with a spurious TAB
	if ($line eq '') {next}
#	print "$line (prev=$prev_value)\n";
	# '11.8211	From_analysis	"RNASeq.elegans.N2.WBls:0000038.Hermaphrodite.WBbt:0007833.SRP035479.SRX435700"'
	my ($value, $analysis) = ($line =~ /(\S+)\s+\S+\s+(\S+)/);

	# '	From_analysis	"RNASeq.elegans.PS4730.WBls:0000038.Male.WBbt:0005062.SRP015688.SRX185680"'
	if (!defined $value || $value eq '') {
	  $value = 0; ($dummy, $analysis) = ($line =~ /(\S+)\s+(\S+)/);
	}
	# '""	""	"RNASeq.elegans.PS4730.WBls:0000038.Male.WBbt:0005062.SRP015688.SRX185663"'
	if ($value eq '""') {
	  $value = $prev_value;
	}

	$prev_value = $value;
	my ($srx) = ($analysis =~ /\.(\w+)"$/);
#	print "val=$value\tanal=$analysis\tprev=$prev_value\n";
	if (exists $experiments{$srx}) {
	  my ($stage, $type, $library) = @{$experiments{$srx}};
	  push @{$data_by_library{$library}}, $value;
	}
      }
    }

    # now get median value of technical replicates in each library
    foreach my $library (keys %data_by_library) {
      $objdata{$library} = median(@{$data_by_library{$library}});
    }

    $data{$name} = {%objdata};
  }

  return (\%data);
}
############################################################################
# return the median value of a list of values
sub median {

    my @vals = sort {$a <=> $b} @_;
    my $len = @vals;
    if($len%2) #odd?
    {
        return $vals[int($len/2)];
    }
    else #even
    {
        return ($vals[int($len/2)-1] + $vals[int($len/2)])/2;
    }
}
############################################################################
# return the mean value of a list of values
# this expects there to be some values in the input array!
sub mean {
  return sum(@_)/@_;
}
############################################################################

1;
