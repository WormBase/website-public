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

my @object_names = qw(cenix:235-f12_T7 184904_at sjj_C06C6.4);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Pcr_oligo'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
