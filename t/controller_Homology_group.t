use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase' }
BEGIN { use_ok 'WormBase::Controller::Homology_group' }

ok( request('/homology_group')->is_success, 'Request should succeed' );


