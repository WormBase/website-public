#!/usr/bin/env perl

# Rest tests for the Person page

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package anatomy;

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

    # Check anatomy ontology_browser for child_nucleus_of relationship
    sub test_anatomy_ontology_browser {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $anatomy_id    = 'WBbt:0001002';
        my $url_base      = "http://$host:$port";

        my $url_rest      = $url_base . "/rest/widget/anatomy_term/$anatomy_id/ontology_browser";
        my $response_rest = get($url_rest);
        is($response_rest =~ /$anatomy_id/, 1, "contains $anatomy_id");

        my $run_link      = "/tools/ontology_browser/run?inline=1&class=anatomy_term&name=$anatomy_id";
        my $run_escaped   = $run_link; $run_escaped =~ s/\//\\\//g; $run_escaped =~ s/\?/\\\?/g;	# escape characters for regex
        is($response_rest =~ /$run_escaped/, 1, "contains run link $anatomy_id");

        my $url_run       = $url_base . $run_link;
        my $response_run  = get($url_run);
        is($response_run  =~ /child_nucleus_of/, 1, "contains child_nucleus_of");
    }

    # Check WormAtlas url
    sub test_anatomy_wormatlas {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $anatomy_id    = 'WBbt:0008218';
        my $url_base      = "http://$host:$port";

        my $url_rest      = $url_base . "/rest/widget/anatomy_term/$anatomy_id/overview";
        my $response_rest = get($url_rest);
        ok($response_rest =~ /$anatomy_id/, "contains $anatomy_id");

        my $wa_link      = "http://wormatlas.org/hermaphrodite/somatic gonad/Somframeset.html";
        my $wa_escaped   = $wa_link; $wa_escaped =~ s/\//\\\//g; $wa_escaped =~ s/\?/\\\?/g;	# escape characters for regex
        ok($response_rest =~ /$wa_escaped/, "contains single escaped WormAtlas link $anatomy_id");

        my $wa_response  = get($wa_link); #get returns undef if failed
        isnt($wa_response, undef, "WormAtlas url is working");
    }

    # check neuralnet url
    sub test_anatomy_neuralnet {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url_base      = "http://$host:$port";

        my $anatomy_id    = 'WBbt:0004003';
        my $url_rest      = $url_base . "/rest/widget/anatomy_term/$anatomy_id/external_links";
        my $response_rest = get($url_rest); #get returns undef if failed
        isnt($response_rest, undef, "request widget succeeds");

        my $expect_link      = "http://wormweb.org/neuralnet#c=ADFL&m=0";

        # make sure calling the expected url succeeds
        my $expect_response  = get($expect_link); #get returns undef if failed
        isnt($expect_response, undef, "Neuralnet url is working");

        # check the expected link is present in the widget rest response
        ok($response_rest =~ /\Q$expect_link\E/, "response contains neuralnet link for $anatomy_id");


    }

}

1;
