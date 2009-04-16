package WormBase::Web::Model::Homology_group;
use base qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Homology_group'}->{args};
  $args->{class}   = 'Homology_group';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('GFF');
  $args->{gff_model} = $c->model('AceDB');
  return $args;
}

1;
