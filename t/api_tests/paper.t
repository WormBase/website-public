#!/usr/bin/env perl

#tests for the Paper object

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package paper;

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

    # Tests refers_to method
    sub test_refers_to {
        my $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00004400' });

        can_ok('WormBase::API::Object::Paper', ('refers_to'));

        my $refers_to = $paper->refers_to();

        # Please keep test names/descriptions all lower case.
        isnt($refers_to->{'data'}, undef, 'data returned');
        isnt($refers_to->{'data'}->{'Gene'}, undef, 'genes refered to found');
        is($refers_to->{'data'}->{'Gene'}->[0]->{'label'}, 'air-1', 'a correct gene returned');

        # test for count accuracy
        $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00041190' });
        $refers_to = $paper->refers_to();

        # Please keep test names/descriptions all lower case.
        isnt($refers_to->{'data'}, undef, 'data returned');

        cmp_ok($refers_to->{'data'}->{'Expr_pattern'}, '>', 0, 'correct number of expression patterns found');

    }

    sub test__refers_to_evidence {
        my $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00041128' });

        can_ok('WormBase::API::Object::Paper', ('refers_to'));

        my $refers_to = $paper->refers_to();

        isnt($refers_to->{'data'}, undef, 'data returned');
        isnt($refers_to->{'data'}->{'Gene'}, undef, 'genes refered to found');

        my @ref_genes = @{$refers_to->{'data'}->{'Gene'}};
        my ($g) = grep { eval { $_->{'text'}->{'label'} eq 'nduo-2' } } @ref_genes;
        isnt($g, undef, 'gene with different Published_as name returned');
        is($g->{'evidence'}->{'Published_as'}->[0]->{'id'}, 'ND2', 'correct published_as name returned');

    }

    #tests the name parsing algorithm - does it work for multi-word names?
    sub test__parsed_authors {
        my $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00032910' });

        can_ok('WormBase::API::Object::Paper', ('_parsed_authors'));

        my $parsed_authors = $paper->_parsed_authors();

        # Please keep test names/descriptions all lower case.
        isnt($parsed_authors, undef, 'data returned');
        isnt($parsed_authors->{'van der Voet M'}, undef, 'van der voet m found');
          is($parsed_authors->{'van der Voet M'}[0], "M", 'van der voet m first name correctly parsed to m');
          is($parsed_authors->{'van der Voet M'}[1], " van der Voet", 'van der voet m last name correctly parsed to van der voet');

    }

    #test doi - some environments were giving it a false value
    sub test_doi {
        my $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00023007' });

        can_ok('WormBase::API::Object::Paper', ('doi'));

        my $doi = $paper->doi();

        isnt($doi, undef, 'data returned');
          is($doi->{'data'}, undef, 'no doi for this paper');

        # test on paper with doi
        $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00027286' });
        $doi = $paper->doi();

        isnt($doi, undef, 'data returned');
          is($doi->{'data'}, "10.1895/wormbook.1.1.1", 'correct doi returned (doi exists)');

        # test on paper with doi from #2799
        $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00036072' });
        $doi = $paper->doi();

        isnt($doi, undef, 'data returned');
          is($doi->{'data'}, "10.1534/genetics.110.116293", 'correct doi returned (doi exists)');


        # test on paper with multiple names
        $paper = $api->fetch({ class => 'Paper', name => 'WBPaper00000802' });
        $doi = $paper->doi();

        isnt($doi, undef, 'data returned');
          is($doi->{'data'}, "10.1007/BF01024112", 'correct doi returned (multiple names)');
    }

}

1;
