package WormBase::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Session

=cut

__PACKAGE__->table('sessions');
__PACKAGE__->add_columns(qw/id session_data expires/);
__PACKAGE__->set_primary_key('id');

1;
