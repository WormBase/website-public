package WormBase::Util::Hash;

use strict;
use warnings;
use Carp;
use Exporter 'import';

our @EXPORT_OK = qw(merge_hashes);

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

1;
