#!/usr/bin/env perl

# This is a unit test template for implementing tests that work
# with a running WormBase Website instance.
#
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/live_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#
# Actual tests are implemented at the bottom of this file. Please see:
#
# 1. test_port_open
# 2. test_single_gene_overview

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package template;

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
    # defined in t/live.t.
    my $configuration;

    # A setter method for passing on configuration settings from t/live.t to
    # the subs of this package.
    sub config {
        $configuration = $_[0];
    }

    # This is an example test that checks whether the test server is running.
    # The test will always succeed, because this condition is already being
    # a prerequisite that is being checked by the calling code (t/live.t).
    sub test_port_open {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $sock = IO::Socket::INET->new(PeerAddr => "$host:$port");

        # Please keep test names/descriptions all lower case.
        isnt($sock, undef, 'port open');
    }

    # This is another example test that retrieves information about a gene
    # via the RESTful API. The test demonstrates a granular testing approach
    # that reveals the failing point to great detail, if the returned data
    # should not adhere to the spec defined by the test.
    sub test_single_gene_overview {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/rest/widget/gene/WBGene00006763/overview?content-type=application/json";
        my $response = from_json(get($url));

        isnt($response, undef, 'populated data structure');
        isnt($response->{'fields'}, undef, 'data fields defined');
        isnt($response->{'fields'}->{'name'}, undef, 'data field "name" defined');
        isnt($response->{'fields'}->{'name'}->{'data'}, undef, '"name" data field has data attached to it');
        isnt($response->{'fields'}->{'name'}->{'data'}->{'id'}, undef, 'data of the "name" data field contains an "id" key');
        is  ($response->{'fields'}->{'name'}->{'data'}->{'id'}, 'WBGene00006763', 'matching accession');
    }

}

1;

