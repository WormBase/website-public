package WormBase::Web::Model::Phenotype_ontology;
use base qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_;
  my $args  = $c->config->{'Model::Phenotype_ontology'}->{args};
  $args->{class}   = 'Phenotype_ontology';
  $args->{request} = $c->stash->{request};
  $args->{log}     = $c->log;
  $args->{ace_model} = $c->model('AceDB');
  $args->{gff_model} = $c->model('GFF');
  $args->{gbrowse_conf_dir} = $c->config->{gbrowse_conf_dir};
  return $args;
}

1;
