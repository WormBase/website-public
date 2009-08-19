# t/WormBase/API.t

use strict;
use warnings;

use Test::More tests => 8;

use WormBase::API;

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new()),
    'Constructed WormBase::API object ok'
    );


# Check that we can fetch a version string from the object
like ( my $version = $wormbase->version,
       qr/WS\d\d\d/,
       "Check version of database ok: " . $wormbase->version );


# Test dbh caching. Should return a sace://localhost::2005 string
my $dbh = $wormbase->acedb_dbh;
is ( $dbh,
     'sace://localhost:2005',
     "Handle successfully cached $dbh" );


# Try fetching an object from the dbh via Ace::fetch
my $variation;
is (
     ($variation = $wormbase->fetch(-class=>'Variation',-name=>'e345')),
     'e345',
     "Successfully fetched an object from AceDB via fetch() delegated");

isa_ok($variation,'Ace::Object');
  
# Try fetching an object via our wrapper get_object method
# which is really just a wrapper around Ace::fetch
my $gene_name;
is (
   $gene_name = $wormbase->get_object('gene_name','unc-26'),
   'unc-26',
   "Successfully fetched an object via get_object(): " . $gene_name->Public_name_for);



# Test out our factory
my $gene = $wormbase->test_get('Gene','WBGene00006763');
isa_ok($gene,"WormBase::API::Object::Gene");

is( $gene->name,
       'WBGene00006763',
       "Successfully fetched object/created: " . ref($gene) . " - " . $gene->name);

