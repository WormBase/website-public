package WormBase::API::Service::Search;

use Moose;
use Config::General;


has 'dbh' => (
    is         => 'ro',
    isa        => 'WormBase::API::Service::acedb',
    );

has 'api' => (
    is         => 'ro',
    isa        => 'WormBase::API',
    );

has config => (
    is     => 'ro',
    isa    => 'Config::General',
    );


sub basic {
  my ($self,$args) = @_;
  my $class     = $args->{class};
  my $pattern   = $args->{pattern};
  my @objs = $self->dbh->fetch(-class=>$class,
			    -pattern=>$pattern);

  return _wrap_objs($self, \@objs, $class);
   
}
# Search for paper objects
sub paper {
    my ($self,$args) = @_;
   
    my @references = ();
    my $class = $args->{class};
    my $name = $args->{pattern};
    my $DB = $self->dbh;
    if ($class ne 'paper' && $class ne 'all') {
      # Keywords are treated specially because of Ace query language
      # deficiencies (bugs?)
      my $follow = $class =~ /keyword/i ?
	'Quoted_in' : ($class =~ /author/i || $class =~ /person/i) ? 'Paper' : 'Reference';
      @references = $DB->find(-query=>qq{$class IS "$name" ; >$follow},
			      -fill=>1);
      @references = grep ($_->class eq 'Paper',@references) if $class =~  /keyword/i;
    } else {
      my @genes = $DB->fetch(-class=>'Gene',-pattern=>$name);
      @genes = map { $_->Public_name_for } $DB->fetch(-class=>'Gene_name',-name=>$name, -fill=>1) unless @genes;
      @references = map {eval {$_->Reference} } @genes if (@genes == 1);

      unless(@references){
	my @vars = $DB->fetch(-class=>'Varation',-pattern=>$name);
	@vars = map { $_->Public_name_for } $DB->fetch(-class=>'Variation_name',-name=>$name, -fill=>1) unless @vars;
	@references = map {eval {$_->Reference} } @vars if (@vars == 1);
      }
      unless(@references){
	if ($name =~ /^WBPaper.*\d+/) {
	  @references = $DB->fetch(-class=>'Paper', -name=>$name);
        }
      }
    }
    
    my (%year,%author,%month,%day);
    foreach (@references) { 
    my ($yr) = $_->Publication_date; # note array context
    # some older references encode the publication year in the name
#     $yr =~ /.*(\d\d\d\d)\s.*/;
    $yr =~ /(\d\d\d\d)(-(\d\d)(-(\d\d))?)?/;
    $yr = $1;
    my $mo = $3;
    my $day = $5;

    $yr ||= 0;
    $mo ||= 0;
    $day ||= 0;
    $year{$_} = "$yr";
    $month{$_} = "$mo";
    $day{$_} = "$day";
    ($author{$_}) = $_->Author;  # note array context
  }
    my @sorted = sort { ($year{$b} <=> $year{$a}) ||  ($month{$b} <=> $month{$a}) ||  ($day{$b} <=> $day{$a}) || ($author{$a} cmp $author{$b})
		  } @references;
    return _wrap_objs($self, \@sorted, 'paper');
}



sub protein {
  my ($self,$args) = @_;
  my $pattern = $args->{pattern};
  my $offset;
  my ($count,@objs);
  my $DB = $self->dbh;

  # first look for a Protein
  @objs = $DB->fetch(-class=>'Wormpep',-pattern=>$pattern);
  return _wrap_objs($self, \@objs, 'protein') if @objs;
  # first look for a Protein
  @objs = $DB->fetch(-class=>'Wormpep',-pattern=>"*$pattern*");
  return _wrap_objs($self, \@objs, 'protein') if @objs;

  # now look for a sequence 
  @objs = $DB->fetch(-query=>qq(find CDS IS "$pattern"; follow Corresponding_protein));
  return _wrap_objs($self, \@objs, 'protein') if @objs;

  # now look for a locus
  @objs = $DB->fetch(-query=>qq(find Locus IS "$pattern"; follow Genomic_sequence; follow Corresponding_protein));
  return _wrap_objs($self, \@objs, 'protein') if @objs;

  my @genes = @{fetchGene($self, $pattern)};
  @objs = map {eval {$_->Corresponding_CDS} } @genes if (@genes == 1);
  @objs = map{ eval {$_->Corresponding_protein} } @objs;
  return _wrap_objs($self, \@objs, 'protein') if @objs;

  do_accession_search($self, 'Protein',$pattern,$offset);
}

sub do_accession_search {
  my ($self,$class,$pattern,$offset) = @_;
  my $DB = $self->dbh;
  my @acc = $DB->fetch(-class=>'Accession_number',-pattern=>$pattern);
  my $search_class = $class;
  $search_class = 'Sequence' if $class =~ /^(Predicted_gene|Genome_sequence)$/;
  my @objs;
  push @objs,grep {$_->class eq $search_class} $_->Entry(2) foreach @acc;
  my $count = @objs;
  unless (@acc) {
    @objs = $DB->fetch(-class=>'Transcript',-pattern=>$pattern);
  }
#   return (\@objs,$count);
  return _wrap_objs($self, \@objs, lc($class)) if @objs;
}


# Search for gene objects
sub gene {
  my ($self,$args) = @_;
  my $query   = $args->{pattern};
#   my ($count,@objs);
my $DB = $self->dbh;
  my (@genes,%seen);


  @genes = @{fetchGene($self, $query)};
  unless(@genes) {
  if (my @gene_classes = $DB->fetch(-class=>'Gene_class',-name=>$query,-fill=>1)) {
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
  }elsif (@variations = $DB->fetch(-class=>'Variation_name',-name=>$query, -fill=>1)) {
      @genes = map { eval { $_->Public_name_for->Gene} } @variations;
  }
  }
# Try finding genes using general terms
  # 1. Homology_group
  # 2. Concise_description
  # 3. Gene_class

  unless (@genes) {
      my @homol = $DB->fetch(-query=>qq{find Homology_group where Title="*$query*"});
      @genes = map { eval { $_->Protein->Corresponding_CDS->Gene } } @homol;
      push (@genes,map { $_->Genes } $DB->fetch(-query=>qq{find Gene_class where Description="*$query*"}));
      push (@genes,$DB->fetch(-query=>qq{find Gene where Concise_description="*$query*"}));
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
  
  return _wrap_objs($self, \@unique_genes, 'gene');
}

#get aceobj gene, only look at name
sub fetchGene {
  my $self = shift;
  my $query = shift;
  my $DB = $self->dbh;
  my (@genes,%seen);

  if ($query =~ /^WBG.*\d+/) {
    @genes = $self->dbh->fetch(-class=>'Gene',
			    -pattern=>$query);
  } else {
      my @gene_names = $DB->fetch(-class=>'Gene_name',-name=>$query,-fill=>1);
      @gene_names = $DB->fetch(-class=>'Gene_name',-name=>"*$query*",-fill=>1) unless @gene_names;
      # HACK!  For cases in which a gene is assigned to more than one Public_name_for.
      @genes = grep { !$seen{$_}++} map { $_->Public_name_for } @gene_names;

      @genes = grep {!$seen{$_}++} map {$_->Sequence_name_for
					    || $_->Molecular_name_for
					    || $_->Other_name_for
					} @gene_names unless @genes;
      undef @gene_names;
  } 
  return \@genes;
}

#get aceobj var, only look at name
sub fetchVar {
    my $self = shift;
    my $query = shift;
    my $DB = $self->dbh;
    my @vars;
    @vars  = $DB->fetch(-class=>'Variation',
			    -name=>$query);
    unless (@vars) {
      my @var_name = $DB->fetch(-class=>'Variation_name',-name=>$query,-fill=>1); 
      @vars = map { $_->Public_name_for } @var_name;
    }
    unless (@vars) {
      my @var_name = $DB->fetch(-class=>'Variation_name',-name=>"*$query*",-fill=>1); 
      @vars = map { $_->Public_name_for } @var_name;
    }
    return \@vars;
}

# Search for variataion objects
sub variation {
    my ($self,$args) = @_;
    my $query = $args->{pattern};
    my $DB = $self->dbh;
    my @vars = @{fetchVar($self, $query)};
    unless (@vars){
      my @genes = @{fetchGene($self, $query)};
      @vars = map {eval {$_->Allele} } @genes if (@genes == 1); #only lookup for exact matches (shoudl we allow more??)
   }
    unless (@vars){ #do we want variables associated to phenotypes...?
      my @phenes = @{fetchPhen($self, $query)};
      @vars = map {eval {$_->Variation} } @phenes if (@phenes == 1); #only lookup for exact matches (shoudl we allow more??)
   }
    return _wrap_objs($self, \@vars, 'variation');
}

sub fetchPhen {
  my $self = shift;
  my $name = shift;
  my $DB = $self->dbh;
  my @phenes = $DB->fetch(-class=>'Phenotype',-name => $name,-fill=>1) ;
    
    # 2. Try text searching the Phenotype class
    unless (@phenes) {
	my @obj = $DB->fetch(-class=>'Phenotype_name',-name=>$name,-fill=>1);
        @obj = $DB->fetch(-class=>'Phenotype_name',-name=>"*$name*",-fill=>1) unless @obj;
        if ($name =~ m/ / && @obj == 0) {
	  my $query = $name;
	  $query =~ s/ /_/g;
          @obj = $DB->fetch(-class=>'Phenotype_name',-name=>"$query",-fill=>1) unless @obj;
	  @obj = $DB->fetch(-class=>'Phenotype_name',-name=>"*$query*",-fill=>1) unless @obj;
	}
        @phenes = map { $_->Primary_name_for || $_->Synonym_for || $_->Short_name_for } @obj;	
    }
  return \@phenes;
}

sub microarray_results {
  my ($self, $args) = @_;
  my $query = $args->{pattern};
  my $DB = $self->dbh;

  my @genes = @{fetchGene($self, $query)};
  my @mr = map {eval {$_->Microarray_results} } @genes if (@genes == 1);

 return _wrap_objs($self, \@mr, 'microarray_results');
}


sub expression_cluster {
  my ($self, $args) = @_;
  my $query = $args->{pattern};
  my $DB = $self->dbh;

  my @genes = @{fetchGene($self, $query)};
  my @ec = map {eval {$_->Expression_cluster} } @genes if (@genes == 1);

 return _wrap_objs($self, \@ec, 'expression_cluster');
}

sub interaction {
  my ($self, $args) = @_;
  my $query = $args->{pattern};
  my $DB = $self->dbh;

  my @interactions;
  my @genes = @{fetchGene($self, $query)};
  @interactions = map {eval { map { my $t = $_->Interaction_type; ("$t" eq "No_interaction")? "": $_;} $_->Interaction} } @genes if (@genes == 1); #only lookup for exact matches (shoudl we allow more??)

  return unless @interactions;
  return _wrap_objs($self, \@interactions, 'interaction');
}


sub phenotype {
    my ($self, $args) = @_;
    my $name = $args->{pattern};
    my $DB = $self->dbh;
   
        
    # 1. Simplest case: assume a WBPhene ID
    my @phenes = @{fetchPhen($self, $name)};
    @phenes = $DB->fetch(-query=>qq{find Phenotype where Description=\"*$name*\"}) unless @phenes;	

    
    # 3. Perhaps we searched with one of the main classes
    # Variation, Transgene, or RNAi
    unless (@phenes) {
        my @vars =  @{fetchVar($self, $name)};
        @phenes = map {$_->Phenotype} @vars if @vars==1; #only if one variation

	foreach my $class (qw/Transgene RNAi GO_term/) {
	    if (my @objects = $DB->fetch($class => $name)) {
		# Try fetching phenotype objects from these
		push @phenes, map { $_->Phenotype } @objects;
	    }
	}
    }
    
    # 4. Okay, maybe user entered a gene or sequence
    unless (@phenes) {
	my $gene = fetchGene($self,$name);
        if (@$gene == 1) {
# 	if ($gene) {
            $gene = @$gene[0];
	    my (@objects,$query_class);

	    # Fetch all RNAi objects that map to this gene
# 	    push @objects,
# 	    $DB->fetch(-query=>qq{find RNAi where Gene=$gene});

	    # ...or attached to transgenes
	    push @objects,
	    $DB->fetch(-query=>qq{find Transgene where Driven_by_gene=$gene});
				      
	    # ...or perhaps even variations
	    push @objects,
	    $DB->fetch(-query=>qq{find Transgene where Gene=$gene});

# 	    my %seen;
	    @phenes = map { $_->Phenotype } @objects;
	}
    }
    my %seen;
    @phenes = grep(!$seen{$_}++, @phenes);
    return _wrap_objs($self, \@phenes, 'phenotype');
}

# input: list of ace objects
# output: list of Result objects
sub _wrap_objs {
  my $self = shift;
  my $list = shift;
  my $class = shift;

  # don't get config info if nothing to config
  return $list if (@$list < 1); 
  
  my $api = $self->api;
  my $fields;
  my $f = $self->config->{'DefaultConfig'}->{pages}->{$class}->{search}->{fields};
  push(@$fields, @$f);

  # default fields for all objects
  push(@$fields, 'name');

  my @ret;
  foreach my $ace_obj (@$list) {
    my $object;
    if (eval{$ace_obj->class}){
      # this is faster than passing the ace_obj.  I know, weird.
      $object = $api->fetch({class => $ace_obj->class, 
                            name => $ace_obj}) or die "$!";
    } else {
      $object = $ace_obj;
    }
    my %data;
    $data{obj_name}=$ace_obj;
    foreach my $field (@$fields) {
      my $field_data = $object->$field;# if  $object->meta->has_method($field);
      $field_data = $field_data->{data};
      $field_data =~ s/((.){200})(.)*/$1.../ unless $field eq 'abstract';
      $data{$field} = $field_data;
    }
    push(@ret, \%data);
  }
  return \@ret;
}

#just a test of concept... remember to remove this
sub all {
    my ($self,$args) = @_;

    my @results;
    push(@results, @{variation($self,$args)});
    push(@results, @{gene($self,$args)});
    push(@results, @{paper($self,$args)});
    push(@results, @{phenotype($self,$args)});
    push(@results, @{interaction($self,$args)});
    push(@results, @{expression_cluster($self,$args)});
    push(@results, @{microarray_results($self,$args)});

   foreach my $class (qw(sequence expression_cluster gene_class protein antibody)) {
      $args->{'class'} = $class;
      push(@results, @{basic($self,$args)});
      push(@results, @{paper($self,$args)});
   }

   return \@results;
}




no Moose;
__PACKAGE__->meta->make_immutable;

1;
