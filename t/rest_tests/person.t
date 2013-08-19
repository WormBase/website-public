#!/usr/bin/env perl

# Rest tests for the Person page

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package person;

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

    # Check person overview for a case-sensitive url
    sub test_single_person_overview {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url_html = "http://$host:$port/rest/widget/person/WBPerson15014/overview";
        my $response_html = get($url_html);

        isnt($response_html =~ /href\=\"http\:\/\/www\.bact\.wisc\.edu\/faculty\.php\?init\=HGB\&show\=LAB\"/, '', 'lab link is case sensitive');

    }

}

1;

