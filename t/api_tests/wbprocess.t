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
        isnt($pathway->{'data'}[0]->{'pathway_id'}, undef, 'defined');
        isnt($pathway->{'data'}[0]->{'revision'}, undef, 'found revision');
        is($pathway->{'data'}[0]->{'pathway_id'}, 'WP2313', 'found id');
    }


    # This is a test for the Wikipathways in the Pathways widget in the Topics page
    # related to issue #2856
    sub test_pathways {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000039' });

        can_ok('WormBase::API::Object::Wbprocess', ('pathway'));

        my $pathway = $wbprocess->pathway();

        isnt($pathway->{'data'}, undef, 'data returned');
        isnt($pathway->{'data'}[0]->{'pathway_id'}, undef, 'pathway id defined');
        is($pathway->{'data'}[0]->{'pathway_id'}, 'WP2233', 'correct pathway id returned');


        # formerly test_unfolded_protein
        my $wbprocess_unfolded = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000046' });
        my $pathway_unfolded = $wbprocess_unfolded->pathway();

        isnt($pathway_unfolded->{'data'}, undef, 'data returned');
        isnt($pathway_unfolded->{'data'}[0]->{'pathway_id'}, undef, 'pathway id defined');
        is($pathway_unfolded->{'data'}[0]->{'pathway_id'}, 'WP2578', 'found id for protein folding process');
    }

    #Test the related_process in the Overview widget
    #related to issue #2862
    sub test_related_topics {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000040' });

        can_ok('WormBase::API::Object::Wbprocess', ('related_process'));

        my $related_process = $wbprocess->related_process();
        my @keys = keys $related_process->{'data'};

        isnt($related_process->{'data'}, undef, 'data returned');
        isnt($keys[0], undef, 'related topics group retuned');
        isnt($related_process->{'data'}->{'Generalisation of'}, undef, 'related topic returned');
        my ($related) = grep {
            $_->{id} eq 'WBbiopr:00000006';
        } @{$related_process->{'data'}->{'Generalisation of'}};
        isnt($related, undef, 'correct related topic returned');

    }

    sub test_involved_genes {
        my $wbprocess = $api->fetch({ class => 'Wbprocess', name => 'WBbiopr:00000002' });

        can_ok('WormBase::API::Object::Wbprocess', ('genes'));

        my $g = $wbprocess->genes();
        isnt($g->{'data'}, undef, 'data returned');

        my @genes = @{ $g->{data} };
        my ($gene_mec_10) = grep { $_->{name}->{label} eq 'mec-10'; } @genes;
        ok($gene_mec_10, 'correct gene returned');
    }
}

1;
