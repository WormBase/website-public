#!/usr/bin/env perl

# This is a unit test template for implementing tests that work
# with a running WormBase Website instance.
#
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/rest_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#
# Actual tests are implemented at the bottom of this file. Please see:
#
# 1. test_port_open
# 2. test_single_gene_overview

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package movies;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    use LWP::Simple qw(get getstore);
    use JSON        qw(from_json);

    my $configuration;

    sub config {
        $configuration = $_[0];
    }

    sub test_port_open {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $sock = IO::Socket::INET->new(PeerAddr => "$host:$port");

        # Please keep test names/descriptions all lower case.
        isnt($sock, undef, 'port open');
    }

    sub test_movies {
        my $host = $configuration->{'host'};
        my $port = $configuration->{'port'};
        my $url = "http://$host:$port/img-static/movies/200806024_lin-11_7H3_1_L1.mov";
        
        print $url,"\n";

        my $filename = 'delete.x';
        unlink $filename if -e $filename;;
        my $file = getstore($url, $filename);

        #print "\n\n",-e $filename,"\n\n";
        
        is  (-e $filename, 1, 'movie found at url');
        unlink $filename;
    }

}

1;

