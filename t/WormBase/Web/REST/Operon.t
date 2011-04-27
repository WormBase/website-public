# t/WormBase/Web/REST/Operon.t

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

my @object_names = qw(CEOP2736 CEOP4581 CEOP4252);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Operon'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
