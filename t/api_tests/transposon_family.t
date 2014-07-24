#!/usr/bin/env perl


{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package transposon_family;

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

    sub test_tfs {
        can_ok('WormBase::API::Object::Transposon_family', qw/
            title
            description
            family_members
            variations
            motifs
        /);

        my $tf = $api->fetch({ class => 'Transposon_family', name => 'Tc4' });
        isnt($tf, undef, 'data returned');
        isnt($tf->title, undef, 'title returned');
        isnt($tf->description, undef, 'description returned');
        isnt($tf->family_members, undef, 'transposons returned');
        isnt($tf->variations, undef, 'variations returned');


        my $tf_motif = $api->fetch({ class => 'Transposon_family', name => 'Tc6' });
        isnt($tf_motif, undef, 'data returned');
        isnt($tf_motif->motifs, undef, 'motif data returned');

    }


}

1;

