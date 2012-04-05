#!/usr/bin/perl

# Clean up starman processes that have grown too large.

# Run as cron every 30 minutes:
# */30 * * * * /usr/local/wormbase/admin/crons/starman-reaper.pl

use strict;

#die "Usage: $0 ram_limit_in_bytes\n" unless $bytes;

# 500 MB limit for now, in bytes
my $bytes = '524288000';

my $processes;

my $time = `date`;
chomp $time;

kill_hogs('starman');
kill_hogs('perl');

sub kill_hogs {
    my $ps = shift;
    
    if (open ($processes, "/bin/ps -eo pid,rss,comm | grep $ps | ")) {
#if (open ($processes, "/bin/ps -o pid= -o vsz= -p `cat $ppid`|")) {
	my @memory_hogs;
	
	while (<$processes>) {
	    chomp;
	    my ($pid,$mem,$name) = split;

	    # ps shows KB.  we want bytes.
	    my $mem_in_bytes  = $mem * 1024;
	    my $mem_in_mbytes = $mem/1024;
	    
	    if ($mem_in_bytes >= $bytes) {
#		push @memory_hogs, $pid;
		push @memory_hogs, [$pid,$mem_in_mbytes];
	    }
	}
	
	close($processes);
	
	# kill them slowly, so that all connection serving
	# children don't suddenly die at once.	

	if (@memory_hogs > 0) {
	    print "We found some hogs at $time; reaping:\n";
	}

	my $hostname = `hostname`;
	foreach my $hog (@memory_hogs) {
	    my ($pid,$mem) = @$hog;
	    print "\tKilled $pid; it was using $mem MB memory\n";
#	kill 'HUP', $hog;
	    system("kill -9 $pid");
	    sleep 10;	
	}
    } else {
	die "Can't get process list: $!\n";
    }
}
