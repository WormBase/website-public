package WormBase::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::Role

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 role

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "role_id",
  { data_type => "integer", is_nullable => 0 },
  "role",
  { data_type => "char(255)", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("role_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 14:27:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XWqI6tiCaGUj75+wZZDcgg
__PACKAGE__->has_many(users_to_roles=>'WormBase::Schema::Result::UserRole', 'role_id');
__PACKAGE__->many_to_many(users => 'users_to_roles', 'user', ,{ where => { active => 1 }}); 
# You can replace this text with custom content, and it will be preserved on regeneration
1;
