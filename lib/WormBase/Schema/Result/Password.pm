package WormBase::Schema::Result::Password;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Password

=cut

__PACKAGE__->table("password_reset");



__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "token",
  { data_type => "char(50)", default_value => "", is_nullable => 1 },
  "expires",
  { data_type => "integer", default_value => "", is_nullable => 1 },

);
__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aWUX+zL4WtBgQQBgwyvCyg

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');
# You can replace this text with custom content, and it will be preserved on regeneration
1;
