# t/WormBase/Web/REST/Picture.t

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

my @object_names = qw(F52C12.4_BC10278_GFP_l-2_1prjctn23.jpg
                      WBPicture0000007352 WBPicture0000007352);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Picture'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
