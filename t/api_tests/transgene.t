#!/usr/bin/env perl

# Unit tests regarding "Transgene" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package transgene;

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

    # Tests whether the reporter_construct sub returns a single value for WBTransgene00009878.
    sub test__reporter_construct {
        my $transgene = $api->fetch({ class => 'Transgene', name => 'WBTransgene00009878' });

        can_ok('WormBase::API::Object::Transgene', ('reporter_construct'));

        my $products = $transgene->reporter_construct();

        isnt($products, undef, 'data returned');
        isnt($products->{'data'}, undef, 'data hash not empty');
        $products = $products->{'data'};
        is  (keys %$products, 1, 'has a reporter product');
    }

}

1;

