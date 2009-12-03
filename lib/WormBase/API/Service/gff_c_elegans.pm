package WormBase::API::Service::gff_c_elegans;

use Moose;
use Bio::DB::GFF;

with 'WormBase::API::Role::Service::gff';    # Must come first as it provides connect();
with 'WormBase::API::Role::Service';
#with 'WormBase::API::Role::Logger';

has 'species' => (
    is => 'ro',
    isa => 'Str',
    default => 'c_elegans',
    );

has function => (
    is => 'ro',
    default => 'fjfkdfk',
    );



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
