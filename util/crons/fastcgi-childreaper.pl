#!/usr/bin/perl

# FastCGI child reaper (to trap slow copy-to-write memory leaks)

# Run as cron every 30 minutes:
# */30 * * * * /usr/local/wormbase/admin/crons/fastcgi-childreaper.pl `cat /var/run/wormbase/wormbase.pid` [104857600]


use strict;

my ($ppid, $bytes) = @ARGV;

die "Usage: kidreaper PPID ram_limit_in_bytes\n" unless $ppid;

# 250 MB limit for now
$bytes ||= '262144000';

my $kids;

if (open ($kids, "/bin/ps -o pid= -o vsz= -p `cat $ppid`|")) {
    my @goners;

    while (<$kids>) {
	chomp;
	my ($pid, $mem) = split;

	# ps shows KB.  we want bytes.
	$mem *= 1024;
	
	if ($mem >= $bytes) {
	    push @goners, $pid;
	}
    }
    
    close($kids);
    
    if (@goners) {

	# kill them slowly, so that all connection serving
	# children don't suddenly die at once.
	
	foreach my $victim (@goners) {
	    print STDERR "HUPing goner $victim\n";
	    kill 'HUP', $victim;
	    sleep 10;
	}
    }
} else {
    die "Can't get process list: $!\n";
}

