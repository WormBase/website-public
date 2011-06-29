package WormBase::Schema::Result::PageWidgets;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::PageWidgets

=cut

__PACKAGE__->table("page_widgets");

__PACKAGE__->add_columns(
  "page_id",
  { data_type => "integer", is_nullable => 0 },
  "widget_id",
  { data_type => "integer", is_nullable => 0 },
   "widget_title",
  { data_type => "char(72)", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("page_id", "widget_id");

__PACKAGE__->belongs_to(page=>'WormBase::Schema::Result::Page','page_id');
#__PACKAGE__->has_many(widgets=>'WormBase::Schema::Result::Widgets', 'widget_id'); 

1;
