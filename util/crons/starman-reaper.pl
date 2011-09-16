#!/usr/bin/perl

# Clean up starman processes that have grown too large.

# Run as cron every 30 minutes:
# */30 * * * * /usr/local/wormbase/admin/crons/starman-reaper.pl [104857600]

use strict;
my $bytes = shift;

#die "Usage: $0 ram_limit_in_bytes\n" unless $bytes;

# 500 MB limit for now
$bytes ||= '524288000';

my $processes;

if (open ($processes, "/bin/ps -eo pid,rss,comm | grep starman | ")) {
#if (open ($processes, "/bin/ps -o pid= -o vsz= -p `cat $ppid`|")) {
    my @memory_hogs;
    my %memory_hogs;


    while (<$processes>) {
	chomp;
	my ($pid,$mem,$name) = split;

	# ps shows KB.  we want bytes.
	$mem *= 1024;
	
	if ($mem >= $bytes) {
	    push @memory_hogs, $pid;
	    $memory_hogs{$pid} = $mem/1024) / 1024);
	}
    }
    
    close($processes);
    
    # kill them slowly, so that all connection serving
    # children don't suddenly die at once.	
    foreach my $hog (@memory_hogs) {
	print STDERR "HUPing memory hog $hog\n";
#	kill 'HUP', $hog;
	system("kill -9 $hog");
	sleep 10;
    }
} else {
    die "Can't get process list: $!\n";
}

