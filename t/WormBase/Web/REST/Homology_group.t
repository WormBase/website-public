# t/WormBase/Web/REST/Homology_group.t

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

my @object_names = qw(OMpre_WH002352 KOG4475 TWOG0028);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Homology_group'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
