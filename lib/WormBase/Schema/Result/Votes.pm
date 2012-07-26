package WormBase::Schema::Result::Votes;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Votes

=cut

__PACKAGE__->table("votes");



__PACKAGE__->add_columns(
  "session_id",
  { data_type => "char(72)", default_value => 0, is_nullable => 0 },
  "question_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "answer_id",
  { data_type => "integer", default_value => 0 },
);
__PACKAGE__->set_primary_key("session_id", "question_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

# You can replace this text with custom content, and it will be preserved on regeneration
1;
