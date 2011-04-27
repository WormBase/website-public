# t/WormBase/API/Object/Person.t

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
      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Person');
} # Person.t loads ok

my @object_names = qw(WBPerson323 WBPerson320 WBPerson1352);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Person',
});

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

done_testing;
