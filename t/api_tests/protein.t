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

    sub test__motif_details {
        my $protein = $api->fetch({ class => 'Protein', name => 'WP:CE03840' });
        can_ok('WormBase::API::Object::Protein', ('motif_details'));

        my $motif_data = $protein->motif_details;
        isnt($motif_data, undef, 'data returned');
        ok($motif_data->{'data'}, 'motifs not empty');

        my @motifs = @{$motif_data->{'data'}};  # must dereferencing the array
        my @some_motifs = ();
        my $some_start_positions = {};

        # take all instances of a specific motif, put into @some_motifs. and
        # take all start positons and make them keys of a hash, used to test for existence later
        foreach my $mo (@motifs) {
            if ($mo->{'feat'}->{'label'} eq 'INTERPRO:IPR006212') {
                push @some_motifs, $mo;
                my $strt = $mo->{'start'};
                $some_start_positions->{$strt} = 1; # True
            }
        }
        ok(@some_motifs, 'spsecific motifs returned');
        ok(exists($some_start_positions->{259}), 'test one of the start positions');
        ok(exists($some_start_positions->{747}), 'test another start positions');


        # test a motif source
        my $mo_x = pop @some_motifs;
        is($mo_x->{'source'}->{'db'}, 'interpro', 'corrcet db for the source database');
        is($mo_x->{'source'}->{'id'}, 'IPR006212', 'correct id for the source database');
    }


    # Test class in hits - best_blastp_matches
    # issue #2950
    sub test_best_blastp_matches {
        my $protein = $api->fetch({ class => 'Protein', name => 'BM:BM38825' });

        can_ok('WormBase::API::Object::Protein', ('best_blastp_matches'));

        my $hits = $protein->best_blastp_matches();

        isnt($hits, undef, 'data returned');
        isnt($hits->{'data'}, undef, 'data hash not empty');
        like(@{$hits->{'data'}{'hits'}}[0]->{'hit'}{'class'}, qr/protein/i, 'hit returned correct class')

    }

}

1;
