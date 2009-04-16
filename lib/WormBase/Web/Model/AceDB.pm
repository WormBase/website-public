package WormBase::Web::Model::AceDB;
use base qw/Catalyst::Model::Adaptor/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args     = $c->config->{'Model::AceDB'}->{args};
  $args->{log} = $c->log;
  return $args;
}

1;
