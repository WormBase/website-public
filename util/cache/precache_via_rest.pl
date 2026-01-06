#!/usr/bin/env perl
use strict;
use warnings;

# Reduce buffering; does not guarantee non-interleaving without --log-dir
$| = 1;
select STDERR; $| = 1;
select STDOUT;

use utf8;
use Sys::Hostname qw(hostname);

# precache_rest_first_v5.pl
#
# REST-first cache generator for WormBase WS298.
#
# Inputs:
#   - Enumerates objects per class from KeySet-style *.ace files:
#       KeySet : Answer_1
#       <CLASS>:
#         <id1>
#         <id2>
#         ...
#
# Fetch:
#   - Widgets: /rest/widget/<lc(class)>/<object>/<widget_name>
#   - Fields:  /rest/field/<lc(class)>/<object>/<field_name>
#
# Output (JSON on disk):
#   When --compress (default), writes:
#     <cache-root>/json/<kind>/<class>/<shard1>/<shard2>/<leaf>/<name>.json.gz
#   When --no-compress, writes legacy:
#     <cache-root>/json/<kind>/<class>/<shard1>/<shard2>/<leaf>/<name>.json
#
# Misplaced field migration (Option 1A):
#   If a FIELD payload is missing in its canonical location, but exists under:
#     <cache-root>/json/widget/<class>/<sh1>/<sh2>/<leaf>/<field_name>.json
#   it can be moved into the correct FIELD location when --move-misplaced-fields is enabled.
#
# Audit-only mode:
#   --audit-misplaced-fields scans for misplaced field payloads without moving or fetching anything.
#   It reports counts and writes a JSON report (default: misplaced_fields_audit.json).

use FindBin qw/$Bin/;
use lib "$Bin/../../../lib";

use Getopt::Long qw(GetOptions);
use File::Spec;
use File::Path qw(make_path);
use File::Basename qw(dirname);
use JSON::PP qw(decode_json encode_json);
use HTTP::Tiny;
use Time::HiRes qw(time);
use Digest::SHA qw(sha256_hex);
use URI::Escape qw(uri_escape_utf8);
use IO::Compress::Gzip qw(gzip $GzipError);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

use WormBase::Cache::ShardPath qw(leaf_from_name shards_from_name);

my %opt = (
  base_url               => 'http://rest.wormbase.org/rest',
  cache_root             => undef,
  json_subdir            => 'json',
  ace_dir                => undef,
  class                  => undef,
  classes_file           => undef,
  kinds                  => 'widget',
  widgets                => undef,
  fields                 => undef,
  widgets_file           => undef,
  fields_file            => undef,
  timeout                => 1200,
  retries                => 1,
  sleep_ms               => 0,
  verify_json            => 1,
  compare_existing       => 0,
  overwrite_on_diff      => 0,
  canonicalize_json      => 1,
  canonicalize_write     => 1,
  dump_canonical_on_diff => 0,
  dump_canonical_dir     => undef,
  workers                => 1,
  worker_id              => undef,
  shard_prefix           => undef,
  object_offset          => 0,
  object_limit           => undef,
  debug_workers          => 0,
  strict_missing_only    => 0,
  exists_debug           => 0,
  canon_skip_keys        => '^(?:timestamp|time_stamp|generated|generated_at|generated_at_utc|build(?:_date)?|fetched_at|retrieved_at|request_time|server_time|cache_time|last_updated|lastUpdate|last_modified|lastModified|date)$',
  skip_if_exists         => 1,
  move_misplaced_fields  => 0,
  audit_misplaced_fields => 0,
  audit_out              => 'misplaced_fields_audit.json',
  audit_list_limit       => 5000,
  log_errors             => 'precache.errors.log',
  log_progress           => 'precache.progress.log',
  dry_run                => 0,
  max_objects            => undef,
  max_requests           => undef,
  verbose                => 0,

  # On-disk compression
  # When enabled, payloads are written as .json.gz (atomic), and reads/existence checks
  # transparently accept either .json.gz or legacy .json.
  compress               => 1,
  compress_level         => 1,

  # Heartbeat (progress) reporting.
  # Emits periodic progress lines into a single per-class file, suitable for tail -f.
  heartbeat_every_objects => 5000,
  heartbeat_every_urls    => 0,
  heartbeat_file          => 'precache.heartbeat.tsv',
);

sub usage {
  die <<"USAGE";
Usage:
  precache_rest_first_v5.pl --cache-root DIR --ace-dir DIR [options]

Required:
  --cache-root DIR      Root output cache directory
  --ace-dir DIR         Directory containing KeySet-style *.ace files (one per class). Default: <cache-root>/ace

Optional:
  --json-subdir NAME    Subdirectory under cache-root for JSON tree (default: json)

Class selection:
  --class CLASS         Restrict to a single class (must correspond to <CLASS>.ace in --ace-dir)
  --classes-file FILE   File with one class per line (if not set, script infers classes from *.ace filenames)

REST endpoint:
  --base-url URL        Default: http://rest.wormbase.org/rest

Kinds / payload types:
  --kinds widget,field  Default: widget

Widget/field names:
  --widgets w1,w2       Widgets for all classes (if per-class mapping not provided)
  --fields f1,f2        Fields for all classes
  --widgets-file FILE   Lines: "class<TAB>w1,w2,w3". Default: <cache-root>/available_widgets_and_fields/swagger.widgets.tsv (if kinds includes widget)
  --fields-file FILE    Lines: "class<TAB>f1,f2,f3". Default: <cache-root>/available_widgets_and_fields/swagger.fields.tsv (if kinds includes field)

Behavior:
  --skip-if-exists/--no-skip-if-exists        Default: on
  --compress/--no-compress                    Default: on (write .json.gz)
  --compress-level N                          Gzip level 1-9 (default: 1)
  --verify-json/--no-verify-json              Default: on
  --compare-existing                         If destination exists, fetch and compare (SHA-256 of bytes) instead of skipping
  --overwrite-on-diff                        With --compare-existing, overwrite destination when content differs
  --canonicalize-json/--no-canonicalize-json       Canonicalize JSON before hashing/comparison (default: on)
  --canonicalize-write/--no-canonicalize-write     Write canonicalized JSON to disk (default: on)
  --canon-skip-keys REGEX                          Regex of key names to drop during canonicalization
  --dump-canonical-on-diff                         When compare-existing finds a DIFF, write canonicalized existing/fetched JSON to disk for inspection
  --dump-canonical-dir DIR                         Where to write canonical dumps (default: <cache-root>/logs/<class>/canonical_dumps)
  --workers N                                     Number of parallel workers (default: 1)
  --shard-prefix XX or XX/YY                      Process only objects whose shard prefix matches (e.g. 9c or 9c/b0)
  --object-offset N                               Skip first N objects in the class keyset (after shard/worker filtering)
  --object-limit N                                Process at most N objects in the class keyset (after shard/worker filtering)
  --debug-workers                               Print worker assignment decisions (use with --verbose)
  --exists-debug                               Extra logging around filesystem existence checks
  --strict-missing-only                        In missing-only mode, die if an existing file would be overwritten
  --move-misplaced-fields                     Move misplaced field files found under json/widget/ into json/field/
  --audit-misplaced-fields                    Audit for misplaced field files (no moves, no network)
  --audit-out FILE                            Where to write audit JSON (default: misplaced_fields_audit.json)
  --audit-list-limit N                        Max number of detailed entries to write (default: 5000)

Safety/testing:
  --dry-run          Do not write files; only report planned actions
  --max-objects N    Process at most N objects (across all classes)
  --max-requests N   Stop after N REST requests (across all classes)
  --verbose          Print per-request actions

Logs:
  --log-errors FILE    Default: precache.errors.log
  --log-progress FILE  Default: precache.progress.log

Outputs:
  Run summary: <cache-root>/logs/<class>/precache.summary.tsv (one class per invocation)
  Run metadata:       <cache-root>/logs/<class>/run-meta.tsv (or --log-dir/<class>/run-meta.tsv if --log-dir is set)

Heartbeat:
  --heartbeat-every-objects N   Emit a heartbeat after every N objects processed by the worker (default: 5000; 0 disables)
  --heartbeat-every-urls N      Emit a heartbeat after every N widget/field URLs evaluated (default: 0 disables)
  --heartbeat-file FILE         Heartbeat TSV filename under the class log dir (default: precache.heartbeat.tsv)
USAGE
}

GetOptions(
  'base-url=s'               => \$opt{base_url},
  'cache-root=s'             => \$opt{cache_root},
  'json-subdir=s'            => \$opt{json_subdir},
  'ace-dir=s'                => \$opt{ace_dir},
  'log-dir=s'                => \$opt{log_dir},
  'class=s'                  => \$opt{class},
  'classes-file=s'           => \$opt{classes_file},
  'kinds=s'                  => \$opt{kinds},
  'widgets=s'                => \$opt{widgets},
  'fields=s'                 => \$opt{fields},
  'widgets-file=s'           => \$opt{widgets_file},
  'fields-file=s'            => \$opt{fields_file},
  'timeout=i'                => \$opt{timeout},
  'retries=i'                => \$opt{retries},
  'sleep-ms=i'               => \$opt{sleep_ms},
  'verify-json!'             => \$opt{verify_json},
  'compare-existing!'       => \$opt{compare_existing},
  'overwrite-on-diff!'      => \$opt{overwrite_on_diff},
  'canonicalize-json!'    => \$opt{canonicalize_json},
  'canonicalize-write!'   => \$opt{canonicalize_write},
  'canon-skip-keys=s'     => \$opt{canon_skip_keys},
  'dump-canonical-on-diff!' => \$opt{dump_canonical_on_diff},
  'dump-canonical-dir=s'    => \$opt{dump_canonical_dir},
  'workers=i'               => \$opt{workers},
  'worker-id=i'             => \$opt{worker_id},
  'shard-prefix=s'          => \$opt{shard_prefix},
  'object-offset=i'         => \$opt{object_offset},
  'object-limit=i'          => \$opt{object_limit},
  'skip-if-exists!'          => \$opt{skip_if_exists},
  'move-misplaced-fields!'   => \$opt{move_misplaced_fields},
  'audit-misplaced-fields!'  => \$opt{audit_misplaced_fields},
  'audit-out=s'              => \$opt{audit_out},
  'audit-list-limit=i'       => \$opt{audit_list_limit},
  'log-errors=s'             => \$opt{log_errors},
  'log-progress=s'           => \$opt{log_progress},
  'compress!'                => \$opt{compress},
  'compress-level=i'         => \$opt{compress_level},
  'heartbeat-every-objects=i' => \$opt{heartbeat_every_objects},
  'heartbeat-every-urls=i'    => \$opt{heartbeat_every_urls},
  'heartbeat-file=s'          => \$opt{heartbeat_file},
  'dry-run!'                 => \$opt{dry_run},
  'max-objects=i'            => \$opt{max_objects},
  'max-requests=i'           => \$opt{max_requests},
  'verbose!'                 => \$opt{verbose},
  'debug-workers!'           => \$opt{debug_workers},
  'strict-missing-only!'    => \$opt{strict_missing_only},
  'exists-debug!'           => \$opt{exists_debug},
  'help'                     => sub { usage() },
) or usage();

usage() unless $opt{cache_root};

$opt{cache_root} = File::Spec->rel2abs($opt{cache_root});

# Defaults derived from --cache-root
$opt{ace_dir} ||= File::Spec->catdir($opt{cache_root}, 'ace');

# Normalize derived paths
$opt{ace_dir} = File::Spec->rel2abs($opt{ace_dir});

# Normalize kinds; default is 'widget'
$opt{kinds} ||= 'widget';

# Default widgets/fields mapping files based on kinds
my %kinds_enabled_opt = map { $_ => 1 } grep { length } split /,/, $opt{kinds};

if ($kinds_enabled_opt{widget} && !defined $opt{widgets_file}) {
  $opt{widgets_file} = File::Spec->catfile($opt{cache_root}, 'available_widgets_and_fields', 'swagger.widgets.tsv');
}
if ($kinds_enabled_opt{field} && !defined $opt{fields_file}) {
  $opt{fields_file} = File::Spec->catfile($opt{cache_root}, 'available_widgets_and_fields', 'swagger.fields.tsv');
}

die "ace-dir does not exist: $opt{ace_dir}\n" unless -d $opt{ace_dir};

warn "Effective workers=$opt{workers}\n";

# One class per invocation: require --class for predictable logging and worker partitioning
if (($opt{workers}||1) > 1 && !defined $opt{class}) {
  die "--class is required when using --workers in auto-fork mode\n";
}
if (defined($opt{log_dir}) && length($opt{log_dir})) {
  die "--log-dir requires --class (script is invoked one class at a time)\n" unless defined $opt{class};
  my $class_log_dir = File::Spec->catdir($opt{log_dir}, $opt{class});
  make_path($class_log_dir) unless -d $class_log_dir;
  $opt{effective_log_dir} = $class_log_dir;
}

# Run identifier (parent generates; children inherit via fork)
$opt{run_start_ts} = time;
$opt{host} = hostname();
$opt{run_id} = sprintf("%s.%s.pid%d", scalar(gmtime($opt{run_start_ts})), $opt{host}, $$);
$opt{run_id} =~ s/\s+/-/g;

sub _class_logs_dir {
  my $class = $opt{class} || $opt{current_class} || 'GLOBAL';
  # Prefer user-specified --log-dir/<class> when available; otherwise default to <cache-root>/logs/<class>
  my $dir = (defined($opt{effective_log_dir}) && length($opt{effective_log_dir}))
    ? $opt{effective_log_dir}
    : File::Spec->catdir($opt{cache_root}, 'logs', $class);
  make_path($dir) unless -d $dir;
  return $dir;
}

sub run_meta_path {
  my $dir = _class_logs_dir();
  return File::Spec->catfile($dir, "run-meta.tsv");
}

sub write_run_meta {
  my ($event, %kv) = @_;
  my $p = run_meta_path();
  open my $fh, '>>:utf8', $p or die "Cannot open $p for append: $!\n";
  my @fields = (
    "event=$event",
    "ts=" . time,
    "run_id=$opt{run_id}",
    "host=$opt{host}",
    "pid=$$",
    (defined($opt{worker_id}) ? "worker_id=$opt{worker_id}" : "worker_id=NA"),
  );
  push @fields, map { $_ . "=" . (defined $kv{$_} ? $kv{$_} : '') } sort keys %kv;
  print $fh join("\t", @fields), "\n";
  close $fh;
}

# ------------------------------------------------------------------
# Worker launcher (fork N identical processes, each processes 1/N of objects)
# NOTE: Must run before class selection so --class/--classes-file still parallelize.
# ------------------------------------------------------------------
if (($opt{workers}||1) > 1 && !defined $opt{worker_id}) {
  my $n = $opt{workers};
  die "--workers must be >= 1\n" if $n < 1;

  # Record run start once (parent only)
  write_run_meta('RUN_START',
    base_url => $opt{base_url} || '',
    cache_root => $opt{cache_root},
    ace_dir => $opt{ace_dir},
    workers => $n,
    log_dir => ($opt{effective_log_dir} || $opt{log_dir} || ''),
  );

  if (defined $opt{effective_log_dir} && length $opt{effective_log_dir}) {
    require File::Path;
    File::Path::make_path($opt{effective_log_dir}) unless -d $opt{effective_log_dir};
    die "Cannot create effective log dir $opt{effective_log_dir}\n" unless -d $opt{effective_log_dir};
  }

  my @pids;
  for my $wid (0 .. $n-1) {
    my $pid = fork();
    die "fork failed: $!\n" unless defined $pid;
    if ($pid == 0) {
      # Child: set worker id and continue in same script
      $opt{worker_id} = $wid;
      $0 = "precache_via_rest-v1.2 worker=$wid";

      if (defined $opt{effective_log_dir} && length $opt{effective_log_dir}) {
        my $out = File::Spec->catfile($opt{effective_log_dir}, sprintf('worker.W%d.out', $wid));
        my $err = File::Spec->catfile($opt{effective_log_dir}, sprintf('worker.W%d.err', $wid));
        open STDOUT, '>>:utf8', $out or die "Cannot open $out for append: $!\n";
        open STDERR, '>>:utf8', $err or die "Cannot open $err for append: $!\n";
        select STDERR; $| = 1;
        select STDOUT; $| = 1;
      }
      last;
    } else {
      push @pids, $pid;
    }
  }

  # Parent: wait for children and exit
  if (!defined $opt{worker_id}) {
    my $fail = 0;
    for my $pid (@pids) {
      waitpid($pid, 0);
      my $st = $? >> 8;
      $fail ||= $st;
    }
    # Auto-fork mode: after children finish, aggregate their emitted stats.
    aggregate_worker_stats($n);

    write_run_meta('RUN_END',
      exit_code => $fail,
    );

    exit($fail);
  }
}

$opt{base_url} =~ s{/+$}{};
$opt{json_subdir} =~ s{^/+}{};
$opt{json_subdir} =~ s{/+$}{};

my %kind_enabled = map { $_ => 1 } grep { length } split /,/, $opt{kinds};
my $need_fields = ($kind_enabled{field} || $opt{move_misplaced_fields} || $opt{audit_misplaced_fields}) ? 1 : 0;
$opt{need_fields} = $need_fields;


sub log_fullpath {
  my ($file) = @_;
  my $class = $opt{current_class} || 'GLOBAL';
  my $log_dir = File::Spec->catdir($opt{cache_root}, 'logs', $class);
  make_path($log_dir) unless -d $log_dir;
  my $suffix = defined($opt{worker_id}) ? ".W$opt{worker_id}" : "";
  return File::Spec->catfile($log_dir, $file . $suffix);
}

sub log_line {
  my ($file, $line) = @_;
  my $fullpath = log_fullpath($file);

  open my $fh, '>>:utf8', $fullpath
    or die "Cannot open log $fullpath: $!\n";
  print $fh $line, "\n";
  close $fh;
}
sub log_error    { log_line($opt{log_errors},   $_[0]); }
sub log_progress { log_line($opt{log_progress}, $_[0]); }

sub heartbeat_path {
  my $file = $opt{heartbeat_file} || 'precache.heartbeat.tsv';
  return $file if File::Spec->file_name_is_absolute($file);
  my $dir = _class_logs_dir();
  return File::Spec->catfile($dir, $file);
}

sub log_heartbeat {
  my (%kv) = @_;
  my $p = heartbeat_path();
  open my $fh, '>>:utf8', $p or die "Cannot open $p: $!\n";
  print $fh join("\t",
    'HEARTBEAT',
    'ts=' . time,
    'run_id=' . ($opt{run_id} // ''),
    'host=' . ($opt{host} // ''),
    'pid=' . $$,
    'worker=' . (defined($opt{worker_id}) ? $opt{worker_id} : 'NA'),
    'class=' . ($opt{current_class} // ($opt{class} // 'GLOBAL')),
    (map { $_ . '=' . (defined $kv{$_} ? $kv{$_} : 0) } sort keys %kv),
  ), "\n";
  close $fh;
}

# ------------------------------------------------------------------
# Global stats (auto-fork workers)
#   - Each worker writes a single TSV line at end-of-run.
#   - Parent aggregates those worker stats into one per-class summary (one class per invocation).
# ------------------------------------------------------------------

sub _stats_dir {
  return _class_logs_dir();
}

sub worker_stats_path {
  my ($wid) = @_;
  my $dir = _stats_dir();
  return File::Spec->catfile($dir, sprintf('worker-stats.W%d.tsv', $wid));
}

sub write_worker_stats {
  my (%s) = @_;
  return unless defined $opt{worker_id};
  my $p = worker_stats_path($opt{worker_id});
  open my $fh, '>>:utf8', $p or die "Cannot open $p: $!\n";
  print $fh join("\t",
    'STATS',
    'pid=' . $$,
    'worker=' . $opt{worker_id},
    'objects_seen=' . ($s{objects_seen} // 0),
    'urls_evaluated=' . ($s{urls_evaluated} // 0),
    'widgets_skipped=' . ($s{widgets_skipped} // 0),
    'widgets_fetched=' . ($s{widgets_fetched} // 0),
    'errors=' . ($s{errors} // 0),
    'ts=' . time,
  ), "\n";
  close $fh;
}

sub aggregate_worker_stats {
  my ($n) = @_;
  $n ||= 1;
  my $dir = _stats_dir();

  my %tot = (
    objects_seen    => 0,
    urls_evaluated  => 0,
    widgets_skipped => 0,
    widgets_fetched => 0,
    errors          => 0,
  );

  for my $wid (0 .. $n-1) {
    my $p = worker_stats_path($wid);
    next unless -e $p;
    open my $fh, '<:utf8', $p or next;
    while (my $line = <$fh>) {
      chomp $line;
      next unless $line =~ /^STATS\t/;
      my %kv;
      for my $f (split(/\t/, $line)) {
        next if $f eq 'STATS';
        my ($k,$v) = split(/=/, $f, 2);
        $kv{$k} = $v if defined $k;
      }
      $tot{objects_seen}    += $kv{objects_seen}    || 0;
      $tot{urls_evaluated}  += $kv{urls_evaluated}  || 0;
      $tot{widgets_skipped} += $kv{widgets_skipped} || 0;
      $tot{widgets_fetched} += $kv{widgets_fetched} || 0;
      $tot{errors}          += $kv{errors}          || 0;
    }
    close $fh;
  }

  my $out = File::Spec->catfile($dir, 'precache.summary.tsv');
  open my $ofh, '>>:utf8', $out or die "Cannot open $out: $!\n";
  print $ofh join("\t",
    'SUMMARY',
    'objects_seen=' . $tot{objects_seen},
    'urls_evaluated=' . $tot{urls_evaluated},
    'widgets_skipped=' . $tot{widgets_skipped},
    'widgets_fetched=' . $tot{widgets_fetched},
    'errors=' . $tot{errors},
    'ts=' . time,
  ), "\n";
  close $ofh;
}

sub read_class_map {
  my ($path) = @_;
  return {} unless $path;
  open my $fh, '<:utf8', $path or die "Cannot read $path: $!\n";
  my %m;
  while (<$fh>) {
    chomp;
    next if /^\s*#/ || /^\s*$/;
    my ($class, $csv) = split /\t/, $_, 2;
    next unless $class && defined $csv;
    my @names = grep { length } split /,/, $csv;
    # Normalize: trim whitespace and de-duplicate while preserving order
    my %seen;
    @names = map { my $x = $_; $x =~ s/^\s+//; $x =~ s/\s+$//; $x } @names;
    @names = grep { length($_) } @names;
    @names = grep { !$seen{$_}++ } @names;
    $m{$class} = \@names;
  }
  close $fh;
  return \%m;
}

my $widgets_by_class = read_class_map($opt{widgets_file});
my $fields_by_class  = read_class_map($opt{fields_file});

my @widgets_default = $opt{widgets} ? grep { length } split(/,/, $opt{widgets}) : ();
my @fields_default  = $opt{fields}  ? grep { length } split(/,/, $opt{fields})  : ();

sub read_lines_file {
  my ($path) = @_;
  open my $fh, '<:utf8', $path or die "Cannot read $path: $!\n";
  my @out;
  while (<$fh>) {
    chomp;
    s/\r$//;
    next if /^\s*#/ || /^\s*$/;
    push @out, $_;
  }
  close $fh;
  return @out;
}

sub infer_classes_from_ace_dir {
  my ($dir) = @_;
  opendir(my $dh, $dir) or die "Cannot open ace-dir $dir: $!
";
  my @classes;
  while (my $f = readdir($dh)) {
    next if $f =~ /^\./;
    next unless $f =~ /^(.*)\.ace$/;
    push @classes, $1;
  }
  closedir($dh);
  return sort @classes;
}

# ------------------------------------------------------------------

$opt{vp} = defined($opt{worker_id}) ? "[W$opt{worker_id} pid=$$] " : "[pid=$$] ";

# Startup banner (per process)
my $summary_path = File::Spec->catfile(_class_logs_dir(), 'precache.summary.tsv');
my $runmeta_path = run_meta_path();
warn sprintf("%srun_id=%s host=%s cache_root=%s ace_dir=%s workers=%s log_dir=%s
",
  $opt{vp}, ($opt{run_id}||''),
  ($opt{host}||''),
  $opt{cache_root},
  $opt{ace_dir},
  ($opt{workers}||1),
  (defined($opt{log_dir}) ? $opt{log_dir} : '')
);
warn sprintf("%ssummary=%s runmeta=%s
", $opt{vp}, $summary_path, $runmeta_path);
warn sprintf("%seffective_log_dir=%s
", $opt{vp}, (defined($opt{effective_log_dir}) ? $opt{effective_log_dir} : ''));



my @classes;
if ($opt{class}) {
  @classes = ($opt{class});
} elsif ($opt{classes_file}) {
  @classes = read_lines_file($opt{classes_file});
} else {
  @classes = infer_classes_from_ace_dir($opt{ace_dir});
}
die "No classes to process.\n" unless @classes;

sub objects_from_keyset_ace {
  my ($path) = @_;
  open my $fh, '<:utf8', $path or die "Cannot read $path: $!\n";
  my $in_stanza = 0;
  my @ids;
  while (my $line = <$fh>) {
    $line =~ s/\r?\n\z//;
    next if $line =~ /^\s*$/;
    next if $line =~ /^KeySet\s*:/;
    if (!$in_stanza && $line =~ /^[A-Za-z_][A-Za-z0-9_]*\s*:\s*$/) {
      $in_stanza = 1;
      next;
    }
    if ($in_stanza) {
      if ($line =~ /^\s+(\S+)\s*$/) {
        push @ids, $1;
        next;
      }
      last;
    }
  }
  close $fh;
  die "No objects parsed from $path (unexpected KeySet format?)\n" unless @ids;
  return @ids;
}

sub objects_for_class {
  my ($class) = @_;
  my $path = File::Spec->catfile($opt{ace_dir}, "$class.ace");
  die "ACE KeySet file not found for class=$class at $path\n" unless -e $path;
  return objects_from_keyset_ace($path);
}

sub names_for {
  my ($kind, $class) = @_;
  if ($kind eq 'widget') {
    return @{ $widgets_by_class->{$class} } if $widgets_by_class->{$class};
    return @widgets_default if @widgets_default;
    die "No widgets configured for class=$class. Provide --widgets or --widgets-file.\n";
  }
  if ($kind eq 'field') {
    return @{ $fields_by_class->{$class} } if $fields_by_class->{$class};
    return @fields_default if @fields_default;
    return () unless $opt{need_fields};
    die "No fields configured for class=$class. Provide --fields or --fields-file.\n";
  }
  die "Unknown kind=$kind\n";
}

sub json_root {
  return File::Spec->catdir($opt{cache_root}, $opt{json_subdir});
}

sub payload_paths_for {
  my (%a) = @_;
  my ($kind,$class,$object,$name) = @a{qw(kind class object name)};
  my ($shards) = shards_from_name(name_u => $object, shard_levels => 2, shard_chars => 2);
  my $leaf = leaf_from_name($object);
  my $dir  = File::Spec->catdir(json_root(), $kind, $class, $shards->[0], $shards->[1], $leaf);
  my $json_path = File::Spec->catfile($dir, "$name.json");
  my $gz_path   = File::Spec->catfile($dir, "$name.json.gz");
  my $write_path = $opt{compress} ? $gz_path : $json_path;
  return ($write_path, $dir, $shards, $leaf, $gz_path, $json_path);
}

sub existing_payload_path_for {
  my (%a) = @_;
  my (undef, undef, undef, undef, $gz_path, $json_path) = payload_paths_for(%a);
  return $gz_path   if -e $gz_path;
  return $json_path if -e $json_path;
  return undef;
}

sub canonical_dest_for {  # backward-compat alias
  return payload_paths_for(@_);
}

# Compatibility helpers for the streaming object loop (v10.x)
sub dest_path_for {
  my (%a) = @_;
  my ($file, $dir) = payload_paths_for(%a);
  make_path($dir) unless -d $dir;
  return $file;
}

sub slurp_file {
  my ($path) = @_;
  if ($path =~ /\.gz\z/) {
    my $out = '';
    gunzip $path => \$out or die "gunzip failed for $path: $GunzipError\n";
    return $out;
  }
  open my $fh, '<:raw', $path or die "Cannot read $path: $!\n";
  local $/;
  my $bytes = <$fh>;
  close $fh;
  return $bytes;
}

sub canonicalize_json_for_compare {
  my ($bytes, $context) = @_;
  return canonicalize_json_bytes($bytes, $context);
}

sub http_get {
  my ($url) = @_;
  my ($status, $headers, $content) = fetch_bytes($url);
  my $ok = ($status && $status >= 200 && $status < 300) ? 1 : 0;
  return { success => $ok, status => $status, headers => $headers, content => $content };
}

sub write_file_atomic {
  my ($path, $bytes) = @_;
  if ($path =~ /\.gz\z/) {
    my $dir = dirname($path);
    make_path($dir) unless -d $dir;
    my $tmp = "$path.$$." . int(rand(1_000_000)) . ".tmp";
    gzip(\$bytes => $tmp, Level => ($opt{compress_level}||1))
      or die "gzip failed for $tmp: $GzipError\n";
    rename($tmp, $path) or die "Rename $tmp -> $path failed: $!\n";
  } else {
    atomic_write_bytes($path, $bytes);
  }
  return 1;
}


sub misplaced_field_candidate_for {
  my (%a) = @_;
  my ($class,$sh1,$sh2,$leaf,$field_name) = @a{qw(class sh1 sh2 leaf field_name)};
  my $json_path = File::Spec->catfile(json_root(), 'widget', $class, $sh1, $sh2, $leaf, "$field_name.json");
  my $gz_path   = File::Spec->catfile(json_root(), 'widget', $class, $sh1, $sh2, $leaf, "$field_name.json.gz");
  return ($gz_path, $json_path);
}



sub _canon_walk {
  my ($x) = @_;
  if (ref($x) eq 'HASH') {
    my %h;
    for my $k (keys %$x) {
      next if defined($opt{canon_skip_keys}) && $k =~ /$opt{canon_skip_keys}/;
      $h{$k} = _canon_walk($x->{$k});
    }
    return \%h;
  }
  if (ref($x) eq 'ARRAY') {
    return [ map { _canon_walk($_) } @$x ];
  }
  return $x;
}

sub canonicalize_json_bytes {
  my ($bytes, $context) = @_;
  return $bytes unless $opt{canonicalize_json};

  my $data = eval { decode_json($bytes) };
  if ($@) {
    return $bytes; # caller will log BAD_JSON elsewhere
  }

  $data = _canon_walk($data);

  my $j = JSON::PP->new->canonical(1)->utf8(1);
  return $j->encode($data);
}



sub canonicalize_json_file_bytes {
  my ($path, $context) = @_;
  open my $fh, '<:raw', $path or die "Cannot open $path: $!\n";
  local $/;
  my $bytes = <$fh>;
  close $fh;
  return canonicalize_json_bytes($bytes, $context);
}

sub dump_canonical_pair {
  my (%a) = @_;
  my ($dest_path, $canon_existing, $canon_fetched, $class, $kind, $object, $name) =
    @a{qw(dest_path canon_existing canon_fetched class kind object name)};

  my $root = $opt{dump_canonical_dir}
    || File::Spec->catdir($opt{cache_root}, 'logs', ($opt{current_class} || 'GLOBAL'), 'canonical_dumps');
  make_path($root) unless -d $root;

  my $base = join("__", $class, $kind, $object, $name);
  $base =~ s{[^A-Za-z0-9._-]+}{_}g;

  my $ex_path = File::Spec->catfile($root, "$base.existing.canon.json");
  my $fe_path = File::Spec->catfile($root, "$base.fetched.canon.json");

  atomic_write_bytes($ex_path, $canon_existing);
  atomic_write_bytes($fe_path, $canon_fetched);

  log_error("CANON_DUMP	$dest_path	existing=$ex_path	fetched=$fe_path");
  print "CANON_DUMP	$dest_path	existing=$ex_path	fetched=$fe_path
" if $opt{verbose};
}

sub sha256_file {
  my ($path, $context) = @_;
  open my $fh, '<:raw', $path or die "Cannot open for hashing $path: $!
";
  local $/;
  my $bytes = <$fh>;
  close $fh;

  my $canon = canonicalize_json_bytes($bytes, $context);
  return sha256_bytes($canon);
}

sub sha256_bytes {
  my ($bytes) = @_;
  my $sha = Digest::SHA->new(256);
  $sha->add($bytes);
  return $sha->hexdigest;
}

sub maybe_verify_json_file {
  my ($path) = @_;
  return 1 unless $opt{verify_json};
  open my $fh, '<:raw', $path or do {
    log_error("EXISTING_READ_FAIL\t$path\t$!");
    return 0;
  };
  local $/;
  my $bytes = <$fh>;
  close $fh;
  eval { decode_json($bytes); 1 } or do {
    log_error("EXISTING_BAD_JSON\t$path\t" . ($@ || 'unknown json parse error'));
    return 0;
  };
  return 1;
}


sub atomic_write_bytes {
  my ($path, $bytes) = @_;
  my $dir = dirname($path);
  make_path($dir) unless -d $dir;
  my $tmp = "$path.$$." . int(rand(1_000_000)) . ".tmp";
  open my $fh, '>:raw', $tmp or die "Cannot write $tmp: $!\n";
  print $fh $bytes;
  close $fh;
  rename($tmp, $path) or die "Rename $tmp -> $path failed: $!\n";
}

sub run_audit_misplaced_fields {
  my $t0 = time();
  my %rep = (
    generated_at_utc => scalar gmtime() . " UTC",
    cache_root       => $opt{cache_root},
    json_root        => json_root(),
    ace_dir          => $opt{ace_dir},
    classes          => \@classes,
    totals => {
      objects_scanned       => 0,
      candidates_checked    => 0,
      misplaced_found       => 0,
      already_correct       => 0,
      both_present          => 0,
      missing_both          => 0,
    },
    per_class => {},
    misplaced_examples => [],
    capped => JSON::PP::false,
  );

  CLASS:
  for my $class (@classes) {
  $opt{current_class} = $class;
  log_progress("START_CLASS\t$class\tpid=$$\tworker=" . (defined($opt{worker_id}) ? $opt{worker_id} : 'PARENT'));
  log_progress("LOG_PATHS\terrors=" . log_fullpath($opt{log_errors}) . "\tprogress=" . log_fullpath($opt{log_progress}));

    my @fields = $opt{need_fields} ? names_for('field', $class) : ();
    
    # Stream objects from ACE KeySet file to avoid loading huge lists into memory.
    my $ace_path = File::Spec->catfile($opt{ace_dir}, "$class.ace");
    die "ACE KeySet file not found for class=$class at $ace_path\n" unless -e $ace_path;

    my ($want_sh1, $want_sh2);
    if (defined $opt{shard_prefix}) {
      if ($opt{shard_prefix} =~ /^([0-9a-f]{2})(?:\/([0-9a-f]{2}))?$/i) {
        $want_sh1 = lc($1);
        $want_sh2 = defined($2) ? lc($2) : undef;
      } else {
        die "--shard-prefix must be XX or XX/YY (hex bytes)\n";
      }
    }

    my $offset = $opt{object_offset} || 0;
    my $limit  = $opt{object_limit};
    my $seen_after_filters = 0;
    my $processed_after_filters = 0;

    open my $ace_fh, '<:utf8', $ace_path or die "Cannot read $ace_path: $!\n";
    my $in_stanza = 0;
    OBJECT: OBJECT: while (my $line = <$ace_fh>) {
      $line =~ s/\r?\n\z//;
      next if $line =~ /^\s*$/;
      next if $line =~ /^KeySet\s*:/;
      if (!$in_stanza && $line =~ /^[A-Za-z_][A-Za-z0-9_]*\s*:\s*$/) {
        $in_stanza = 1;
        next;
      }
      next unless $in_stanza;

      my ($object) = ($line =~ /^\s+(\S+)\s*$/);
      last unless defined $object;

      # Global max_objects (across classes) guard
      if (defined $opt{max_objects}) {
        my $remaining = $opt{max_objects} - $rep{totals}{objects_scanned};
        last if $remaining <= 0;
      }

      my ($shards) = shards_from_name(name_u => $object, shard_levels => 2, shard_chars => 2);
      my $obj_sh1 = $shards->[0];
      my $obj_sh2 = $shards->[1];

      # Hard worker gating at object level (prevents any overlap across workers)
      if (defined $opt{worker_id} && ($opt{workers}||1) > 1) {
        my $n   = $opt{workers};
        my $wid = $opt{worker_id};
        my $h16 = hex($obj_sh1 . $obj_sh2);
        my $assigned = $h16 % $n;
        if ($opt{debug_workers} && $opt{verbose}) {
          print $opt{vp} . "WORKER_ASSIGN\tobject=$object\tsh=$obj_sh1/$obj_sh2\th16=$h16\tassigned=$assigned\tneed=$wid\n";
        }
        if ($assigned != $wid) {
          print $opt{vp} . "SKIP_OBJECT_OTHER_WORKER\t$object\tassigned=$assigned\n" if $opt{verbose} && $opt{verbose} > 1;
          next OBJECT;
        }
        if ($opt{debug_workers} && $opt{verbose}) {
          print $opt{vp} . "PROCESS_OBJECT\tobject=$object\tsh=$obj_sh1/$obj_sh2\tassigned=$assigned\n";
        }
      }


      # Shard filtering based on object name
      if (defined $want_sh1) {
        next if $obj_sh1 ne $want_sh1;
        next if defined($want_sh2) && $obj_sh2 ne $want_sh2;
      }

      # Worker partitioning handled earlier (object-level gate)

      $seen_after_filters++;

      # Offset/limit apply after shard+worker filtering
      next if $seen_after_filters <= $offset;
      if (defined $limit && $processed_after_filters >= $limit) {
        last;
      }
      $processed_after_filters++;


      $rep{totals}{objects_scanned}++;
      $rep{per_class}{$class}{objects_scanned}++;

      for my $fname (@fields) {
        $rep{totals}{candidates_checked}++;
        $rep{per_class}{$class}{candidates_checked}++;

        my ($dest_path, undef, $shards, $leaf) = canonical_dest_for(
          kind => 'field', class => $class, object => $object, name => $fname
        );
        my ($src_gz, $src_json) = misplaced_field_candidate_for(
          class => $class, sh1 => $shards->[0], sh2 => $shards->[1], leaf => $leaf, field_name => $fname
        );

        my $field_existing = existing_payload_path_for(kind => 'field', class => $class, object => $object, name => $fname);
        my $src_path = -e $src_gz ? $src_gz : (-e $src_json ? $src_json : undef);
        my $has_field  = $field_existing ? 1 : 0;
        my $has_widget = $src_path ? 1 : 0;

        if ($has_field) {
          $rep{totals}{already_correct}++;
          $rep{per_class}{$class}{already_correct}++;
          if ($has_widget) {
            $rep{totals}{both_present}++;
            $rep{per_class}{$class}{both_present}++;
          }
          next OBJECT;
        }

        if ($has_widget) {
          $rep{totals}{misplaced_found}++;
          $rep{per_class}{$class}{misplaced_found}++;

          if (@{ $rep{misplaced_examples} } < $opt{audit_list_limit}) {
            push @{ $rep{misplaced_examples} }, {
              class => $class,
              object => $object,
              field_name => $fname,
              src => $src_path,
              dest => $dest_path,
            };
          } else {
            $rep{capped} = JSON::PP::true;
          }
        } else {
          $rep{totals}{missing_both}++;
          $rep{per_class}{$class}{missing_both}++;
        }
      }
    
    }
    close $ace_fh;

  }

  $rep{elapsed_seconds} = time() - $t0 + 0;

  open my $fh, '>:utf8', $opt{audit_out} or die "Cannot write audit report $opt{audit_out}: $!\n";
  print $fh encode_json(\%rep), "\n";
  close $fh;

  print "Audit complete.\n";
  print "  Objects scanned:      $rep{totals}{objects_scanned}\n";
  print "  Candidates checked:   $rep{totals}{candidates_checked}\n";
  print "  Misplaced found:      $rep{totals}{misplaced_found}\n";
  print "  Already correct:      $rep{totals}{already_correct}\n";
  print "  Both present:         $rep{totals}{both_present}\n";
  print "  Missing both:         $rep{totals}{missing_both}\n";
  print "  Report:               $opt{audit_out}\n";
  exit(0);
}

if ($opt{audit_misplaced_fields}) {
  run_audit_misplaced_fields();
}

my $http = HTTP::Tiny->new(
  timeout => $opt{timeout},
  agent   => "WormBasePrecacheRESTFirst/10.24",
);


sub _url_seg {
    my ($s) = @_;
    # Encode everything except unreserved: ALPHA / DIGIT / "-" / "." / "_" / "~"
    return uri_escape_utf8($s, q{^A-Za-z0-9\-\._~});
}

sub rest_url_for {
    my (%a) = @_;
    my ($kind,$class,$object,$name) = @a{qw(kind class object name)};
    
    die "kind required\n"   unless defined $kind;
    die "class required\n"  unless defined $class;
    die "object required\n" unless defined $object;
    
    my $c = lc($class);
    
    if ($kind eq 'widget') {
	die "widget name required\n" unless defined($name) && length($name);
	return join('/',
		    $opt{base_url},
		    'widget',
		    _url_seg($c),
		    _url_seg($object),
		    _url_seg($name),
	    );
    }
    elsif ($kind eq 'field') {
	die "field name required\n" unless defined($name) && length($name);
	return join('/',
		    $opt{base_url},
		    'field',
		    _url_seg($c),
		    _url_seg($object),
		    _url_seg($name),
	    );
    }
    
    die "Unknown kind=$kind\n";
}


#sub rest_url_for {
#  my (%a) = @_;
#  my ($kind,$class,$object,$name) = @a{qw(kind class object name)};
#  my $c = lc($class);
#  if ($kind eq 'widget') {
#      die "widget name required\n" unless $name;
#    return "$opt{base_url}/widget/$c/$object/$name";
#  } elsif ($kind eq 'field') {
#    die "field name required\n" unless $name;
#    return "$opt{base_url}/field/$c/$object/$name";
#  }
#  die "Unknown kind=$kind\n";
#}

sub fetch_bytes {
  my ($url) = @_;
  for my $attempt (0..$opt{retries}) {
    my $res = $http->get($url);
    return ($res->{status}, $res->{headers}, $res->{content}) if $res->{success};
    my $st = $res->{status} // 0;
    my $reason = $res->{reason} // 'unknown';
    if ($attempt < $opt{retries}) {
      log_error("RETRY\t$st\t$reason\t$url\tattempt=$attempt");
      select(undef, undef, undef, 0.25);
      next;
    }
    return ($st, $res->{headers} || {}, $res->{content});
  }
  return (599, {}, '');
}

sub maybe_verify_json {
  my ($bytes, $url) = @_;
  return 1 unless $opt{verify_json};
  eval { decode_json($bytes); 1 } or do {
    log_error("BAD_JSON\t$url\t" . ($@ || 'unknown json parse error'));
    return 0;
  };
  return 1;
}

my $t0 = time();
my $objects_done  = 0;
my $requests_done = 0;
my $errors_seen   = 0;
my $widgets_skipped = 0;   # existing on disk / identical / kept existing / late exists
my $widgets_fetched = 0;   # HTTP success + valid JSON (even if not written)
my $urls_evaluated  = 0;   # widget/field name attempts evaluated (includes skipped-on-exists)

my $hb_every_objects = int($opt{heartbeat_every_objects} || 0);
my $hb_every_urls    = int($opt{heartbeat_every_urls} || 0);
die "--heartbeat-every-objects must be >= 0\n" if $hb_every_objects < 0;
die "--heartbeat-every-urls must be >= 0\n" if $hb_every_urls < 0;
my $next_hb_objects = ($hb_every_objects > 0) ? $hb_every_objects : undef;
my $next_hb_urls    = ($hb_every_urls > 0)    ? $hb_every_urls    : undef;

# Should refactor this into something simpler.
#my %stats = ();

CLASS:
for my $class (@classes) {
  $opt{current_class} = $class;
  log_progress("START_CLASS\t$class\tpid=$$\tworker=" . (defined($opt{worker_id}) ? $opt{worker_id} : 'PARENT'));
  log_progress("LOG_PATHS\terrors=" . log_fullpath($opt{log_errors}) . "\tprogress=" . log_fullpath($opt{log_progress}));

  # Stream objects from ACE KeySet file to avoid loading huge lists into memory.
  my $ace_path = File::Spec->catfile($opt{ace_dir}, "$class.ace");
  die "ACE KeySet file not found for class=$class at $ace_path\n" unless -e $ace_path;

  my ($want_sh1, $want_sh2);
  if (defined $opt{shard_prefix}) {
    if ($opt{shard_prefix} =~ /^([0-9a-f]{2})(?:\/([0-9a-f]{2}))?$/i) {
      $want_sh1 = lc($1);
      $want_sh2 = defined($2) ? lc($2) : undef;
    } else {
      die "--shard-prefix must be XX or XX/YY (hex bytes)\n";
    }
  }

  my $offset = $opt{object_offset} || 0;
  my $limit  = $opt{object_limit};
  my $seen_after_filters = 0;
  my $processed_after_filters = 0;

  open my $ace_fh, '<:utf8', $ace_path or die "Cannot read $ace_path: $!\n";
  my $in_stanza = 0;

  OBJECT: while (my $line = <$ace_fh>) {
    $line =~ s/\r?\n\z//;
    next if $line =~ /^\s*$/;
    next if $line =~ /^KeySet\s*:/;
    if (!$in_stanza && $line =~ /^[A-Za-z_][A-Za-z0-9_]*\s*:\s*$/) {
      $in_stanza = 1;
      next;
    }
    next unless $in_stanza;

    my ($object) = ($line =~ /^\s+(\S+)\s*$/);
    next unless defined $object;

    # Optional local object filter: uncomment if desired
#    next unless $object =~ /^A_12_.*/;
#    next unless $object =~ /^WBGene.*/;

    # Global max_objects guard (across all classes)
    if (defined $opt{max_objects}) {
      my $remaining = $opt{max_objects} - $objects_done;
      last CLASS if $remaining <= 0;
    }

    # Pre-compute shards once (used for path + filtering + worker assignment)
    my ($shards) = shards_from_name(name_u => $object, shard_levels => 2, shard_chars => 2);
    my $obj_sh1 = $shards->[0];
    my $obj_sh2 = $shards->[1];

    # Shard slice filter
    if (defined $want_sh1) {
      next if $obj_sh1 ne $want_sh1;
      next if defined($want_sh2) && $obj_sh2 ne $want_sh2;
    }

    # Worker assignment (object-level, no overlap)
    if (defined $opt{worker_id} && ($opt{workers}||1) > 1) {
      my $n   = $opt{workers};
      my $wid = $opt{worker_id};
      my $h16 = hex($obj_sh1 . $obj_sh2);
      my $assigned = $h16 % $n;

      if ($opt{debug_workers} && $opt{verbose}) {
        my $wa = "WORKER_ASSIGN\tobject=$object\tsh=$obj_sh1/$obj_sh2\th16=$h16\tassigned=$assigned\tneed=$wid";
        print $opt{vp} . "$wa\n";
        log_error($wa);
      }

      next OBJECT if $assigned != $wid;
    }

    $seen_after_filters++;
    next if $seen_after_filters <= $offset;
    if (defined $limit && $processed_after_filters >= $limit) {
      last;
    }
    $processed_after_filters++;

    $objects_done++;

    if (defined $next_hb_objects && $objects_done >= $next_hb_objects) {
      log_heartbeat(
        objects_done     => $objects_done,
        urls_evaluated   => $urls_evaluated,
        requests_done    => $requests_done,
        widgets_fetched  => $widgets_fetched,
        widgets_skipped  => $widgets_skipped,
        errors_seen      => $errors_seen,
      );
      warn $opt{vp} . "HEARTBEAT objects_done=$objects_done urls_evaluated=$urls_evaluated requests_done=$requests_done widgets_fetched=$widgets_fetched widgets_skipped=$widgets_skipped errors_seen=$errors_seen\n";
      $next_hb_objects += $hb_every_objects;
    }

    for my $kind (qw(widget field)) {
      next unless $kind_enabled{$kind};

      my @names = names_for($kind, $class);
      NAME: for my $name (@names) {
        my $dest_path = dest_path_for(class => $class, kind => $kind, object => $object, name => $name);
        my $existing_path = existing_payload_path_for(class => $class, kind => $kind, object => $object, name => $name);

        $urls_evaluated++;
        if (defined $next_hb_urls && $urls_evaluated >= $next_hb_urls) {
          log_heartbeat(
            objects_done     => $objects_done,
            urls_evaluated   => $urls_evaluated,
            requests_done    => $requests_done,
            widgets_fetched  => $widgets_fetched,
            widgets_skipped  => $widgets_skipped,
            errors_seen      => $errors_seen,
          );
          warn $opt{vp} . "HEARTBEAT objects_done=$objects_done urls_evaluated=$urls_evaluated requests_done=$requests_done widgets_fetched=$widgets_fetched widgets_skipped=$widgets_skipped errors_seen=$errors_seen\n";
          $next_hb_urls += $hb_every_urls;
        }

        my $exists = defined($existing_path) ? 1 : 0;
        if ($opt{exists_debug} && $opt{verbose}) {
          my $sz = $exists ? (-s $existing_path) : 0;
          print $opt{vp} . "EXISTS_CHECK	$dest_path	exists=$exists	size=$sz\n";
        }
        if ($opt{skip_if_exists} && $exists && !$opt{compare_existing}) {
	  my $p = $existing_path || $dest_path;
	  print $opt{vp} . "SKIP\t$p\n" if $opt{verbose};
	  $widgets_skipped++;
          next NAME;
        }


        my $url = rest_url_for(kind => $kind, class => $class, object => $object, name => $name);
        my $resp = http_get($url);
	$requests_done++;
        if (!$resp->{success}) {
          my $status = $resp->{status} || 'NA';
          log_error("HTTP_$status\t$url\tclass=$class\tobject=$object\tkind=$kind\tname=$name\t$dest_path");
	  $errors_seen++;
          next NAME;
        }
        my $bytes = $resp->{content};

        unless (maybe_verify_json($bytes, $url)) {
          $errors_seen++;
          next NAME;
        }

        # Count as fetched once it has passed JSON verification (or verification disabled).
        $widgets_fetched++;

        if ($opt{compare_existing} && $existing_path) {
          my $existing = slurp_file($existing_path);
          my $canon_existing = eval { canonicalize_json_for_compare($existing, { class => $class, kind => $kind, object => $object, name => $name, source => 'existing' }) };
          if ($@) { log_error("CANON_EXISTING_FAIL\t$existing_path\t$@"); next NAME; }
          my $canon_fetched  = eval { canonicalize_json_for_compare($bytes,   { class => $class, kind => $kind, object => $object, name => $name, source => 'fetched' }) };
          if ($@) { log_error("CANON_FETCH_FAIL\t$dest_path\t$@"); next NAME; }

          my $sha_existing = sha256_bytes($canon_existing);
          my $sha_fetched  = sha256_bytes($canon_fetched);

          if ($sha_existing eq $sha_fetched) {
            print $opt{vp} . "SKIP_IDENTICAL\t$dest_path\n" if $opt{verbose};
            $widgets_skipped++;
            next NAME;
          }

          if ($opt{dump_canonical_on_diff}) {
            dump_canonical_pair(dest_path => $dest_path, existing => $canon_existing, fetched => $canon_fetched,
                                class => $class, kind => $kind, object => $object, name => $name);
          }

          if (!$opt{overwrite_on_diff}) {
            print $opt{vp} . "KEEP_EXISTING_DIFF\t$dest_path\n" if $opt{verbose};
            $widgets_skipped++;
            next NAME;
          }
          # else fall through to write fetched bytes
        }

        my $late_existing = existing_payload_path_for(class => $class, kind => $kind, object => $object, name => $name);
        if ($opt{skip_if_exists} && $late_existing && !$opt{compare_existing}) {
          my $msg = "RACE_OR_PATH_MISMATCH\t$late_existing\trefusing_overwrite";
          if ($opt{strict_missing_only}) {
            die "$msg\n";
          }
          log_error($msg);
          print $opt{vp} . "SKIP_EXISTING_LATE\t$late_existing\n" if $opt{verbose};
          $widgets_skipped++;
          next NAME;
        }
        write_file_atomic($dest_path, $bytes);
        print $opt{vp} . "WROTE\t$dest_path\n" if $opt{verbose};
      }
    }
  }

  close $ace_fh;


  log_progress("END_CLASS\t$class\tobjects_done=$objects_done\trequests_done=$requests_done\terrors_seen=$errors_seen");
}

my $dt = time() - $t0;
log_progress("DONE\tt=${dt}s\tobjects=$objects_done\turls_evaluated=$urls_evaluated\trequests=$requests_done\terrors_seen=$errors_seen\twidgets_fetched=$widgets_fetched\twidgets_skipped=$widgets_skipped");

# Emit per-worker totals for parent aggregation (auto-fork mode).
write_worker_stats(
  objects_seen    => $objects_done,
  urls_evaluated  => $urls_evaluated,
  widgets_skipped => $widgets_skipped,
  widgets_fetched => $widgets_fetched,
  errors          => $errors_seen,
);

# Single-process mode: write a per-class summary directly.
if (!defined($opt{worker_id}) && ($opt{workers}||1) <= 1) {
  my $dir = _stats_dir();
  my $out = File::Spec->catfile($dir, 'precache.summary.tsv');
  open my $ofh, '>>:utf8', $out or die "Cannot open $out: $!\n";
  print $ofh join("\t",
    'SUMMARY',
    'objects_seen=' . $objects_done,
    'urls_evaluated=' . $urls_evaluated,
    'widgets_skipped=' . $widgets_skipped,
    'widgets_fetched=' . $widgets_fetched,
    'errors=' . $errors_seen,
    'ts=' . time,
  ), "\n";
  close $ofh;
}

print "DONE! objects=$objects_done urls_evaluated=$urls_evaluated requests=$requests_done errors=$errors_seen widgets_fetched=$widgets_fetched widgets_skipped=$widgets_skipped   ---> time=${dt}s\n";
print "DONE! objects=$objects_done urls_evaluated=$urls_evaluated requests=$requests_done errors=$errors_seen widgets_fetched=$widgets_fetched widgets_skipped=$widgets_skipped   ---> time=${dt}s\n";
