#!/usr/bin/env perl

# REST tests for the gene page
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package gene;

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

    # This test checks the links in the blastp matches in the homology widget
    sub test_homology_blastp_matches {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};

        my $url_html = "http://$host:$port/rest/widget/gene/WBGene00006763/homology";
        my $response_html = get($url_html);
        isnt($response_html =~ /http:\/\/www.ensembl.org/, '', 'external links added to html');

        my $url = "http://$host:$port/rest/widget/gene/WBGene00006763/homology?content-type=application/json";
        my $response = from_json(get($url));

        isnt($response, undef, 'populated data structure');
        isnt($response->{'fields'}, undef, 'data fields defined');
        isnt($response->{'fields'}->{'best_blastp_matches'}, undef, 'data field "best_blastp_matches" defined');
        isnt($response->{'fields'}->{'best_blastp_matches'}->{'data'}, undef, '"best_blastp_matches" data field has data attached to it');
        isnt($response->{'fields'}->{'best_blastp_matches'}->{'data'}->{'hits'}, undef, '"best_blastp_matches" data has hits!');
        isnt($response->{'fields'}->{'best_blastp_matches'}->{'data'}->{'hits'}[5]->{'class'}, 'ENSEMBLE', 'Use the ENSEMBLE class - external linking in table');
    }

    # Test if wormbase id/all fields with no key specified are being displayed
    sub test_id_field {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};

        my $url_html = "http://$host:$port/rest/widget/gene/WBGene00006763/overview";
        my $response_html = get($url_html);

        # I'm trying to make sure the WormBase ID field does not have the 'disabled' class.
        isnt($response_html =~ /<div class\=\"field\s+\"\>  \<div class\=\"field-title\"\>\s+\<span title\=\"\"\ .+?> WormBase ID/, '', 'WormBase ID field displayed');
    }

    # Test if links treat gene names lin-15 and lin-15A differently
    sub test_linking_to_genes {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};

        my $url_html = "http://$host:$port/rest/widget/gene/WBGene00003004/overview?download=1&content-type=text%2Fhtml";
        my $response_html = get($url_html);

        ok($response_html =~ /lin-15/, 'contains gene lin-15');
        ok($response_html =~ /lin-15A/, 'contains gene lin-15A');
        ok($response_html =~ /<a href="\/search\/gene\/lin-15" class="gene-link">lin-15<\/a>/,
           'contains links to gene lin-15');
        ok($response_html =~ /<a href="\/search\/gene\/lin-15A" class="gene-link">lin-15A<\/a>/,
           'contains links to gene lin-15A');

    }

    # Test links to topo maps
    sub test_linking_to_topo_maps {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};

        my $url_html = "http://$host:$port/rest/widget/gene/WBGene00015099/expression?download=1&content-type=text%2Fhtml";
        my $response_html = get($url_html);

        ok($response_html =~ /B0280\.1\b/, 'lists a topo map');
        ok($response_html =~ /B0280\.11\b/, 'lists another topo map');
        ok($response_html =~ /href=\"\/species\/(c_elegans|all)\/expr_profile\/B0280.1\"/,
           'contains links to one topo map');
        ok($response_html =~ /href=\"\/species\/(c_elegans|all)\/expr_profile\/B0280.11\"/,
           'contains links to another topo map');

    }

}

1;
