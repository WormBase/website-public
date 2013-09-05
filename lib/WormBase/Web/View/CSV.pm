package WormBase::Web::View::CSV;

use base qw ( Catalyst::View::CSV );
use strict;
use warnings;

__PACKAGE__->config ( sep_char => ",", suffix => "csv" );

=head1 NAME

WormBase::Web::View::CSV - CSV view for WormBase::Web

=head1 DESCRIPTION

CSV view for WormBase::Web

=head1 SEE ALSO

L<WormBase::Web>, L<Catalyst::View::CSV>, L<Text::CSV>

=head1 AUTHOR

Abigail Cabunoc

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
