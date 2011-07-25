package WormBase::Schema::Result::Widgets;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::PageWidgets

=cut

__PACKAGE__->table("widgets");

__PACKAGE__->add_columns(
  "widget_id",
  { data_type => "integer", is_nullable => 0, is_autoincrement=>1 },
  "page_id",
  { data_type => "integer", is_nullable => 1 },
  "widget_title",
  { data_type => "char(72)", is_nullable => 1 },
  "widget_order",
  { data_type => "integer", is_nullable => 1 },
  "current_revision_id",
  { data_type => "integer", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("widget_id");

__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');
__PACKAGE__->might_have(content=>'WormBase::Schema::Result::WidgetRevision', { 'foreign.widget_revision_id' => 'self.current_revision_id' });

#__PACKAGE__->has_many(widgets=>'WormBase::Schema::Result::Widgets', 'widget_id'); 

1;
