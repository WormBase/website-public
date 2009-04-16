package WormBase::DBH::GFF;

use strict;
use Bio::DB::GFF;
use base qw/WormBase::Model/; 

__PACKAGE__->mk_accessors(qw/mysql_user
			     mysql_host
			     mysql_pass
			     mysql_host
			    /);

my %config = ( elegans       => {
				 -adaptor        => 'dbi::mysqlace',
				 -aggregator   => ['processed_transcript{coding_exon,5_UTR,3_UTR/CDS}',
						   'full_transcript{coding_exon,five_prime_UTR,three_prime_UTR/Transcript}',
						   'transposon{coding_exon,five_prime_UTR,three_prime_UTR}',
						   'clone',
						   'alignment',
						   'waba_alignment',
						   'coding{coding_exon}',
						   'pseudo{exon:Pseudogene/Pseudogene}',
						   'rna{exon/Transcript}'
						  ],
				},
	       briggsae         => {
				    -adaptor     => 'dbi::mysqlace',
				    -aggregator  => ['wormbase_cds{coding_exon,three_prime_UTR,five_primer_UTR/CDS}',
						     'clone',
						     'alignment',
						     'waba_alignment'],
				   },
	       remanei          => {
				    -adaptor     => 'dbi::mysqlace',
				    -aggregator  => [qw(wormbase_gene)],
				   },
	       elegans_pmap     => {
				    -adaptor     => 'dbi::mysqlace',
				    -aggregator  => [qw(wormbase_gene)],
				   },
	       elegans_gmap     => {
				    -adaptor     => 'dbi::mysqlace',
				    -aggregator  => [qw(wormbase_gene)],
				   },
	     );


sub new {
  my ($class,$args) = @_;
  my $this = bless $args,$class;
  $this->log->debug("Instantiating WormBase::DBH::GFF...");
  
  # Connect to each GFF/Support database
  foreach my $species (@{$this->{dsn}}) {
    #    $this->connect($species,$this->{dbh}) 
    #      or $self->log->fatal("Could not connect to the GFF dbh $species");
    $this->connect($species);
  }
  return $this;
}


sub connect {
  my ($self,$species,$acedb) = @_;
  $self->log->info("Connecting to the GFF database for $species:");
  
  my $gff_args = $config{$species};
  
  return unless ($gff_args);
  
  $gff_args->{-user} = $self->mysql_user;
  $gff_args->{-pass} = $self->mysql_pass;
  $gff_args->{-dsn}  = "dbi:mysql:database=$species;host=" . $self->mysql_host;

  if ($self->log->is_debug()) {
    $self->log->debug("     using the following parameters:");
    foreach (keys %$gff_args) {
      $self->log->debug("       $_" . " "  . $gff_args->{$_});
    }
  }  

  my $dbh = Bio::DB::GFF->new(%$gff_args,$acedb ? (-acedb=>$acedb) : ())
    or $self->log->fatal("Couldn't connect to the $species GFF database!");

  $self->log->info("   --> succesfully established connection to $species GFF") if $dbh;

  #my $dbh = Bio::DB::GFF->new(%$gff_args) or die;  
  $self->dbh($species,$dbh);
  return $self;
}

sub dbh {
  my ($self,$species,$dbh) = @_;
  if ($species && $dbh) {
    $self->{$species}->{dbh} = $dbh;
  } else {
    
    # Do we already have a dbh?
    if ($self->{$species}->{dbh}) {
      return $self->{$species}->{dbh};
    } else {
      $self->log->debug("GFF DBH is AWOL: trying to reconnect...");
      $dbh = $self->connect();
      $self->{$species}->{dbh} = $dbh;
      return $dbh;
    }
  }
}


# I'm not really sure where to put this. Core?
# GENE.pm uses this but is called on the dbh handle itself.
sub fetch_gff_gene {
  my ($self,$transcript) = @_;
  
  # Dynamically fetch a DBH
  my $genus_species = $transcript->Species;
  $genus_species =~ /.* (.*)/;
  my $species = $1;

  # Blech.
  #  my $ace_dbh = WormBase::Model::AceDB->dbh($species);
  my $db      = $self->dbh($species);
  
  # Yuck. Species-specific junk
  my $trans;
  if ($species =~ /briggsae/) {
    ($trans)      = grep {$_->method eq 'wormbase_cds'} $db->fetch_group(CDS => $transcript);
  }
  
  ($trans)      = grep {$_->method eq 'full_transcript'} $db->fetch_group(Transcript => $transcript) unless $trans;
  
  # Now pseudogenes
  ($trans) = grep {$_->method eq 'pseudo'} $db->fetch_group(Pseudogene => $transcript) unless ($trans);
  
  # RNA transcripts - this is getting out of hand
  ($trans) = $db->segment(Transcript => $transcript) unless ($trans);
  return $trans;
}



=head1 NAME

WormBase::Model::GFF - DBI Model Class

=head1 SYNOPSIS

See L<WormBase>

=head1 DESCRIPTION

DBI Model Class.

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
