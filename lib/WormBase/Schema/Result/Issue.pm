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
    "issue_id",
    { data_type => "integer", is_nullable => 0 },
    "reporter_id",
    { data_type => "integer", is_nullable => 1 },
    "responsible_id",
    { data_type => "integer", is_nullable => 1 },
    "title",
    { data_type => "text", is_nullable => 1 },
    "state",
    { data_type => "text", is_nullable => 1 },
    "severity",
    { data_type => "text", is_nullable => 1 },
    "is_private",
    { data_type => "text", is_nullable => 1 },
    "timestamp",
    { data_type => "integer", is_nullable => 1 },
    "page_id",
    { data_type => "integer", default_value => 0, is_nullable => 0 },
    "content",
    { data_type => "text", is_nullable => 1 },
    );

__PACKAGE__->set_primary_key("issue_id");

__PACKAGE__->has_many(threads=>'WormBase::Schema::Result::IssueThread', 'issue_id'); 
__PACKAGE__->belongs_to(reporter=>'WormBase::Schema::Result::User','reporter_id');
__PACKAGE__->belongs_to(responsible=>'WormBase::Schema::Result::User','responsible_id');
__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');

1;
