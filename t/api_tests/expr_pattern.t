#!/usr/bin/env perl

# Unit tests regarding "Expr_pattern" instances.

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package expr_pattern;

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

    # Test the historical gene method
    sub test_historical_gene {
        # one gene associated
        my $expr_pattern = $api->fetch({ class => 'Expr_pattern', name => 'Expr4699' });

        can_ok('WormBase::API::Object::Expr_pattern', ('historical_gene'));

        my $gene = $expr_pattern->historical_gene();
        $gene = $gene->{'data'};

        isnt($gene, undef, 'data returned');
        isnt(@$gene[0], undef, 'historical gene returned');
        isnt(@$gene[0]->{'text'}, undef, 'gene data returned');
        is  (@$gene[0]->{'text'}->{'id'}, 'WBGene00015274', 'correcthistorical  gene returned');
        is  (scalar @$gene, 1, 'correct number of historical genes returned');

        # multiple genes associated
        $expr_pattern = $api->fetch({ class => 'Expr_pattern', name => 'Expr3084' });

        my $genes = $expr_pattern->historical_gene();
        $genes = $genes->{'data'};

        isnt($genes, undef, 'data returned');
        isnt(@$genes[1], undef, 'historical gene returned');
        isnt(@$genes[1]->{'text'}, undef, 'historical gene data returned');
        is  (@$genes[1]->{'text'}->{'id'}, 'WBGene00012263', 'correct historical gene returned');
        is  (scalar @$genes, 6, 'correct number of historical genes returned');
    }

}

1;

