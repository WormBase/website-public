#!/usr/bin/env perl

#tests for the CDS object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package cds;

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

    # Tests gene_history method
    sub test_gene_history {
        my $cds = $api->fetch({ class => 'Cds', name => '2L52.1:wp89' });

        can_ok('WormBase::API::Object::Cds', ('gene_history'));

        my $gene_history = $cds->gene_history();

        isnt($gene_history->{'data'}, undef, 'data returned');
        is  ( scalar @{$gene_history->{'data'}}, 1, "correct number of genes returned");
        is  ( $gene_history->{'data'}[0]->{id}, "WBGene00007063", "correct gene returned");

    }

}

1;

