# t/WormBase/API/Object/Pcr_oligo.t

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

my @object_names = qw(sjj_VF39H2.1_b II_6008875
                      cenix:64-g9_T3 183610_at
                      II_6008875 183610_at
                      sjj_F13A2.8 sjj_Y51B9A.5);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Pcr_oligo',
}); # create API object, load class module, etc.

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1, # don't want to test parent methods
    exclude_roles_methods   => 1, # don't want to test role methods
});

done_testing;
