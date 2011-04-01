# t/WormBase/API/Object/Transgene.t

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
      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Transgene');
} # Transgene.t loads ok

my @test_objects = qw(WBPaper00032201Ex1); # cgc4781Is1

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/test.conf',
    class     => 'Transgene',
});

$tester->run_common_tests({
    objects                 => \@test_objects,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

done_testing;
