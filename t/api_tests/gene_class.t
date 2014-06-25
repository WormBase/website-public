#!/usr/bin/env perl

# This is a unit test for Gene_class object
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


{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package gene_class;

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

    # This is a test that checks whether former_laboratory attribute is correctly returned
    # related to #2551
    sub test_former_designating_laboratory {
        my $gene_class = $api->fetch({ class => 'Gene_class', name => 'daf' });

        can_ok('WormBase::API::Object::Gene_class', ('former_laboratory'));

        my $former_designating_laboratory = $gene_class->former_laboratory();

        # Please keep test names/descriptions all lower case.
        isnt($former_designating_laboratory->{'data'}, undef, 'data returned');
        is($former_designating_laboratory->{'data'}->{'lab'}->{'id'}, 'DR', 'correct lab returned');
        is($former_designating_laboratory->{'data'}{'time'}, '19 Mar 2014', 'correct time returned');
    }

}

1;

