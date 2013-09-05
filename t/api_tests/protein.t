#!/usr/bin/env perl

# Unit tests regarding "Protein" instances.
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package protein;

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

    # Tests whether the __build_genetic_position returns multiple genetic
    # positions for the protein WP:CE00285.
    sub test__genetic_positions {
        my $protein = $api->fetch({ class => 'Protein', name => 'WP:CE00285' });

        can_ok('WormBase::API::Object::Protein', ('_build_genetic_position'));

        my $positions = $protein->_build_genetic_position();

        isnt($positions, undef, 'data returned');
        isnt($positions->{'data'}, undef, 'data hash not empty');
        $positions = $positions->{'data'};
        is  (scalar @$positions, 2, 'two genes present');
    }

    # Tests whether the __build_genomic_position returns multiple genomic
    # positions for the protein WP:CE00285.
    sub test__genomic_positions {
        my $protein = $api->fetch({ class => 'Protein', name => 'WP:CE00285' });

        can_ok('WormBase::API::Object::Protein', ('_build_genomic_position'));

        my $positions = $protein->_build_genomic_position();

        isnt($positions, undef, 'data returned');
        isnt($positions->{'data'}, undef, 'data hash not empty');
        $positions = $positions->{'data'};
        is  (scalar @$positions, 2, 'two genes present');
    }

}

1;

