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

    sub test_associations {
        my $feature = $api->fetch({ class => 'Feature', name => 'WBsf919593' });

        can_ok('WormBase::API::Object::Feature', ('associations'));
        my $all_associations = $feature->associations();

        # check that a known association is found
        isnt($all_associations->{'data'}, undef, 'Data is returned');
        my ($a1) = grep { $_->{'association'}->{'label'} =~ /lin-39/ } @{$all_associations->{'data'}};
        isnt($a1, undef, 'Correct association is returned');
        is($a1->{'association'}->{'class'}, 'gene', 'Correct type of interaction is returned');


        # check for the same associated gene is returned by associated_gene sub
        can_ok('WormBase::API::Object::Feature', ('associated_gene'));
        isnt($all_associations->{'data'}, undef, 'Data is returned');
        my $associated_genes = $feature->associated_gene();
        isnt($associated_genes->{'data'}, undef, 'Correct associatied gene is returned');
        my ($a2) = @{$associated_genes->{'data'}};
        is($a2->{'class'}, 'gene', 'Correct type of interaction is returned');
    }

    sub test_binds_gene_product {
        my $feature = $api->fetch({ class => 'Feature', name => 'WBsf919593' });

        can_ok('WormBase::API::Object::Feature', ('binds_gene_product'));
        my $genes = $feature->binds_gene_product();

        # check that a known association is found
        isnt($genes->{'data'}, undef, 'Data is returned');
        my ($gene1) = grep { $_->{'label'} =~ /lin-1/ } @{$genes->{'data'}};
        isnt($gene1, undef, 'Correct association is returned');

    }

    sub test_transcription_factor {
        my $feature = $api->fetch({ class => 'Feature', name => 'WBsf919593' });

        can_ok('WormBase::API::Object::Feature', ('transcription_factor'));
        my $tf = $feature->transcription_factor();

        # check that a known association is found
        isnt($tf->{'data'}, undef, 'Data is returned');
        is($tf->{'data'}->{'class'}, 'transcription_factor', 'Correct class returned');
        is($tf->{'data'}->{'label'}, 'WBTranscriptionFactor000135', 'Correct transcription factor is returned');
    }

    sub test_feature_sequence {
        can_ok('WormBase::API::Object::Feature', ('flanking_sequences'));

        my $polyA_site = $api->fetch({ class => 'Feature', name => 'WBsf629640' });
        my $seqs_polyA_site = $polyA_site->flanking_sequences();
        isnt($seqs_polyA_site->{'data'}, undef, 'Data is returned');
        is($seqs_polyA_site->{'data'}->{'feature_seq'}, '', 'Correct 0 length feature sequence for polyA_site');

        my $polyA_signal = $api->fetch({ class => 'Feature', name => 'WBsf014010' });
        my $seqs_polyA_signal = $polyA_signal->flanking_sequences();
        isnt($seqs_polyA_signal->{'data'}, undef, 'Data is returned');
        is($seqs_polyA_signal->{'data'}->{'feature_seq'}, 'AATAAA', 'Correct feature sequence for polyA_signal_sequence feature');

        my $history_feature = $api->fetch({ class => 'Feature', name => 'WBsf016253' });
        my $err;
        my $seqs_history_feature = eval {
            $history_feature->flanking_sequences();
        } || do { $err = $@; };
        is($err, undef, 'No error for accessing history_feature');
        is($seqs_history_feature->{'data'}, undef, 'As expected, no sequence retrieved for history_feature');

    }


}

1;
