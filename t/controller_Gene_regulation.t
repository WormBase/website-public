use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase' }
BEGIN { use_ok 'WormBase::Controller::Gene_regulation' }

ok( request('/gene_regulation')->is_success, 'Request should succeed' );


