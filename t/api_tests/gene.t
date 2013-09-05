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

    # Test that the returned information of a gene model contains a pre-determined
    # number of rows.
    sub test__gene_models {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00003328' });

        can_ok('WormBase::API::Object::Gene', ('gene_models'));

        my $models = $gene->gene_models();

        isnt($models, undef, 'data returned');
        isnt($models->{data}, undef, 'data structure returned');
        $models = $models->{data};
        is  (scalar @$models, 2, 'two models returned');
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


    # Tests the concise_description method of Gene
    sub test_concise_description {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00000846' });

        can_ok('WormBase::API::Object::Gene', ('concise_description'));

        my $c_desc = $gene->concise_description();

        isnt($c_desc, undef, 'data returned');
        isnt($c_desc->{data}, undef, 'data structure returned');
        isnt($c_desc->{data}->{evidence}, undef, 'evidence returned');

        # issue #346 - rename Curator_confirmed to Curator
        isnt($c_desc->{data}->{evidence}->{Curator}, undef, 'Curator evidence returned');
        is($c_desc->{data}->{evidence}->{Curator_confirmed}, undef, 'no Curator_confirmed evidence returned');
    }

}

1;

