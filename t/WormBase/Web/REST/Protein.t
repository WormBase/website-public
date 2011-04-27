# t/WormBase/Web/REST/Protein.t

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

my @object_names = qw(WBStructure000875 WP:CE23521 WP:CE17558);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Protein'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
