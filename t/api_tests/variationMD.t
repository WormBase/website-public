#!/usr/bin/env perl

# 1. test_single_gene

{
    package variationMD;

    use strict;

    use Test::More;

    my $api;

    sub config {
        $api = $_[0];
    }

    # This is a test for the Sequence (that contains over 1000000) and Features Affected (that contains over 500) fields
    # in the Molucular Details widget in the Variation page
    # related to issue #2788 
    sub test_sequence {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar01500129' });

        can_ok('WormBase::API::Object::Variation', ('context'));

        my $context = $variation->context();

        isnt($context->{'data'}->{'placeholder'}, undef, 'data returned');
        is($context->{'data'}->{'placeholder'}, 'A sequence of length 7566000 is too long to display.', 'The (over 1000000) comment is returned');
    }

    sub test_features_affected {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar01500129' });

        can_ok('WormBase::API::Object::Variation', ('features_affected'));

        my $features_affected = $variation->features_affected();

        isnt($features_affected->{'data'}, undef, 'data returned');
        is($features_affected->{'data'}->{'Gene'}, "2849 (Too many features to display. You may download them using <a href='/tools/wormmine/'>WormMine</a>.)", 'The (over 500) comment is returned');
        is($features_affected->{'data'}->{'Predicted_CDS'}, "2357 (Too many features to display. You may download them using <a href='/tools/wormmine/'>WormMine</a>.)", 'The (over 500) comment is returned');
        is($features_affected->{'data'}->{'Transcript'}, "1969 (Too many features to display. You may download them using <a href='/tools/wormmine/'>WormMine</a>.)", 'The (over 500) comment is returned');
  
    }
}

1;

