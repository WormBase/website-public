# t/WormBase/Web/REST/Position_matrix.t

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

my @object_names = qw(WBPmat00000054 WBPmat00000144 WBPmat00000145);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Position_matrix'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
