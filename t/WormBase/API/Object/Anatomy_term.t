# t/WormBase/API/Object/Anatomy_term.t

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

my @object_names = qw(WBbt:0003639 WBbt:0003904);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Anatomy_term',
}); # create API object, load class module, etc.

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1, # don't want to test parent methods
    exclude_roles_methods   => 1, # don't want to test role methods
});

done_testing;

