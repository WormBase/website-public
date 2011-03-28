# t/WormBase/API/Object/Analysis.t

use strict;
use warnings;
use FindBin qw/$Bin/;
use feature "switch";	     
use Test::More;

my $indent = " " x 6;


BEGIN {
      # This will cause a new connection to database(s)
      use_ok('WormBase::API');
}

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new({conf_dir => "./conf"})),
    'Constructed WormBase::API object ok'
    );


# Instantiate a WormBase::API::Object::* wrapper object

my $analysis = 'TreeFam';

my $object = $wormbase->fetch({class=>'Analysis',name=>$analysis}); 
isa_ok($object,'WormBase::API::Object::Analysis');

