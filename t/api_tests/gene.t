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

        # test curator remarks
        $gene = $api->fetch({ class => 'Gene', name => 'WBGene00006763' });
        $models = $gene->gene_models();

        isnt($models, undef, 'data returned');
        isnt($models->{data}, undef, 'data structure returned');
        isnt($models->{data}{remarks}, undef, 'remarks data structure returned');

        my $ae = $models->{data}{remarks}{3}{evidence}{Accession_evidence};
        is  (scalar @$ae, 2, 'two accession evidences returned');
        is  ($ae->[0]{id}, 'AF283324', 'correct accession returned');
        is  ($ae->[0]{class}, 'sequence', 'correct class returned');

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

    # test automated description obtained through concise_desription
    sub test_automated_description {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00015099' });

        can_ok('WormBase::API::Object::Gene', ('concise_description'));

        my $c_desc = $gene->concise_description();

        isnt($c_desc, undef, 'data returned');
        isnt($c_desc->{data}, undef, 'data structure returned');
        isnt($c_desc->{data}->{evidence}, undef, 'evidence returned');

        my $evidence = $c_desc->{data}->{evidence};
        ok($evidence->{Inferred_automatically}, 'description is inferred automatically');
        my ($inferred_auto_label) = map { $_->{label} } @{$evidence->{Inferred_automatically}};
        ok($inferred_auto_label =~ /^This description was generated automatically/,
           'correct text marking automatically inferred description');

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

# TODO: ADD BACK!
        # ok(grep( $_->{'label'}->{'label'} eq 'RNASeq.brugia.FR3.WBls:0000081.Unknown.WBbt:0007833.PRJEB2709.ERX026030',
        #          @{ $fpkm_expression->{'data'}->{'table'}->{'fpkm'}->{'data'} }),
        #    'correct link returned');


        # # test O. voluvus fpkm data
        # # issue #2864
        # my $gene_ovol = $api->fetch({ class => 'Gene', name => 'WBGene00243220' });

        # my $fpkm_expression_ovol = $gene_ovol->fpkm_expression_summary_ls();

        # ok(grep( $_->{'label'}->{'label'} eq 'RNASeq.ovolvulus.O_volvulus_Cameroon_isolate.WBls:0000108.Unknown.WBbt:0007833.PRJEB2965.ERX200392',
        #          @{ $fpkm_expression_ovol->{'data'}->{'table'}->{'fpkm'}->{'data'}}),
        #    'correct o.vol link returned');

        #test project name
        my $gene_1 = $api->fetch({ class => 'Gene', name => 'WBGene00001530' });
        my $version = $api->version;
        my $fpkm_expression_1 = $gene_1->fpkm_expression_summary_ls();
        is($fpkm_expression_1->{'description'}, 'Fragments Per Kilobase of transcript per Million mapped reads (FPKM) expression data' , 'correct description returned ');

        my @data = @{ $fpkm_expression_1->{'data'}->{'table'}->{'fpkm'}->{'data'} };

        my @data_sub = grep { $_->{'project_info'}->{'id'} eq 'SRP016006' } @data;
        isnt($data_sub[0], undef, 'data returned');
        is($data_sub[0]->{'project_info'}->{'label'}, 'Thomas Male Female comparison', 'correct project description returned');

        my $plot_uri_pttn = "\Q/img-static/rplots/$version/1559/fpkm_WBGene00001530/\E.+";
        like($fpkm_expression_1->{'data'}->{'plot'}->[0]->{'uri'},
             qr/$plot_uri_pttn/,
             'correct plot path returned');

    }

    #Tests the alleles and polymorphisms methods of Gene
    #Related to issue #2809
    sub test_alleles {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00015146' });

        can_ok('WormBase::API::Object::Gene', ('alleles'));
        my $alleles = $gene->alleles()->{data};
        ok(grep($_->{variation}->{label} eq 'gk175216', @$alleles), 'correct allele returned');

        can_ok('WormBase::API::Object::Gene', ('polymorphisms'));
        my $polymorphisms = $gene->polymorphisms()->{data};
        ok(grep($_->{variation}->{label} eq 'WBVar00061322', @$polymorphisms), 'correct polymprphism returned');

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

        #related to issue #2710
    sub test_expression_widget {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00015146' });

        #test microarray_topology_map_position
        can_ok('WormBase::API::Object::Gene', ('microarray_topology_map_position'));

        my $profiles = $gene->microarray_topology_map_position();
        is($profiles->{'description'}, 'microarray topography map', 'correct description returned');
        isnt($profiles->{'data'}, undef, 'data returned');

        my $p = shift @{$profiles->{'data'}};

        is($p->{'id'}, 'B0336.6', 'correct profile id returned');
        is($p->{'class'}, 'expr_profile', 'correct class returned');
        ok($p->{'label'} =~ /Mountain: 11/, 'correct mountain for expression profile returned');


        #test anatomic_expression_patterns
        can_ok('WormBase::API::Object::Gene', ('anatomic_expression_patterns'));

        my $patterns = $gene->anatomic_expression_patterns();
        isnt($patterns->{'data'}, undef, 'data returned');
        is($patterns->{'description'}, 'expression patterns for the gene' , 'correct description returned ');
        is($patterns->{'data'}->{'image'}, '/img-static/virtualworm/Gene_Expr_Renders/WBGene00015146.jpg' , 'correct image returned');


        #test expression_patterns
        can_ok('WormBase::API::Object::Gene', ('expression_patterns'));
        my $expressions = $gene->expression_patterns();
        isnt($expressions->{'data'}, undef, 'data returned');
        is($expressions->{'description'}, 'expression patterns associated with the gene:WBGene00015146' , 'correct description returned ');
        is($expressions->{'data'}[0]->{'description'}->{'text'}, 'Collectively, these approaches revealed that ABI-1 is expressed in a number of neurons within the nerve ring and head, including the amphid interneurons AIYL/R, the RMEL/R motoneurons, coelomocytes, and several classes of ventral cord motoneuron.' , 'correct expression description returned' );
        ok(scalar grep { 'Reporter gene' } @{$expressions->{'data'}[0]->{'type'}}, 'type reporter gene returned');
        ok(scalar grep { 'Cis regulatory element' } @{$expressions->{'data'}[0]->{'type'}}, 'type cis regulatory element returned');
        is($expressions->{'data'}[0]->{'expression_pattern'}->{'id'}, 'Expr8549', 'correct expression pattern returned');

        #test expression_profiling_graphs
        can_ok('WormBase::API::Object::Gene', ('expression_profiling_graphs'));
        my $graphs = $gene->expression_profiling_graphs();
        isnt($graphs->{'data'}, undef, 'data returned');
        is($graphs->{'description'}, 'expression patterns associated with the gene:WBGene00015146' , 'correct description returned ');
        is($graphs->{'data'}[0]->{'description'}->{'text'}, 'Developmental gene expression time-course.  Raw data can be downloaded from ftp://caltech.wormbase.org/pub/wormbase/datasets-published/levin2012' , 'correct expression description returned' );
        ok(scalar grep { 'Microarray' } @{$graphs->{'data'}[0]->{'type'}}, 'correct type returned');
        is($graphs->{'data'}[0]->{'expression_pattern'}->{'id'}, 'Expr1011958', 'correct expression pattern returned');

        #test anatomy_terms
        can_ok('WormBase::API::Object::Gene', ('anatomy_terms'));
        my $anatomy_terms = $gene->anatomy_terms();
        isnt($anatomy_terms->{'data'}, undef, 'data returned');
        is($anatomy_terms->{'description'}, 'anatomy terms from expression patterns for the gene' , 'correct description returned ');
        is($anatomy_terms->{'data'}->{'WBbt:0005751'}->{'class'}, 'anatomy_term' , 'correct anatomy term class returned');
        is($anatomy_terms->{'data'}->{'WBbt:0005751'}->{'label'}, 'coelomocyte' , 'correct anatomy term label returned');
        is($anatomy_terms->{'data'}->{'WBbt:0005751'}->{'id'}, 'WBbt:0005751' , 'correct anatomy term id returned');

        #test expression_cluster
        can_ok('WormBase::API::Object::Gene', ('expression_cluster'));
        my $expression_cluster = $gene->expression_cluster();
        isnt($expression_cluster->{'data'}, undef, 'data returned');
        is($expression_cluster->{'description'}, 'expression cluster data' , 'correct description returned ');
        my ($ec) = grep($_->{'expression_cluster'}->{'id'} eq 'cgc4489_group_2',
                        @{ $expression_cluster->{'data'} });
        ok($ec, 'correct expression cluster id returned');
        is($ec->{'description'}, 'Genome-wide analysis of developmental and sex-regulated gene expression profile.' , 'correct expression cluster description returned');


    }

    sub test_interactions {
        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00006759' });

        can_ok('WormBase::API::Object::Gene', ('interactions'));

        my $data = $gene->interactions()->{data};
        isnt($data, undef, 'data returned');
        isnt($data->{edges}, undef, 'interactions returned');
        my @interactions = @{$data->{edges}};

        # test Effector->Affected interaction
        my ($interaction1) = grep { $_->{interactions}->[0]->{id} eq 'WBInteraction000518902' } @interactions;
        is($interaction1->{interactions}->[0]->{label}, 'unc-22 : unc-54', 'A correction interaction returned');
        is($interaction1->{direction}, 'Effector->Affected', 'correct direction of interacion returned');
        is($interaction1->{type}, 'Suppression', 'correct interaction type returned');

        # test low log-likelihood interaction
        my ($interaction2) = grep { $_->{interactions}->[0]->{id} eq 'WBInteraction000136005' } @interactions;
        is($interaction2, undef, 'An interaction with low log-likelihood correction interaction is NOT returned');

        my ($interaction2) = grep { $_->{interactions}->[0]->{id} eq 'WBInteraction000136005' } @interactions;
        is($interaction2, undef, 'A predicted interaction with low log-likelihood correction interaction is NOT returned');

        # test high log-likelihood interaction
        my ($interaction3) = grep { $_->{interactions}->[0]->{id} eq 'WBInteraction000031891' } @interactions;
        is($interaction3->{interactions}->[0]->{label}, 'unc-105 : unc-22', 'A correction interaction returned');
        is($interaction3->{type}, 'Predicted', 'A predicted interaction with high log-likelihood correction interaction IS returned');
        is($interaction3->{direction}, 'non-directional', 'correct direction of interacion returned');


    }

    sub test_named_by {
        my $gene =  $api->fetch({ class => 'Gene', name => 'WBGene00017620' });
        can_ok('WormBase::API::Object::Gene', ('named_by'));

        my $data = $gene->named_by()->{data};
        isnt($data, undef, 'data returned');

        my @named_by = map { $_->{label} } @$data;

        ok( grep(/\QGregory Hannon\E/, @named_by), 'Person evidence is returned');
        ok( grep(/\QGoh et al., 2014\E/, @named_by), 'Paper evidence is returned');
    }
}

1;
