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
  "openid_url",
  { data_type => "text", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("openid_url");


#__PACKAGE__->add_unique_constraint([ 'openid_url' ]);

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');

