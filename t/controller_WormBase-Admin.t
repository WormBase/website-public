use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase' }
BEGIN { use_ok 'WormBase::Controller::WormBase::Admin' }

ok( request('/wormbase/admin')->is_success, 'Request should succeed' );


