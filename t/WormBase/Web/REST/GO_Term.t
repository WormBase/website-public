# t/WormBase/Web/REST/Go_term.t

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

my @object_names = qw(GO:0023034 GO:0007268 GO:0005635);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Go_term'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
