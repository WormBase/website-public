# t/WormBase/Web/REST/Sequence.t

use strict;
use warnings;

BEGIN {
    use FindBin '$Bin';
    chdir "$Bin/../../.."; # t/
    use lib 'lib';
    use lib '../lib';
}

use Test::More;
use WormBase::Test::Web::REST;

my @object_names = qw(embryo_him-8_20dC_post-L1_bundle_of_reads_supporting_SL1_IV_6632205_6632206_+_wb170
                      Y113G7B Y106G6H);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Sequence'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
