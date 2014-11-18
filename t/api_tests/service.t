#!/usr/bin/env perl

# service (datasource, gff database) tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package service;

    # Limit the use of unsafe Perl constructs.
    use strict;

    # We use Test::More for all tests, so include that here.
    use Test::More;

    # This variable will hold a reference to a WormBase API object.
    my $api;

    # A setter method for passing on a WormBase API object from t/api.t to
    # the subs of this package.
    sub config {
        $api = $_[0];
    }

    # Testing connecting to datasource and gff databases
    sub test_service_connect {
        my @db_names = keys %{$api->_services};
        @db_names = grep { !/map$/ } @db_names;  #special db, not sure what they do

        foreach my $source (@db_names){
            my $db = $api->_services->{$source};

            my $err;
            my $dbh;
            eval { $dbh = $db->dbh; } || do {
                $err = $@;  print "$err\n";
            };
            isnt($dbh, undef, "$source database handle returned");
        }
    }

}

1;
