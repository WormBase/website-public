# t/WormBase/Web/REST/Life_stage.t

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

my @object_names = ('L3 larva male', 'L2 larva', 'L3 larva');

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Life_stage'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
