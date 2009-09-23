package WormBase::DBH::AceDB;

use Ace;
use base qw/WormBase::Model/;
use strict;

__PACKAGE__->mk_accessors(qw/acedb_host
			     acedb_port
			     acedb_user
			     acedb_pass
			     cache_root
			     cache_expires
			     cache_size
			     cache_auto_purge_interval/);


sub new {
    my ($class,$args) = @_;
    my $this = bless $args,$class;
    $this->log->debug("Instantiating WormBase::Model::AceDB...");
    $this->connect;
    return $this;
}

sub connect {
    my ($self) = @_;
    $self->log->info("Connecting to acedb:");

    # TODO: Should be able to select from a number of available acedb hosts
    #  my @available_hosts = $self->acedb_hosts;
    #  my $host = $available_hosts[int(rnd())];
    
    my @auth  = (-user=>$self->acedb_user,
		 -pass=>$self->acedb_pass) 
	if $self->acedb_user && $self->acedb_pass;
    my @cache = (-cache => {
	cache_root => $self->cache_root,
	max_size   => $self->cache_size
	    || $Cache::SizeAwareCache::NO_MAX_SIZE
	    || -1,  # hardcoded $NO_MAX_SIZE constant
	    default_expires_in  => $self->cache_expires       || '1 day',
	    auto_purge_interval => $self->cache_auto_purge_interval || '6 hours',
		 } 
	) if $self->cache_root;
    
    if ($self->log->is_debug()) {
	$self->log->debug('     using the following parameters:');
	$self->log->debug('       ' . $self->acedb_host . ':' . $self->acedb_port);
    }
    
    my $dbh = Ace->connect(-host=>$self->acedb_host,
			   -port=>$self->acedb_port,
			   -timeout=>50,@auth,@cache)
	or $self->log->fatal("Could not connect to the acedb at " . $self->acedb_host);
    
    $self->log->info("   --> succesfully established connection to acedb on " . $self->acedb_host) if $dbh;
    
    # Cache my handle
    $self->dbh($dbh);
    return $dbh;
}

# IS SHOULD BE DYNAMIC FOR MULTIPLE ACES / MULTIPLE HOSTS!
sub dbh {
    my ($self,$dbh) = @_;
    if ($dbh) {
	$self->{dbh} = $dbh;
    } else {
	
	# Do we have a live dbh?
	if ($self->{dbh} && $self->{dbh}->ping) {
	    return $self->{dbh};
	} else {
	    $self->{log}->debug("Acedb has gone away. Trying to reconnect...");
	    my $dbh = $self->connect();
	    $self->{dbh} = $dbh;
	    return $dbh;
	}
    }
}

sub version {
    my ($self) = @_;
    return $self->dbh->version;
}

# Provided with the name of an object,
# fetch it from the database.
# NOTE: This is intended to only return
# a single object. It is NOT a search!

sub get_object {
    my ($self,$class,$name) = @_;
    
    $self->log->debug("get_object(): class:$class name:$name");
    
    my $db = $self->dbh();
    my $formatted_class = ucfirst($class);
    my $object = $db->fetch(-class=>$formatted_class,-name=>$name,-fill=>1);  
    
    return $object;
}



=head1 NAME

WormBase::Model::AceDB - AceDB Model Class

=head1 SYNOPSIS

See L<WormBase>

=head1 DESCRIPTION

AceDB Model Class

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
