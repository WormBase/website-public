package WormBase::API::Service::gff;

use Moose;
use Bio::DB::SeqFeature::Store () ;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Bio::DB::SeqFeature::Store',   # Could also be a seq feature store, eh?
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/search_notes get_features_by_name/],
);

with 'WormBase::API::Role::Service';

has 'ace' => (
    is  => 'rw',
    isa => 'Ace',
);

has 'adaptor' => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->conf->{data_sources}->{$self->species}->{adaptor};
    }
);

has 'aggregators' => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
        my $self = shift;
        my @array;
        my $ret = $self->conf->{data_sources}->{$self->species}->{aggregator};

	if ($ret =~ /ARRAY/) {
	    push(@array, @$ret);
	} else {
	    push(@array, $ret);
	}
        return \@array;
    }
);

sub _build_function {
    return 'get connection to GFF database';
}

sub ping {
  my $self= shift;
  return @_;

}

# Added to handle all the places where we pass an Ace Object to segment
sub segment {
    my ($self, $object) = @_;
    return $self->dbh->segment("$object");
}

sub connect {
    my $self = shift;

    my $db = Bio::DB::SeqFeature::Store->new( -user => $self->user,
			      -pass => $self->pass,
			      -dsn => "dbi:mysql:database=".$self->source.";host=" . $self->host,
			      -adaptor     => $self->adaptor,
			      -aggregators => $self->aggregators,
				  $self->ace ? (-acedb=>$self->ace):()
    );

#    $db->freshen_ace if $db;
	if($db && $self->ace) {
		$self->log->debug("freshen ace");
		$db->freshen_ace ;
	}
    return $db;
}
1;
