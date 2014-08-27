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
        my ($err, $markedup_omims) = $disease->markup_omims(\@test_omims_subset_1);
        is($err, undef, 'No error with external API');
        ok(%$markedup_omims, "markedup OMIM returned");
        my $markedup1 = $markedup_omims->{$test_omims[0]};
        ok($markedup1->{'label'} =~ /ASPERGER SYNDROM/, "correct OMIM markup returned");

        # test remembering previously reqeusted items
        my $ref_unknown = $disease->_select_unknown(\@test_omims);
        my @unknown_omims = @{$ref_unknown};
        ok(grep(/300497/, @unknown_omims), "'300497' HAS NOT been requested before");
        my $found_in_unknown = grep(/300494/, @unknown_omims);
        is(grep(/300494/, @unknown_omims), 0, "'300494' HAS been requested before");

        # test reqeusting more items
        $disease->markup_omims(\@test_omims);
        ok($disease->known_omims->{$test_omims[0]}, 'first items requested');
        ok($disease->known_omims->{$test_omims[1]}, 'second items requested');

    }

    # test resource_error attribute (a static/class attribute) of the Role OMIM
    # is updated based on external API response, and
    # is recovered after waiting
    sub test_omim_error {
        my $fake_response_class = Moose::Meta::Class->create(
            'FakeResponse',
                methods => {
                code => sub { return '409'}
            },
        );
        my $fake_resp = $fake_response_class->new_object();

        can_ok($fake_resp, ('code'));
        is($fake_resp->code, '409', 'Fake response is working, generating a fake error code');

        my $disease = $api->fetch({ class => 'Disease', name => 'DOID:206' });
        is($disease->resource_error->{'error_time'}, undef, 'Resource error has No error_time at the beginning');

        my $err;
        eval {$disease->_process_response($fake_resp)} || do {$err = $@};

        isnt($err, undef, 'Got an error with fake error response');
        ok(defined $disease->resource_error->{'error_time'}, 'Resource error time is updated');

        my @test_omims = ('133700', '133701');
        # test data returning when external API is not available
        my ($err_msg, $markedup_omims) = $disease->markup_omims(\@test_omims);
        isnt($err_msg, undef, 'Got an error with fake error response');
        is(scalar keys %$markedup_omims, 2, 'correct number of marked up OMIMs returned');
        is($markedup_omims->{$test_omims[0]}->{'label'}, 'OMIM:133700', 'correct label of the OMIM returned despite error');

        # test persistence of error across objects
        my $disease2 = $api->fetch({ class => 'Disease', name => 'DOID:0050432' });
        ok(defined $disease2->resource_error->{'error_time'}, 'Resource error time is updated');

        # test reset of the error
        my $an_hour_ago = time() - 3600;
        $disease->resource_error->{'error_time'} = $an_hour_ago;  #fake error time
        ok($disease->waited(), 'Waiting has happened');
        is($disease->resource_error->{'error_time'}, undef, 'Resource error has No error_time after waiting');

        # normality of retrieving external data after resetting the error status
        my ($err_msg_1, $markedup_omims_1) = $disease->markup_omims(\@test_omims);
        is($err_msg_1, undef, 'no error message');
        is(scalar keys %{$markedup_omims_1}, 2, 'correct number of marked up OMIMs returned');
        is($markedup_omims_1->{$test_omims[0]}->{'label'}, 'EXOSTOSES, MULTIPLE, TYPE I',
           'correct label of the OMIM returned with external API back to normal');
     }

    # test error flag, which will be used to decide to cache a widget
    # ensure error flag is set if and only if external API related error occurred
    sub test_omim_error_flag {
        my $fake_response_class = Moose::Meta::Class->create(
            'FakeResponse',
                methods => {
                code => sub { return '409'}
            },
        );
        my $fake_resp = $fake_response_class->new_object();

        sub clear_hash {
            my ($h) = @_;
            for (keys %$h){
                delete $h->{$_};
            }
        }

        my $disease = $api->fetch({ class => 'Disease', name => 'DOID:206' });
        is($disease->resource_error->{'error_time'}, undef, 'Resource error has No error_time at the beginning');
        can_ok('WormBase::API::Object::Disease', ('genes_biology'));
        clear_hash($disease->known_omims);  #force it to call external than using locally stored data
        is($disease->genes_biology->{'error'}, undef, 'No error flag with genes_biology field');

        # fake error to disrupt external API
        can_ok($fake_resp, ('code'));
        is($fake_resp->code, '409', 'Fake response is working, generating a fake error code');
        my $err;
        clear_hash($disease->known_omims);  #force it to call external than using locally stored data
        eval {$disease->_process_response($fake_resp)} || do {$err = $@};
        isnt($err, undef, 'Got an error with fake error response');
        isnt($disease->genes_biology->{'error'}, undef, 'Error flag specified with genes_biology field');

        # After recovering from error state
        my $an_hour_ago = time() - 3600;
        $disease->resource_error->{'error_time'} = $an_hour_ago;  #fake error time
        clear_hash($disease->known_omims);  #force it to call external than using locally stored data
        is($disease->genes_biology->{'error'}, undef, 'Again No error flag with genes_biology field');
    }

}

1;
