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
        my $match = $api->xapian->fetch({ query => "\"neurodegenerative disease\"", class => "disease"});

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'DOID:1289', 'correct id returned - neurodegenerative disease search');
        is  ($match->{label}, 'neurodegenerative disease', 'correct label returned - neurodegenerative disease search');


        # Search for unc-26 in gene class
        $match = $api->xapian->fetch({ query => "unc-26", class => "gene"});

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'WBGene00006763', 'correct id returned - unc-26 search');
        is  ($match->{label}, 'unc-26', 'correct label returned - unc-26 search');


        # Search for "bag of worms" in phenotype class
        $match = $api->xapian->fetch({ query => "\"bag of worms\"", class => "phenotype"});

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'WBPhenotype:0000007', 'correct id returned - bag of worms');
        is  ($match->{label}, 'bag of worms', 'correct label returned - bag of worms');


        # Search for a CDS object - wasn't working after refactor
        $match = $api->xapian->fetch({ query => "JC8.10a", class => "cds", label => 1});

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'JC8.10a', 'correct id returned - jc810.a cds');
        is  ($match->{label}, 'JC8.10a', 'correct label returned - jc810.a cds');

        # Search for a person object - mult class search wasn't working (Author/Person)
        $match = $api->xapian->fetch({ query => "WBPerson3249", class => "person", label => 1});

        isnt($match, undef, 'data returned');
        is  ($match->{id}, 'WBPerson3249', 'correct id returned - wbperson3249 person');
        is  ($match->{label}, 'Joshua N Bembenek', 'correct label returned - wbperson3249 person');

    }

    sub test_autocompelte {
        my $it = $api->xapian->autocomplete("neuro", "disease");

        isnt($it, undef, 'data returned');
        my @matches = @{$it->{struct}};
        is  (scalar @matches, 10, 'correct amount of results returned');
        is  ($matches[0]->{id}, 'DOID:169', 'correct result first');


    }

}

1;

