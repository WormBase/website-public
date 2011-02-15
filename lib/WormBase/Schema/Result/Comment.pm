package WormBase::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Issue

=cut

__PACKAGE__->table("comments");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "reporter",
  { data_type => "char(50)", is_nullable => 1 },
   "submit_time",
  { data_type => "char(50)", is_nullable => 1 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "content",
  { data_type => "text", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');

#__PACKAGE__->has_many(issues_to_threads=>'WormBase::Schema::Result::IssueThread', 'issue_id'); 
# __PACKAGE__->belongs_to(owner=>'WormBase::Schema::Result::User','reporter');
1;
