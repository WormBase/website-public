# t/WormBase/Web/REST/Pcr_oligo.t

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

my @object_names = qw(sjj_F13A2.8 sjj_Y51B9A.5
                      II_6008875 183610_at
                      sjj_VF39H2.1_b cenix:64-g9_T3);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Pcr_oligo'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
