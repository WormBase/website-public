#!/usr/bin/env perl

# Unit tests regarding "Feature" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package features;

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

    # Retrieve a sequence feature and make some API calls on it.
    #
    # Properties tested:
    #   1. strand
    sub test_single_sequence_feature {
        my $feature = $api->fetch({ class => 'Feature', name => 'WBsf621357' });

        # Retrieve the strand on which this feature is located on.
        can_ok('WormBase::API::Role::Sequence', ('strand'));
        my $strand = $feature->strand();

        # Check that the sequence feature is on the forward strand:
        is  ($strand->{'data'}, '+', 'feature correctly located on forward strand');
    }

}

1;

