use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase' }
BEGIN { use_ok 'WormBase::Controller::Operon' }

ok( request('/operon')->is_success, 'Request should succeed' );


