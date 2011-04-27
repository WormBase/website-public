# t/WormBase/Web/REST/Microarray_results.t

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

my @object_names = qw(C37H5.4 183610_at Aff_C04H5.5);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Microarray_results'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
