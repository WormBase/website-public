#!/usr/bin/env perl

# Person page tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package person;

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

    # Tests previous addresses
    sub test_previous_addresses {

        # test previous address for Lincoln Stein
        my $person = $api->fetch({ class => 'Person', name => 'WBPerson1482' });

        can_ok('WormBase::API::Object::Person', ('previous_addresses'));

        my $previous_addresses = $person->previous_addresses();

        isnt($previous_addresses->{'data'}, undef, 'data returned');
          is($previous_addresses->{'data'}[0]->{'institution'}, "Cold Spring Harbor Laboratory, Cold Spring Harbor NY, USA", 'correct previous address');

        # test previous address for person with no previous address
        $person = $api->fetch({ class => 'Person', name => 'Kim do H' });
        $previous_addresses = $person->previous_addresses();

        isnt($previous_addresses, undef, 'data structure returned');
          is($previous_addresses->{'data'}, undef, 'does not break with no old_address');


    }

}

1;

