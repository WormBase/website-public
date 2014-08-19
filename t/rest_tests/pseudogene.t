#!/usr/bin/env perl

{
    package pseudogene;

    use strict;

    use Test::More;

    use LWP::Simple qw(get);
    use JSON        qw(from_json);

    my $configuration;

    sub config {
        $configuration = $_[0];
    }

    # A test for the type description in the Overview widget
    sub test_type_description {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/rest/widget/pseudogene/C06A1.4/overview?download=1&content-type=text%2Fhtml";
        my $response_html = get($url);

        ok($response_html =~ /A pseudogenic loci that appears to have once been coding/, 'contains the type description');

    }

}

1;

