# t/WormBase/Web/REST/Interaction.t

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

my @object_names = qw(WBInteraction0052389 WBInteraction0500107
                      WBInteraction0456416);

# load in sections of config
my $tester = WormBase::Test::Web::REST->new({
    conf_file => 'wormbase.conf',
    class     => 'Interaction'
});

$tester->check_all_widgets({names => \@object_names});

done_testing;
