# t/WormBase/Web/REST/Phenotype.t

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

my @object_names = qw(WBPhenotype:000040 WBPhenotype:0000643
                      WBPhenotype:00000061);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Phenotype'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
