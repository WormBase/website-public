#!/usr/bin/env perl

use strict;

use Bio::Graphics::Browser2::DataSource;
use Cwd;
use File::Basename;
use File::Compare;
use Getopt::Long;
use LWP::Simple qw(get);
use Test::More;
use POSIX qw(strftime);
use AnyEvent::CouchDB;

use Data::Dumper;

# Modus operandi:
#
# In any case, read the GBrowse configuration files in conf/gbrowse, then
#
#   CREATE_REFERENCE_SET : creates reference images in t/gbrowse_img_references
#   VERIFY               : check if the returned images match the reference images
use constant {
    CREATE_REFERENCE_SET => 'Create Reference Set',
    VERIFY               => 'Verify'
};

# Current time. Used for logging and report generation.
my $now = strftime "%Y%m%d_%H%M", localtime;

# Log the progress:
my $log_path = "logs/gbrowse_test.log";
open(my $log, ">$log_path") or die "Unable to open $log_path for writing";
$log->autoflush(1);

print $log "\nNew run $now. Successful completion will terminate with the line \"Done $now.\"\n";

# NOTE Test connection to CouchDB... will write reports to there...
my $couchdb = couch('http://dev.wormbase.org:5984/');
print Dumper($couchdb->all_dbs->recv);

# Creates a reference image set, or verifies images, of one species GBrowse configuration.
sub test_config {
    # server : base URL of the GBrowse instance
    # path   : path to the GBrowse configuration file
    # cutoff : ratio of broken URLs to total URLs at which testing a config is aborted
    # mode   : either CREATE_REFERENCE_SET or VERIFY (see above)
    my ($server, $path, $cutoff, $mode) = @_;

    # Load the GBrowse configuration as a hash ref.
    my $provenance = basename($path, ".conf");
    my $config_file = Bio::Graphics::FeatureFile->new(-file=>$path);
    my $config = $config_file->{config};

    # Landmarks that were defined as "examples" in the configuration.
    my @examples = split(/ +/, $config->{general}->{examples});

    # All sections of the configuration file, except the "general" section.
    my @tracks = grep { !($_ eq 'general' || $_ =~ m/:database$/) } keys %$config;

    # Count...
    # ...the number of image files successfully retrieved.
    my $images = 0;
    # ...number of URLs for which no image was returned.
    my $broken_urls = 0;

    # Number of all URLs to process:
    my $total_urls = (scalar @tracks) * (scalar @examples);

    # Calculated below: ratio of broken URLs to total URLs.
    my $ratio_broken_urls;

    TRACK_LOOP: for my $track (@tracks) {
        # Make track name suitable for use with Unix file paths:
        $track =~ s/\/| /_/g;

        for my $example (@examples) {
            # Basic name for the test. Might get a suffix below that explicitly states what went wrong
            # or what was expected for a test to succeed.
            my $testname = "Get image: species $provenance, track $track, landmark $example";

            # gbrowse_img URL.
            my $url = "$server$provenance/?name=$example&type=$track";

            # The actual PNG image.
            my $image = get($url);

            # If there was no image returned, then treat it as a broken URL.
            if (!defined $image) {
                $broken_urls++;

                $ratio_broken_urls = $broken_urls / $total_urls;
                if ($ratio_broken_urls >= $cutoff) {
                    last TRACK_LOOP;
                }

                if ($mode eq CREATE_REFERENCE_SET) {
                    print $log "No image for URL: $url\n";
                } elsif ($mode eq VERIFY) {
                    fail($testname . ' (URL did not return an image)');
                }
            } else {
                $images++;
                my $reference_path = "t/gbrowse_img_references/$provenance--$track--$example.png";

                if ($mode eq CREATE_REFERENCE_SET) {
                    open(my $png_path, '>:raw', $reference_path) or die "Unable to open: $!";
                    print $png_path $image;
                    close $png_path;
                } elsif ($mode eq VERIFY) {
                    if (-e $reference_path) {
                        my $tempfile = ".gbrowse_img_tmp";

                        open(my $png_path, '>:raw', $tempfile) or die "Unable to open temporary file: $!";
                        print $png_path $image;
                        close $png_path;

                        ok(compare($tempfile, $reference_path) == 0, $testname . ' (image comparison)');

                        unlink($tempfile);
                    } else {
                        fail($testname . ' (reference image does not exist)');
                    }
                }
            }
        }
    }

    # Output some summary information.
    print "Configuration        : $provenance\n";
    if ($ratio_broken_urls >= $cutoff) {
        my $percentage_broken_urls = $ratio_broken_urls * 100;
        print "    ABORTED: too many broken URLs (>= $percentage_broken_urls%)\n";
        print $log "ABORTED: too many broken URLs (>= $percentage_broken_urls%) for $provenance\n";
    } else {
        print "    Retrieved images : $images\n";
        print "    Broken URLs      : $broken_urls\n";
        print $log "Created $images ($broken_urls broken URLs) for $provenance\n";
    }
}

# Boolean variable: are we creating a reference image set?
my $reference;

# Cutoff ratio for broken URLs to total URLs at which the loop below is aborted.
my $cutoff;

# Base URL of the GBrowse instance, e.g. http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img/
my $base_url;

GetOptions("reference" => \$reference,
           "cutoff=f" => \$cutoff,
           "base=s" => \$base_url);

die "No '--base URL' provided. Example: --base http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img/" unless $base_url;

$cutoff = 0.1 unless defined undef;
$base_url = "$base_url/" unless $base_url =~ m/\/$/;

my $mode;

# When creating a new reference image set, get rid of any existing images first.
if ($reference) {
    $mode = CREATE_REFERENCE_SET;
    my @image_references = <t/gbrowse_img_references/*.png>;
    foreach my $image_reference (@image_references) {
        unlink $image_reference;
    }
} else {
    $mode = VERIFY;
}

# Archive in which mode we are operating:
print $log "Mode: $mode";

# Go through all GBrowse configurations.
my @gbrowse_configs = <conf/gbrowse/?_*_P*.conf>;
foreach my $gbrowse_config (@gbrowse_configs) {
    test_config($base_url, getcwd . '/' . $gbrowse_config, $cutoff, $mode);
}

if ($mode eq VERIFY) {
    done_testing();
}

print $log "Done $now.\n";

close($log);

1;

