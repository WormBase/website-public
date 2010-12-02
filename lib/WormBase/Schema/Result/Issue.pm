package WormBase::Schema::Result::Issue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Issue

=cut

__PACKAGE__->table("issues");

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "reporter",
  { data_type => "integer", is_nullable => 1 },
  "responser",
  { data_type => "integer", is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "state",
  { data_type => "text", is_nullable => 1 },
   "submit_time",
  { data_type => "char(50)", is_nullable => 1 },
  "location",
  { data_type => "text", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");


#__PACKAGE__->add_unique_constraint([ 'openid_url' ]);
__PACKAGE__->has_many(users_to_issues=>'WormBase::Schema::Result::UserIssue', 'issue_id');
__PACKAGE__->has_many(issues_to_threads=>'WormBase::Schema::Result::IssueThread', 'issue_id'); 
__PACKAGE__->belongs_to(owner=>'WormBase::Schema::Result::User','reporter');
__PACKAGE__->belongs_to(responser=>'WormBase::Schema::Result::User','responser');
1;