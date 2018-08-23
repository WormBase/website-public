#!/usr/bin/env perl


# API unit tests for the disease class
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package disease;

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

    # genes_by_biology method unit test
    sub test_genes_by_biology {
        my $disease = $api->fetch({ class => 'Disease', name => 'DOID:9970' });

        # Test if the object contains this method
        can_ok('WormBase::API::Object::Disease', ('genes_biology'));

        my $genes_biology = $disease->genes_biology;
        isnt( $genes_biology, undef, "data returned");

        my $genes_by_biology = $genes_biology->{data};
        is( ref $genes_by_biology, 'ARRAY', "data contains array reference");

        # This object should have 7 genes by biology
        is(scalar @$genes_by_biology, 7, 'correct number of genes by biology');
    }



}

1;
