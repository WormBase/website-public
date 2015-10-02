#!/usr/bin/env perl

# This is a unit test for go_term (Gene Ontology) API class that work
# with a running WormBase Website instance.
#
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/api_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package go_term;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    # This variable will hold a reference to a WormBase API object.
    my $api;

    # A setter method for passing on a WormBase API object from t/api.t to
    # the subs of this package.
    sub config {
        $api = $_[0];
    }

    # Test associated genes and corresponding species are returned for a GO term
    sub test_associated_gene {
        my $go = $api->fetch({ class => 'Go_term', name => 'GO:0007411' });

        can_ok('WormBase::API::Object::Go_term', ('genes'));

        my $genes = $go->genes();

        # Please keep test names/descriptions all lower case.
        isnt($genes->{'data'}, undef, 'data returned');
        is(ref($genes->{'data'}), 'ARRAY', 'gets array of genes');

        my $aGene = shift($genes->{'data'});
        isnt($aGene, undef, 'Data is returned for a gene');
        isnt($aGene->{'gene'}, undef, 'A gene is specified');
        isnt($aGene->{'species'}, undef, 'A species is specified');
    }

    sub test_go_name {
        my $go = $api->fetch({ class => 'Go_term', name => 'GO:0006810' });

        can_ok('WormBase::API::Object::Go_term', ('term'));

        my $term_name = $go->term();
        isnt($term_name->{data}, undef, 'data returned');
        is($term_name->{data}->{label}, 'transport', 'correct Go term name returned');
    }

}

1;
