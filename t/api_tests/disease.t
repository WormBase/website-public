#!/usr/bin/env perl


# API unit tests for the disease class
{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package disease;

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

    # genes_by_biology method unit test
    sub test_genes_by_biology {
        my $disease = $api->fetch({ class => 'Disease', name => 'DOID:9970' });
        
        # Test if the object contains this method
        can_ok('WormBase::API::Object::Disease', ('genes_biology'));
        
        my $genes_biology = $disease->genes_biology;
        isnt( $genes_biology, undef, "data returned");
        
        my $genes_by_biology = $genes_biology->{data};
        is( ref $genes_by_biology, 'ARRAY', "data contains array reference");
        
        # This object should have 7 genes by biology
        is(scalar @$genes_by_biology, 7, 'correct number of genes by biology');
    }
    
    # test OMIM external API stuff
    sub test_markup_omims {
        my $disease = $api->fetch({ class => 'Disease', name => 'DOID:0050432' });
        
        # Test if the object contains this method
        can_ok('WormBase::API::Object::Disease', ('markup_omims'));
        my @test_omims = ('300494', '300497');
        my @test_omims_subset_1 = ($test_omims[0]);
        my @markedup_omims = @{$disease->markup_omims(\@test_omims_subset_1)};
        ok(@markedup_omims, "markedup OMIM returned");
        my $markedup1 = pop @markedup_omims;
        ok($markedup1->{'label'} =~ /ASPGX1/, "correct OMIM markup returned");

        # test remembering previously reqeusted items
        my $ref_unknown = $disease->_select_unknown(\@test_omims);
        my @unknown_omims = @{$ref_unknown};
        ok(grep(/300497/, @unknown_omims), "'300497' HAS NOT been requested before");
        my $found_in_unknown = grep(/300494/, @unknown_omims);
        is(grep(/300494/, @unknown_omims), 0, "'300494' HAS been requested before");

        # test reqeusting more items
        @{$disease->markup_omims(\@test_omims)};
        ok($disease->known_omims->{$test_omims[0]}, 'first items requested');
        ok($disease->known_omims->{$test_omims[1]}, 'second items requested');

    }

}

1;

