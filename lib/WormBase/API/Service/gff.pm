package WormBase::API::Service::gff;

use Moose;
use Bio::DB::GFF () ;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Bio::DB::GFF',   # Could also be a seq feature store, eh?
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/segment search_notes fetch_group /],
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
        return $self->conf->{data_sources}->{$self->source}->{adaptor};
    }
);

has 'aggregators' => (
    is  => 'ro',
    isa => 'ArrayRef[Str]',
    lazy => 1,
    default => sub {
        my $self = shift;
        return $self->conf->{data_sources}->{$self->source}->{aggregator};
    }
);

sub _build_function {
    return 'get connection to GFF database';
}

sub ping {
  my $self= shift;
  return @_;

}

sub connect {
    my $self = shift;

    my $db = Bio::DB::GFF->new( -user => $self->user,
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

# AD: pending removal
# # HACK!  This probably belongs in GFF.pm
# sub fetch_gff_gene {
#     my $self       = shift;
#     my $transcript = shift;
#     my $trans;
# #    if ($SPECIES =~ /briggsae/) {
# #	($trans)      = grep {$_->method eq 'wormbase_cds'} $GFF->fetch_group(Transcript => $transcript);
# #    }

#     my $dbh = $self->dbh;

#     ($trans) = grep {$_->method eq 'full_transcript'} $dbh->fetch_group(Transcript => $transcript) unless $trans;

#     # Now pseudogenes
#     ($trans) = grep {$_->method eq 'pseudo'} $dbh->fetch_group(Pseudogene => $transcript) unless ($trans);

#     # RNA transcripts - this is getting out of hand
#     ($trans) = $dbh->segment(Transcript => $transcript) unless ($trans);
#     return $trans;
# }

1;
