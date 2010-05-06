package WormBase::API::Service::gff;

use Moose;
use Bio::DB::GFF ();

has 'dbh' => (
    is        => 'rw',
    isa       => 'Bio::DB::GFF',   # Could also be a seq feature store, eh?
    predicate => 'has_dbh',
    writer    => 'set_dbh',
    );


with 'WormBase::API::Role::Service';

sub BUILD {
    my $self = shift;
#     $self->symbolic_name("gff");
    $self->function("get connection to GFF database");
    # record all the info from Conf file $self->conf_dir
#     $self->hosts([$self->conf->{host}]);
    $self->user($self->conf->{user});
    $self->pass($self->conf->{pass});

}

sub ping {
  my $self= shift;
  return @_;

}

sub connect {
    my $self = shift;
     
    return Bio::DB::GFF->new( -user => $self->user,
			      -pass => $self->pass,
			      -dsn => "dbi:mysql:database=".$self->species.";host=" . $self->host,
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
