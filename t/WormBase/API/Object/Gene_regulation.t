# t/WormBase/API/Object/Gene_regulation.t

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

my @object_names = qw(cgc6355_sdc-1 WBPaper00028555_gld-1);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Gene_regulation',
}); # create API object, load class module, etc.

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1, # don't want to test parent methods
    exclude_roles_methods   => 1, # don't want to test role methods
});

done_testing;
