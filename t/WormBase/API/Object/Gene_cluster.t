#t/WormBase/API/Object/Gene_cluster.t

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

my $class = 'Gene_cluster';
my $tag = '<<TAG of interest in class>>';

## get test object with a tag data populated (hopefully)
# my $test_objects = PrintOut::get_features($class,$tag); 

## list test_objects 
my $test_objects = ["HIS3_cluster"];

BEGIN {
      use_ok($WormBase::Test::API::Object::OBJECT_BASE . '::Gene_cluster'); ## "::$class"
} # Gene_cluster.t loads ok

my $tester = WormBase::Test::API::Object->new({
    conf_file => 'data/conf/test.conf',
    class     => 'Gene_cluster',
});

# uncomment appropriate test procedure

 my $test_type = 'all' ; ## 
#my $test_type = 'methods';

## list methods to be tested here

my @methods = qw(
			

				);
###

if ($test_type eq 'methods') {
	$tester->run_common_tests({
		names                   => $test_objects,
		include_methods => \@methods,    
	});

	foreach my $test_object (@$test_objects) {
		my $wb_object = $tester->fetch_object_ok($test_object);	
		foreach my $method (@methods) {
			print "\n#######\n";
			note("Testing $method()...");
			my $result = $wb_object->$method;
			PrintOut::print_data($result); ## 
		}
	}
}
else {
	$tester->run_common_tests({
		names   => $test_objects,   
		exclude_parents_methods => 1, # don't want to test parent methods
    	exclude_roles_methods   => 1, # don't want to test role methods
	});
}

done_testing();




