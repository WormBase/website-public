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
    package laboratory;

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

    # This is a test for the Former Gene Class table in the Gene Class widget
    # rrelated to #2551
    # data entries.
    sub test_single_gene {
        my $lab = $api->fetch({ class => 'Laboratory', name => 'DR' });

        isnt($lab, undef, 'There is a lab');

        can_ok('WormBase::API::Object::Laboratory', ('former_gene_classes'));

        my $former_gene_classes = $lab->former_gene_classes();

        # Please keep test names/descriptions all lower case.
        isnt($former_gene_classes->{'data'}[0], undef, 'data returned');
        isnt($former_gene_classes->{'data'}[0]->{'former_gene_class'}, undef, 'former gene class returned');
        isnt($former_gene_classes->{'data'}[0]->{'description'}, undef, 'description returned');
        #isnt($$data2[0]->{'data'}->{'label'}, undef, 'label specified');
        is($former_gene_classes->{'data'}[0]->{'former_gene_class'}->{'id'}, 'daf', 'correct former gene class returned');
        is($former_gene_classes->{'data'}[0]->{'description'}, 'abnormal DAuer Formation', 'correct description returned');
        #is  ($$data2[0]->{'data'}->{'taxonomy'}, 'c_elegans', 'species with associated gene correct');

    }

    # Test that remarks are working for laboratory
    # #2934
    sub test_remark {
        my $lab = $api->fetch({ class => 'Laboratory', name => 'AB' });
        can_ok('WormBase::API::Object::Laboratory', ('remarks'));
        my $remarks = $lab->remarks();

        isnt($remarks->{'data'}, undef, 'data returned');
        isnt($remarks->{'data'}[0], undef, 'remark returned');
        is  ($remarks->{'data'}[0]->{'text'}, "No longer an active PI", 'correct remark returned');

    }

}

1;

