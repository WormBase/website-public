package WormBase::Web::Model::Motif;
use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args    = $c->config->{'Model::Motif'}->{args};
  $args->{request} = $c->stash->{request};
  $args->{class}   = 'Motif';
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  return $args;
}

1;
