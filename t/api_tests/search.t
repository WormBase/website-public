#!/usr/bin/env perl

# search tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package search;

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

    # Testing the search_exact method
    sub test_search_exact {

        # Search for "neurodegenerative disease" in disease class
        # Issue #2971
        my $it = $api->xapian->search_exact($api, "\"neurodegenerative disease\"", "disease");

        my $o = @{$it->{struct}}[0];
        my $objs = $api->xapian->_pack_search_obj($api, $o->get_document);

        isnt($objs, undef, 'data returned');
        is  ($objs->{id}, 'DOID:1289', 'correct id returned - neurodegenerative disease search');
        is  ($objs->{label}, 'neurodegenerative disease', 'correct label returned - neurodegenerative disease search');


        # Search for unc-26 in gene class
        $it = $api->xapian->search_exact($api, "unc-26", "gene");

        $o = @{$it->{struct}}[0];
        $objs = $api->xapian->_pack_search_obj($api, $o->get_document);

        isnt($objs, undef, 'data returned');
        is  ($objs->{id}, 'WBGene00006763', 'correct id returned - unc-26 search');
        is  ($objs->{label}, 'unc-26', 'correct label returned - unc-26 search');


        # Search for "bag of worms" in phenotype class
        $it = $api->xapian->search_exact($api, "\"bag of worms\"", "phenotype");

        $o = @{$it->{struct}}[0];
        $objs = $api->xapian->_pack_search_obj($api, $o->get_document);

        isnt($objs, undef, 'data returned');
        is  ($objs->{id}, 'WBPhenotype:0000007', 'correct id returned - bag of worms');
        is  ($objs->{label}, 'bag of worms', 'correct label returned - bag of worms');

    }

}

1;

