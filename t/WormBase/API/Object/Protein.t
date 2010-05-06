#!/usr/bin/perl
# t/WormBase/API/Object/Protein.t

use strict;
use warnings;
use FindBin qw/$Bin/;
use feature "switch";	     

use Test::More;

my $indent = " " x 6;

BEGIN {
      # Use the API (and establish connections to DBs)
      use_ok('WormBase::API');
}

# Test object construction.
# Object construction also connects to sgifaceserver at localhost::2005
ok ( 
    ( my $wormbase = WormBase::API->new({conf_dir => "$Bin/../../../../conf"})),
    'Constructed WormBase::API object ok'
    );

# Instantiate a WormBase::API::Object::* object
my $protein = $wormbase->fetch({class => 'Protein', 
   	      		          name  => 'WP:CE28239'});
isa_ok($protein,'WormBase::API::Object::Protein');


# Dynamically build a list of methods or specify it manually.
# my @methods = introspect($protein);
 
 
my @methods = qw/
name
species
title
transcripts
type
genes
homology_groups
ortholog_genes
amino_acid_composition
homology_image
motif_homologies
best_blastp_matches
estimated_isoelectric_point
estimated_molecular_weight
protein_history
protein_length
protein_sequence
/;
   
for my $method ( @methods ) {
    note("Testing $method()...");

    my $result = test_method($method);
    test_description($result);
    my $data = get_data($result);

    # Test specific elements of data structures
    if ($method eq 'name') {       
	is ( $data, 'WP:CE28239', $indent . "Name is set: " . $data );
    } elsif ($method eq 'species') {
	is ( $data, 'Caenorhabditis elegans', $indent . "species is set: " . $data );	
    } elsif ($method eq 'title') {
	is ( $data, 'UNC-26', $indent . "title is set: " . $data );
    } elsif ($method eq 'type') {
	is ( $data, 'curated', $indent . "type is set: " . $data );
    } 
# else {
# 	generically_test_method($method,$data);
#     }
}


# The total number of tests is that identified through introspection
# plus a few extras.
done_testing((scalar @methods) + 4);

# Simply call the method.
sub test_method {
    my $method = shift;
    my $result = $protein->$method;
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
