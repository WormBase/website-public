package WormBase::Web::Model::Structure_data;
use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Structure_data'}->{args};
  $args->{class}   = 'Structure_data';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  $args->{gff_model}  = $c->model('GFF');
  return $args;
}

1;
