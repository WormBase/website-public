# t/WormBase/Web/REST/Anatomy_term.t

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

my @object_names = qw(WBbt:0003639 WBbt:0003904 WBbtf0062);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Anatomy_term'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
