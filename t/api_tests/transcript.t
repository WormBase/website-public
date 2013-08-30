#!/usr/bin/env perl

# This is a unit test template for implementing tests that work
# with a running WormBase Website instance.
#
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/api_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#
# Actual tests are implemented at the bottom of this file. Please see:
#
# 1. test_single_gene

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package transcript;

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

    sub test_transcript_features {
        my $transcript = $api->fetch({ class => 'Transcript', name => 'B0336.10.2' });

        can_ok('WormBase::API::Object::Transcript', ('feature'));

        my $features = $transcript->feature();

        # Please keep test names/descriptions all lower case.
        isnt($features->{'data'}, undef, 'data returned');
        is  ( scalar keys %{$features->{'data'}}, 3, "correct number of features returned");
    }

}

1;

