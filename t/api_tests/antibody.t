#!/usr/bin/env perl

# Unit tests regarding "Antibody" instances.


{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package antibody;

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

    # Test the historical gene method
    sub test_historical_gene {
        my $antibody = $api->fetch({ class => 'Antibody', name => '[WBPaper00041071]::anti-SPE-44' });

        can_ok('WormBase::API::Object::Antibody', ('historical_gene'));

        my $gene = $antibody->historical_gene();

        isnt($gene->{'data'}, undef, 'data returned');
        isnt($gene->{'data'}[0], undef, 'historcal gene returned');
        isnt($gene->{'data'}[0]->{'text'}, undef, 'historcal gene data returned');
        is  ($gene->{'data'}[0]->{'text'}->{'id'}, 'WBGene00045485', 'correct historcal gene returned');
    }

}

1;

