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
use Config::Simple;
use MIME::Base64;
use boolean;
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

# Will hold a reference to the log file:
my $log;

# Will hold a reference to the "reports" CouchDB database -- if "--report" is specified on the CLI:
my $reportdb;

# Current time. Used for logging and report generation.
my $seconds_since_epoch = time;
my $now = strftime "%Y%m%d_%S%M%H", localtime($seconds_since_epoch);
my $human_readable_now = strftime "%Y-%m-%dT%H:%M:%S", localtime($seconds_since_epoch);

# Create a unique ID for the report:
my $reportid = "$now\_gbrowse_" . sprintf("%08x", rand(2147483648));

# Add report content that gets archived in CouchDB:
sub report_test_status {
    my ($test_status) = @_;

    # If reporting is not turned on, then do not interact with CouchDB.
    return unless ($reportdb);

    my $reportdoc = $reportdb->open_doc($reportid)->recv;

    my %updateddoc = ( %$reportdoc, %$test_status );

    $reportdb->save_doc(\%updateddoc)->recv;
}

# Sets up a file where logging output can be written to. Preserves previous log file contents.
sub init_logging {
    # log_path : path (including filename) that determines where log output is written to
    my ($log_path) = @_;

    open(my $log, ">>$log_path") or die "Unable to open $log_path for writing";
    $log->autoflush(1);

    return $log;
}

# Sets up a connection to CouchDB where a report of the rest is going to be deposited.
sub init_reporting {
    # host : hostname where CouchDB resides
    # port : the port that is occupied by CouchDB
    # username : username to use for credentials
    # password : password for user authentication
    # database : name of the database where reports are stored
    my ($host, $port, $username, $password, $database) = @_;

    $database = couchdb("http://$username:$password\@$host:$port/$database");
}

# Creates a reference image set, or verifies images, of one species GBrowse configuration.
sub test_config {
    # server : base URL of the GBrowse instance
    # path   : path to the GBrowse configuration file
    # cutoff : ratio of broken URLs to total URLs; test is aborted if ratio goes over the cutoff
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
    # ...list of broken URLs.
    my @broken_url_links = ();
    # ...number of missing references.
    my $missing_references = 0;
    # ...list of URLs whose references are missing.
    my @missing_reference_links = ();
    # ...number of mismatching images.
    my $mismatches = 0;
    # ...list of mismatching URLs.
    my @mismatch_links = ();

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
                push(@broken_url_links, $url);

                $ratio_broken_urls = $broken_urls / $total_urls;
                if ($ratio_broken_urls > $cutoff) {
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

                        unless (compare($tempfile, $reference_path) == 0) {
                            $mismatches++;
                            push(@mismatch_links, $url);
                        }

                        ok(compare($tempfile, $reference_path) == 0, $testname . ' (image comparison)');

                        unlink($tempfile);
                    } else {
                        $missing_references++;
                        push(@missing_reference_links, $url);
                        fail($testname . ' (reference image does not exist)');
                    }
                }
            }
        }
    }

    my $test_aborted = undef;
    $test_aborted = 1 if ($ratio_broken_urls > $cutoff);

    my $test_status ={
        $provenance => {
            aborted              => $test_aborted,
            broken_urls          => $broken_urls,
            broken_urls_evidence => \@broken_url_links,
            cutoff               => $cutoff,
            example_landmarks    => (scalar @examples),
            total_urls           => $total_urls,
            tracks               => (scalar @tracks)
        }
    };

    if ($mode eq VERIFY) {
        $test_status->{$provenance}->{image_mismatches} = $mismatches;
        $test_status->{$provenance}->{image_mismatches_evidence} = \@mismatch_links;
        $test_status->{$provenance}->{missing_references} = $missing_references;
        $test_status->{$provenance}->{missing_references_evidence} = \@missing_reference_links;
    }

    # Report test results:
    report_test_status($test_status);

    # Output some summary information.
    print "Configuration        : $provenance\n";
    if ($test_aborted) {
        my $percentage_broken_urls = $ratio_broken_urls * 100;
        print "    ABORTED: too many broken URLs (>= $percentage_broken_urls%)\n";
        print $log "ABORTED: too many broken URLs (>= $percentage_broken_urls%) for $provenance\n";
    } else {
        print "    Retrieved images : $images\n";
        print "    Broken URLs      : $broken_urls\n";
        print $log "Created $images ($broken_urls broken URLs) for $provenance\n";
    }
}

# Boolean variable: should a report be generated and deposited in CouchDB?
my $create_report;

# Boolean variable: are we creating a reference image set?
my $reference;

# Cutoff ratio for broken URLs; loop is aborted if the ratio of broken URLs exceeds the cutoff.
my $cutoff;

# Base URL of the GBrowse instance, e.g. http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img/
my $base_url;

GetOptions("report" => \$create_report,
           "reference" => \$reference,
           "cutoff=f" => \$cutoff,
           "base=s" => \$base_url);

die "No '--base URL' provided. Example: --base http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img/" unless $base_url;

$cutoff = 0.1 unless defined $cutoff;
$cutoff = $cutoff * 1; # Ensure that the cutoff is a number.

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

# Load configuration setting from file:
my $configuration = new Config::Simple('conf/t/config.ini');

# Log the progress:
$log = init_logging($configuration->param('LogFile'));

print $log "\nNew run $now. Successful completion will terminate with the line \"Done $now.\"\n";

# If a report should be created: connect to CouchDB, which will hold the final report.
if ($create_report) {
    $reportdb = init_reporting($configuration->param('CouchHost'),
                               $configuration->param('CouchPort'),
                               $configuration->param('CouchUsername'),
                               $configuration->param('CouchPassword'),
                               'reports');
}

# Get all GBrowse configs and create a track listing:
my @gbrowse_configs = <conf/gbrowse/?_*_P*.conf>;
my @config_names = ();
foreach my $gbrowse_config (@gbrowse_configs) {
    push(@config_names, basename($gbrowse_config, ".conf"));
}

# Record that testing has started, but has not finished yet ("completed" is null):
if ($create_report) {
   $reportdb->save_doc({
       _id                 => $reportid,
       completed           => undef,
       mode                => $mode,
       type                => 'gbrowse',
       started             => $human_readable_now,
       started_since_epoch => $seconds_since_epoch,
       configurations      => \@config_names
   })->recv;
}

# Archive in which mode we are operating:
print $log "Mode: $mode";

# Go through all GBrowse configurations.
foreach my $gbrowse_config (@gbrowse_configs) {
    test_config($base_url, getcwd . '/' . $gbrowse_config, $cutoff, $mode);
}

if ($mode eq VERIFY) {
    done_testing();
}

# Record that testing is complete:
report_test_status({ completed => 1 });

print $log "Done $now.\n";

close($log);

1;

