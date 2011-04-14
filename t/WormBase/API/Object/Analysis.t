# t/WormBase/API/Object/Analysis.t

use strict;
use warnings;

BEGIN {
      use FindBin '$Bin';
      chdir "$Bin/../../.."; # /t
      use lib 'lib';
      use lib '../lib';
}

use Test::More;
use WormBase::Test::API::Object;

BEGIN {
      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Analysis');
} # Analysis loads ok

my @test_objects = qw(TreeFam RNASeq_Hillier.dauer_daf-2);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Analysis',
});

$tester->run_common_tests({
    objects                 => \@test_objects,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

done_testing;
