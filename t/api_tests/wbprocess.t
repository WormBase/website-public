#!/usr/bin/env perl
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package wbprocess;

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

    sub test_revision_number {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000001' });
        can_ok('WormBase::API::Object::Wbprocess', ('pathway'));
        my $pathway = $wbprocess->pathway();

        isnt($pathway->{'data'}, undef, 'data returned');
        isnt($pathway->{'data'}[0]->{'pathway_id'}, undef, 'Defined');
        isnt($pathway->{'data'}[0]->{'revision'}, undef, 'Found Revision');
        is($pathway->{'data'}[0]->{'pathway_id'}, 'WP2313', 'Found Id');
    }

    sub test_unfolded_protein {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000046' });
        can_ok('WormBase::API::Object::Wbprocess', ('pathway'));
        my $pathway = $wbprocess->pathway();

        isnt($pathway->{'data'}, undef, 'data returned');
        isnt($pathway->{'data'}[0]->{'pathway_id'}, undef, 'Defined');
        is($pathway->{'data'}[0]->{'pathway_id'}, 'WP2578', 'Found Id');
    }

    # This is a test for the Wikipathways in the Pathways widget in teh Topis page 
    # related to issue #2856
    sub test_pathways {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000039' });

        can_ok('WormBase::API::Object::Wbprocess', ('pathway'));

        my $pathway = $wbprocess->pathway();

        
        isnt($pathway->{'data'}, undef, 'data returned');
        isnt($pathway->{'data'}[0]->{'pathway_id'}, undef, 'Defined');
        is($pathway->{'data'}[0]->{'pathway_id'}, 'WP2233', 'correct id returned');
    }    

}

1;
