# t/WormBase/DSN/AceDB.t

use strict;
use warnings;

use Test::More tests => 5;

use WormBase::DSN::AceDB;

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $acedb = WormBase::DSN::AceDB->new()),
    'Constructed WormBase::DSN::AceDB object ok'
    );


# Check that we can fetch a version string from the object
like ( my $version = $acedb->version,
       qr/WS\d\d\d/,
       "Check version of database ok: " . $acedb->version );


# Test dbh caching. Should return a sace://localhost::2005 string
my $dbh = $acedb->dbh;
is ( $dbh,
     'sace://localhost:2005',
     "Handle successfully cached $dbh" );


# Try fetching an object from the dbh via Ace::fetch
my $variation;
is (
     ($variation = $acedb->dbh->fetch(-class=>'Variation',-name=>'e345')),
     'e345',
     "Successfully fetched an object via Ace::fetch $variation");

  
# Try fetching an object via our wrapper get_object method
# which is really just a wrapper around Ace::fetch
my $gene_name;
is (
   $gene_name = $acedb->get_object('gene_name','unc-26'),
   'unc-26',
   "Successfully fetched an object via get_object(): " . $gene_name->Public_name_for);