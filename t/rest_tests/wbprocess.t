#!/usr/bin/env perl

{
    package wbprocess;

    use strict;

    use Test::More;

    use LWP::Simple qw(get);
    use JSON        qw(from_json);

    my $configuration;

    sub config {
        $configuration = $_[0];
    }

    # test presense of wikipathway links
    sub test_wiki {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/rest/widget/wbprocess/WBbiopr:00000039/pathways?download=1&content-type=text%2Fhtml";
        my $response_html = get($url);

        ok($response_html =~ /<a href="https:\/\/www.wikipathways.org\/index.php\/Pathway:WP2233">https:\/\/www.wikipathways.org\/index.php\/Pathway:WP2233<\/a>/,
        'contains a link to the first Wikipathway');

        ok($response_html =~ /<a href="https:\/\/www.wikipathways.org\/index.php\/Pathway:WP2234">https:\/\/www.wikipathways.org\/index.php\/Pathway:WP2234<\/a>/,
        'contains a link to the second Wikipathway');

    }

}

1;
