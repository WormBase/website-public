package WormBase::Ace;

use strict;
use warnings;

use parent 'Ace';

=over

=item raw_fetch(I<$object>, I<$tag>)

    my $object = $ace->fetch(Gene => 'WBGene00000018');
    my $species = $ace->raw_fetch($object, 'Species'); # raw Species string

Fetches the raw string value (i.e. no Ace object is made) of a tag in
an object.  If the tag could not be found, then undef is returned.

B<When to [not] use C<raw_fetch>>. C<raw_fetch> should be used when
fetching the value of an object's field only i.e. no Ace::Object needs
to be created. The performance gains are most apparent when fetching
the string (only) of many fields of an object. C<raw_fetch> should not
be used when the field data is large, as the gain is minimal. It
should not be used when the field contains escaped double-quotes. If
C<raw_fetch> I<must> be used on a field which can have escaped
double-quotes, read on.

C<raw_fetch> uses, by default, a simple matching pattern to extract the
value of a given tag.  If the simple pattern does not suffice, then a
more specialized pattern can be used by adding it to the PATTERN_CACHE
variable in this module. A CONCLUSIVE_PATTERN has been provided for
convenience and completeness which should work on any field but is
significantly slower than the simple pattern.

=cut

{
    # The following "conclusive pattern" will capture "-delimited strings
    # that include escaped double-quotes (\") and handle escaped back-slashes
    # (\\) as well. In general, doing a raw_fetch with data expected to
    # contain these special cases is a bad idea. This pattern is included
    # for completeness [only].
    my $CONCLUSIVE_PATTERN = qr/\s+"(.*?)(?<!(?<!\\)\\)"/; # see %PATTERN_CACHE for usage

    my %PATTERN_CACHE = (
        # TAG => qr/^TAG\s+$CONCLUSIVE_PATTERN/sm, # TAG needs the conclusive pattern
        # TAG => qr/^TAG\s+SOME_PATTERN/sm,        # TAG needs a special pattern
    );

    # wishlist: list context should return a bunch
    sub raw_fetch {
        my ($self, $object, $tag) = @_;

        # uncomment the following if separate optimized methods exist
        # # run the optimized/correct method if possible
        # my $raw_fetch_alt = "raw_fetch_\l$tag";
        # return $self->$raw_fetch_alt($object) if $self->can($raw_fetch_alt);

        my $regex = $PATTERN_CACHE{$tag} //= qr/^$tag\s+"([^"]+)"/m;

        my $class = $object->class;
        $self->raw_query(qq(find $class "$object"));
        my ($val) = $self->raw_query("show -a $tag") =~ $regex;
        return $val;
    }
}

# NO FILE CACHE. GIVES ENOUGH HEADACHES.
sub cache {}

1;
