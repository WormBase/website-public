package WormBase::Web::Model::Gene_regulation;
use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args    = $c->config->{'Model::Gene_regulation'}->{args};
  $args->{request}   = $c->stash->{request};
  $args->{class}     = 'Gene_regulation';
  $args->{log}       = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  return $args;
}

1;
