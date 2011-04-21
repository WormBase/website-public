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

my $CHECK_EXTERNAL = 1;

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

#my $default_hook = sub { print join('|', @_), "\n"; return 1;};

my $base_url = URI::URL->new($ENV{CATALYST_SERVER} || 'http://localhost/');

my @followed;

# setup robot

# check external URLs but don't follow them
$robot->addHook('follow-url-test', \&check_external_url);
$robot->addHook('invoke-on-followed-url', sub {
                    my ($robot, $hook_name, $url) = @_;
                    diag("Following: $url");
                    push @followed, $url;
                });
$robot->addHook('invoke-after-get', sub {
                    my ($robot, $hook_name, $url, $response) = @_;
                    ok ($response->is_success, "Got $url successfully")
                        or diag("$url -- ", $response->status_line);
                });

# don't let the robot go out of control
$robot->addHook('continue-test', robot_under_control(1000));

$robot->run($base_url); # start'er up!

diag("Total followed: ", scalar @followed);
diag($_) foreach @followed;

done_testing;

################################################################################


sub is_same_domain {
    my ($url1, $url2) = @_;
    my $hp1 = $url1->can('host_port') ? $url1->host_port : '';
    my $hp2 = $url2->can('host_port') ? $url2->host_port : '';
    return $hp1 eq $hp2;
}

sub robot_under_control {
    my $max = shift;
    my $counter = 0;
    return sub {
        ++$counter < $max;
    }
}

sub check_external_url {
    my ($robot, $hook_name, $url) = @_;

    diag("check_external_url: $url");

    return unless $url->path; # is just a fragment...

    # follow if it's internal
    return 1 if is_same_domain($url, $base_url);

    return unless $CHECK_EXTERNAL; # do we want to run checks?
    # otherwise check the link and but don't let the bot follow

    push @followed, $url; # pretend it followed though

    my $response = $robot->get_url($url);
    ok($response->is_success, "$url is ok")
       or diag("$url -- ", $response->status_line);

    return;
}

# takes in a sub/name of sub and returns a sub that will
# print out the value returned by the sub in addition to returning
# the same value as the sub
sub echo_wrap {
    my $sub = shift;
    my $name = shift;
    unless (ref $sub eq 'CODE') {
        no strict 'refs';
        $name ||= $sub;
        $sub = \&$sub; # soft reference
        use strict 'refs';
    }
    $name ||= '';

    return sub {
        if (wantarray) {
            my @arr = &$sub;
            diag("$name(): ARRAY: ", join('; ', map { $_ // 'UNDEF' } @arr));
            return @arr;
        }
        else {
            my $val = &$sub;
            diag("$name(): VALUE: ", $val // 'UNDEF');
            return $val;
        }
    }
}
