#!/usr/bin/env perl

#tests for the CDS object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package cds;

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

    # Tests gene_history method
    sub test_gene_history {
        my $cds = $api->fetch({ class => 'Cds', name => '2L52.1:wp89' });

        can_ok('WormBase::API::Object::Cds', ('gene_history'));

        my $gene_history = $cds->gene_history();

        isnt($gene_history->{'data'}, undef, 'data returned');
        is  ( scalar @{$gene_history->{'data'}}, 1, "correct number of genes returned");
        is  ( $gene_history->{'data'}[0]->{id}, "WBGene00007063", "correct gene returned");

    }

    sub test_brief_identification {
        my $cds = $api->fetch({ class => 'Cds', name => 'AH6.1'});
        can_ok('WormBase::API::Object::Cds', ('identity'));

        my $brief = $cds->identity();
        isnt($brief->{'data'}, undef, 'data returned');
        is($brief->{'data'}->{'text'}, 'Guanylate cyclase receptor-type gcy-1', 'Correct brief identification');
        isnt($brief->{'data'}->{'evidence'}, undef, 'evidence returned');
        isnt($brief->{'data'}->{'evidence'}->{'Accession_evidence'}, undef, 'correct type of evidence returned');

        my $evs = $brief->{'data'}->{'evidence'}->{'Accession_evidence'};
        ok(\$evs, 'has one Accession_evidence');
        my $evidence = shift $evs;
        is($evidence->{'class'}, 'UniProt', 'Correct external database specified');
        is($evidence->{'id'}, 'Q09435', 'Correct cross-referecne id specified');
    }

    sub test_tier3_genomic_position {
        # ensure genomic_position is obtained
        # unlike core species, tier 3 has prefix added to the ACe object name,
        #that needs to striped before fetching segments from GFF databases

        my $expected_position = 'Acey_s0107_scaf:399963..412768';

        can_ok('WormBase::API::Object::Cds', ('genomic_position'));
        my $cds = $api->fetch({ class => 'Cds', name => 'PRJNA231479:Acey_s0107.g3812.t1'});
        my $gp_cds = $cds->genomic_position();
        isnt($gp_cds->{data}, undef, 'genomic position for the CDS is returned');
        is($gp_cds->{data}->[0]->{label}, $expected_position, 'genomic position for the CDS is correct');

    }
}

1;
