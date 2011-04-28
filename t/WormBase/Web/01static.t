# t/WormBase/Web/01app.t
# draft

# proof of concept for testing all static pages for proper linkage

use strict;
use warnings;

BEGIN {
    use FindBin '$Bin';
    chdir "$Bin/../.."; # /t
    use lib '../lib';
    use lib 'lib';

}

use Test::More;
use WormBase::Test::Web;
use WWW::Robot;

# these should be tested separately
my @DO_NOT_FOLLOW = (qr{^/rest/}o, qr{^/tools/tree}o);

my $VERBOSE = 0;
my $CHECK_EXTERNAL = 1; # use ENV?
my $MAX_LINKS_FOLLOWED = 1000;

################################################################################

my $tester = WormBase::Test::Web->new;
my $mech = $tester->mech;

my $robot = WWW::Robot->new(
    NAME             => 'WormBase Testing Robot',
    VERSION          => 0.1,
    EMAIL            => 'Adrian.Duong@oicr.on.ca', # choose one?
    CHECK_MIME_TYPES => 0, # this makes the robot fast!
    USERAGENT        => $mech,
);

$robot->setAttribute(TRAVERSAL => 'breadth'); # BFS

my @followed;

# setup robot
$robot->addHook('follow-url-test', sub { &check_external_url && &check_dnf_list });
$robot->addHook('invoke-on-followed-url', sub {
                    my ($robot, $hook_name, $url) = @_;
                    diag("Following: $url") if $VERBOSE;
                    push @followed, $url;
                });
$robot->addHook('invoke-after-get', sub {
                    my ($robot, $hook_name, $url, $response) = @_;
                    ok ($response->is_success, "GET $url")
                        or diag("$url -- ", $response->status_line);
                });

# safeguard against the robot going out of control
# the robot will not follow-through more than MAX_LINKS_FOLLOWED
$robot->addHook('continue-test', max_counted($MAX_LINKS_FOLLOWED));

$robot->run($tester->root_url); # start'er up!

if ($VERBOSE) {
    diag($_) foreach @followed;
}
diag("Total followed: ", scalar @followed);

done_testing;

################################################################################
# helper subs

# checks whether the URL is external to the test server
# if external, fetch the resource but do not allow the robot to follow it
# else let the robot fetch it
sub check_external_url {
    my ($robot, $hook_name, $url) = @_;

    diag("check_external_url: $url") if $VERBOSE;

    return unless $url->path; # is just a fragment...

    # follow if it's internal
    return 1 if ! $tester->is_external_url($url);

    # we now know that the link is external
    return unless $CHECK_EXTERNAL; # do we want to run checks?

    diag("FOLLOWING EXTERNAL: $url") if $VERBOSE;

    # check the link and but don't let the bot follow
    push @followed, $url; # pretend it followed though

    $mech->get_ok($url);
    return;
}

sub check_dnf_list {
    my ($robot, $hook_name, $url) = @_;

    my $path = $url->path;
    diag("check_do_not_follow path: $path") if $VERBOSE;

    foreach (@DO_NOT_FOLLOW) {
        if ($path =~ /$_/) {
            diag("IS ON DNF LIST") if $VERBOSE;
            return;
        }
    }
    return 1;
}

# counter sub generator
sub max_counted {
    my $max = shift;
    my $counter = 0;
    return sub {
        ++$counter < $max;
    }
}
