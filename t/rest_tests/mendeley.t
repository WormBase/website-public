#!/usr/bin/env perl

# Testing of Mendeley related API calls.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package mendeley;

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

    # Retrieves related papers for a given publication. Checks whether:
    # 
    #   1. the returned result is not empty
    sub test_related_papers {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/rest/widget/paper/WBPaper00027286/related_papers?content-type=application/json";
        my $response = from_json(get($url));

        isnt($response, undef, 'populated related_papers data structure');
    }

}

1;

