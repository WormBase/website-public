package WormBase::Schema::Result::UserHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::UserIssue

=cut

__PACKAGE__->table("user_history");



__PACKAGE__->add_columns(
  "user_history_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "session_id",
  { data_type => "char(72)", default_value => 0, is_nullable => 0 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("user_history_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

__PACKAGE__->belongs_to(session=>'WormBase::Schema::Result::Session','session_id');
__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');

__PACKAGE__->has_many(visits=>'WormBase::Schema::Result::HistoryVisits', 'user_history_id');
# You can replace this text with custom content, and it will be preserved on regeneration
1;
