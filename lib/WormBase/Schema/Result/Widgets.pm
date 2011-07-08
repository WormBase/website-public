package WormBase::Schema::Result::Widgets;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Widgets

=cut

__PACKAGE__->table("widgets");

__PACKAGE__->add_columns(
  "widget_id",
  { data_type => "integer", is_nullable => 0 },
   "content",
  { data_type => "text", is_nullable => 1 },
   "user_id",
  { data_type => "integer", is_nullable => 1 },
   "widget_date",
  { data_type => "char(50)", is_nullable => 0 },
   "current_version",
  { data_type => "boolean", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("widget_id", "widget_date");

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');
#__PACKAGE__->has_many(widgets=>'WormBase::Schema::Result::Widgets', 'widget_id'); 

1;
