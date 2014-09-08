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

        can_ok('WormBase::API::Object::Clone', ('remarks'));

        my $remarks = $clone->remarks();

        isnt($remarks->{'data'}, undef, 'data returned');
        my $remark_text = 'Probable link by 4.5kb PCR';
        my @matched_remark = grep { $_->{'text'} eq $remark_text } @{$remarks->{'data'}};
        isnt(@matched_remark, (), 'remark returned');
        is(@matched_remark[0]->{'text'}, $remark_text, 'correct remark returned');
    }

}

1;
