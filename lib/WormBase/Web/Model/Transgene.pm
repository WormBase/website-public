package WormBase::Web::Model::Transgene;
use base qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Transgene'}->{args};
  $args->{class}   = 'Transgene';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
#  $args->{dbh_gff} = $c->model('GFF');
  return $args;
}

1;
