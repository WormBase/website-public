package WormBase::Util::Hash;

use strict;
use warnings;
use Carp;
use Exporter 'import';

our @EXPORT_OK = qw(merge_hashes elements_at_level);

=over

=item B<merge_hahes($hash1, $hash2, ...)>

    merge_hahes($hash1, $hash2);

Merges two or more hashes together. If only one hash is provided, that has is
returned. Subhashes sharing a key are recursively merged together. Hashes
specified later in the argument list overwrite the value of hashes specified
earlier.

    $hash1 = { a => 1, b => 2, c => 3 };
    $hash2 = { a => 2 };

    $hash3 = {
        a => {
            a => 1,
            b => 2,
            c => 3,
        },
    };
    $hash4 = {
        a => {
            a => 999,
        }
    };

    merge_hash($hash1, $hash2); # { a => 2, b => 2, c => 3 }
    merge_hash($hash2, $hash1); # { a => 1, b => 2, c => 3 }

    merge_hash($hash1, $hash3); # { a => { ... }, b => 2, c => 3 }
    merge_hash($hash3, $hash1); # { a => 1, b => 2, c => 3 }

    merge_hash($hash3, $hash4); # { a => { a => 999, b => 2, c => 3 } }
    merge_hash($hash4, $hash3); # { a => { a => 1, b => 2, c => 3 } }

=cut

sub merge_hashes {
    my @hashes = grep {defined $_} @_;
    my $hashref = shift @hashes;
    croak 'Args must be hashrefs.' unless ref $hashref eq 'HASH';

    my %hash1 = %$hashref;
    return \%hash1  unless @hashes;

    $hashref = shift @hashes;
    croak 'Args must be hashrefs.' unless ref $hashref eq 'HASH';

    my %hash2 = %$hashref;

    foreach my $key (keys %hash2) {
        if(exists $hash1{$key} and
           ref $hash1{$key} eq 'HASH' and ref $hash2{$key} eq 'HASH') {
            $hash1{$key} = merge_hashes($hash1{$key}, $hash2{$key})
        }
        else {
            $hash1{$key} = $hash2{$key};
        }
    }

    return merge_hashes(\%hash1, @hashes);
}

=item B<elements_at_level($structured_obj, $level)>

    @elems = elements_at_level($structured_obj, $level);

Traverses a structured object (hash or array) down to the specified level
and returns a list of the elements at that level. The 0th level is the object
itself, the 1st level is everything contained within the object, and so on.

For example,

    $hash = {
        a => { d => 4,
               e => 5,
               f => [7, 8, 9]
             },
        b => { # empty hash
             },
        c => [ 1,
               2,
               3,
               {
                   g => 6,
               }
           ]
    };

   elements_at_level($hash, 0); # $hash itself
   elements_at_level($hash, 1); # (hash at a, hash at b, array at c)
   elements_at_level($hash, 2); # (4, 5, [7, 8, 9], 1, 2, 3, { g => 6 })
   elements_at_level($hash, 3); # (7, 8, 9, 6)
   elements_at_level($hash, 4); # ()

This is like taking cross-sections of a structured object.

=cut

# not really a hash-specific method -- works for arrays as well
sub elements_at_level {
    my $obj = shift // return;
    my $level = shift or return $obj; # level 0
    croak 'The depth/level must be non-negative' if $level < 0;

    return map { elements_at_level($_, $level-1) } values %$obj
        if ref $obj eq 'HASH';

    return map { elements_at_level($_, $level-1) } @$obj
        if ref $obj eq 'ARRAY';

    return; # don't know what it is
}

1;
