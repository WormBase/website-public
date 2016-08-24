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
        is  ($ntc->{data}[0]->{wildtype_label}, 'wild type', 'correct wildtype label');
        is  ($ntc->{data}[0]->{wildtype}, 'A', 'correct wildtype');
        is  ($ntc->{data}[0]->{mutant}, 'C', 'correct mutant');

        # mutant_label change in #3201, partly
        #due to same variant observed in multiple strains
        is  ($ntc->{data}[0]->{mutant_label}, 'variant', 'correct mutant label');    }

    # test nucleotide change - sparse data #2603
    sub test_sparse_nucleotide_change {
        my $var = $api->fetch({ class => 'Variation', name => 'WBVar00274963' });

        can_ok('WormBase::API::Object::Variation', ('nucleotide_change'));

        my $ntc = $var->nucleotide_change();

        isnt($ntc->{data}, undef, 'data returned');
        is  ($ntc->{data}[0]->{wildtype_label}, 'wild type', 'correct wildtype label');
        is  ($ntc->{data}[0]->{wildtype}, '', 'correct wildtype');
        is  ($ntc->{data}[0]->{mutant}, '', 'correct mutant');
        is  ($ntc->{data}[0]->{mutant_label}, 'variant', 'correct mutant label');
    }

    # test a Sequence field that contains over 1000000
    # related to issue #2788
    sub test_sequence {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar01500129' });

        can_ok('WormBase::API::Object::Variation', ('context'));

        my $context = $variation->context();

        isnt($context->{'data'}->{'placeholder'}, undef, 'data returned');
        is($context->{'data'}->{'placeholder'}->{'seqLength'}, '7,566,000', 'The (over 1000000) comment is returned');
    }

    # test a Features Affected field that contains over 500
    # related to issue #2788
    sub test_features_affected {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar01500129' });

        can_ok('WormBase::API::Object::Variation', ('features_affected'));

        my $features_affected = $variation->features_affected();

        isnt($features_affected->{'data'}, undef, 'data returned');
        ok($features_affected->{'data'}->{'Gene'} =~ /Too many features to display/, 'Comment is returned for # genes > 500');
        ok($features_affected->{'data'}->{'Predicted_CDS'} =~ /Too many features to display/, 'Comment is returned for # predicted cds > 500');
        ok($features_affected->{'data'}->{'Transcript'} =~ /Too many features to display/, 'Comment is returned for # transcripts > 500');

    }

    sub test_negative_strand_deletion {
        my $variation = $api->fetch({ class => 'Variation', name => 'WBVar00275092' });

        can_ok('WormBase::API::Object::Variation', ('_build_sequence_strings'));

        my ($wt_seq,$mut_seq,$wt_full,$mut_full) = $variation->_build_sequence_strings();

        my $match_wt_seq = $wt_seq =~ /acaccattgaacttccaattgcatACGGAAGCGGTAGACGCATTTCGCAAACGGGTAGACCTGTTAGGCTGAAATTTGAATTTTTGATAGGATTATCAGTATATATAGTTATCCATACTTATTGATGGTTACTTTCGACCCAAAACCGAAGCCTAATGGAGCCGCACCAATTCCTGCGGATATCAGCCATAccagaactatcacgtaatttatacg/i;
        ok($match_wt_seq, 'correct wild type sequence');
        ok($mut_seq =~ /acaccattgaacttccaattgcatccagaactatcacgtaatttatacg/i, 'correct mutant sequence');

    }

}

1;
