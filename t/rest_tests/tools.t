#!/usr/bin/env perl

# REST tests for the tools section
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package tools;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    # This template is for running tests against a live WormBase Website
    # installation. As such, the following modules are included to
    # carry out REST operations in a single line of Perl code.
    use LWP::Simple qw(get getprint);
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

    # This test checks if the non-existant tool 'foo' returns a 404
    sub test_non_extistant_tools {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/tools/foo?content-type=application/json";
        my $response = getprint($url);

        is($response, '405', '404 returned for tool "foo"');
    }

}

1;

