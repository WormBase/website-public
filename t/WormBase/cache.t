# t/WormBase/cache.t

use strict;
use warnings;

use FindBin;
BEGIN { chdir "$FindBin::Bin" }
use lib '../lib'; # t/lib
use lib '../../lib'; # approot/lib

use WormBase::Test::CHI::Driver::Couch;
use JSON;
use LWP::Simple;
use UUID;
use Test::More;
use YAML::Any ();

BEGIN {
    use_ok('WormBase::CouchAgent');
    use_ok('WormBase::CHI::Driver::Couch');
}

################################################################################
#
# CouchAgent tests
#
################################################################################

my $couchagent = new_ok('WormBase::CouchAgent' => [ database => 'test' ]);
my $uuid = generate_uuid();

my ($res, $time);

# create a document
$res = $couchagent->create_document({
    document => {
        _id => $uuid,
        test => $time = time,
    },
});
ok($res->{id} eq $uuid, 'Created document ok');

# fetch the document
$res = $couchagent->fetch_document({ id => $uuid });
ok($res && $res->{test} == $time, 'Fetched document ok');

# update the document
$res = $couchagent->update_document({
    document => {
        _id => $uuid,
        test => $time = time,
    }
});
ok($res->{id} eq $uuid, 'Updated document ok');

# verify the document
$res = $couchagent->fetch_document({ id => $uuid });
ok($res && $res->{_id} eq $uuid && $res->{test} == $time,
   'Fetched updated document ok');

# delete the document
$res = $couchagent->delete_document({ id => $uuid });
ok($res, 'Deleted document ok');

# make sure the document is really gone
$res = $couchagent->get_document({ id => $uuid });
ok(!$res, 'Cannot get deleted document ok');

undef $uuid;

# improper bulk inserts
$res = eval {
    $couchagent->bulk_update_documents({
        documents => { id => 'dummy' }
    });
};
ok(!$res && $@, 'Improper bulk update okay (not arrayref)');

$res = eval {
    $couchagent->bulk_update_documents({
        documents => [ 'dummy', 'dummy', 'dummy' ],
    });
};
ok(!$res && $@, 'Improper bulk update okay (not hashrefs in arrayref)');

$res = eval {
    $couchagent->bulk_update_documents({
        documents => [ { test => 'dummy' } ],
    });
};
ok(!$res && $@, 'Improepr bulk update okay (no _id in hashrefs)');

# proper bulk insert
my @uuids = map { generate_uuid() } (1..10);

$time = time;
$res = $couchagent->bulk_update_documents({
    documents => [ map { _id => $_, test => $time }, @uuids ],
});
ok($res, 'Bulk insert ok');

# proper bulk fetch
$res = $couchagent->bulk_fetch_documents({ keys => \@uuids });
ok($res, 'Bulk fetch ok');

# verify the bulk fetch
subtest 'Verify bulk fetch ok' => sub {
    for (my $i = 0; $i < @$res; ++$i) {
        ok(my $row = $res->[$i], 'Row defined ok');
        is($row->{_id}, $uuids[$i], 'Same id');
        is($row->{test}, $time, 'Same time data');
    }
} or do { diag(YAML::Any::Dump($res)); diag(YAML::Any::Dump(\@uuids)) };

# proper bulk get
$res = $couchagent->bulk_get_documents({ keys => \@uuids });
ok($res && (grep !defined, @$res) == 0, 'Bulk get ok');

my %revs;
for (my $i = 0; $i < @$res; ++$i) {
    $revs{$uuids[$i]} = $res->[$i];
}

# proper bulk delete
$res = $couchagent->bulk_update_documents({
    documents => [
        map { _id => $_, _deleted => JSON::true, _rev => $revs{$_} }, @uuids
    ],
});
ok($res, 'Bulk delete ok');

subtest 'Verify bulk delete ok' => sub {
    ok(! ( $res = $couchagent->fetch_document({ id => $_ }) ))
        foreach (@uuids);
};

ok($couchagent->delete_database, 'Delete database ok');

################################################################################
#
# Couch CHI tests
#
################################################################################

subtest 'namespace escape ok' => sub {
    my @tests = (
        'abc',       # all lower
        'aBc',       # mixed case
        'a_bc',      # _ used
        'a_Bc',      # _ and mix
        '_a_Bc',     # _ and mix and begin
        'x_a_Bc',    # _ and mix and begin x
        'A_bc',      # _ and begin with non-lower
        '2_a_cD___', # lots of _ and begin with non-alpha
        '$What',     # begin with URI-unsafe char
    );
    foreach (@tests) {
        my $esc = WormBase::CHI::Driver::Couch->escape_namespace($_);
        my $unesc = WormBase::CHI::Driver::Couch->unescape_namespace($esc);
        is($unesc, $_, qq("$_" escapes to "$esc" and back)) or diag("Escaped version: ", $esc);
    }
};

subtest 'CHI standard tests' => sub {
    # local $ENV{TEST_METHOD} = '.*';
    WormBase::Test::CHI::Driver::Couch->runtests;
};

done_testing;

sub generate_uuid {
    my ($bin, $uuid);
    UUID::generate($bin);
    UUID::unparse($bin, $uuid);
    return $uuid;
}
