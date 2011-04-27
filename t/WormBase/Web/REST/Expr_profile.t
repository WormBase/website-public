# t/WormBase/Web/REST/Expr_profile.t

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

my @object_names = qw(F30F8.2 Y77E11A_3443.F B0344.2);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Expr_profile'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
