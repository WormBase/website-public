# t/WormBase/API.t

use strict;
use warnings;

use Test::More tests => 8;

BEGIN {
      use_ok('WormBase::API');
}

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new()),
    'Constructed WormBase::APIPluggable object ok'
    );

# Can we fetch the version and does it look like something expected?
like ( my $version = $wormbase->version,
       qr/WS\d\d\d/,
       "Check version of database ok: " . $wormbase->version );

# Have we correctly instantiated a Service::acedb?
my $service = $wormbase->servic('acedb');
isa_ok ( $service,'WormBase::API::Service::acedb');

# Have we correctly instantiated a Service::gff?
my $gff_dbh = $wormbase->dbh('gff');
isa_ok($gff_dbh,'WormBase::API::Service::gff');



# Can we instantiate a WormBase::API::Object via fetch?
my $variation = $wormbase->fetch({class=>'Variation',name=>'e345'});
isa_ok ($variation,'WormBase::API::Object::Variation');

# What about the name of the variation?
is ($variation->name,
   'e345',
   "Successfully called local method " . ref($variation) . "->name");


# Try it again, this time with ::Gene
my $gene = $wormbase->fetch({class=>'Gene',name=>'WBGene00006763'});
isa_ok($gene,'WormBase::API::Object::Gene');

is ($gene->object->Public_name,
   'unc-26',
   "Successfully called an (autoload) method " . ref($gene) . "->name");
