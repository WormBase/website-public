package WormBase::Cache::ShardPath;

use strict;
use warnings;

use Exporter qw(import);
use Digest::SHA qw(sha1_hex);
use Encode qw(encode decode);
use Unicode::Normalize qw(NFC);

our @EXPORT_OK = qw(
  canon_utf8_bytes
  percent_encode_bytes
  leaf_from_name
  shards_from_name
  object_name_from_leaf
  object_rel_dir
);

# Canonicalization used by the sharded cache:
#  - Normalize to NFC
#  - Encode to UTF-8 bytes (croak on invalid)
sub canon_utf8_bytes {
    my ($text) = @_;
    die "canon_utf8_bytes: undef\n" unless defined $text;
    my $nfc = NFC($text);
    return encode('UTF-8', $nfc, Encode::FB_CROAK);
}

# Percent-encode bytes, leaving only RFC3986 unreserved characters unescaped.
# Input MUST be bytes, not a Perl character string.
sub percent_encode_bytes {
    my ($bytes) = @_;
    die "percent_encode_bytes: undef\n" unless defined $bytes;
    $bytes =~ s/([^A-Za-z0-9\-\._~])/sprintf("%%%02X", ord($1))/ge;
    return $bytes;
}

# Given a Unicode object name, return the directory leaf used on disk/S3.
# This is a lossless encoding of the UTF-8 bytes, with special-casing for '.' and '..'.
sub leaf_from_name {
    my ($name_u) = @_;
    die "leaf_from_name: undef\n" unless defined $name_u;
    my $bytes = canon_utf8_bytes($name_u);
    my $leaf  = percent_encode_bytes($bytes);
    $leaf = "%2E"    if $leaf eq ".";
    $leaf = "%2E%2E" if $leaf eq "..";
    die "Encoded leaf empty; unexpected\n" if $leaf eq "";
    return $leaf;
}

# Given a Unicode object name, return shard components derived from sha1(UTF-8 bytes).
# Returns: (\@shards, $sha1_hex)
sub shards_from_name {
    my (%args) = @_;
    my $name_u       = $args{name_u}       // die "shards_from_name: name_u required\n";
    my $shard_levels = $args{shard_levels} // 2;
    my $shard_chars  = $args{shard_chars}  // 2;

    die "--shard-levels must be >= 1\n" unless $shard_levels >= 1;
    die "--shard-chars must be >= 1\n"  unless $shard_chars  >= 1;

    my $bytes = canon_utf8_bytes($name_u);
    my $hex   = sha1_hex($bytes);

    my @shards;
    for my $i (0 .. $shard_levels - 1) {
        push @shards, substr($hex, $i * $shard_chars, $shard_chars);
    }

    return (\@shards, $hex);
}

# Reverse mapping used by manifest tooling: leaf -> UTF-8 bytes -> Unicode (NFC).
sub object_name_from_leaf {
    my ($leaf) = @_;
    die "object_name_from_leaf: undef\n" unless defined $leaf;

    my $bytes = $leaf;
    $bytes =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/ge;

    my $u = decode('UTF-8', $bytes, Encode::FB_CROAK);
    return NFC($u);
}

# Relative directory path for an object below a <root>/<class>.
# Returns: (<shard1>, <shard2>, <leaf>) (or more shards if configured).
sub object_rel_dir {
    my (%args) = @_;
    my $name_u       = $args{name_u}       // die "object_rel_dir: name_u required\n";
    my $shard_levels = $args{shard_levels} // 2;
    my $shard_chars  = $args{shard_chars}  // 2;

    my ($shards, undef) = shards_from_name(
        name_u       => $name_u,
        shard_levels => $shard_levels,
        shard_chars  => $shard_chars,
    );

    my $leaf = leaf_from_name($name_u);
    return (@$shards, $leaf);
}

1;
