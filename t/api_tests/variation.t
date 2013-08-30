#!/usr/bin/env perl

# Unit tests regarding "Variation" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package variation;

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

    # Tests nucleotide change method
    sub test_nucleotide_change {
        my $var = $api->fetch({ class => 'Variation', name => 'WBVar00068686' });

        can_ok('WormBase::API::Object::Variation', ('nucleotide_change'));

        my $ntc = $var->nucleotide_change();

        isnt($ntc->{data}, undef, 'data returned');
        is  ($ntc->{data}[0]->{wildtype_label}, 'reference', 'correct wildtype label');
        is  ($ntc->{data}[0]->{wildtype}, 'T', 'correct wildtype');
        is  ($ntc->{data}[0]->{mutant}, 'G', 'correct mutant');
        is  ($ntc->{data}[0]->{mutant_label}, 'HK104', 'correct mutant label');
    }

}

1;

