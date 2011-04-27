# t/WormBase/API/Object/Variation.t

use strict;
use warnings;

BEGIN {
    use FindBin '$Bin';
    chdir "$Bin/../../.."; # /t
    use lib 'lib';
    use lib '../lib';
}

use Test::More;
use WormBase::Test::API::Object;

my @object_names = qw(WBVar00094689 tm1325 e936 tm501);

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Variation',
});

$tester->run_common_tests({
    names                   => \@object_names,
    exclude_parents_methods => 1,
    exclude_roles_methods   => 1,
});

# specific tests

my $e205 = $tester->fetch_object_ok('e205');

my $taxonomy = $tester->call_method_ok($e205, 'taxonomy');
$tester->compliant_data_ok($taxonomy, 'taxonomy');
is("$taxonomy->{data}{genus} $taxonomy->{data}{species}", 'Caenorhabditis elegans',
   'e205 calling taxonomy returning correct data');

my $nucl_change = $tester->call_method_ok($e205, 'nucleotide_change');
$tester->compliant_data_ok($nucl_change, 'nucleotide_change');
my $first_change = $nucl_change->{data}->[0];
subtest 'e205 calling nucleotide_change returning correct data' => sub {
    isa_ok($first_change, 'HASH');
    is($first_change->{type}, 'Substitution');
    is($first_change->{wildtype}, 'g');
    is($first_change->{mutant}, 'a');
    is($first_change->{wildtype_label}, 'wild type');
    is($first_change->{mutant_label}, 'mutant');
};

my $flanks = $tester->call_method_ok($e205, 'flanking_sequences');
$tester->compliant_data_ok($flanks, 'flanks');
is("$flanks->{data}{left_flank}:$flanks->{data}{right_flank}",
   'agctgagcaaattcgacgatggcgatctat:gattgtactgaatagtggagaaatggcatt',
   'e205 calling flanking_sequences returning correct data');

# # this test needs to be checked
# my $genomic_position = $tester->call_method_ok($e205, 'genomic_position');
# $tester->compliant_data_ok($genomic_position, 'genomic_position');
# is($genomic_position->{data}[0]{pos_string},
#    'IV:13263584..13263584');

done_testing;

#     } elsif ($method eq 'context') {
# 	# Context is a biggie containing lots of meta information
# 	# But we need to call other methods to adequately test / display informative debug information
# 	my $coords = $e205->genomic_position;

# note("VARIATION COORDS: " .
# join("\t",$coords->{data}->{abs_start},
# $coords->{data}->{abs_stop},
# $coords->{data}->{start},
# $coords->{data}->{stop}));

