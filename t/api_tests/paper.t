#!/usr/bin/env perl

#tests for the Paper object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package paper;

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

    # Tests refers_to method
    sub test_refers_to {
        my $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00004400' });

        can_ok('WormBase::API::Object::Paper', ('refers_to'));

        my $refers_to = $paper->refers_to();

        # Please keep test names/descriptions all lower case.
        isnt($refers_to->{'data'}, undef, 'data returned');
        isnt($refers_to->{'data'}->{'Gene'}, undef, 'genes refered to found');    }

}

1;

