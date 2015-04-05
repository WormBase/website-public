#!/usr/bin/env perl

# For the 'can_ok' tests it is necessary to include the Perl module here.
use WormBase::API::Service::rserve;

# Unit tests regarding plot/chart generation using an R backend.
{
    # Rserve testing package.
    package rserve;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    # This variable will hold a reference to a WormBase API object.
    my $api;

    # Some test data that is used with barcharts and boxplots.
    my $testdata = [
        {
            'value'      => '3.97874',
            'label'      => 'RNASeq_Hillier.L4_larva_Male_cap2_Replicate2',
            'project'    => 'RNASeq_Hillier',
            'project_info' => { id => 'testID1' },
            'life_stage' => {id => 'WBls:0000024'}
        },
        {
            'value'      => '1e-10',
            'label'      => 'RNASeq.elegans.SRP015688.L4.linker-cells.nhr-67.4',
            'project'    => 'RNASeq_Hillier',
            'project_info' => { id => 'testID1' },
            'life_stage' =>  {id => 'WBls:0000024'}
        },
        {
            'value'      => '5.7759',
            'label'      => 'RNASeq_Hillier.L4_Larva_Replicate1',
            'project'    => 'RNASeq_Hillier',
            'project_info' => { id => 'testID1' },
            'life_stage' =>  {id => 'WBls:0000024'}
        }
    ];

    # Parameters that are passed along when generating barcharts and boxplots.
    my $plot_parameters = {
        filename => 'fpkm_WBGene00015146FAKE.png',
        xlabel => 'X Label',
        ylabel => 'Y Label',
        width  => 1000,
        height => 1000
    };


    # A setter method for passing on a WormBase API object from t/api.t to
    # the subs of this package.
    sub config {
        $api = $_[0];
    }

    # Test whether subs that are required by all charting/plotting implementations
    # are present and
    sub test__framework {
        can_ok('WormBase::API::Service::rserve', ('init_chart'));
        can_ok('WormBase::API::Service::rserve', ('execute_r_program'));
    }

    # # Test that a barchart can be produced.
    # sub test__barchart {
    #     can_ok('WormBase::API::Service::rserve', ('barchart'));

    #     my $plot_result = $api->_tools->{rserve}->barchart($testdata, $plot_parameters);
    #     isnt($plot_result, undef, 'plot result nonempty');
    #     is  (exists $plot_result->{'uri'}, 1, '"uri" key present in result set');
    #     isnt($plot_result->{'uri'}, undef, '"uri" key-value present in result set');
    #     like($plot_result->{'uri'}, qr/\/img-static\/rplots\/.+/, 'image URI returned');
    # }

    # Test that a boxplot can be produced.
    sub test__boxplot {
        can_ok('WormBase::API::Service::rserve', ('boxplot'));

        my $plot_result = $api->_tools->{rserve}->boxplot($testdata, $plot_parameters);
        isnt($plot_result, undef, 'plot result nonempty');
        isnt($plot_result->[0]->{'uri'}, undef, '"uri" key-value present in result set');
        like($plot_result->[0]->{'uri'}, qr/\/img-static\/rplots\/.+/, 'image URI returned');
    }
}

1;
