#!/usr/bin/env perl


#  Test an Phenotype object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package phenotype;

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


    sub test_description_evidence {
        my $phenotype = $api->fetch({ class => 'Phenotype', name => 'WBPhenotype:0000643' });

        can_ok('WormBase::API::Object::Phenotype', ('description'));

        my $descr = $phenotype->description();
        my $descr_data = $descr->{'data'} && $descr->{'data'}->[0];
        isnt($descr_data, undef, 'data returned');

        my $evidence_map = $descr_data->{evidence} || undef;
        isnt($evidence_map, undef, 'evidence data returned');

        my ($go_term_evidence) = grep {
            $_->{id} eq 'GO:0040011';
        } @{$evidence_map->{GO_term_evidence} || []};

        isnt($go_term_evidence, undef, 'GO term evidence returned');
        is ($go_term_evidence->{label}, 'GO:0040011(locomotion)','right GO term label for evidence is returned');
    }

    sub test_go_term {

        my $phenotype = $api->fetch({ class => 'Phenotype', name => 'WBPhenotype:0000583' });

        can_ok('WormBase::API::Object::Phenotype', ('go_term'));

        my $go_term = $phenotype->go_term;
        isnt($go_term->{'data'}, undef, 'data returned');

        my ($term1) = grep {
            $_->{label} eq 'body morphogenesis';
        } @{$go_term->{data}};
        ok($term1, 'correct GO term returned');

    }

}

1;
