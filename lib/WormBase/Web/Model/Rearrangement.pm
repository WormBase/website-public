package WormBase::Web::Model::Rearrangement;
use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Rearrangement'}->{args};
  $args->{class}   = 'Rearrangement';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  $args->{gff_model} = $c->model('GFF');
  return $args;
}

1;
