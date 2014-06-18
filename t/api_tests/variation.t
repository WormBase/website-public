#!/usr/bin/env perl

# Unit tests regarding "Variation" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package variation;

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

    # Tests nucleotide change method
    sub test_nucleotide_change {
        my $var = $api->fetch({ class => 'Variation', name => 'WBVar00068686' });

        can_ok('WormBase::API::Object::Variation', ('nucleotide_change'));

        my $ntc = $var->nucleotide_change();

        isnt($ntc->{data}, undef, 'data returned');
        is  ($ntc->{data}[0]->{wildtype_label}, 'reference', 'correct wildtype label');
        is  ($ntc->{data}[0]->{wildtype}, 'A', 'correct wildtype');
        is  ($ntc->{data}[0]->{mutant}, 'C', 'correct mutant');
        is  ($ntc->{data}[0]->{mutant_label}, 'HK104', 'correct mutant label');
    }

    # test nucleotide change - sparse data #2603
    sub test_sparse_nucleotide_change {
        my $var = $api->fetch({ class => 'Variation', name => 'WBVar00274963' });

        can_ok('WormBase::API::Object::Variation', ('nucleotide_change'));

        my $ntc = $var->nucleotide_change();

        isnt($ntc->{data}, undef, 'data returned');
        is  ($ntc->{data}[0]->{wildtype_label}, 'wild type', 'correct wildtype label');
        is  ($ntc->{data}[0]->{wildtype}, '', 'correct wildtype');
        is  ($ntc->{data}[0]->{mutant}, '', 'correct mutant');
        is  ($ntc->{data}[0]->{mutant_label}, 'mutant', 'correct mutant label');     
    }

    # test a Sequence field that contains over 1000000 
    # related to issue #2788 
    sub test_sequence {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar01500129' });

        can_ok('WormBase::API::Object::Variation', ('context'));

        my $context = $variation->context();

        isnt($context->{'data'}->{'placeholder'}, undef, 'data returned');
        is($context->{'data'}->{'placeholder'}, 'A sequence of length 7566000 is too long to display.', 'The (over 1000000) comment is returned');
    }

    # test a Features Affected field that contains over 500 
    # related to issue #2788 
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

