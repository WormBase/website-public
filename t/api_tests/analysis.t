#!/usr/bin/env perl


#  Test an Analysis object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package analysis;

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


#Tests for issue #2571
    sub test_url {
        my $analysis = $api->fetch({ class => 'Analysis', name => 'OMA' });

        can_ok('WormBase::API::Object::Analysis', ('url'));

        my $url = $analysis->url();

        # Please keep test names/descriptions all lower case.
        isnt($url->{'data'}, undef, 'data returned');
        is ($url->{'data'}, 'https://omabrowser.org','there is the right data');
    }

}

1;
