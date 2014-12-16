#!/usr/bin/env perl

# Pseudogene API tests

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package pseudogene;

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

    sub test_single_pseudogene {
        my $pg = $api->fetch({ class => 'Pseudogene', name => 'Y106G6D.5a:wp245' });

        can_ok('WormBase::API::Object::Pseudogene', qw/
            parent_sequence
            from_lab
            gene
            transposon
            brief_id
            type
            related_seqs
            microarray_results
            alleles
            polymorphisms
            matching_cdnas
            sage_tags
            predicted_exon_structure
        /);

        isnt($pg->parent_sequence,'undef','parent_sequence data returned');
        isnt($pg->from_lab,'undef','from_lab data returned');
        isnt($pg->gene,'undef','gene data returned');
        isnt($pg->transposon,'undef','transposon data returned');
        isnt($pg->brief_id,'undef','brief_id data returned');
        isnt($pg->type,'undef','type data returned');
        isnt($pg->related_seqs,'undef','related_seqs data returned');
        isnt($pg->microarray_results,'undef','microarray_results data returned');
        isnt($pg->alleles,'undef','alleles data returned');
        isnt($pg->polymorphisms,'undef','polymorphisms data returned');
        isnt($pg->matching_cdnas,'undef','matching_cdnas data returned');
        isnt($pg->sage_tags,'undef','sage_tags data returned');
        isnt($pg->predicted_exon_structure,'undef','predicted_exon_structure data returned');
    }

    # This is an example test that checks whether a particular gene can be
    # returned and whether the resulting data structure contains certain
    # data entries.
#    sub test_single_gene {
#        my $gene = $api->fetch({ class => 'Gene', name => 'WBGene00006763' });

#        can_ok('WormBase::API::Object::Gene', ('locus_name'));

#        my $locus_name = $gene->locus_name();

        # Please keep test names/descriptions all lower case.
#        isnt($locus_name->{'data'}, undef, 'data returned');
#        isnt($locus_name->{'data'}->{'class'}, undef, 'class specified');
#        isnt($locus_name->{'data'}->{'id'}, undef, 'id specified');
#        isnt($locus_name->{'data'}->{'label'}, undef, 'label specified');
#        isnt($locus_name->{'data'}->{'taxonomy'}, undef, 'taxonomy specified');
#        is  ($locus_name->{'data'}->{'class'}, 'Gene', 'correct class fetched');
#        is  ($locus_name->{'data'}->{'id'}, 'WBGene00006763', 'correct gene fetched');
#        is  ($locus_name->{'data'}->{'taxonomy'}, 'c_elegans', 'species with associated gene correct');
#    }

}

1;
