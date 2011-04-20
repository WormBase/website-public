package PrintOut;
use Ace;
use strict;

sub get_features {
	my $class = shift;
	my $tag = shift;
	my $DB = Ace->connect(-host=>'localhost', -port=>2005);
	my @test_objects;
	my $counts = 0;
	my @features = $DB->fetch(-class=>$class);
		foreach my $feature (@features) {
			my @data = $feature->$tag;
			if ($counts < 1) {
				if (@data) {
					print "$feature\n";
					push @test_objects, "$feature";
					$counts++;
				}
				else {
					next;
				}		
			} 
			else {
				last;
			}
		}
	return \@test_objects;
}


sub print_array{
	my ($array_ref) = @_;
	foreach my $element (@{$array_ref}){
		print "$element\n";
	}
}

sub print_hash{
	my ($hash_ref) = @_;
	foreach my $key (keys %{$hash_ref}){
		print "$key\:\:${$hash_ref}{$key}\n";
	}
}

sub print_object_name{
	my ($object) = @_;
	my $object_name;
	if($object){
		$object_name = $object->name;
	}
	else{
		$object_name = 'none';
	}
	print "$object_name\n";
}

sub print_object_data{
	my ($object,$method) = @_;
	my $object_name;
	my $object_data;
	
	if($object){
	
		$object_data = $object->$method;
	}
	else{
	
	$object_data = 'none';
	}
	print "$object_data\n";
}

sub print_array_of_hashes {
	my ($array_ref) = @_;
	foreach my $element (@{$array_ref}){
		print_hash ($element);
	}
}

sub print_hash_of_hashes {
	my ($hash_ref) = @_;
	foreach my $key (keys %{$hash_ref}){
		print "$key\=\>n";
		print_hash(${$hash_ref}{$key});
	}
}
		
sub print_hash_of_arrays {
	print "print_hash_of_arrays \=\> TBD\n";
}
	
sub print_array_of_arrays {
	print "print_array_of_arrays \=\> TBD\n";
}

sub print_hash_of_objects {
	print "print_hash_of_objects \=\> TBD\n";
}

sub print_array_of_objects {
	my ($array_ref,$method) = @_;
	foreach my $element (@{$array_ref}){
		print_object_data ($element,$method);
	}
}

sub data_type {
	my ($ref) = @_;
	my $data_type;
	
	my (@data,%data,$data,$object_name);

	eval{$object_name = $ref->name;};
	eval{%data = %{$ref};};
	eval{@data = @{$ref};};
	eval{$data = ${$ref};};
	
	if($object_name){
		$data_type = 'OBJECT';		
	}
	else {
		if (%data){
				$data_type = 'HASH';
		}
		elsif (@data){
				$data_type = 'ARRAY';
		}
		else{
				$data_type = 'SCALAR';
		}
	} 
	return $data_type;
}

sub print_data {
	my ($data, $level) = @_;
			if (!($level)) {
			$level = 0
		}
		$level++;
		
		my $spacer = "";
		
		for (1 .. $level) {
			$spacer = $spacer . "\t";
		}
	
	my $data_type = data_type($data);
	
	if ($data_type eq 'OBJECT'){
		print "$data";
	}
	elsif ($data_type eq 'SCALAR'){
		print "$data";
	}
	elsif($data_type eq 'ARRAY'){
		print "ARRAY:";
		foreach my $array_datum  (@{$data}){
			print "\n$spacer";	
			print_data($array_datum);
		}		
	}
	elsif($data_type eq 'HASH'){
		
		foreach my $key (keys %{$data}){

			print "\n$spacer";			
			print "$key\=\>";
			print_data(${$data}{$key}, $level);
		}
	}
}



1;
