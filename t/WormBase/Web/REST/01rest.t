# t/WormBase/Web/REST/01rest.t
# draft

use strict;
use warnings;

BEGIN {
    use FindBin '$Bin';
    chdir "$Bin/../../.."; # t/
    use lib 'lib';
    use lib '../lib';
}

use Config::General;
use URI::URL;

use Test::More;
use WormBase::Test::Web; # for now; later my use ::REST

my $WIDGET_BASE = '/rest/widget';

# load in sections of config
my %config = Config::General->new(-ConfigFile => 'wormbase.conf')->getall;
my $sections = $config{sections} or die "Can't get sections from config file";

my $tester = WormBase::Test::Web->new;
my $mech = $tester->mech;

my $base_url = URI::URL->new($ENV{CATALYST_SERVER} || 'http://localhost/');

my $section;

my %seen;

#################
# species
#################

foreach my $type (qw(species resources)) {
    $section = $sections->{$type};

    while (my ($class, $class_hash) = each %$section) {
        my $uclass = ucfirst $class;
        my $obj = get_obj($uclass) or next; # object name

        subtest "All widgets ok for $obj $uclass" => sub {
            while (my ($widget, $widget_hash) = each %{$class_hash->{widgets}}) {
                my $url = "$WIDGET_BASE/$class/$obj/$widget";

                my $res = $mech->get($url);
                ok($res->is_success, "Got $url") or
                diag("GET $url -- ", $res->status_line);
            }
        };
    }
}

done_testing;

# hard code these for now
# it would be nice to have an API-level method for this
sub get_obj {
    my $class = shift;

    my %obj = (
        Variation => 'WBVar00143616',
        Paper     => 'WBPaper00000031',
    );

    return $obj{$class};
}
