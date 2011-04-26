package WormBase::Util::URI;

use strict;
use warnings;

use URI;
use URI::URL;
use List::Util qw(reduce);
use Exporter 'import';

our @EXPORT;
our @EXPORT_OK = qw(is_same_domain);

sub is_same_domain {
    my @absolute_hps = map { $_->can('host_port') ? $_->host_port : () }
                       map { ref $_ ? $_ : URI::URL->new($_) } @_;
    return 1 unless @absolute_hps;

    # have to check equality amongst the absolute URIs
    return reduce { $a eq $b && $b } @absolute_hps;
}

1;
