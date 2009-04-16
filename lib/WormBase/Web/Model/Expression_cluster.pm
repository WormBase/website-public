package WormBase::Web::Model::Expression_cluster;
use base qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Expression_cluster'}->{args};
  $args->{class}   = 'Expression_cluster';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  return $args;
}

1;
