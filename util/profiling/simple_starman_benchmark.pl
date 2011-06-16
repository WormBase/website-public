#!/usr/bin/perl

use strict;
use warnings;
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => 'http://localhost:5000');

my $old_mem = 0;
print "req#\tmem\n";
foreach my $i (1..1000) {
    my $res = $ua->request($req);
    (my $mem = $res->content) =~ s/\D//g;
    next if( $mem == $old_mem );
    print "$i\t$mem\n";
    $old_mem = $mem;
}
