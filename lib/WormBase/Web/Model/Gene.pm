package WormBase::Web::Model::Gene;
use base qw/Catalyst::Model::Factory/;

#sub prepare_arguments {
#  my ($self, $c) = @_; # $app sometimes written as $c
#  my $args = $self->SUPER::prepare_arguments('Gene','use_ace','use_gff');
#  $args->{gbrowse_conf_dir} = $c->config->{gbrowse_conf_dir};
#  return $args;
#}


# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_; # $app sometimes written as $c

  $c->log->debug("Instantiating model for Gene");

  # Fetch the default args and pass along some extras
  # This seems unnecessary - should be automatic.
  my $args  = $c->config->{'Model::Gene'}->{args};
  $args->{request}          = $c->stash->{request};
  $args->{class}            = 'Gene';
  $args->{ace_model}        = $c->model('AceDB');
  $args->{gff_model}        = $c->model('GFF');
  $args->{gbrowse_conf_dir} = $c->config->{gbrowse_conf_dir};
  $args->{log}              = $c->log;
  return $args;
}



1;
