package WormBase::Schema::Result::WidgetRevision;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Widgets

=cut

__PACKAGE__->table("widget_revision");

__PACKAGE__->add_columns(
  "widget_revision_id",
  { data_type => "integer", is_nullable => 0 },
  "widget_id",
  { data_type => "integer", is_nullable => 1 },
   "content",
  { data_type => "text", is_nullable => 1 },
   "user_id",
  { data_type => "integer", is_nullable => 1 },
   "timestamp",
  { data_type => "integer", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("widget_revision_id");

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');
__PACKAGE__->belongs_to(widget=>'WormBase::Schema::Result::Widgets','widget_id');

#__PACKAGE__->has_many(widgets=>'WormBase::Schema::Result::Widgets', 'widget_id'); 

1;
