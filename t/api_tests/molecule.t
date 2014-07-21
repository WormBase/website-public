#!/usr/bin/env perl

# Tests for the Molecule object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package molecule;

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

    # Tests to make sure that the molecule object has a references method
    sub test_references {
        my $molecule = $api->fetch({ class => 'Molecule', name => 'WBMol:00001538' });

        can_ok('WormBase::API::Object::Molecule', ('references'));

        my $references = $molecule->references();
        isnt($references->{'data'}, undef, 'data returned');
    }

}

1;

