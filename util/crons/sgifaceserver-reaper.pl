#!/usr/bin/perl

# Clean up sgifaceserver processes that are too big.

# Run as cron every 30 minutes:
# */30 * * * * /usr/local/wormbase/admin/crons/sgifaceserver-reaper.pl [104857600]

use strict;
my $bytes = shift;

#die "Usage: $0 ram_limit_in_bytes\n" unless $bytes;

# 4000 MB limit for now, in bytes
$bytes ||= '4194304000';

my $processes;

kill_hogs('sgifaceserver');

sub kill_hogs {
    my $ps = shift;
    
    if (open ($processes, "/bin/ps -eo pid,rss,comm | grep $ps | ")) {
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
		$memory_hogs{$pid} = ($mem/1024) / 1024;
	    }
	}
	
	close($processes);
	
	# kill them slowly, so that all connection serving
	# children don't suddenly die at once.	
	# There should only be a single sgifaceserver process running.
	foreach my $hog (@memory_hogs) {
	    print STDERR "HUPing memory hog $hog\n";
#	kill 'HUP', $hog;

	    system("chown root /usr/local/wormbase/acedb/wormbase/database/serverlog.wrm");
	    system("echo ' ' > /usr/local/wormbase/acedb/wormbase/database/serverlog.wrm");

            # ensure that acedb owns the logs - there is some other log rotation
            # functionality that periodically sets the owner to root.
            system("chown acedb:acedb /usr/local/wormbase/acedb/wormbase/database/serverlog.wrm");
	    system("chown acedb:acedb /usr/local/wormbase/acedb/wormbase/database/log.wrm");
	    system("kill -9 $hog");
	    sleep 10;	
	}
    } else {
	die "Can't get process list: $!\n";
    }
}
