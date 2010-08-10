#!/usr/bin/perl

# Precache specific WormBase widgets
# Use this script to populate the ON DISK (not squid) cache
# That is, it should be run after a release to automatically
# populate the on disk cache of all gene pages
# squid can then pull them from the back end servers as necessary

# Usage: ./precache_widgets.pl

use strict;
use Ace;
use WWW::Mechanize;
$|++;

# Class, object name, widget
my $base_url = 'http://www.wormbase.org/rest/widget/%s/%s/%s';


my $db    = Ace->connect(-host=>'localhost',-port=>2005);
my $version = $db->status->{database}{version};

my %classes = ( variation => [ qw/overview/ ],
		protein   => [ qw/overview external_links molecular_details homology history/ ],
    );

foreach my $class (keys %classes) {
    open OUT,">$version-precached-widgets-$class.txt";
    my $start = time();
    
    my $ace_class = ucfirst($class);
    my $i = $db->fetch_many($ace_class => '*');
    while (my $obj = $i->next) {
	
	my %status;
	foreach my $widget (@{$classes->{$class}}) {
	    my $url = sprintf($base_url,$obj->name,$widget);
	
	    my $cache_start = time();

	    # No need to watch state - create a new agent for each gene to keep memory usage low.
	    my $mech = WWW::Mechanize->new(-agent => 'WormBase-PreCacher/1.0');
	    $mech->get($url);
	    my $success = ($mech->success) ? 'success' : 'failed';
	    my $cache_stop = time();
	    print OUT join("\t",$class,$obj,$widget,$url,$success,$cache_stop - $cache_start),"\n";
	    $status{$class}++;
	}
    }

    my $end = time();
    my $seconds = $end - $start;
    print OUT "\n\nTime required to cache " . (scalar keys %status) . ": ";
    printf OUT "%d days, %d hours, %d minutes and %d seconds\n",(gmtime $seconds)[7,2,1,0];    
    close OUT;
}
