# t/WormBase/Web/REST/Rnai.t

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

my @object_names = qw(WBRNAi00066492 WBRNAi00042161 WBRNAi00059855);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Rnai'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
