# t/WormBase/API/Object/Gene_class.t

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
      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Gene_class');
} # Gene_class.t loads ok

my @object_names = qw(ocs idf unc lev);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Gene_class',
});

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

done_testing;
