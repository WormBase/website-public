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



__PACKAGE__->many_to_many(pages => 'user_saved', 'page');
__PACKAGE__->has_many(user_saved=>'WormBase::Schema::Result::UserSave', 'session_id');

# __PACKAGE__->many_to_many(visited => 'user_history', 'page');
__PACKAGE__->has_many(user_history=>'WormBase::Schema::Result::UserHistory', 'session_id');

1;
