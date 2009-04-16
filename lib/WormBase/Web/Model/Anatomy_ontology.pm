package WormBase::Web::Model::Anatomy_ontology;
use base qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Anatomy_ontology'}->{args};
  $args->{request} = $c->stash->{request};
  $args->{class}   = 'Anatomy_ontology';
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  $args->{gff_model} = $c->model('GFF');
  return $args;
}

1;
