#!/usr/bin/perl

use strict;
use FindBin qw/$Bin/;

my $htmlroot = "$Bin/../../root/docs/api";
my $libroot  = "$Bin/../../lib/WormBase/API";

my $pod = get_pod();

opendir (DIR,"$libroot/Object") || die "Couldn't open the lib dir for processing";

while (my $file = readdir DIR) {
#    next unless $file =~ /laboratory/i;

    next if ($file =~ /^\./);
    next if $file =~ /^\#/;
    # Read the current code into a buffer
    open (LIB,"$libroot/Object/$file") || die "Couldn't open the current library file";

    my @code;
    while (<LIB>) {
	if ($_ =~ /^\#\ \<\<\ include\ (.*)\ \>\>/) {

	    # Get the corresponding pod
	    push @code,"\n\n";
	    push @code,@{$pod->{$1}};
	    push @code,"\n\n";
	}
	push @code,$_;
    }
    close LIB;
    
    # Write code to temp file
    open (TMP,">/var/tmp/pod.tmp");
    print TMP join('',@code);
    close TMP;

    # Now turn it into POD...
    my ($title) = $file =~ /(.*)\.pm/;
    system("pod2html --title='WormBase API: $title' /var/tmp/pod.tmp > $htmlroot/$title.html");
    
    # Delete the tmpfile
    system("rm -f /var/tmp/pod.tmp");
}

# Parse code snippets from Role/Object.pm
sub get_pod {
    my @roles = glob("$libroot/Role/*.pm");
    my %pod;
    foreach my $role (@roles) {
	open (LIB,"$libroot/Role/$role") || die "Couldn't open the role file for fetching boilerplate POD";
	
	my $in_stanza;
	while (<LIB>) {
	    if ($_ =~ /^=head3\s(.*)/) {
		$in_stanza = 1;
	    }
	    push @{$pod{$1}},$_ if $in_stanza;
	    
	    
	    if ($in_stanza && $_ =~ /^=cut/) {
		$in_stanza = undef;
	    }       
	}
	close LIB;    
    }
    return \%pod;
}



    
