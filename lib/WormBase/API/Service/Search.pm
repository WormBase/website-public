package WormBase::API::Service::Search;

use Moose;
use WormBase::API::Service::Search::Result;

has 'dbh' => (
    is         => 'ro',
    isa        => 'WormBase::API::Service::acedb',
    );

sub basic {
  my ($self,$args) = @_;
  my $class     = $args->{class};
  my $pattern   = $args->{pattern};
  my @objs = $self->dbh->fetch(-class=>$class,
			    -pattern=>$pattern);
  return (\@objs) if @objs;
}

# Search for gene objects
sub gene {
  my ($self,$args) = @_;
  my $query   = $args->{pattern};
#   my ($count,@objs);

  my $DB = $self->dbh;
  my (@genes,%seen);

  if ($query =~ /^WBG.*\d+/) {
    @genes = $self->dbh->fetch(-class=>'Gene',
			    -pattern=>$query);
  } elsif (my @gene_names = $DB->fetch(-class=>'Gene_name',-name=>$query,-fill=>1)) {
      # HACK!  For cases in which a gene is assigned to more than one Public_name_for.
      @genes = grep { !$seen{$_}++} map { $_->Public_name_for } @gene_names;

      @genes = grep {!$seen{$_}++} map {$_->Sequence_name_for
					    || $_->Molecular_name_for
					    || $_->Other_name_for
					} @gene_names unless @genes;
      undef @gene_names;
  } elsif (my @gene_classes = $DB->fetch(-class=>'Gene_class',-name=>$query,-fill=>1)) {
      @genes = map { $_->Genes } @gene_classes;
  } elsif (my @transcripts = $DB->fetch(-class=>'Transcript',-name=>$query,-fill=>1)) {
      @genes = map { eval { $_->Corresponding_CDS->Gene } } @transcripts;
  } elsif (my @ests = $DB->fetch(-class=>'Sequence',-name=>$query,-fill=>1)) {
    foreach (@ests) {
      if (my $gene = $_->Gene(-filled=>1)) {
	push @genes,$gene;
      } elsif (my $cds = $_->Matching_CDS(-filled=>1)) {
	my $gene = $cds->Gene(-filled=>1);
	push @genes,$gene if $gene;
      }
    }
  }elsif (my @variations = $DB->fetch(-class=>'Variation',-name=>$query,-fill=>1)) {
      @genes = map { eval { $_->Gene} } @variations;
  }

# Try finding genes using general terms
  # 1. Homology_group
  # 2. Concise_description
  # 3. Gene_class

  unless (@genes) {
      my @homol = $DB->fetch(-query=>qq{find Homology_group where Title=*$query*});
      @genes = map { eval { $_->Protein->Corresponding_CDS->Gene } } @homol;
      push (@genes,map { $_->Genes } $DB->fetch(-query=>qq{find Gene_class where Description="*$query*"}));
      push (@genes,$DB->fetch(-query=>qq{find Gene where Concise_description=*$query*}));
  }

  unless (@genes) {
      my @accession_number = $DB->fetch(Accession_number => $query);
      my %seen;
      my @cds = grep {  $seen{$_}++ } map { $_->CDS } @accession_number;
      push @cds,grep { !$seen{$_}++ } map { eval {$_->Protein->Corrsponding_CDS } } @accession_number;
      push @cds,grep { !$seen{$_}++ } map { eval {$_->Sequence->Matching_CDS }  } @accession_number;
      @genes =  grep { !$seen{$_}++ } map { $_->Gene } @cds;
  }
  # Analyze the Other_name_for of the Gene_name to see if the gene
  # corresponds to another named gene.
  my (@unique_genes);
  %seen = ();
  foreach my $gene (@genes) {
    next if defined $seen{$gene};
    my $gene_name  = $gene->Public_name;
    my @other_names = eval { $gene_name->Other_name_for; };
    foreach my $other_name (@other_names) {
      if ($other_name ne $gene) {
	$seen{$other_name}++;
      }
    }
    push (@unique_genes,$gene);
    $seen{$gene}++;
  }

  my $result = __PACKAGE__ . "::Result";
  @unique_genes = map { $result->new($_)} @unique_genes;

  return (\@unique_genes) if @unique_genes;
}

# Search for variataion objects
sub variation {
    my ($self,$args) = @_;
    my $query = $args->{pattern};
    
    my $DB = $self->dbh;
    my @vars = $DB->fetch(-class => 'Variation',
			   -name  => $query);
      
    my $result = __PACKAGE__ . "::Result";
    my @vars = map { $result->new($_)} @vars;
    return \@vars;
}


no Moose;
# __PACKAGE__->meta->make_immutable;

1;
