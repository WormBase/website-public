#!/usr/bin/env perl

# tree display tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package tree;

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

    # Testing tree display for ACe class that doesn't map to a WB class
    sub test_tree_display_non_wb_class {
        my $result = $api->_tools->{tree}->run({
            'name' => '[cgc5475]:day16-19',
            'class' => 'Microarray_experiment'
        });

        ok(@{$result->{tree}}, 'tree returned for Ace class object');
    }

    # No longer appliable: we consider Author and Person different now - SG, Feb 2019
    #
    # # Testing tree display for Multiple ACe classes mapping to same WB class
    # sub test_tree_display_multiple_aceclass {
    #     my $result = $api->_tools->{tree}->run({
    #         'name' => 'Argon Y',
    #         'class' => 'Person'
    #     });
    #     ok(@{$result->{tree}}, 'tree returned for Author object when requesting WB class Person');
    #     is($result->{object}->{class}, 'Author', 'tree for an Author');

    # }
}

1;
