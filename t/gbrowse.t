#!/usr/bin/env perl

use Bio::Graphics::Browser2::DataSource;
use Cwd;
use File::Basename;
use Test::More;

use Data::Dumper;

sub test_config {
    my ($server, $path) = @_;

    my $config_file = Bio::Graphics::FeatureFile->new(-file=>$path);
    my $config = $config_file->{config};

    print "path: $path\n";
    print "conf: $config\n";
    my @examples = split(/ +/, $config->{general}->{examples});
    my @tracks = grep { !($_ eq 'general') } keys %$config;

    for my $track (@tracks) {
        for my $example (@examples) {
            print "$server?name=$example&type=$track\n";
        }
    }
}

test_config('http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img/', getcwd . '/conf/gbrowse/c_elegans_PRJNA13758.conf');

1;

