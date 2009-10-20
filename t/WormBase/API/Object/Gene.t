# t/WormBase/API/Object/Gene.t

use strict;
use warnings;
use feature "switch";	     

use Test::More;

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


#my @methods = (qw/name
#		  common_name
#		  ids
#		  description
#		  proteins
#		  /);
#

#for my $method ( @methods ) {
#    print "$method: " . $gene->$method . "\n";
#    }

#exit;
#
#
#1;


# Do some introspection of the class.
#my @methods = $gene->meta->get_all_methods;

my @methods = qw/common_name
   	         name
   	         ids
		 concise_description
		 proteins
		 cds
		 kogs
		 other_sequences
		 cloned_by
		 history
		 gene_models
		 /;

for ( @methods ) {
#    my $method = $_->name;
     my $method = $_;

    # Skip some methods...
    next if $method =~ /does/i;            # Ignore Class::MOP internals
    next if $method =~ /                   # Ignore Moose internals
    	    	       BUILDARGS
		     | BUILDALL
   		     | DESTROY
		     | DEMOLISHALL
		     | meta
		     /x;
    next if $method eq 'new';   		 # Ignore constructor (already tested)
    next if $method =~ /^_/;               # Ignore private methods    
    next if $method eq 'wrap';             # Ignore the superclass meta method wrap. Starting to accumulate...

#    print "$method: " . $gene->$method . "\n";

    if ($method eq 'proteins') {
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
	} else {
	
	    # Call the method
 	    my $data = $gene->$method;

	    # We may get
	    #    HASHes - a data structure for processing
	    #    ARRAYs - Lists of WormBase::API::Object::* objects
	    #        or true/false (successful no data / method failed)
	    # Handle each case:
	    #    HASHes - print the primary keyed element (ie name for $method eq 'name')
	    #    ARRAYS - print the 0th element
	    #    true   - method scuccesful but no data
            #    false  - method failed
	    my $msg;
	    given ($data) {
	       	 when (ref $data eq 'HASH')  { $msg = 'HASH; namesake keyed element contains ' . $data->{$method}; }
		 when (ref $data eq 'ARRAY') { $msg = 'ARRAY; first element is '  . $data->[0]; }
		 when ($data)                { $msg = 'returned true, but no data';             }
		 default                     { $msg = 'RETURNED FALSE. FAIL!';                  }
		 }

    	    ok ($data,$method . "(): " . $msg);
	}
}


# The total number of tests is that identified through introspection
# plus a few extras.
done_testing((scalar @methods) + 4);