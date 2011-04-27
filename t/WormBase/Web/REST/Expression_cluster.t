# t/WormBase/Web/REST/Expression_cluster.t

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

my @object_names = qw(WBPaper00028788:MPK-1_Response_Strong
                      [cgc6390]:Cluster_F [cgc6390]:Cluster_C);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Expression_cluster'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
