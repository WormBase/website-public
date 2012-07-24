#!/usr/bin/perl

# Clean up starman processes that have grown too large.

# Run as cron every 30 minutes:
# */30 * * * * /usr/local/wormbase/admin/crons/starman-reaper.pl

BEGIN {
    push @INC,(
        '/usr/local/wormbase/extlib/lib/perl5/x86_64-linux-gnu-thread-multi',
        '/usr/local/wormbase/extlib/lib/perl5',
    );
}


use strict;
# Gmail doesn't use fixed width fonts. Boo.
use MIME::Lite;

my $size_limit_in_bytes = '524288000';


my $processes_killed = check_processes();

# For ec2, we fetch hostnames and IPs via the rest API.
my ($date,$external_ip,$hostname);
if (@$processes_killed) {
    $date = `date "+%Y %d %h %Y (%a) - %l:%M%P %Z"`;
    chomp $date;
    $external_ip = `curl -S http://169.254.169.254/latest/meta-data/public-ipv4`;
    chomp $external_ip;
    $hostname    = `curl -S http://169.254.169.254/latest/meta-data/public-hostname`;
    chomp $hostname;
    $hostname ||= `hostname`;
    chomp $hostname;
    
    my $content = prepare_content($processes_killed);
    
#    send_email($content);
    save_detailed_log($content);
    save_master_log();
}

sub check_processes {
    my $ps = shift;
    
    my @processes_killed;
    foreach my $process (qw/perl starman/) {
	
	my $processes;    
	if (open ($processes, "/bin/ps -eo pid,rss,comm | grep $process | ")) {
	    #if (open ($processes, "/bin/ps -o pid= -o vsz= -p `cat $ppid`|")) {
	    my @memory_hogs;
	    
	    while (<$processes>) {
		chomp;
		my ($pid,$mem,$name) = split;
		
		# ps shows KB.  we want bytes.
		my $mem_in_bytes  = $mem * 1024;
		my $mem_in_mbytes = $mem/1024;
		
		if ($mem_in_bytes >= $size_limit_in_bytes) {
		    push @memory_hogs, [$pid,$mem_in_mbytes];
		}
	    }
	    
	    close($processes);
	    
	    # kill them slowly, so that all connection serving
	    # children don't suddenly die at once.	
	    
	    if (@memory_hogs > 0) {
		
		my $hostname = `hostname`;
		foreach my $hog (@memory_hogs) {
		    my ($pid,$mem) = @$hog;
#		    print "\tKilled $pid; it was using $mem MB memory\n";
                    #	kill 'HUP', $hog;
		    system("kill -9 $pid");
		    sleep 10;	
		    push @processes_killed,[$process,$pid,$mem];
		}
	    }
	} else {
	    die "Can't get process list: $!\n";
	}	
    }
    return \@processes_killed;
}

sub prepare_content {
    my $processes_killed = shift;
    my $content = <<END;

    Starman Reaper Report
    ---------------------
    Hostname : $hostname ($external_ip)
    Date     : $date
       
END

    foreach my $ps (@$processes_killed) {
	my ($process,$pid,$mem) = @$ps;
        $content .= sprintf('%28s %8s %8s',
                            $process,
                            $pid,
			    $mem
	    ) . "\n";
    }
    return $content;
}

sub send_email {    
    my $content = shift;
    my $msg = MIME::Lite->new(
	Subject => "[WB cron: Starman Reaper] Runaway starmen on $hostname!",
	From    => 'todd@wormbase.org',
	To      => 'todd@wormbase.org',
	Type    => 'text/plain',
	Data    => $content,
	);
    $msg->send();
}

# Save a running log of when we had to reap starmen.
sub save_detailed_log {
    my $content = shift;
    my $sanitized_date = $date;
    $sanitized_date =~ s/[ :\-()]/_/g;
    
    open OUT,">/usr/local/wormbase/logs/cron_reports/starman_reaper/$sanitized_date.log";
    print OUT $content;
    close OUT;
}

sub save_master_log {
    my $total_processes_killed = scalar @$processes_killed;
    open OUT,">>/usr/local/wormbase/logs/cron_reports/starman_reaper_master.log";
    print OUT "$date: $total_processes_killed processes killed\n";
    close OUT;
}
