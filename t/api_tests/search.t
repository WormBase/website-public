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

    # Testing the fetch method
    sub test_fetch {

        # Search for "neurodegenerative disease" in disease class
        # Issue #2971
        my $match = $api->xapian->fetch({ query => "\"neurodegenerative disease\"", class => "disease", tag => 1 });

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'DOID:1289', 'correct id returned - neurodegenerative disease search');
        is  ($match->{label}, 'neurodegenerative disease', 'correct label returned - neurodegenerative disease search');


        # Search for unc-26 in gene class
        $match = $api->xapian->fetch({ query => "unc-26", class => "gene", tag => 1 });

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'WBGene00006763', 'correct id returned - unc-26 search');
        is  ($match->{label}, 'unc-26', 'correct label returned - unc-26 search');


        # Search for "bag of worms" in phenotype class
        $match = $api->xapian->fetch({ query => "\"bag of worms\"", class => "phenotype", tag => 1 });

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'WBPhenotype:0000007', 'correct id returned - bag of worms');
        is  ($match->{label}, 'bag of worms', 'correct label returned - bag of worms');

    }

}

1;

