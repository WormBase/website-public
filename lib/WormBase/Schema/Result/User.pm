package WormBase::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 email_address

  data_type: 'text'
  is_nullable: 1

=head2 first_name

  data_type: 'text'
  is_nullable: 1

=head2 last_name

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 1 },
  "password",
  { data_type => "text", is_nullable => 1 },
  "gtalk_key",
  { data_type => "text", is_nullable => 1 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "wbid",
  { data_type => "text", is_nullable => 1 },
  "wb_link_confirm",
  { data_type => "boolean", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07001 @ 2010-08-20 15:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+lEYBqay22QmTazn+Cga1A
__PACKAGE__->has_many(users_to_roles=>'WormBase::Schema::Result::UserRole', 'user_id');
__PACKAGE__->has_many(open_ids=>'WormBase::Schema::Result::OpenID', 'user_id');
__PACKAGE__->has_one(primary_email=>'WormBase::Schema::Result::Email', 'user_id', ,{ where => { validated => 1, primary_email => 1 } });
__PACKAGE__->has_many(valid_emails=>'WormBase::Schema::Result::Email', 'user_id', ,{ where => { validated => 1 } });
__PACKAGE__->has_many(email_address=>'WormBase::Schema::Result::Email', 'user_id');
__PACKAGE__->many_to_many(roles => 'users_to_roles', 'role');

__PACKAGE__->has_many(issues_reported=>'WormBase::Schema::Result::Issue', 'reporter_id');
__PACKAGE__->has_many(issues_responsible=>'WormBase::Schema::Result::Issue', 'responsible_id');
__PACKAGE__->has_many(comments=>'WormBase::Schema::Result::Comment', 'user_id');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
