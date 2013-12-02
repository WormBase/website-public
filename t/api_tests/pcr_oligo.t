#!/usr/bin/env perl

# Pcr_oligo class tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package pcr_oligo;

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

    # test on_orfeome_project method - make sure it's really empty
    sub test_on_orfeome_project {
        my $pcr = $api->fetch({ class => 'Pcr_oligo', name => 'sjj_F32E10.3' });

        can_ok('WormBase::API::Object::Pcr_oligo', ('on_orfeome_project'));

        my $orfeome = $pcr->on_orfeome_project();

        is  ($orfeome->{'data'}, undef, 'data correctly empty');
    }

}

1;

