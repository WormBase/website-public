package WormBase::Web::Model::Sequence;
use base 'Catalyst::Model::Factory';

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
  my ($self, $c) = @_; # $app sometimes written as $c
  
  # Fetch the default args and pass along some extras
  # This seems unnecessary - should be automatic.
  my $args  = $c->config->{'Model::Sequence'}->{args};
  $args->{log}                    = $c->log;
  $args->{request}             = $c->stash->{request};  # Why do I need the request?
  $args->{class}                 = 'Sequence';
  $args->{ace_model}        = $c->model('AceDB');
  $args->{gff_model}         = $c->model('GFF');
  #  $args->{gbrowse_conf_dir} = $c->config->{gbrowse_conf_dir};
  return $args;
}

1;
