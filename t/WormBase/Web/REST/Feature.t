# t/WormBase/Web/REST/Feature.t

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

my @object_names = qw(WBsf013520 WBsf027925);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Feature'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
