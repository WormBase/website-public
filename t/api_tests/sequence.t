#!/usr/bin/env perl


{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package sequence;

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

    sub test_cds_transcript_pg{
        
        can_ok('WormBase::API::Object::Sequence', qw/
            cdss
            transcripts
            pseudogenes
        /);
        
        my $seq_cds_tt = $api->fetch({ class => 'Sequence', name => 'AA109292' });
        isnt($seq_cds_tt->cdss, 'undef', 'CDSs data returned');
        isnt($seq_cds_tt->transcripts, 'undef', 'transcripts data returned');
        
        my $seq_pg = $api->fetch({ class => 'Sequence', name => 'yk1352b08.5' });
        isnt($seq_pg->pseudogenes, 'undef', 'pseudogenes data returned');
    }
}

1;

