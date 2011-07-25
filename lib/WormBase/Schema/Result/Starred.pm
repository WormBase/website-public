package WormBase::Schema::Result::Starred;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::UserIssue

=cut

__PACKAGE__->table("starred");



__PACKAGE__->add_columns(
  "session_id",
  { data_type => "char(72)", default_value => 0, is_nullable => 0 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "save_to",
  { data_type => "char(50)", default_value => 'reports', is_nullable => 1 },
  "timestamp",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("session_id", "page_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

__PACKAGE__->belongs_to(session=>'WormBase::Schema::Result::Session','session_id');
__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');
# You can replace this text with custom content, and it will be preserved on regeneration
1;
