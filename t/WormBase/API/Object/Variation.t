#!/usr/bin/perl
# t/WormBase/API/Object/Variation.t

use strict;
use warnings;

BEGIN {
    use FindBin '$Bin';
    chdir "$Bin/../../.."; # /t
    use lib 'lib';
    use lib '../lib';
}

use feature 'switch';
use Test::More;
use WormBase::Test::API::Object;

BEGIN {
    use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Variation');
} # Variation loads ok

my @test_objects = qw(e205);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/test.conf',
    class     => 'Variation',
});

$tester->run_common_tests({
    objects                 => \@test_objects,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

done_testing; exit; # comment this line to continue with old tests
# TODO: convert old tests to new framework

############################################################
# Old tests below (some are quite specific)
############################################################

my $wormbase = $tester->api;
my $variation = $tester->fetch_object_ok({class => 'Variation',
                                          name  => 'e205'});
isa_ok($variation,'WormBase::API::Object::Variation') or diag($variation);

my $indent = " " x 6;

# Dynamically build a list of methods or specify it manually.
#my @methods = build_method_list($variation);
my @methods = qw/
name
cgc_name
other_names
taxonomy
variation_type
remarks
type_of_mutation
nucleotide_change
flanking_sequences
cgh_deleted_probes
context
deletion_verification
features_affected
flanking_pcr_product
/;
   
for my $method ( @methods ) {
    note("Testing $method()...");

    my $result = test_method($method);
    test_description($result);
    my $data = get_data($result);

    # Test specific elements of data structures
    if ($method eq 'taxonomy') {       
	is ( $data->{genus} . " " . $data->{species},
	     'Caenorhabditis elegans',
	     $indent . "Taxonomy is set: " . $data->{genus} . " " . $data->{species}
	    );
    } elsif ($method eq 'nucleotide_change') {
	# The data structure is an array of hashes.
	foreach my $nucleotide_change (@{$data}) {
	    # The nucleotide change type
	    is($nucleotide_change->{type},
	       'Substitution',
	       format_message("variation type: " . $nucleotide_change->{type}),
		);
	
	    # The wildtype nucleotide change
	    is($nucleotide_change->{wildtype},
	       'g',
	       format_message("wildtype nucleotide change: " . $nucleotide_change->{wildtype}),
		);
	    
	    # The mutant nucleotide change
	    is($nucleotide_change->{mutant},
	       'a',
	       format_message("mutant nucleotide change: " . $nucleotide_change->{mutant}),
		);
	    
	    # The wildtype label
	    is($nucleotide_change->{wildtype_label},
	       'wild type',
	       format_message("wildtype label/source: " . $nucleotide_change->{wildtype_label}),
		);
	    
	    # The mutant label
	    is($nucleotide_change->{mutant_label},
	       'mutant',
	       format_message("mutant label/source: " . $nucleotide_change->{mutant_label}),
		);
	}	
    } elsif ($method eq 'flanking_sequences') {
	is ($data->{left_flank} . ':' . $data->{right_flank},
	    'agctgagcaaattcgacgatggcgatctat:gattgtactgaatagtggagaaatggcatt',
	    format_message('flanking sequences: ' . $data->{left_flank} . ':' . $data->{right_flank}));
	
    } elsif ($method eq 'context') {
	# Context is a biggie containing lots of meta information
	# But we need to call other methods to adequately test / display informative debug information
	my $coords = $variation->genomic_position;

note("VARIATION COORDS: " .
join("\t",$coords->{data}->{abs_start},
$coords->{data}->{abs_stop},
$coords->{data}->{start},
$coords->{data}->{stop}));

    } elsif ($method eq 'genomic_position') {
	# chromosome:start..stop
	is ($data->{chromosome} . ':' . $data->{start} . '..' . $data->{stop},
	    'IV:13263584..13263584',
	    format_message('chromosome: ' . $data->{chromosome} . ':' . $data->{start} . '..' . $data->{stop} ));
	
    } else {
	generically_test_method($method,$data);
    }
}


# The total number of tests is that identified through introspection
# plus a few extras.
done_testing((scalar @methods) + 4);

################################################################################
# Old test methods
################################################################################

# Simply call the method.
sub test_method {
    my $method = shift;
    my $result = $variation->$method;
    ok($result,
       format_message("called $method()"));
    return $result;
}

# Is the description populated?
sub test_description {
    my $result = shift;
    my $description = $result->{description};
    ok($description,format_message("description populated: $description"));
}

sub format_message {
    my $msg = shift;
    return "$indent$msg";
}

sub get_data {
    my $result = shift;
    return $result->{data};
}


sub generically_test_method {
    my ($method,$data) = @_;
# All handled already
#    my $method = shift;   
#    # Call the method
#    my $result = test_method($method);
#    
#    # Is the description populated?
#    test_description($result);    
#    my $data = get_data($result);
    
    # Data may contain
    #    HASHes - a data structure for processing
    #    ARRAYs - Lists of WormBase::API::Object::* objects
    #        or true/false (successful no data / method failed)
    #    SCALAR - simple scalar return value
    # Handle each case:
    #    HASHes - print the primary keyed element (ie name for $method eq 'name')
    #    ARRAYS - print the 0th element
    #    SCALAR - print the scalar
    #    true   - method scuccesful but no data
    #    false  - method failed
    
    my $msg;
    given ($data) {
	when (ref $data eq 'HASH')  { $msg = 'HASH; namesake keyed element contains ' . $data->{$method}; }
	when (ref $data eq 'ARRAY' && scalar @$data > 0) { $msg = 'ARRAY; first element is '  . $data->[0]  }
	when ($data ne '')          { $msg = "simple scalar: $data";                   }
	when ($data eq '')          { $msg = "return true, but no data";               }
	default                     { $msg = 'RETURNED FALSE. FAIL!';                  }
    }
    ok ($data,format_message($msg));
}



# Get a list of all methods.
sub build_method_list {
    my $object = shift;
    my @methods = $object->meta->get_all_methods;
    
    my %to_test;    
    for my $method (sort { $a->name cmp $b->name }  @methods ) {
    	my $name = $method->name;
        
	# Skip some methods...
    	next if $name =~ /                   # Ignore Moose internals
    	     	       BUILDARGS
		     | BUILDALL
   		     | DESTROY
		     | DEMOLISHALL
                     | DOES                 # Ignore Class::MOP internals
		     | meta
		     | new                  # Ignore constructor (already tested)
		     | wrap                 # Ignore the superclass meta method wrap. Starting to accumulate...
 		     /x;
    	next if $name =~ /^_/;               # Ignore private methods
	$to_test{$name}++;	
    }
    return sort { $a cmp $b } keys %to_test;
}


# Try introspecting the object automatically.
# This probably won't work for all object/method combinations
# and since it doesn't test the contents of the data
# structure isn't very thorough.
sub introspect {
    my $object = shift;	
    # Fetch all available methods by introspection.
    my @methods = $object->meta->get_all_methods;
    
    for my $method (sort { $a->name cmp $b->name }  @methods ) {
    	my $name = $method->name;
        
	# Skip some methods...
    	next   if $name =~ /                   # Ignore Moose internals
    	     	       BUILDARGS
		     | BUILDALL
   		     | DESTROY
		     | DEMOLISHALL
                     | does                 # Ignore Class::MOP internals
		     | meta
		     | new                  # Ignore constructor (already tested)
		     | wrap                 # Ignore the superclass meta method wrap. Starting to accumulate...
 		     /x;
    	next if $name =~ /^_/;               # Ignore private methods
#     	print $method . " " . $name . "\n";
	print $name . "\n";
    }
}
