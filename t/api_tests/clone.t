#!/usr/bin/env perl

{
    package clone;

    use strict;

    use Test::More;

    my $api;

    sub config {
        $api = $_[0];
    }

    # Test remarks method in Clone page
    # related to issue 2935
    sub test_single_gene {
        my $clone = $api->fetch({ class => 'Clone', name => '2L52' });

        can_ok('WormBase::API::Object::Gene', ('remarks'));

        my $remarks = $clone->remarks();

        isnt($remarks->{'data'}, undef, 'data returned');
        isnt($remarks->{'data'}[0]->{'text'}, undef, 'remark returned');
        is($remarks->{'data'}[0]->{'text'}, 'Probable link by 4.5kb PCR', 'correct remark returned');
    }

}

1;

