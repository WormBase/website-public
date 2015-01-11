package WormBase::API::Service::gff;

use Moose;
use Bio::DB::SeqFeature::Store () ;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Bio::DB::SeqFeature::Store',
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/search_notes segment get_features_by_name get_features_by_attribute/],
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

#has 'aggregators' => (
#    is  => 'ro',
#    isa => 'ArrayRef[Str]',
#    lazy => 1,
#    default => sub {
#        my $self = shift;
#        my @array;
#        my $ret = $self->conf->{data_sources}->{$self->species}->{aggregator};
#
#	if ($ret =~ /ARRAY/) {
#	    push(@array, @$ret);
#	} else {
#	    push(@array, $ret);
#	}
#        return \@array;
#    }
#);

sub _build_function {
    return 'get connection to GFF database';
}

sub ping {
  my $self= shift;
  return @_;

}

# Added to handle all the places where we pass an Ace Object to segment
around 'segment' => sub {
    my ($orig, $self, $object, $start, $stop) = @_;
    my $name = $self->prepare_name($object);
    return $self->$orig($name, $start, $stop);
   # return $self->segment("$name", $start, $stop);
};

around 'get_features_by_name' => sub {
    my ($orig, $self, $object) = @_;
    my $name = $self->prepare_name($object);
    return $self->$orig($name);
};

sub prepare_name {
    my ($self, $object) = @_;
    my $name;
    if ("$object" =~ m/\w?+:(.+)/) {
        # remove species prefix in tier 3 sequences
        $name = $1;
    }else{
        $name = $object;
    }
    return $name;
}

sub connect {
    my $self = shift;

    my $db = Bio::DB::SeqFeature::Store->new( -user => $self->user,
					      -pass => $self->pass,
					      -dsn => "dbi:mysql:database=".$self->source.";host=" . $self->host,
					      -adaptor     => $self->adaptor,
	);
    # No longer req'd; testing to be certain
#			      -aggregators => $self->aggregators,
#					      $self->ace ? (-acedb=>$self->ace):()
#	);

    return $db;
}
1;
