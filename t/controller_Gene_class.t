use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'WormBase' }
BEGIN { use_ok 'WormBase::Controller::Gene_class' }

ok( request('/gene_class')->is_success, 'Request should succeed' );


