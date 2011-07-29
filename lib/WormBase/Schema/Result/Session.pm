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
__PACKAGE__->add_columns(
  "session_id",
   { data_type => "char(72)", is_nullable => 0},
   "session_data",
   { data_type => "text", is_nullable =>1},
    "expires",
   { data_type => "int(10)", is_nullable =>1},
   );
__PACKAGE__->set_primary_key('session_id');



__PACKAGE__->many_to_many(pages => 'user_saved', 'page');
__PACKAGE__->has_many(user_saved=>'WormBase::Schema::Result::Starred', 'session_id');

# __PACKAGE__->many_to_many(visited => 'user_history', 'page');
__PACKAGE__->has_many(user_history=>'WormBase::Schema::Result::History', 'session_id');

1;
