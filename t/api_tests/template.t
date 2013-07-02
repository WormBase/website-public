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
    package template;

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

    # This is an example test that checks whether a particular gene can be
    # returned and whether the resulting data structure contains certain
    # data entries.
    sub test_single_gene {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00006763' });

        can_ok('WormBase::API::Object::Gene', ('locus_name'));

        my $locus_name = $gene->locus_name();

        # Please keep test names/descriptions all lower case.
        isnt($locus_name->{'data'}, undef, 'data returned');
        isnt($locus_name->{'data'}->{'class'}, undef, 'class specified');
        isnt($locus_name->{'data'}->{'id'}, undef, 'id specified');
        isnt($locus_name->{'data'}->{'label'}, undef, 'label specified');
        isnt($locus_name->{'data'}->{'taxonomy'}, undef, 'taxonomy specified');
        is  ($locus_name->{'data'}->{'class'}, 'Gene', 'correct class fetched');
        is  ($locus_name->{'data'}->{'id'}, 'WBGene00006763', 'correct gene fetched');
        is  ($locus_name->{'data'}->{'taxonomy'}, 'c_elegans', 'species with associated gene correct');
    }

}

1;

