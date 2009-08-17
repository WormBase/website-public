# t/WormBase.t

use strict;
use warnings;

use Test::More qw/no_plan/;

use WormBase;

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase->new()),
    'Constructed WormBase object ok'
    );

# Can we fetch a Log::Log4Perl object?
ok (my $log = $wormbase->log,
	 "Successfully instantiated a Log4perl object");

can_ok($log,'debug','info');

# Check that we can fetch a version string from the object
#like ( my $version = $acedb->version,
#       qr/WS\d\d\d/,
#       "Check version of database ok: " . $acedb->version );


# Test dbh caching. Should return a sace://localhost::2005 string
#is (
#     my $dbh = $acedb->dbh,
#     'sace://localhost:2005',
#     "Handle successfully cached " . $acedb->dbh );




# Try fetching an object from the dbh via Ace::fetch
#my $variation;
#is (
#     ($variation = $acedb->dbh->fetch(-class=>'Variation',-name=>'e345')),
#     'e345',
#     "Successfully fetched an object via Ace::fetch $variation");

  
# Finally, try fetching an object via our wrapper get_object method
# which is really just a wrapper around Ace::fetch
#my $gene_name;
#is (
#   $gene_name = $acedb->get_object('gene_name','unc-26'),
#   'unc-26',
#   "Successfully fetched an object via get_object(): " . $gene_name->Public_name_for);