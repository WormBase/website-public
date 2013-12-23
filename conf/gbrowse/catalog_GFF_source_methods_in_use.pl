#!/usr/bin/perl

use strict;
my $root = '/usr/local/ftp/pub/wormbase/releases';
my $release = shift;
chomp $release;

my $features = { };
opendir DIR,"$root/$release/species" or die "Couldn't open the dir: $!";



while (my $species = readdir(DIR)) {
    next if ($species =~ /^\./);
    next if ($species =~ /ASSEMBLIES/);

    my $species_path = "$root/$release/species/$species";

    opendir BPID_DIR,"$species_path" or die "Coudln't open the dir: $!";
    while (my $bp_id = readdir(BPID_DIR)) {
	warn $bp_id;
	next if ($bp_id =~ /^\./);
	
	warn "$species $bp_id";
	
	my ($source_file,$gff_version);
	my $path = "$root/$release/species/$species/$bp_id";
#    if (-e "$path/$species.$release.annotations.gff2.gz") {
#	$source_file = "$path/$species.$release.annotations.gff2.gz";
#	$gff_version = 2;
	if (-e "$path/$species.$bp_id.$release.annotations.gff3.gz") {
	    $source_file = "$path/$species.$bp_id.$release.annotations.gff3.gz";
	    $gff_version = 3;
	} else { warn "No GFF file for $species..." && next}
	
	open FILE, "gunzip -c $source_file |" or warn $! && next;
	
	$features->{species}->{$species}->{gff_version} = $gff_version;
	$features->{species}->{$species}->{file} = $source_file;
	print STDERR "Processing $source_file...\n";;
	while (my $line = <FILE>) {
	    next if $line =~ /^\#/;	
	    my ($ref,$source,$method,@rest) = split(/\t/,$line);
	    $features->{species}->{$species}->{features}->{"$source:$method"}++;	
	    $features->{global}->{"$source:$method"}++;
	}
	close FILE;
    }
}



# Process
foreach my $species ( sort keys %{$features->{species}} ) {
    my $gff_version = $features->{species}->{$species}->{gff_version};
    my $file        = $features->{species}->{$species}->{file};
    print "$species\n";
    print "gff_version: $gff_version\n";
    print "file: $file\n";
    print join("\t",qw/feature source method count/) . "\n";
    foreach my $feature (sort { $a cmp $b } keys %{$features->{species}->{$species}->{features}}) {
	my ($source,$method) = split(":",$feature);
	print join("\t",$feature,$source,$method,$features->{species}->{$species}->{features}->{$feature}) . "\n";	
    }
    print "\n\n";
}


# Now global features with presence/absence in species.

print join("\t",'FEATURE',sort keys %{$features->{species}}),"\n";
foreach my $feature (sort {$a cmp $b } keys %{$features->{global}}) {
    my @values;
    push @values,$feature;
    my ($source,$method) = split(":",$feature);
    push @values,$source,$method;
    foreach my $species ( sort keys %{$features->{species}} ) {
	my $val = $features->{species}->{$species}->{features}->{$feature};
	$val ||= 0;       
	push @values,$val;
    }
    print join("\t",@values);
    print "\n";
}
