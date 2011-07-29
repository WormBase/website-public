package WormBase::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Messages

=cut

__PACKAGE__->table("messages");

__PACKAGE__->add_columns(
  "message_id",
  { data_type => "integer", is_nullable => 0 },
   "message",
  { data_type => "text", is_nullable => 1 },
   "message_type",
  { data_type => "char(72)", is_nullable => 1 },
   "timestamp",
  { data_type => "integer", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("message_id");

#__PACKAGE__->has_many(widgets=>'WormBase::Schema::Result::Widgets', 'widget_id'); 

1;
