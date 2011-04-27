# t/WormBase/Web/REST/Antibody.t

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

my @object_names = qw([cgc4387]:hsp-16.2 [cgc1785]:skn-1_c
                      [WBPaper00002061]:dpy-27);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Antibody'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
