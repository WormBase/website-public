use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase::Web' }
BEGIN { use_ok 'WormBase::Web::Controller::Expression_cluster' }

ok( request('/expression_cluster')->is_success, 'Request should succeed' );


