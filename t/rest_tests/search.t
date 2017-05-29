#!/usr/bin/env perl

# Search REST tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package search;

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

    # test markup - #2976
    sub test_markup {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url_html = "http://$host:$port/search/gene/dpy-/1?inline=1&content-type=text%2Fhtml";
        my $response_html = get($url_html);

        isnt($response_html, undef, 'data returned');
        ok($response_html =~ /dpy-23/, 'contains gene dpy-23');

        ok($response_html =~ /<span class="locus"><a href="\/search\/gene\/dpy-23" class="gene-link">dpy-23<\/a><\/span>/,
           'contains links to gene dpy-23');
        ok($response_html =~ /<span class="locus"><a href="\/search\/gene\/dpy-23" class="gene-link">dpy-23<\/a><\/span> encodes/,
           'contains link in description to gene dpy-23');
    }

    # test external linking - #3025
    sub test_external_link {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url_html = "http://$host:$port/search/disease/bone/1?inline=1&content-type=text%2Fhtml";
        my $response_html = get($url_html);

        isnt($response_html, undef, 'data returned');
        ok($response_html =~ /DOID\:184/, 'contains doid:184');

        my $do_url = "http://www.disease-ontology.org/?id=DOID:184";
        ok($response_html =~ qr/^\Q$do_url\E$/,
           'contains links to doid:184');
    }

}

1;
