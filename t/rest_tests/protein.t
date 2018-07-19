#!/usr/bin/env perl

# This is a unit test for protein via REST API
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/rest_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package protein;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    # This template is for running tests against a live WormBase Website
    # installation. As such, the following modules are included to
    # carry out REST operations in a single line of Perl code.
    use LWP::Simple qw(get);
    use JSON        qw(from_json);

    # This variable will hold a hash reference with configuration parameters
    # that are passed to the package using the sub "config". Its contents are
    # defined in t/rest.t.
    my $configuration;

    # A setter method for passing on configuration settings from t/rest.t to
    # the subs of this package.
    sub config {
        $configuration = $_[0];
    }

    # test that the external link from a motif details table
    # via the RESTful API.
    sub test_motif_details_external_link {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url_html = "http://$host:$port/rest/widget/protein/CE03840/motif_details?download=1&content-type=text%2Fhtml";
        my $response_html = get($url_html);

        ok($response_html =~ /PFAM\:PF01030/, 'contains PFAM:PF01030 motif');
        my $pfam_obj_url = 'http://pfam.xfam.org/family/PF01030';
        ok($response_html =~ /<a href="\Q$pfam_obj_url\E"/, 'links to Pfam');

        ok($response_html =~ /INTERPRO\:IPR020635/, 'contains INTERPRO:IPR020635 motif');
        my $interpro_obj_url = 'http://www.ebi.ac.uk/interpro/entry/IPR006212';
        ok($response_html =~ /<a href="\Q$interpro_obj_url\E"/, 'links to InterPro');

    }

}

1;
