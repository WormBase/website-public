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

my @test_objects = qw([WBPaper00002061]:dpy-27);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Antibody'
});

$tester->check_all_widgets({objects => \@test_objects});

done_testing;
