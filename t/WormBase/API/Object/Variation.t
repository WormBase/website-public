#!/usr/bin/perl
# t/WormBase/API/Object/Variation.t

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
my $variation = $wormbase->fetch({class => 'Variation', 
   	      		          name  => 'e205'});
isa_ok($variation,'WormBase::API::Object::Variation');


# Manually introspect the class
my @methods = qw/
   name
   common_name
   cgc_name
   other_names
   taxonomy
   variation_type
   remarks
   
   type_of_mutation
   nucleotide_change
   variation_coordinates
   flanking_sequences
   cgh_deleted_probes
   context
   deletion_verification
   features_affected
   flanking_pcr_products

   genetic_position
   genomic_position
   genomic_image
   /;

#alleles
#best_blastp_matches
#best_phenotype_name
#build_data_structure
#dbh_ace
#dsn
#dump
#fasta
#gazette_abstracts
#get_references
#gff_dsn
#id2species
#interpolated_position
#markup
#meeting_abstracts
#parsed_species
#phenotype_remark
#phenotypes_not_observed
#phenotypes_observed
#polymorphisms
#published_literature
#reactome_knowledgebase
#strains
#wormbook_abstracts
#all_references


for my $method ( @methods ) {
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
	       $indent . "variation type: " . $nucleotide_change->{type}
		);
	
	    # The wildtype nucleotide change
	    is($nucleotide_change->{wildtype},
	       'g',
	       $indent . "wildtype nucleotide change: " . $nucleotide_change->{wildtype},
		);

	    # The mutant nucleotide change
	    is($nucleotide_change->{mutant},
	       'a',
	       $indent . "mutant nucleotide change: " . $nucleotide_change->{mutant},
		);

	    # The wildtype label
	    is($nucleotide_change->{wildtype_label},
	       'wild type',
	       $indent . "wildtype label/source: " . $nucleotide_change->{wildtype_label},
		);

	    # The mutant label
	    is($nucleotide_change->{mutant_label},
	       'mutant',
	       $indent . "mutant label/source: " . $nucleotide_change->{mutant_label},
		);
	}

    } elsif ($method eq 'variation_coordinates') {
	# Chromosome: start, stop
	is ($data->{chromosome} . ':' . $data->{start} . '..' . $data->{stop}
	    'IV:XXXXX..XXXXX',
	    'chromosome: ' . $data->{chromosome} . ':' . $data->{start} . '..' . $data->{stop} );

    } else {
	generically_test_method($method,$data);
    }
}


# The total number of tests is that identified through introspection
# plus a few extras.
done_testing((scalar @methods) + 4);

# Simply call the method.
sub test_method {
    my $method = shift;
    my $result = $variation->$method;
    ok($result,"testing $method()...");
    return $result;
}

# Is the description populated?
sub test_description {
    my $result = shift;
    my $description = $result->{description};
    ok($description,$indent . "description populated: $description");
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
	when (ref $data eq 'ARRAY') { $msg = 'ARRAY; first element is '  . $data->[0]  }
	when ($data)                { $msg = "returned true: $data";                   }
	when ($data eq '')          { $msg = "return true, but no data";               }
	default                     { $msg = 'RETURNED FALSE. FAIL!';                  }
    }
    ok ($data,"$indent$msg");
}




# Try introspecting the object automatically.
# This probably won't work for all objects
# and isn't very thorough.
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
