# t/WormBase.t

use strict;
use warnings;

use Test::More qw/no_plan/;

use WormBase;

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase->new(
    {mysql_user => 'root',
    mysql_pass  => '3l3g@nz',
    data_sources => { c_elegans => { adaptor => 'dbi::mysqlace',
    		      	        aggregator => 'wormbase_gene' },
				},
      })),
    'Constructed WormBase object ok'
    );

# Can we fetch a Log::Log4Perl object?
ok (my $log = $wormbase->log,
	 "Successfully instantiated a Log4perl object");

can_ok($log,'debug','info');


# Check that we can fetch a version string from the object
like ( my $version = $wormbase->version,
       qr/WS\d\d\d/,
       "Check version of database ok: " . $wormbase->version );


# Test dbh caching. Should return a sace://localhost::2005 string
my $acedb = $wormbase->acedb_dbh;
is ( $acedb,
     'sace://localhost:2005',
     "Handle successfully cached $acedb" );


# Try fetching an object from the dbh via Ace::fetch
my $variation;
is (
     ($variation = $acedb->fetch(-class=>'Variation',-name=>'e345')),
     'e345',
     "Successfully fetched an object via Ace::fetch $variation");

  
# Try fetching an object via our wrapper get_object method
# which is really just a wrapper around Ace::fetch
my $gene_name = $wormbase->get_object('gene_name','unc-26');
is ($gene_name,
   'unc-26',
   "Successfully fetched an object via get_object(): " . $gene_name->Public_name_for);


my $gff_dbh = $wormbase->gff_dbh();
ok($gff_dbh,"Recovered the GFF database handles hash - ugly object implementation here, please fix!");

# Get the C. elegans GFF handle - currently poking inside the object
my $handle = $gff_dbh->{"c_elegans"}; 
isa_ok($handle,'Bio::DB::GFF');

# Try fetching a segment from the GFF handle
my $segment = $handle->segment('I',1 => 100000);
ok($segment,"Testing GFF segment fetching");

my @transcripts = $segment->features("transcript");
ok(@transcripts,"Testing GFF feature fetching: retrieved "
			 . scalar @transcripts
			 . " transcripts"    
			 );
