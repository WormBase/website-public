 #t/WormBase/API/Object/Gene.t

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
use PrintOut;
use Ace;

my @test_classes = ("Clone","Gene","Protein","Disease");
my %test_objects = (
    Gene    => ['WBGene00028408'],
    Disease => ["staphyloenterotoxemia"],
    Protein => ["WP:CE23248"],
    CDS     => ["Y110A7A.10"],
    Clone   => ["15E4"]
);

foreach my $class (@test_classes){
    
    print "\n\n\n";
    print "Testing $class\n";

    
    my $test_objects = $test_objects{$class};
    print "Looking for: ".join(",",@$test_objects)."\n";

    #BEGIN {
    #      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Gene'); ## "::$class"
    #} # Gene.t loads ok

    my $tester = WormBase::Test::API::Object->new({
        conf_file => 'data/conf/test.conf',
        class     => $class,
    });

    # uncomment appropriate test procedure



    $tester->run_common_tests({
        names                   => $test_objects,
        exclude_parents_methods => 1, # don't want to test parent methods
        exclude_roles_methods   => 1, # don't want to test role methods
        
    });
}

done_testing();




