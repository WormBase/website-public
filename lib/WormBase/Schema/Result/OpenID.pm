package WormBase::Schema::Result::OpenID;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::OpenID

=cut

__PACKAGE__->table("openid");

__PACKAGE__->add_columns(
  "auth_id",
  { data_type => "text", is_nullable => 0, is_auto_increment => 1},
  "openid_url",
  { data_type => "char(255)", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "provider",
  { data_type => "text", default_value => "", is_nullable => 1 },
  "oauth_access_token",
  { data_type => "text", default_value => "", is_nullable => 1 },
  "oauth_access_token_secret",
  { data_type => "text", default_value => "", is_nullable => 1 },
  "screen_name",
  { data_type => "text", default_value => "", is_nullable => 1 },
  "auth_type",
  { data_type => "text", default_value => "", is_nullable => 1 },

);

__PACKAGE__->set_primary_key("auth_id");


#__PACKAGE__->add_unique_constraint([ 'openid_url' ]);

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');

