package WormBase::Web::Model::Gene;
use parent qw/Catalyst::Model::Factory/;

# Fetch the default args and pass along some extras
# including our C::Log::Log4perl
sub prepare_arguments {
    my ($self, $c) = @_; # $app sometimes written as $c
    
    $c->log->debug("Instantiating model for Gene");
    
    # Fetch the default args and pass along some extras
    # This seems unnecessary - should be automatic.
#    my $args  = $c->config->{'Model::Gene'}->{args};
    my $args = {};
    $args->{name}  = $c->stash->{request};
    $args->{class} = $c->stash->{class};

#    $args->{log}              = $c->log;


    # The process of instantiating the wrapper object also populates
    # it with the full driver object.
    # Perhaps subclassing would be clearer.

#    $args->{object} = $c->stash->{object};
#    my $object = $c->stash->{object};
#    $c->log->debug("Class is Gene");
#    $c->log->debug("Object is $object");# . ": " . $object->Public_name);


    return $args;
}

#sub mangle_arguments {
#    my ($self,$args) = @_;
#    return ({object => $c->stash->{object}});
	    
#    return ({ acedb_dbh => $c->model('WormBaseAPI')->acedb_dbh,
#	      name      => "WBGene00006763",
#	      class     => "Gene",
#	    });
#    return ("Gene","WBGene00006763");
#    return %$args;
#}


=head1

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

    # We need access to the ace and gff models
#    $args->{ace_model}        = $c->model('AceDB');
#    $args->{gff_model}        = $c->model('GFF');
#    $args->{wormbase}         = $c->model('WormBase');

    $args->{gbrowse_conf_dir} = $c->config->{gbrowse_conf_dir};
    $args->{log}              = $c->log;
    return $args;
}


=cut

1;
