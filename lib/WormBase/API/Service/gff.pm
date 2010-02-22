package WormBase::API::Service::gff;

use Moose;
use Bio::DB::GFF;

has 'dbh' => (
    is        => 'rw',
    isa       => 'Bio::DB::GFF',   # Could also be a seq feature store, eh?
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    handles   => [qw/fetch/],
    );


with 'WormBase::API::Role::Service';
#with 'WormBase::API::Role::Logger';

sub BUILD {
    my $self = shift;
    $self->symbolic_name("gff");
    $self->function("get connection to GFF database");
    # record all the info from Conf file $self->conf_dir
    $self->hosts([qw/aceserver.cshl.edu/]);
    $self->user("nobody");
    $self->pass("");

}

sub ping {
  my $self= shift;
  return @_;

}

sub connect {
    my $self = shift;
    my ($host,$port,$user,$pass)=@_;
    return Bio::DB::GFF->new( -user => $user,
			      -pass => $pass,
			      -dsn => "dbi:mysql:database=".$self->species.";host=" . $host,
    );
}


# HACK!  This probably belongs in GFF.pm
sub fetch_gff_gene {
    my $self       = shift;
    my $transcript = shift;
    my $trans;
#    if ($SPECIES =~ /briggsae/) {
#	($trans)      = grep {$_->method eq 'wormbase_cds'} $GFF->fetch_group(Transcript => $transcript);
#    }
    
    my $dbh = $self->dbh;

    ($trans) = grep {$_->method eq 'full_transcript'} $dbh->fetch_group(Transcript => $transcript) unless $trans;
    
    # Now pseudogenes
    ($trans) = grep {$_->method eq 'pseudo'} $dbh->fetch_group(Pseudogene => $transcript) unless ($trans);
    
    # RNA transcripts - this is getting out of hand
    ($trans) = $dbh->segment(Transcript => $transcript) unless ($trans);
    return $trans;
}





1;
