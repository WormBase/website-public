#!/usr/bin/env perl

# This is a unit test template for implementing tests that work
# with a running WormBase Website instance.
#
# Unit tests are called automagically, just adhere to the following:
#
# 1. the unit test is placed in the t/api_tests folder
# 2. the filename and package name coincide (sans suffix)
# 3. unit test names have the prefix "test_"
#
# Actual tests are implemented at the bottom of this file. Please see:
#
# 1. test_single_gene

{
    # Package name is the same as the filename (sans suffix, i.e. no .t ending)
    package transcript;

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

    sub test_transcript_features {
        my $transcript = $api->fetch({ class => 'Transcript', name => 'B0336.10.2' });

        can_ok('WormBase::API::Object::Transcript', ('feature'));

        my $features = $transcript->feature();

        # Please keep test names/descriptions all lower case.
        isnt($features->{'data'}, undef, 'data returned');
        is  ( scalar keys %{$features->{'data'}}, 3, "correct number of features returned");
    }

    sub test_print_sequence {

        # -ve strand test
        my $transcript = $api->fetch({ class => 'Transcript', name => 'B0041.11.1' });
        can_ok('WormBase::API::Object::Transcript', ('print_sequence'));

        my $sequence = $transcript->print_sequence();
        isnt($sequence->{'data'}, undef, 'data returned');
        is (scalar @{$sequence->{'data'}}, 3, 'correct amount of sequences returned -ve strand');

        foreach my $seq (@{$sequence->{'data'}}) {
            if($seq->{'header'} eq "unspliced + UTR"){
                is($seq->{'length'}, 1059, 'correct unspliced length returned -ve strand');
            } elsif ($seq->{'header'} eq "spliced + UTR") {
                is($seq->{'length'}, 427, 'correct spliced length returned -ve strand');
                my $spliced = '<span style="Color: #808080">aggatcggatgg</span><span style="Background-color: #FFFF00">ATGGATGGATCAACGACGATCGGGATGGATAGATCCGGGACAGATCGAGATGGACTG</span><span style="Background-color: #FFA500">ATCTCTAGCAA' . "\n" .
                    'ACGACGAAGGATGGATGGTAGGAAAGGATGGATGGTTGGAACAATGGAAATAGAAAATCCAAAGGG</span><span style="Background-color: #FFFF00">ATGTTGA</span><span style="Color: #808080">aagctga' . "\n" .
                    'ttgaagaaattctggacaatcggttgaatgggccgaccaatcaggatggatggatcgggacgagacgacgacgacgacaa' . "\n" .
                    'acaataaggatggacggatggattgggacgatcgaaagggatttgggacaaaatgacgacgacaaaggatggatgaattc' . "\n" .
                    'gggacggatcgggatggacg</span><span style="Color: #808080">cgatcgatggatggatggacgaggcaacaacgaccacgaacgattaggatggatggatgg' . "\n" .
                    'aaggatcgatcg</span><span style="Color: #808080">gatctcaagcaaaca</span>';
                is($seq->{'sequence'}, $spliced, "correct spliced sequence returned -ve strand");
            } elsif ($seq->{'header'} eq "conceptual translation") {
                is($seq->{'length'}, 46, 'correct protein length returned -ve strand');
                is($seq->{'sequence'}, "MDGSTTIGMDRSGTDRDGLISSKRRRMDGRKGWMVGTMEIENPKGC*", 'correct protein sequence returned -ve strand');
            }
        }

        # +ve strand test
        $transcript = $api->fetch({ class => 'Transcript', name => 'AC3.1' });

        $sequence = $transcript->print_sequence();
        isnt($sequence->{'data'}, undef, 'data returned');
        is (scalar @{$sequence->{'data'}}, 3, 'correct amount of sequences returned +ve strand');

        foreach my $seq (@{$sequence->{'data'}}) {
            if($seq->{'header'} eq "unspliced + UTR"){
                is($seq->{'length'}, 1313, 'correct unspliced length returned +ve strand');
            } elsif ($seq->{'header'} eq "spliced + UTR") {
                is($seq->{'length'}, 1068, 'correct spliced length returned +ve strand');
                my $spliced = '<span style="Background-color: #FFFF00">ATCATTCCACTTCGCATCATCTCAATATCAACGGTCTACTCTCCCGAATACAAGAATTCAAACGGAGCGAAGTATTGCAG' . "\n" .
                    'TAACAATAACAACCCATTAA</span><span style="Background-color: #FFA500">TAGCAACACATTGGACCATTGTTGCTCTAACTCTCCATTCCAGTGCAAATGCAATTGTAA' . "\n" .
                    'TGGTTATCACATATCCTCCATACAGACATTTTGTAATGCTATGGAAAACGAACAG</span><span style="Background-color: #FFFF00">GTTTACCCAAATCTCGTTGATAAAT' . "\n" .
                    'TTGCAAGTCTACCAAACTACGTGGTATTTGATTCCAATATATGGGCAATTGTATTCTTTGCATTCATATTTTTTGGTTGT' . "\n" .
                    'ACATATACACTTGTTTTGATTGTCACAACTACTTATCAAATGTTCAAAATATTAGACGATAATCGAAAACATATCAGTGC' . "\n" .
                    'TTCAAACTATGCAAAGCATCGAGCCACTTTGAGAAGTCTTTTAGCTCAGTTTACAACGTGTTTCTTGATTGTTGGTCCAG' . "\n" .
                    'CGTCTTTGTTCTCTTTACTGGTAGTTATAAGATATGAACATAGTCAAG</span><span style="Background-color: #FFA500">ACATATACTGCATTTACCATTTGCTTGGTAGC' . "\n" .
                    'CAGTGCTTTGAATAGTTGCTTTGTTCGGAAGCATCAAGCAATTTCTAAAATCAGCTCTAAATATCTTCTCGATAATGTTA' . "\n" .
                    'CATACTGCATTGTTATATTTCTACTCAATATATATCCAGTTATTGCTGCATCTTTACTTTATTTGAGCATGCTCAATAAG' . "\n" .
                    'TCCGAACAAGTTGAATTGGTGAAATCG</span><span style="Background-color: #FFFF00">TTTGCTGGATGGTTGATGGATCTTCATCTATCTACTTTTATGCAGTTCATTCC' . "\n" .
                    'ATTATTCCCAGTTTTTGGAGGATATTGTACTGGACTCTTGACTCAAATTTTCAGAATTGACGATTCATTTCAAACG</span><span style="Background-color: #FFA500">ATGA' . "\n" .
                    'TCATGTTCACAGAAGCTGAAGTTATGAGTTTTTCATACGCCGTTGATTTTGGAGTTCCCGAATGGCTCAAACTTTACTAT' . "\n" .
                    'CACGTCATTTCCGTGGTGTCAACTGTTATTTCATTTTTCTCAATGTACATAATTTTGTTTCAAAGTGGGAAAATGGATGG' . "\n" .
                    'ATATCGATTCTATCTATTTTATATGCAG</span>';
                is($seq->{'sequence'}, $spliced, "correct spliced sequence returned +ve strand");
            } elsif ($seq->{'header'} eq "conceptual translation") {
                is($seq->{'length'}, 356, 'correct protein length returned +ve strand');
                is($seq->{'sequence'}, "IIPLRIISISTVYSPEYKNSNGAKYCSNNNNPLIATHWTIVALTLHSSANAIVMVITYPPYRHFVMLWKTNRFTQISLINLQVYQTTWYLIPIYGQLYSLHSYFLVVHIHLF*LSQLLIKCSKY*TIIENISVLQTMQSIEPL*EVF*LSLQRVS*LLVQRLCSLYW*L*DMNIVKTYTAFTICLVASALNSCFVRKHQAISKISSKYLLDNVTYCIVIFLLNIYPVIAASLLYLSMLNKSEQVELVKSFAGWLMDLHLSTFMQFIPLFPVFGGYCTGLLTQIFRIDDSFQTMIMFTEAEVMSFSYAVDFGVPEWLKLYYHVISVVSTVISFFSMYIILFQSGKMDGYRFYLFYMQ", 'correct protein sequence returned +ve strand');
            }
        }
    }

}

1;

