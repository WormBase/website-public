#!/usr/bin/env perl

# Unit tests regarding "Gene" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package gene;

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

    # Tests whether the _longest_segment method works - particularly
    # in non-elegans genes
    sub test__longest_segment {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00028294' });

        can_ok('WormBase::API::Object::Gene', ('_longest_segment'));

        my $longest = $gene->_longest_segment();

        isnt($longest, undef, 'data returned');
        # this might change overtime?
        is  ($longest, 'CBG05938a:1,16939', 'correct segment');
    }

}

1;

