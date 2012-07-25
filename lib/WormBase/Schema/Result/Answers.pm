package WormBase::Schema::Result::Answers;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Answers

=cut

__PACKAGE__->table("answers");



__PACKAGE__->add_columns(
  "answer_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "question_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "answer",
  { data_type => "text", default_value => "", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("answer_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

# __PACKAGE__->has_many(users_to_roles=>'WormBase::Schema::Result::Answers', 'question_id');

__PACKAGE__->belongs_to(question=>'WormBase::Schema::Result::Questions','question_id');
__PACKAGE__->has_many(votes=>'WormBase::Schema::Result::Votes', 'answer_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
