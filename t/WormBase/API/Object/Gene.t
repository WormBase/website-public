# t/WormBase/API/Object/Gene.t

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
      use_ok('WormBase::API');
}

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new()),
    'Constructed WormBase::API object ok'
    );


# Instantiate a WormBase::API::Object::* wrapper object
my $gene = $wormbase->fetch({class=>'Gene',name=>'WBGene00006763'});
isa_ok($gene,'WormBase::API::Object::Gene');

# Do some introspection via Moose
for my $method ( $gene->meta->get_all_methods ) {
    my $name = $method->name;

    # Skip some methods...
    next if $name =~ /does/i;    # Ignore Class::MOP internals
    next if $name eq 'new';      # Ignore constructor (already tested)
    next if $name =~ /^_/;       # Ignore private methods    

    print "$name\n";
    pass ($gene->$name);    
}

