# t/WormBase/Web/REST/GO_Term.t

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

my @object_names = qw(GO:0005635);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'GO_Term'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
