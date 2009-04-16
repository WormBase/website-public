use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase::Web' }
BEGIN { use_ok 'WormBase::Web::Controller::Sequence' }

ok( request('/sequence')->is_success, 'Request should succeed' );


