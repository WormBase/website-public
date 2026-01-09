#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";

use Getopt::Long qw(GetOptions);
use File::Find qw(find);
use File::Spec::Functions qw(catdir catfile);

my $class;
my $name;
my $kind;  # 'widget' or 'field'
my $cache_root = '/usr/local/wormbase/json-cache';
my $dry_run = 0;
my $verbose = 0;

GetOptions(
    'class=s'      => \$class,
    'name=s'       => \$name,
    'kind=s'       => \$kind,
    'cache-root=s' => \$cache_root,
    'dry-run'      => \$dry_run,
    'verbose'      => \$verbose,
) or die "Error in command line arguments\n";

die "Usage: $0 --class <class> --name <widget_or_field_name> [--kind widget|field] [--cache-root <path>] [--dry-run] [--verbose]\n"
    unless $class && $name;

# Validate kind if provided
if ($kind && $kind ne 'widget' && $kind ne 'field') {
    die "ERROR: --kind must be 'widget' or 'field'\n";
}

# Determine which kinds to search for
my @kinds = $kind ? ($kind) : ('widget', 'field');

# Build the class directory path
my $class_dir = catdir($cache_root, $class);

unless (-d $class_dir) {
    die "ERROR: Class directory does not exist: $class_dir\n";
}

print "Searching for cached data in: $class_dir\n";
print "Class: $class\n";
print "Name: $name\n";
print "Kind(s): " . join(', ', @kinds) . "\n";
print "Mode: " . ($dry_run ? "DRY RUN (no files will be deleted)" : "DELETE") . "\n";
print "\n";

my @files_to_delete;
my $total_size = 0;

# Search for matching files
find(
    {
        wanted => sub {
            my $file = $_;
            my $path = $File::Find::name;

            # Check if this is a matching file
            foreach my $k (@kinds) {
                # Match both .json and .json.gz
                if ($file eq "$k.$name.json" || $file eq "$k.$name.json.gz") {
                    my $size = -s $path;
                    push @files_to_delete, {
                        path => $path,
                        size => $size,
                        kind => $k,
                    };
                    $total_size += $size;

                    if ($verbose) {
                        print "Found: $path (" . format_bytes($size) . ")\n";
                    }
                }
            }
        },
        no_chdir => 1,
    },
    $class_dir
);

# Report findings
my $count = scalar(@files_to_delete);
print "\nFound $count file(s) matching criteria\n";
print "Total size: " . format_bytes($total_size) . "\n";

if ($count == 0) {
    print "\nNo files to delete.\n";
    exit 0;
}

# Group by kind for summary
my %by_kind;
foreach my $f (@files_to_delete) {
    $by_kind{$f->{kind}}++;
}

print "\nBreakdown:\n";
foreach my $k (sort keys %by_kind) {
    print "  $k: $by_kind{$k} file(s)\n";
}

# Delete files (unless dry-run)
if (!$dry_run) {
    print "\nDeleting files...\n";
    my $deleted = 0;
    my $failed = 0;

    foreach my $f (@files_to_delete) {
        if (unlink $f->{path}) {
            $deleted++;
            print "  Deleted: $f->{path}\n" if $verbose;
        } else {
            $failed++;
            warn "  ERROR deleting $f->{path}: $!\n";
        }
    }

    print "\nDeleted: $deleted file(s)\n";
    print "Failed: $failed file(s)\n" if $failed > 0;
} else {
    print "\nDRY RUN - no files were deleted\n";
    print "Run without --dry-run to delete these files\n";
}

sub format_bytes {
    my ($bytes) = @_;
    return '0 B' if $bytes == 0;

    my @units = ('B', 'KB', 'MB', 'GB', 'TB');
    my $unit_idx = 0;
    my $size = $bytes;

    while ($size >= 1024 && $unit_idx < $#units) {
        $size /= 1024;
        $unit_idx++;
    }

    return sprintf("%.2f %s", $size, $units[$unit_idx]);
}

__END__

=head1 NAME

delete_cached_widgets.pl - Delete specific widget or field JSON files from the on-disk cache

=head1 SYNOPSIS

    # Delete all cached 'genetics' widgets for variation class (dry run)
    ./delete_cached_widgets.pl --class variation --name genetics --kind widget --dry-run

    # Delete all cached 'other_alleles' fields for variation class
    ./delete_cached_widgets.pl --class variation --name other_alleles --kind field

    # Delete both widgets and fields named 'genetics' for gene class
    ./delete_cached_widgets.pl --class gene --name genetics

    # With custom cache root
    ./delete_cached_widgets.pl --class variation --name genetics --cache-root /custom/path

=head1 DESCRIPTION

This script removes specific widget or field JSON files from the WormBase on-disk
JSON cache. It searches through the sharded directory structure for the specified
class and deletes all matching files.

=head1 OPTIONS

=over 4

=item B<--class>

Required. The object class (e.g., gene, variation, protein).

=item B<--name>

Required. The widget or field name to delete (e.g., genetics, other_alleles).

=item B<--kind>

Optional. Specify 'widget' or 'field' to delete only that kind. If omitted,
both widgets and fields matching the name will be deleted.

=item B<--cache-root>

Optional. Path to the JSON cache root directory. Defaults to /usr/local/wormbase/json-cache.

=item B<--dry-run>

Optional. Show what would be deleted without actually deleting files.

=item B<--verbose>

Optional. Print each file as it is found/deleted.

=back

=head1 EXAMPLES

    # Preview what would be deleted
    ./delete_cached_widgets.pl --class variation --name genetics --dry-run --verbose

    # Delete only widget files
    ./delete_cached_widgets.pl --class variation --name genetics --kind widget

    # Delete both widgets and fields
    ./delete_cached_widgets.pl --class gene --name alleles

=cut
