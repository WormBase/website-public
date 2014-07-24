#!/usr/bin/env perl

# Unit tests regarding "Gene" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package gene;

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

    # Test that the returned information of a gene model contains a pre-determined
    # number of rows.
    sub test__gene_models {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00003328' });

        can_ok('WormBase::API::Object::Gene', ('gene_models'));

        my $models = $gene->gene_models();

        isnt($models, undef, 'data returned');
        isnt($models->{data}, undef, 'data structure returned');
        isnt($models->{data}{table}, undef, 'table data structure returned');
        $models = $models->{data}{table};
        is  (scalar @$models, 3, 'two models returned');
    }

    # Tests whether the _longest_segment method works - particularly
    # in non-elegans genes
    sub test__longest_segment {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00028294' });

        can_ok('WormBase::API::Object::Gene', ('_longest_segment'));

        my $longest = $gene->_longest_segment();

        isnt($longest, undef, 'data returned');
        # this might change over time?
        is  ($longest, 'IV:7499433..7516371', 'correct segment');
    }


    # Tests the concise_description method of Gene
    sub test_concise_description {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00000846' });

        can_ok('WormBase::API::Object::Gene', ('concise_description'));

        my $c_desc = $gene->concise_description();

        isnt($c_desc, undef, 'data returned');
        isnt($c_desc->{data}, undef, 'data structure returned');
        isnt($c_desc->{data}->{evidence}, undef, 'evidence returned');

        # issue #346 - rename Curator_confirmed to Curator
        isnt($c_desc->{data}->{evidence}->{Curator}, undef, 'Curator evidence returned');
        is($c_desc->{data}->{evidence}->{Curator_confirmed}, undef, 'no Curator_confirmed evidence returned');
    }


    # Tests the multi_pt_data method of Gene
    sub test_multi_pt_data {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00007555' });

        can_ok('WormBase::API::Object::Gene', ('multi_pt_data'));

        my $mpt_data = $gene->multi_pt_data();

        # issue #2521 - mapping data when Combined undef
        isnt($mpt_data, undef, 'data returned');
        isnt($mpt_data->{data}, undef, 'data structure returned');
    }

        # Tests the named_by method of Gene
    sub test_named_by {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00004679' });

        can_ok('WormBase::API::Object::Gene', ('named_by'));

        my $names = $gene->named_by();

        # issue #2521 - mapping data when Combined undef
        isnt($names, undef, 'data returned');
        isnt($names->{data}, undef, 'data structure returned');
        is  (scalar @{$names->{data}}, 2, 'correct amount of names returned');
        is  (@{$names->{data}}[0]->{id}, 'WBPerson36', 'correct name returned');
        is  (@{$names->{data}}[1]->{id}, 'WBPerson10953', 'correct name returned');

    }

    # This is an example test that checks whether a particular gene can be
    # returned and whether the resulting data structure contains certain
    # data entries.
    sub test_diseases {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00000900' });

        can_ok('WormBase::API::Object::Gene', ('human_diseases'));

        my $human_diseases = $gene->human_diseases();

        # Please keep test names/descriptions all lower case.
        is($human_diseases->{'data'}->{'experimental_model'}, undef, 'undef returned when there is no data');
    }

    # Tests for the fpkm_expression_summary_ls method
    sub test_fpkm_expression_summary_ls {
        can_ok('WormBase::API::Object::Gene', ('fpkm_expression_summary_ls'));

        # test fpkm link
        # Test the analysis link in the fpkm table of the expression method
        # issue #2821
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00227744' });

        my $fpkm_expression = $gene->fpkm_expression_summary_ls();

        isnt($fpkm_expression->{'data'}->{'table'}->{'fpkm'}->{'data'}[0]->{'label'}, undef, 'data returned');
        is($fpkm_expression->{'data'}->{'table'}->{'fpkm'}->{'data'}[0]->{'label'}->{'label'}, 'RNASeq.brugia.FR3.WBls:0000081.Unknown.WBbt:0007833.PRJEB2709.ERX026030', 'correct link returned');


        # test O. voluvus fpkm data
        # issue #2864
        my $gene_ovol = $api->fetch({ class => 'Gene', name => 'WBGene00243220' });

        my $fpkm_expression_ovol = $gene_ovol->fpkm_expression_summary_ls();

        isnt($fpkm_expression_ovol->{'data'}->{'table'}->{'fpkm'}->{'data'}[0]->{'label'}, undef, 'data returned');
        is($fpkm_expression_ovol->{'data'}->{'table'}->{'fpkm'}->{'data'}[0]->{'label'}->{'label'}, 'RNASeq.ovolvulus.O_volvulus_Cameroon_isolate.WBls:0000108.Unknown.WBbt:0007833.PRJEB2965.ERX200392', 'correct o.vol link returned');
    }

    #Tests the alleles and polymorphisms methods of Gene
    #Related to issue #2809
    sub test_alleles {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00006742' });

        can_ok('WormBase::API::Object::Gene', ('alleles'));
        can_ok('WormBase::API::Object::Gene', ('polymorphisms'));

        my $alleles = $gene->alleles();
        my $polymorphisms = $gene->polymorphisms();

        my $first_allele = $alleles->{data}[0];
        my $first_polymorphisms = $polymorphisms->{data}[0];


        isnt($first_allele->{variation}->{label}, undef, 'data returned');
        isnt($first_polymorphisms->{variation}->{label}, undef, 'data returned');
        is  ($first_allele->{variation}->{label}, 'e2342', 'correct allele returned');
        is  ($first_polymorphisms->{variation}->{label}, 'WBVar00053707', 'correct polymorphisms returned');

    }

    #Test the gene classification method
    # Make sure return compiant data - #2906

    sub test_classification {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00014631' });

        can_ok('WormBase::API::Object::Gene', ('classification'));

        my $classification = $gene->classification();


        isnt($classification->{data}, undef, 'data returned');
        isnt($classification->{data}{type}, undef, 'type data returned');
        is  ($classification->{data}{type}, 'snRNA', 'correct allele returned');

    }
}

1;

