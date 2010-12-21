package WormBase::Schema::Result::HistoryVisits;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::UserIssue

=cut

__PACKAGE__->table("history_visits");



__PACKAGE__->add_columns(
  "history_visit_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "user_history_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "visit_time",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("history_visit_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

__PACKAGE__->belongs_to(user_history=>'WormBase::Schema::Result::UserHistory','user_history_id');
# You can replace this text with custom content, and it will be preserved on regeneration
1;
