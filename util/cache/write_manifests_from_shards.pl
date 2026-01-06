#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../../lib";
use WormBase::Cache::ShardPath qw(object_name_from_leaf);

use Getopt::Long qw(GetOptions);
use Encode qw(encode decode);
use File::Spec ();
use File::Basename qw(basename);
use File::Find qw(find);
use File::Temp qw(tempfile);
use JSON::PP ();
use POSIX qw(strftime);
use Unicode::Normalize qw(NFC);
use Time::HiRes qw(time);
use Digest::SHA qw(sha256_hex);


sub escape_for_tsv {
    my ($s) = @_;
    $s = '' unless defined $s;
    $s =~ s/\\/\\\\/g;
    $s =~ s/\t/\\t/g;
    $s =~ s/\r/\\r/g;
    $s =~ s/\n/\\n/g;
    return $s;
}




sub object_payload_stats_flat {
    my ($obj_dir) = @_;

    my $bytes = 0;
    my $files = 0;
    my $min;
    my $max;

    opendir(my $dh, $obj_dir) or die "Cannot opendir $obj_dir: $!";
    while (defined(my $ent = readdir($dh))) {
        next if $ent eq '.' || $ent eq '..';

        # Treat only payload JSON as payloads; exclude manifests
        next unless $ent =~ /\.json\z/i;
        next if $ent eq 'MANIFEST.json';

        my $path = File::Spec->catfile($obj_dir, $ent);
        next unless -f $path;

        my @st = stat($path) or next;
        my $sz = $st[7];

        $bytes += $sz;
        $files++;

        $min = $sz if !defined($min) || $sz < $min;
        $max = $sz if !defined($max) || $sz > $max;
    }
    closedir($dh);

    return ($files, $bytes, $min, $max);
}

sub sha256_file_hex {
    my ($path) = @_;
    open my $fh, '<:raw', $path or die "Cannot open for checksum $path: $!";
    my $sha = Digest::SHA->new(256);
    $sha->addfile($fh);
    close $fh;
    return $sha->hexdigest;
}

sub collect_payload_checksums_flat {
    my ($obj_dir) = @_;
    my %payloads;

    opendir(my $dh, $obj_dir) or die "Cannot opendir $obj_dir: $!";

    while (defined(my $ent = readdir($dh))) {
        next if $ent eq '.' || $ent eq '..';
        next if $ent eq 'MANIFEST.json';           # do not checksum the manifest
        next unless $ent =~ /\.json\z/i;           # payloads only (adjust if needed)

        my $path = File::Spec->catfile($obj_dir, $ent);
        next unless -f $path;

        my @st = stat($path) or next;

        $payloads{$ent} = {
            sha256     => sha256_file_hex($path),
            bytes      => $st[7],
            mtime_epoch=> $st[9],
        };
    }

    closedir($dh);
    return \%payloads;
}


# -----------------------------
# Leaf -> Unicode helper (centralized)
# -----------------------------
# object_name_from_leaf is provided by WormBase::Cache::ShardPath

# -----------------------------
# "Created time" = earliest mtime of files in object directory
# -----------------------------
sub earliest_mtime_in_tree {
    my ($dir) = @_;
    my $earliest;

    find(
        {
            wanted => sub {
                return unless -f $_;
                my @st = stat($_) or return;
                my $mtime = $st[9];
                $earliest = $mtime if !defined($earliest) || $mtime < $earliest;
            },
            no_chdir => 1,
        },
        $dir
	);

    return $earliest; # undef if no files
}

# -----------------------------
# Atomic JSON write (UTF-8)
# -----------------------------
sub write_manifest {
    my (%args) = @_;

    my $obj_dir   = $args{obj_dir}   // die "write_manifest: obj_dir required\n";
    my $payload   = $args{payload}   // die "write_manifest: payload required\n";
    my $overwrite = $args{overwrite} // 0;

    my $path = File::Spec->catfile($obj_dir, 'MANIFEST.json');

    if (-e $path && !$overwrite) {
        return (0, "exists");
    }


    my $json = JSON::PP->new->canonical(1)->pretty(1)->encode($payload);

    my ($fh, $tmp) = tempfile('MANIFEST.json.tmpXXXX', DIR => $obj_dir, UNLINK => 0);
    binmode($fh, ':raw');  # be explicit
    print {$fh} encode('UTF-8', $json);
    close $fh or die "close failed for $tmp: $!\n";

    rename($tmp, $path) or die "rename $tmp -> $path failed: $!\n";

    return (1, "written");
}



sub write_class_manifest_json {
    my (%args) = @_;
    my $class_path = $args{class_path} // die "class_path required";
    my $payload    = $args{payload}    // die "payload required";
    my $overwrite  = $args{overwrite}  // 0;

    my $final = File::Spec->catfile($class_path, 'MANIFEST.json');
    return (0, "exists") if -e $final && !$overwrite;

    my $json = JSON::PP->new->canonical(1)->pretty(1)->encode($payload);

    my ($fh, $tmp) = tempfile('MANIFEST.json.tmpXXXX', DIR => $class_path, UNLINK => 0);
    binmode($fh, ':raw');
    print {$fh} encode('UTF-8', $json);
    close $fh or die "close failed for $tmp: $!";

    rename($tmp, $final) or die "rename $tmp -> $final failed: $!";
    return (1, "written");
}

# -----------------------------
# Release inference
# -----------------------------
sub infer_release_from_path {
    my ($root) = @_;
    return $1 if defined $root && $root =~ m!/(WS\d+)(?:/|$)!;
    return undef;
}



sub open_class_manifest {
    my ($class_path) = @_;

    my $final = File::Spec->catfile($class_path, 'MANIFEST.txt');
    my ($fh, $tmp) = tempfile('MANIFEST.txt.tmpXXXX', DIR => $class_path, UNLINK => 0);

    # Write header (optional; remove if you want pure data)
    print {$fh} encode('UTF-8', "# object_name\trelative_path\n");

    return ($fh, $tmp, $final);
}

sub close_class_manifest {
    my (%args) = @_;
    my $fh       = $args{fh}       // die "close_class_manifest: fh required\n";
    my $tmp      = $args{tmp}      // die "close_class_manifest: tmp required\n";
    my $final    = $args{final}    // die "close_class_manifest: final required\n";
    my $overwrite = $args{overwrite} // 0;

    close $fh or die "close failed for $tmp: $!\n";

    if (-e $final && !$overwrite) {
        unlink $tmp or warn "[WARN] cannot unlink temp manifest $tmp: $!\n";
        return (0, "exists");
    }

    rename($tmp, $final) or die "rename $tmp -> $final failed: $!\n";
    return (1, "written");
}



# -----------------------------
# CLI
# -----------------------------
# Cached json found at /usr/local/wormbase/databases/RELEASE/BUILD_DATE/json
my %opt = (
    root       => '/mnt/json-cache-WS298',
    build_date     => '2025-11-27',
    shard_chars => 2,
    dry_run    => 1,
    overwrite  => 0,
    progress   => 2000,
    generator  => 'write_manifests_from_shards.pl',
    oversized_threshold => 7 * 1024 * 1024,  # 7 MiB
    kinds      => undef,
    );

GetOptions(
    'build_date=s'    => \$opt{build_date},
    'class=s'       => \$opt{class},      # optional: restrict to one class
    'kinds=s'       => \$opt{kinds},      # optional: comma-separated list (widget,field)
    'release=s'     => \$opt{release},
    'dry-run!'      => \$opt{dry_run},
    'overwrite!'    => \$opt{overwrite},
    'progress=i'    => \$opt{progress},
    'generator=s'   => \$opt{generator},
    'shard-chars=i' => \$opt{shard_chars},
    'oversized-threshold=i' => \$opt{oversized_threshold},
    ) or die <<"USAGE";
Usage:
  write_manifests_from_shards.pl [options]

    Options:
  --root PATH          Root cache dir (default: /mnt/json-cache-WS298)
  --build_date         YYYY-MM-DD the build started (default: 2025-11-27)
  --class NAME         Process only this class (otherwise process all class dirs under --root)
  --kinds LIST        Comma-separated kinds under json/ (e.g. widget,field). Default: autodiscover under json/
  --release WS###      Release to write
  --dry-run / --no-dry-run   (default: dry-run)
  --overwrite          Overwrite existing object and class MANIFEST.json files
  --progress N         Print progress every N objects (default: 2000)
  --generator NAME     Generator string (default: write_manifests_from_shards.pl)
  --shard-chars N      Expected shard dir name length (default: 2)
  --oversized-threshold N  Record payloads larger than N bytes (default: 7340032)

  eg
  Dry-run
  perl write_manifests_from_shards.v1_2.pl \
      --release WS298 \
      --class antibody \
      --oversized-threshold $((10*1024*1024)) \
      --dry-run

  No-dry-run
  perl write_manifests_from_shards.v1_2.pl \
      --release WS298 \
      --class antibody \
      --oversized-threshold $((10*1024*1024)) \
      --overwrite 1
      --no-dry-run

USAGE
;
    
die "Root is not a directory: $opt{root}\n" unless -d $opt{root};
die "Please specify a WSXXX release\n" unless $opt{release};

#$opt{json_root} = join("/",$opt{root},$opt{release},"cache",$opt{build_date},"json");
$opt{json_root} = join("/",$opt{root},"json");
# Should I CREATE this dir?

#die $opt{cache_path};

# -----------------------------
# Traverse: class/shard1/shard2/object
# Use nested opendir loops for speed and predictability.
# -----------------------------
my $t0 = time();
my ($classes, $seen, $written, $skipped, $failed) = (0, 0, 0, 0, 0);

sub is_hex_shard {
    my ($s, $n) = @_;
    return defined($s) && $s =~ /\A[0-9a-fA-F]{$n}\z/;
}


my @kinds;
if (defined $opt{kinds} && length $opt{kinds}) {
    @kinds = grep { length($_) } split(/\s*,\s*/, $opt{kinds});
} else {
    opendir(my $kdh, $opt{json_root}) or die "Cannot opendir $opt{json_root}: $!\n";
    while (defined(my $ent = readdir($kdh))) {
        next if $ent eq '.' || $ent eq '..';
        my $p = File::Spec->catdir($opt{json_root}, $ent);
        push @kinds, $ent if -d $p;
    }
    closedir($kdh);
}
@kinds = sort @kinds;

die "No kind directories found under $opt{json_root}\n" unless @kinds;

my ($kinds_done, $classes_done) = (0, 0);

for my $kind (@kinds) {
    my $kind_root = File::Spec->catdir($opt{json_root}, $kind);
    next unless -d $kind_root;
    $kinds_done++;

    my @class_dirs;
    if (defined $opt{class}) {
        push @class_dirs, $opt{class};
    } else {
        opendir(my $rdh, $kind_root) or die "Cannot opendir $kind_root: $!\n";
        while (defined(my $ent = readdir($rdh))) {
            next if $ent eq '.' || $ent eq '..';
            my $p = File::Spec->catdir($kind_root, $ent);
            push @class_dirs, $ent if -d $p;
        }
        closedir($rdh);
    }
    @class_dirs = sort @class_dirs;

    for my $class (@class_dirs) {

        my $class_path = File::Spec->catdir($kind_root, $class);
        next unless -d $class_path;

        # Per-class statistics
        my $class_object_count        = 0;

        my $class_payload_files       = 0;   # total number of payload *.json files (excluding manifests)
        my $class_payload_bytes       = 0;   # total bytes across payload *.json files
        my $class_payload_min;
        my $class_payload_max;

        my $class_objects_missing_overview = 0;  # missing overview.json
        my %class_payload_name_counts      = (); # filename -> count
        my %class_payload_name_bytes_total = (); # filename -> total bytes

        my @class_oversized_payloads      = ();  # payloads > threshold
        my %class_oversized_objects       = ();  # object_name => 1 (if any payload oversized)

        my $class_created_epoch_min;
        my $class_created_epoch_max;

        my ($mfh, $mtmp, $mfinal);
        if ($opt{dry_run}) {
            # no file creation
        } else {
            ($mfh, $mtmp, $mfinal) = open_class_manifest($class_path);
        }

        $classes++;
        $classes_done++;

        # Scan shard1/shard2/leaf directories
        opendir(my $s1dh, $class_path) or do {
            warn "[WARN] Cannot opendir class dir $class_path: $!\n";
            next;
        };

        while (defined(my $shard1 = readdir($s1dh))) {
            next if $shard1 eq '.' || $shard1 eq '..';
            next unless is_hex_shard($shard1, $opt{shard_chars});

            my $s1path = File::Spec->catdir($class_path, $shard1);
            next unless -d $s1path;

            opendir(my $s2dh, $s1path) or do {
                warn "[WARN] Cannot opendir shard $s1path: $!\n";
                next;
            };

            while (defined(my $shard2 = readdir($s2dh))) {
                next if $shard2 eq '.' || $shard2 eq '..';
                next unless is_hex_shard($shard2, $opt{shard_chars});

                my $s2path = File::Spec->catdir($s1path, $shard2);
                next unless -d $s2path;

                opendir(my $ldh, $s2path) or do {
                    warn "[WARN] Cannot opendir leafdir $s2path: $!\n";
                    next;
                };

                while (defined(my $leaf = readdir($ldh))) {
                    next if $leaf eq '.' || $leaf eq '..';

                    my $obj_dir = File::Spec->catdir($s2path, $leaf);
                    next unless -d $obj_dir;

                    $seen++;

                    my $object_name;
                    eval { $object_name = object_name_from_leaf($leaf); 1 } or do {
                        my $e = $@ || "decode failed";
                        $e =~ s/\s+\z//;
                        warn "[FAIL] $obj_dir: cannot decode object leaf '$leaf' ($e)\n";
                        $failed++;
                        next;
                    };

                    # Append to per-class manifest file (relative to <kind>/<class>/)
                    my $rel = File::Spec->catfile($shard1, $shard2, $leaf);
                    my $obj_esc = escape_for_tsv($object_name);

                    if ($opt{dry_run}) {
                        # no-op
                    } else {
                        print {$mfh} encode('UTF-8', "$obj_esc\t$rel\n");
                    }

                    my $created = earliest_mtime_in_tree($obj_dir);
                    if (!defined $created) {
                        my @st = stat($obj_dir);
                        $created = @st ? $st[9] : int(time());
                    }

                    my $payloads = collect_payload_checksums_flat($obj_dir);

                    # Update per-class aggregates
                    $class_object_count++;

                    $class_created_epoch_min = int($created)
                        if !defined($class_created_epoch_min) || int($created) < $class_created_epoch_min;
                    $class_created_epoch_max = int($created)
                        if !defined($class_created_epoch_max) || int($created) > $class_created_epoch_max;

                    $class_objects_missing_overview++ unless exists $payloads->{'overview.json'};

                    my ($pf, $pb, $pmin, $pmax) = (0, 0, undef, undef);
                    for my $fname (keys %{$payloads}) {
                        $pf++;
                        my $sz = $payloads->{$fname}{bytes} // 0;
                        $pb += $sz;

                        $pmin = $sz if !defined($pmin) || $sz < $pmin;
                        $pmax = $sz if !defined($pmax) || $sz > $pmax;

                        $class_payload_name_counts{$fname}++;
                        $class_payload_name_bytes_total{$fname} += $sz;

                        if ($sz > $opt{oversized_threshold}) {
                            my $payload_rel = File::Spec->catfile($shard1, $shard2, $leaf, $fname);
                            push @class_oversized_payloads, {
                                object_name   => $object_name,
                                payload       => $fname,
                                bytes         => $sz,
                                relative_path => $payload_rel,
                            };
                            $class_oversized_objects{$object_name} = 1;
                        }
                    }

                    $class_payload_files += $pf;
                    $class_payload_bytes += $pb;

                    if (defined $pmin) {
                        $class_payload_min = $pmin if !defined($class_payload_min) || $pmin < $class_payload_min;
                    }
                    if (defined $pmax) {
                        $class_payload_max = $pmax if !defined($class_payload_max) || $pmax > $class_payload_max;
                    }

                    # Write per-object MANIFEST.json

                    my $obj_manifest = {

                        schema_version => "WormBaseCacheObjectManifest/2",

                        generated_at   => strftime("%Y-%m-%dT%H:%M:%SZ", gmtime(time())),

                        generator      => $opt{generator},

                        release        => $opt{release},

                        build_date     => $opt{build_date},

                        kind           => $kind,

                        class          => $class,

                        object_name    => $object_name,

                        shard1         => $shard1,

                        shard2         => $shard2,

                        leaf           => $leaf,

                        created_epoch  => int($created),

                        payload_files  => $pf,

                        payload_bytes  => $pb,

                        payload_min    => $pmin,

                        payload_max    => $pmax,

                        payloads       => $payloads,

                    };

                    if ($opt{dry_run}) {

                        # no-op

                    } else {

                        my ($ok, $why) = write_manifest(obj_dir => $obj_dir, payload => $obj_manifest, overwrite => $opt{overwrite});

                        if ($ok) {

                            $written++;

                        } elsif ($why && $why eq 'exists') {

                            $skipped++;

                        } else {

                            $failed++;

                        }

                    }



                    if ($opt{progress} && ($seen % $opt{progress} == 0)) {
                        print STDERR sprintf("[PROGRESS] seen=%d classes=%d kind=%s class=%s\n", $seen, $classes, $kind, $class);
                    }
                }
                closedir($ldh);
            }
            closedir($s2dh);
        }
        closedir($s1dh);

        my $class_manifest = {
            schema_version => "WormBaseCacheClassManifest/3",
            generated_at   => strftime("%Y-%m-%dT%H:%M:%SZ", gmtime(time())),
            generator      => $opt{generator},
            release        => $opt{release},
            build_date     => $opt{build_date},
            kind           => $kind,
            class          => $class,

            objects        => $class_object_count,
            payload_files  => $class_payload_files,
            payload_bytes  => $class_payload_bytes,
            payload_min    => $class_payload_min,
            payload_max    => $class_payload_max,

            created_epoch_min => $class_created_epoch_min,
            created_epoch_max => $class_created_epoch_max,

            objects_missing_overview => $class_objects_missing_overview,

            payload_name_counts      => \%class_payload_name_counts,
            payload_name_bytes_total => \%class_payload_name_bytes_total,

            oversized_threshold_bytes => $opt{oversized_threshold},
            oversized_payloads        => \@class_oversized_payloads,
            oversized_objects_count   => scalar(keys %class_oversized_objects),
        };

        if ($opt{dry_run}) {
            print "[DRY] would write ", File::Spec->catfile($class_path, 'MANIFEST.txt'), "\n";
            print "[DRY] would write ", File::Spec->catfile($class_path, 'MANIFEST.json'), "\n";
        } else {
            close_class_manifest(
                fh        => $mfh,
                tmp       => $mtmp,
                final     => $mfinal,
                overwrite => $opt{overwrite},
            );

            write_class_manifest_json(
                class_path => $class_path,
                payload    => $class_manifest,
                overwrite  => $opt{overwrite},
            );
        }
    }
}
my $dt = time() - $t0;
printf STDERR "DONE: classes=%d objects=%d written=%d skipped=%d failed=%d (%.1fs) release=%s\n",
    $classes, $seen, $written, $skipped, $failed, $dt, $opt{release};

exit($failed ? 2 : 0);
