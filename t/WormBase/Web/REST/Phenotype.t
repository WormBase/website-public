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

my @test_objects = qw(WBPhenotype:00000061);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Phenotype'
});

$tester->check_all_widgets({objects => \@test_objects});

done_testing;
