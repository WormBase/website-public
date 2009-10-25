# t/WormBase/API.t

use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
      use_ok('WormBase::API');
}

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new()),
    'Constructed WormBase::API object ok'
    );

# Can we fetch the version and does it look like something expected?
like ( my $version = $wormbase->version,
       qr/WS\d\d\d/,
       "Check version of database ok: " . $wormbase->version );

# Have we correctly instantiated a Service::acedb?
my $service = $wormbase->service('acedb');
isa_ok ( $service,'WormBase::API::Service::acedb');

# Have we correctly instantiated a Service::gff?
my $gff_service = $wormbase->gff_dsn('c_elegans');
isa_ok($gff_service,'WormBase::API::Service::gff::gff_c_elegans');



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

# Try an AUTOLOAD method.  This will currently die.
is ($gene->object->Public_name,
   'unc-26',
   "Successfully called an (autoload) method " . ref($gene) . "->name");



# Now let's try XREF from one Ace::Object to another, but wrapped in a W::A::O
# Fetch all of the proteins for unc-26
my $proteins = $gene->proteins();
foreach my $protein (@$proteins) {
   isa_ok($protein,'WormBase::API::Object::Protein');

   like ( my $name = $protein->name,
   	    qr/WP:CE/,
            "We successfully fetched a protein " . $protein->name);
   
   last;
}

