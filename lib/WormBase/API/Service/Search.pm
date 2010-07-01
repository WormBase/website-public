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
   
  return (\@objs)   if @objs;
   
}
# Search for paper objects
sub paper {
    my ($self,$args) = @_;
   
    my @references = ();
    my $class = $args->{class};
    my $name = $args->{pattern};
    my $c = $args->{config};
    my $DB = $self->dbh;
      # Keywords are treated specially because of Ace query language
      # deficiencies (bugs?)
      my $follow = $class =~ /keyword/i ?
	'Quoted_in' : ($class =~ /author/i || $class =~ /person/i) ? 'Paper' : 'Reference';
      @references = $DB->find(-query=>qq{$class IS "$name" ; >$follow},
			      -fill=>1);
      @references = grep ($_->class eq 'Paper',@references) if $class =~  /keyword/i;
    
    my (%year,%author,%month,%day);
#     foreach (@references) { 
#     my ($yr) = $_->Publication_date; # note array context
#     # some older references encode the publication year in the name
# #     $yr =~ /.*(\d\d\d\d)\s.*/;
#     $yr =~ /(\d\d\d\d)(-(\d\d)(-(\d\d))?)?/;
#     $yr = $1;
#     my $mo = $3;
#     my $day = $5;
# 
#     $yr ||= 0;
#     $mo ||= 0;
#     $day ||= 0;
#     $year{$_} = "$yr";
#     $month{$_} = "$mo";
#     $day{$_} = "$day";
#     ($author{$_}) = $_->Author;  # note array context
#   }
#     my @sorted = sort { ($year{$b} <=> $year{$a}) ||  ($month{$b} <=> $month{$a}) ||  ($day{$b} <=> $day{$a}) || ($author{$a} cmp $author{$b})
# 		  } @references;
#       return \@sorted;

  my $result = __PACKAGE__ . "::Result";
  @references = map { $result->new({ace_obj => $_, config => $c})} @references;
 return \@references;
}

# Search for gene objects
sub gene {
  my ($self,$args) = @_;
  my $query   = $args->{pattern};
  my $c = $args->{config};
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
  @unique_genes = map { $result->new({ace_obj => $_, config => $c})} @unique_genes;

  return (\@unique_genes) if @unique_genes;
}

# Search for variataion objects
sub variation {
    my ($self,$args) = @_;
    my $query = $args->{pattern};
    my $c = $args->{config};
    my $DB = $self->dbh;
    my @vars = $DB->fetch(-class => 'Variation',
			   -name  => $query);
      
    my $result = __PACKAGE__ . "::Result";
    @vars = map { $result->new({ace_obj => $_, config => $c})} @vars;
    return \@vars;
}

#just a test of concept... remember to remove this
sub all {
    my ($self,$args) = @_;
    my $query = $args->{pattern};
    my $c = $args->{config};

    my @results;
    push(@results, @{variation($self,$args)});
    push(@results, @{gene($self,$args)});
    push(@results, @{paper($self,$args)});
   return \@results;
}

no Moose;
# __PACKAGE__->meta->make_immutable;

1;
