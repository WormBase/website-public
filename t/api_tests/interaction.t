#!/usr/bin/env perl

# Unit tests regarding "Interaction" instances.

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package interaction;

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
        my $interaction = $api->fetch({ class => 'Interaction', name => 'WBInteraction000006446' });

        can_ok('WormBase::API::Object::Interaction', ('historical_gene'));

        my $gene = $interaction->historical_gene();

        isnt($gene->{'data'}, undef, 'data returned');
        isnt($gene->{'data'}[0], undef, 'historcal gene returned');
        isnt($gene->{'data'}[0]->{'text'}, undef, 'historcal gene data returned');
        is  ($gene->{'data'}[0]->{'text'}->{'id'}, 'WBGene00020998', 'correct historcal gene returned');
    }

}

1;

