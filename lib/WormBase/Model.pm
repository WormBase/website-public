package WormBase::Model;

use strict;
use warnings;
use Bio::Graphics::Browser;
use parent qw/Class::Accessor/;
__PACKAGE__->mk_accessors(qw/current_object log/);
our $AUTOLOAD;

sub new {
  my ($this,$args) = @_;
  my $package = ref($this) || $this;
  
  my $self = bless $args,$package;
  $self->log->debug("Instantiating $package...");

  # The class arg may either be passed in via the arguments hash in the controller
  # or decided dynamically.
  
  # Fetch an object and stash it
  my $object = $args->{ace_model}->get_object($args->{class},$args->{request});
  $self->current_object($object) if $object;
  return $self;
}



=head1

use Moose;
extends 'WormBase';			     



# Fetch an object and stash it
has 'dbh_ace'        => (is => 'ro');
has 'gff_handle'     => (is => 'ro');
#			 , lazy => 1
#			 , default => \&build_gff_handle);
has 'name'           => (is => 'ro');
has 'class'          => (is => 'ro');
has 'current_object' => (is => 'ro'
			 , lazy    => 1
			 , default => \&build_ace_object);

sub build_ace_object {
  my $self = shift;
  my $dbh = $self->dbh_ace;
  my $class = $self->class;
  my $name  = $self->name;
  my $object = $dbh->get_object($class,$name);
  return $object;
}

sub current_object {
    my $self  = shift;
    # Fetch an object and stash it
    my $object = $self->ace_model->get_object($self->class,$self->request);
    $self->current_object($object) if $object;
}


=cut




# Conditionally fetch the correct GFF DBH according to the 
# species of the current object.

# dbh_gff should be the GFF ITSELF.  Instead it's the model.
# THIS should just return the dbh_gff. It's NOT
sub dbh_gff {
  my ($self,$dsn) = @_;
  my $object  = $self->current_object;
  my $species = $self->parsed_species();

  my $dbh     = $dsn ? $self->{gff_model}->dbh($dsn) : $self->{gff_model}->dbh($species);
  return $dbh;
}



# Get a direct handle to the AceDB.
sub dbh_ace { shift->{ace_model}->{dbh}; }

#################################################
#
#    COMMON MODEL ELEMENTS
#
# The following items occur in multiple
# places in the ACedb model.
#
# Feel free to override any in a subclass.
# If you do so, it may also be necessary
# to provide a custom template.
#
################################################

=pod

Mapping fields -> tags for more efficient autoloading:

Approach 1:
Name all "singleton" fields the same as the tag in the database.

Use a hash that maps the tag name to the field name in the template


Approach 2:

=cut

sub name {
  my $self = shift;
  my $object = $self->current_object;
  my $name   = $object->name;
  return "$name";
}

# common_name defaults to the name of the object
# This can be over-ridden as necessary.
sub common_name {
  my $self = shift;
  my $name = $self->name;
  return "$name";
}

# Parse out species "from a Genus species" string.
# Return g_species, used primarily for dynamically
# selecting a data source based on species identifier.
sub parsed_species {
  my ($self) = @_;
  my $object = $self->current_object;
  my $genus_species = $object->Species;
  my ($species) = $genus_species =~ /.* (.*)/;
  return lc(substr($genus_species,0,1)) . "_$species";
}

# Ugh.  Can't autoload because singular vs plural
sub remarks {
  my ($self) = @_;
  my $object = $self->current_object;
  my $remarks = $object->Remark;
  return "$remarks";
}


#################################################
#
#   AGGREGATED INFORMATION
#
# The following methods serve to aggregate
# information that occur in multiple Acedb
# classes.  They do not correspond to simple
# tags.
#
################################################
sub reactome_knowledgebase {
  my ($self,$proteins) = @_;

  my @data;
  foreach my $protein (@$proteins) {
    my @db_entry = $protein->at('DB_info.Database');
    my ($reactome_name,$reactome_id);
    
    foreach (@db_entry) {
      next unless $_ eq 'Reactome';
      my @fields = $_->row;
      my $reactome_id = $fields[2];
      # VIEW
      # TODO: This needs to be in the template
      # push @rows,a({-href=>sprintf($fields[0]->URL_constructor,$reactome_id)},$reactome_id);
      push @data,$reactome_id;
    }
  }
  return \@data;
}


# Fetch all of the strains for a given object and extract some pertinent
# info (like is it available from the CGC).
sub strains {
  my ($self) = @_;
  my $object = $self->current_object;
  my @strains;
  foreach ($object->Strain(-filled=>1)) {
    my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;
    my @genes = $_->Gene;
    my $is_solo = (@genes == 1) ? 1 : 0;

    # Boolean flags for CGC availability, is a strain only carrying the gene
    push @strains,["$_",$cgc,$is_solo];
  }
  return \@strains;
}

# This could be generic. See also Variation.
sub alleles {
  my ($self) = @_;
  my $object = $self->current_object;
  # Typically fetching alleles from gene, but might also be from variation
  $object = ($object->class eq 'Gene') ? $object : $object->Gene;

  my @clean;
  foreach ($object->Allele) {
    unless ($_->SNP) {
      push @clean,"$_";
    }
  }
  return \@clean;
}

sub polymorphisms {
  my ($self) = @_;
  my $object = $self->current_object;
  # Typically fetching alleles from gene, but might also be from variation
  $object = ($object->class eq 'Gene') ? $object : $object->Gene;

  my @poly;
  foreach ($object->Allele) {
    if ($_->SNP) {
      push @poly,"$_";
    }
  }
  return \@poly;
}


# Map a given ID to a species (This might also be a method instead of an ID)
# Because of recpirocal BLASTing with elegans and briggsae and database XREFs
# always try to use the ID of the hit first when doing identifications
sub id2species {
  my ($self,$id) = @_;
  
  # Ordered according to (guesstimated) probability
  # It *seems* like this belongs in configuration but
  # it requires regexps...
  return 'Caenorhabditis briggsae'   if ($id =~ /WP\:CBP/i || $id =~ /briggsae/ || $id =~ /^BP/);
  return 'Caenorhabditis elegans'    if ($id =~ /worm/i || $id =~ /^WP/);
  return 'Caenorhabditis remanei'    if ($id =~ /^RP\:/i || $id =~ /remanei/) ;  # Temporary IDs for C. remanei
  return 'Drosophila melanogaster'   if ($id =~ /fly.*\:CG/i);
  return 'Drosophila pseudoobscura'  if ($id =~ /fly.*\:GA/i);
  return 'Saccharomyces cerevisiae'  if ($id =~ /^SGD/i || $id =~ /yeast/);
  return 'Schizosaccharomyces pombe' if ($id =~ /pombe/);
  return 'Homo sapiens'              if ($id =~ /ensembl/ || $id =~ /ensp\d+/);
  return 'Rattus norvegicus'         if ($id =~ /rgd/i);
  return 'Anopheles gambiae'         if ($id =~ /ensang/i);
  return 'Apis mellifera'            if ($id =~ /ensapmp/i);
  return 'Canis familiaris'          if ($id =~ /enscafp/i);
  return 'Danio rerio'               if ($id =~ /ensdarp/i);
  return 'Dictyostelium discoideum'  if ($id =~ /ddb\:ddb/i);
  return 'Fugu rubripes'             if ($id =~ /sinfrup/i);
  return 'Gallus gallus'             if ($id =~ /ensgalp/i);
  return 'Mus musculus'              if ($id =~ /mgi/i);
  return 'Oryza sativa'              if ($id =~ /^GR/i);
  return 'Pan troglodytes'           if ($id =~ /ensptrp/i);
  return 'Plasmodium falciparum'     if ($id =~ /pfalciparum/);
  return 'Tetraodon nigroviridis'    if ($id =~ /gstenp/i);
}

# Generically fetch the genetic position for an object
sub genetic_position {
  my ($self) = @_;
  my $object = $self->current_object;
  my ($chromosome,$position,$error);
  if ($object->Interpolated_map_position) {
    ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
  } else {
    ($chromosome,undef,$position,undef,$error) = eval{$object->Map(1)->row} or return;
  }
  my %data = ( chromosome => "$chromosome",
	       position    => "$position",
	       error       => "$error");
  return \%data;
}

# Generically fetch the interpolated genetic position for an object
# This *might* be the same as genetic_position above.
sub interpolated_position {
  my ($self) = @_;
  my $object = $self->current_object;
  my ($chrom,$pos,$error);
  for my $cds ($object->Corresponding_CDS) {
    ($chrom,$pos,$error) = $self->_get_interpolated_position($cds);
    last if $chrom;
  }
  
  # TODO: Save the formatting for the view
  my %data = (chromosome         => "$chrom",
	      position            => "$pos",
	      formatted_position => sprintf("%s:%2.2f",$chrom,$pos));
  return \%data;
}

# Provided with a GFF segment, return its genomic coordinates
sub genomic_position {
    my ($self,$segment) = @_;
    
    my $abs_start = $segment->abs_start;
    my $abs_stop  = $segment->abs_stop;
    ($abs_start,$abs_stop) = ($abs_stop,$abs_start) if ($abs_start > $abs_stop);
    my %data = (
	chromosome => $segment->abs_ref,
	abs_start  => $abs_start,
	abs_stop   => $abs_stop,
	start      => $segment->start,
	stop       => $segment->stop,
	);
    return \%data;
}

# CONVERTED TO HERE.



# Generically construct a GBrowse img
# Args: Bio::DB::GFF segment,species, [ tracks ], { options }, width
# This is typically called by genomic_environs() ina subclass...
sub build_gbrowse_img {
  my ($self,$segment,$tracks,$options,$width) = @_;
  
  my $species = $self->parsed_species(); 
  
  # open the browser for drawing pictures
  my $BROWSER = Bio::Graphics::Browser->new or die;

  # NOTE! The path to the configuration directory MUST be supplied by W::M::* adaptor!
  $BROWSER->read_configuration($self->{gbrowse_conf_dir}) or die "Couldn't read or find the gbrowse configuration directory";

  $BROWSER->source($species);
  $BROWSER->width($width || '500');
  
  $BROWSER->config->set('general','empty_tracks' => 'suppress');
  $BROWSER->config->set('general','keystyle'     => 'none');
  
  my $absref   = $segment->abs_ref;
  my $absstart = $segment->abs_start;
  my $absend   = $segment->abs_end;
  ($absstart,$absend) = ($absend,$absstart) if $absstart>$absend;
  my $length = $segment->length;
  
  # add another 10% to left and right
  my $start = int($absstart - 0.1*$length);
  my $stop  = int($absend   + 0.1*$length);
  my $db    = $segment->factory;

  my ($new_segment) = $db->segment(-name=>$absref,
				   -start=>$start,
				   -stop=>$stop);

  my ($img,$junk) = $BROWSER->render_panels({segment     => $new_segment,
					     options     => \%$options,
					     labels      => $tracks, 
					     title       => "Genomic segment: $absref:$absstart..$absend",
					     keystyle    => 'between',
					     do_map      => 0,
					     drag_n_drop => 0,
					    });

  $img =~ s|/Users/todd/Documents/projects/wormbase/website/trunk/root||g;
  $img =~ s/border="0"/border="1"/;
  $img =~ s/detailed view/browse region/g;
  $img =~ s/usemap=\S+//;
  
  my %data = (
	      img     => $img,
	      start   => $start,
	      stop    => $stop,
	      species => $species,
	      chromosome => $absref);
  return \%data;
}


# Fetch all of the best_blastp_matches for a list of proteins.
# Used for genes and proteins
sub best_blastp_matches {
  my ($self,$proteins) = @_;

  # current_object might already be a protein. If a gene, it will supply proteins.
  push @$proteins,$self->current_object unless @$proteins;

  return unless @$proteins;
  my ($biggest) = sort {$b->Peptide(2)<=>$a->Peptide(2)} @$proteins;

  my @pep_homol = $biggest->Pep_homol;
  my $length    = $biggest->Peptide(2);
  
  my @hits;
  
  # find the best pep_homol in each category
  my %best;
  return "" unless @pep_homol;
  for my $hit (@pep_homol) {
    next if $hit eq $biggest;         # Ignore self hits
    my ($method,$score) = $hit->row(1) or next;
    
    my $prev_score = (!$best{$method}) ? $score : $best{$method}{score};
    $prev_score = ($prev_score =~ /\d+\.\d+/) ? $prev_score .'0' : "$prev_score.0000";
    my $curr_score = ($score =~ /\d+\.\d+/) ? $score . '0' : "$score.0000";
    
    $best{$method} = {score=>$score,hit=>$hit,adjusted_score=>$curr_score} if !$best{$method} || $prev_score < $curr_score;
  }
  
  foreach (values %best) {
    my $covered = $self->_covered($_->{score}->col);
    $_->{covered} = $covered;
  }
  
  # NOT HANDLED YET
  # my $links = Configuration->Protein_links;
  
  my %seen;  # Display only one hit / species
  
  # I think the perl glitch on x86_64 actually resides *here*
  # in sorting hash values.  But I can't replicate this outside of a
  # mod_perl environment
  # Adding the +0 forces numeric context
  foreach (sort {$best{$b}{adjusted_score}+0 <=>$best{$a}{adjusted_score}+0 } keys %best) {
    my $method = $_;
    my $hit = $best{$_}{hit};
    
    # Try fetching the species first with the identification
    # then method then the embedded species
    my $species = $self->id2species($hit);
    $species  ||= $self->id2species($method);
    
    # Not all proteins are populated with the species 
    $species ||= $best{$method}{hit}->Species;
    $species =~ s/^(\w)\w* /$1. /;
    my $description = $best{$method}{hit}->Description || $best{$method}{hit}->Gene_name;
    if ($method =~ /worm|briggsae/) {
      $description ||= eval{$best{$method}{hit}->Corresponding_CDS->Brief_identification};
      # Kludge: display a description using the CDS
      if (!$description) {
	for my $cds (eval { $best{$method}{hit}->Corresponding_CDS }) {
	  next if $cds->Method eq 'history';
	  $description ||= "gene $cds";
	}
      }
    }
    
    # Ignore mass spec hits
    next if ($hit =~ /^MSP/);
    
    next if ($seen{$species}++);
    
    if ($hit =~ /(\w+):(.+)/) {
      my $prefix    = $1;
      my $accession = $2;
      
      # Try fetching accessions directly from the protein object
      my @dbs = $hit->Database;
      foreach my $db (@dbs) {
	if ($db eq 'FLYBASE') {
	  foreach my $col ($db->col) {
	    if ($col eq 'FlyBase_gn') {
	      $accession = $col->right;
	      last;
	    }
	  }
	}
      }
      
      # NOT HANDLED YET!
#      my $link_rule = $links->{$prefix};
      my $link_rule = '%s';
      my $url       = sprintf($link_rule,$accession);
      # TH: 1/2006 - remanei not yet in the database but blast hits available
      # Generate links to the remanei browser
      # This will not work for mirror sites, of course...
      if ($species =~ /remanei/) {
	$accession =~ s/^RP://;
	$hit = qq{<a href="http://dev.wormbase.org/db/seq/gbrowse/remanei/?name=$accession"</a>$accession</a>};
	$hit .= qq{<br><i>Note: <b>C. remanei</b> predictions are based on an early assembly of the genome. Predictions subject to possibly dramatic revision pending final assembly. Sequences available on the <a href="ftp://ftp.wormbase.org/pub/wormbase/genomes/remanei">WormBase FTP site</a>.};
      } else {
	$hit = qq{<a href="$url" -target="_blank">$hit</a>};
      }
    }
    
    push @hits,[$species,$hit,$description,
		sprintf("%7.3g",10**-$best{$_}{score}),
		sprintf("%2.1f%%",100*($best{$_}{covered})/$length)];
  }
  return \@hits;
}



#################################################
#  Phenotypes
#  (Was: DisplayPhenotypes, is_NOT_phene, FormatPhenotypeHash, etc)
# (ie used in RNAi, Seq, Variation)
#################################################
# Return a list of phenotypes observed
sub phenotypes_observed {
  my ($self) = @_;
  my $object = $self->current_object;
  my $phenes = $self->_get_phenotypes($object);
  return $phenes;
}

# Return a list of phenotypes not observed
sub phenotypes_not_observed {
  my ($self) = @_;
  my $object = $self->current_object;
  my $phenes = $self->_get_phenotypes($object,'NOT');
  return $phenes;
}

sub _get_phenotypes {
  my ($self,$object,$not) = @_;
  my $positives = [];
  my $negatives = [];
  
  my (@phenotypes) = $object->Phenotype;
  my $data = $self->_parse_hash(\@phenotypes);
  ($positives,$negatives) = $self->_is_NOT_phene($data);
  
  my $parsed;
  if ($not) {
    $parsed = $self->_parse_phenotype_hash($negatives);
  } else {
    $parsed = $self->_parse_phenotype_hash($positives);
  }
  return $parsed;
}


# Determine which of a list of Phenotypes are NOTs
# Return a sorted list of positive/not positive phenotypes
sub _is_NOT_phene {
  my ($self,$data) = @_;
  my $positives = [];
  my $negatives = [];
  
  foreach my $entry (@$data) {
    if ($entry->{is_not}) {
      push @$negatives,$entry;
    } else {
      push @$positives,$entry;
    }
    
  }
  return ($positives,$negatives);
}

# Return the best name for a phenotype object.  This is really common_name...
# Pick the best display new for new Phenotype-ontology objects
# and append a short name if one exists
sub best_phenotype_name {
  my ($self,$phenotype) = @_;
  my $name = ($phenotype =~ /WBPheno.*/) ? $phenotype->Primary_name : $phenotype;
  $name =~ s/_/ /g;
  $name .= ' (' . $phenotype->Short_name . ')' if $phenotype->Short_name;
  return $name;
}



# Was: ElegansSubs::AlleleDescription and MutantPhenotype
# TODO: Need to attach the evidence to each Remark
# TODO: This probably should be a function of the VIEW
sub phenotype_remark {
  my ($self) = @_;
  my $object = $self->current_object;

  # Some inconsistency in Ace models here
  my @remarks = $object->Remark,
    eval { $object->Phenotype_remark },
      eval { $object->Phenotype };
  my $formatted_remarks = $self->_cross_reference_remarks(\@remarks);

  #  push @desc,GetEvidenceNew(-object => $allele->Phenotype_remark,
  #			    -format => 'inline',
  #			    -display_label => 1);
  #  push @desc,GetEvidenceNew(-object => $allele->Remark,
  #			    -format => 'inline',
  #			    -display_label => 1);
  #  return unless @desc;
  #  return join(br,@desc); # . '.'; Don't add punctuation, Mary Ann does
  return  $formatted_remarks;
}

# This was MutantPhenotype
sub _cross_reference_remarks {
  my ($self,$remarks) = @_;

  # cross-reference laboratories
  foreach my $d (@$remarks) {
    $d =~ s/;\s+([A-Z]{2})(?=[;\]])
	   /"; ".ObjectLink($1,undef,'Laboratory')
	     /exg;
    
    # cross-reference genes
####    $d =~ s/\b([a-z]+-\d+)\b
####	   /ObjectLink($1,undef,'Locus')
####	     /exg;
    
    # cross-reference other stuff
####    my %xref = map {$_=>$_} @xref;
####    $d =~ s/\b(.+?)\b/$xref{$1} ? ObjectLink($xref{$1}) : $1/gie;
  }
  return $remarks;
}


# History for the ?Gene class.  Too bad this isn't generic...
sub history {
  my $self = shift;
  my $object = $self->current_object;
  my $stash;

  my @history = $object->History;
  foreach my $history (@history) {
    my $type = $history;
    $type =~ s/_ / /g;
    my @versions = $history->col;
    foreach my $version (@versions) {
      my ($vers,$date,$curator,$event,$action,$remark,$target_object,$person);
      # Let's just display date that comes from Version_change entries (obsolete tags at top-level of ?Gene still exist)
      if ($history eq 'Version_change') {
	($vers,$date,$curator,$event,$action,$remark) = $version->row; 
	# For some cases, the remark is actually a gene object
	if ($action eq 'Merged_into' || $action eq 'Acquires_merge'
	    || $action eq 'Split_from' || $action eq 'Split_into') {
	  $target_object = $remark;
	}
	push @{$stash},{ version => $version,
			 action  => $action,
			 date    => $date,
			 curator => $curator,
			 target_object => $remark,
			 type    => $type,};
      }
    }
  }
  return $stash;
}



# TODO: This should be in SUPER
# TODO: Part of View?  Part of Model::Super?
sub fasta {
  my ($self,$name,$protein) = @_;
  $protein ||= '';
  my @markup;
  for (my $i=0; $i < length $protein; $i += 10) {
    push (@markup,[$i,$i % 80 ? ' ':"\n"]);
  }
  $self->markup(\$protein,\@markup);
  return $protein;
}


# insert HTML tags into a string without disturbing order
sub markup {	
  my ($self,$string,$markups) = @_;
  for my $m (sort {$b->[0]<=>$a->[0]} @$markups) { #insert later tags first so position remains correct
    my ($position,$markup) = @$m;
    next unless $position <= length $$string;
    substr($$string,$position,0) = $markup;
  }
}










#################################################
#
#   INTERNAL METHODS
#
# The following items occur often enough
# throughout the Model to warrant inclusion here.
#
################################################




#################################################
#  Hash parsing and formatting
#  Was: ParseHash FormatEvidenceHash, etc
#
# I'm not sure where this belongs.
# On one hand, we should be able to deliver this
# information via webservices. That is, it shouldn't
# be locked up in the view.
#
# On the other, it seems much more view specific.
#
# 2. I should just have top level categories like
# parse_evidence_hash, parse_molecular_change_hash, etc.
# These would return data structure suitable for display
# in the view.
#
# In fact, these could also be actions and ajax targets (ie /parse_hash/node, maybe)
#
# I'd also like to make the parse_hash method private so that it is
# only called by the parse* methods. Unfortunately, some formatting
# needs just the raw hash -- there is code redundancy with duplication
# in parsing, formatting, view decisions, etc.  See for example,the
# RNAi phenoypes section of Gene.pm
#
# To further confuse matters, I have a parse_hash, evidence
# formatting, etc as part of the view.  Clearly, this requires
# additional thought.
#
#################################################

=pod

=item _parse_hash(@params)

Generically parse an evidence, paper, or molecular info
hash from a node of an object tree.

Options

 -node  A node of an object tree (or an array reference of nodes)

If an array reference of nodes is passed, the resulting data structure
will be an array of structures.

Returns

 A data structure suitable for further parsing/display or
 null if no Evidence hash exists to the right of the provided node.

=cut
#'

sub _parse_hash {
  my ($self,$nodes) = @_;
  
  # Mimic the passing of an array reference. Blech.
  $nodes = [$nodes] unless ref $nodes eq 'ARRAY';
  
  # The data structure - a hash of hashes, each pointing to an array
  my $data = [];
  
  # Collect all the hashes available for each node
  foreach my $node (@$nodes) {
    # Save all the top level tags as keys in a perl
    # hash for easier parsing and formatting
    my %hash = map { $_ => $_ } eval { $node->col };
    my $is_not = 1 if (defined $hash{Not});  # Keep track if this is a Not Phene annotation
    push @{$data},{ node => $node,
		    hash => \%hash,
		    is_not => $is_not || 0,
		  };
  }
  return $data;
}


# NOT DONE YET!
sub _parse_evidence_hash {
  my @p = @_;
  my ($data,$format,$display_tag,$link_tag,$display_label,$detail) =
    rearrange([qw/DATA FORMAT DISPLAY_TAG LINK_TAG DISPLAY_LABEL DETAIL/],@p);
  
  my @rows;    # Each row in the table corresponds to an object (each row is stringified)
  my $join = ($format eq 'table') ? '<br>' : ', ';
  my $all_evidence = {};
  
  foreach my $entry (@$data) {
    my $hash  = $entry->{hash};
    my $node  = $entry->{node};
    
    # Conditionally format the data for each type of evidence
    foreach my $key (keys %$hash) {
      my $type = $hash->{$key};
      
      # Suppress the display of Curator_confirmed
      next if $type eq 'Curator_confirmed';
      
      # Just grab the first level entries for each.
      # For the evidence hash, Accession_evidence and Author_evidence 
      # have additional information
      my @sources = eval { $type->col };
      
      # Add appropriate markup for each type of Evidence seen
      # Lots of redundancy here - first we parse the data, then add primary formatting
      # then secondary formatting (ie table, etc)
      # This could all be much cleaner (albeit less flexible) with templates
      if ($type eq 'Paper_evidence') {
	#!!	      my @papers = _format_paper_evidence(\@sources);
	#!!	      $data = join($join,@papers);
      } elsif ($type eq 'Published_as') {
	#!!	      $data = join($join,map { ObjectLink($_,undef,'_blank') } @sources);
      } elsif  ($type eq 'Person_evidence' || $type eq 'Curator_confirmed') {
	#!!	      $data = join($join,map {ObjectLink($_->Standard_name,undef,'_blank')} @sources);
      } elsif  ($type eq 'Author_evidence')   {
	#!!	      $data = join($join,map { a({-href=>'/db/misc/author?name='.$_,-target=>'_blank'},$_) } @sources);
      } elsif ($type eq 'Accession_evidence') {
	foreach my $entry (@sources) {
	  my ($database,$accession) = $entry->row;
	  #!!		  my $accession_links   ||= Configuration->Protein_links;  # misnomer
	  #!!		  my $link_rule = $accession_links->{$database};
	  #!!		  $data = $link_rule ? a({-href=>sprintf($link_rule,$accession),
	  #!!					  -target=>'_blank'},"$database:$accession")
	  #!!		      : ObjectLink($accession,"$database:$accession");
	}	
      } elsif ($type eq 'Protein_id_evidence') {
	#!!	      $data = join($join,map { a({-href=>Configuration->Entrezp},$_) } @sources);
	
	# Lots of generic entries that just need to be linked
      } elsif ($type eq 'GO_term_evidence' || $type eq 'Laboratory_evidence') {
	#!!	$data = join($join,map {ObjectLink($_) } @sources);
      } elsif ($type eq 'Expr_pattern_evidence') {
	#!!	$data = join($join,map {ObjectLink($_) } @sources);
      } elsif ($type eq 'Microarray_results_evidence') {
	#!!	$data = join($join,map {ObjectLink($_) } @sources);
      } elsif ($type eq 'RNAi_evidence') {
	#!!	$data = join($join,map {ObjectLink($_,$_->History_name ? $_ . ' (' . $_->History_name . ')' : $_) } @sources);
      } elsif ($type eq 'Gene_regulation_evidence') {
	#!!	$data = join($join,map {ObjectLink($_) } @sources);
      } elsif ($type eq 'CGC_data_submission') {
      } elsif ($type =~ /Inferred_automatically/i) {
	#!!	$data = join($join,map { $_ } @sources);
      } elsif ($type eq 'Date_last_updated') {
	#!!	($data) = @sources;
	#!!	$data =~ s/\s00:00:00//;
      }
      
      $type =~ s/_/ /g;
      
      # Retain $node again since this is an object
      push @{$all_evidence->{$type}},
	{ type => $type,
	  data => $data,
	  node => $node,
	};
    }
  }
  
  # Format the evidence as requested
  my $return;
  if ($format eq 'table') {
    foreach my $tag (keys %$all_evidence) {
      
      my @evidence = @{$all_evidence->{$tag}};
      my $table =
	start_table()
	  . TR(th('Evidence type')
	       . th('Source'));
      
      my $count = 0;
      foreach (@evidence) {
	my $node = $_->{node};
	
	# Only need to do this for the first iteration
	if ($count == 0) {
	  if ($display_tag) {
	    $link_tag = 1 if $node eq 'Evidence'; # hack for cases in which evidence is attached
	    #!!		      my $description = $link_tag ? $node :
	    #!!			  ref $node && $node->class eq 'Gene_name' ?
	    #!!			  a({-href=>Object2URL(GeneName2Gene($node))},$node)
	    #!!			  : ObjectLink($node);
	    #!!		      $return .= $description;
	  }
	  $count++;
	  $return .= h3('Supported by:');
	}
	
	my $type = $_->{type};
	my $data = $_->{data};
	#!!	      $table .= TR(td({-valign=>'top'},$type),
	#!!			   td($data));
      }
      #!!	  $table .= end_table();
      #!!	  $return .= $table;
    }
  } else {
    # Returning stringified form of evidence
    my @entries;
    foreach my $tag (keys %$all_evidence) {	
      my @evidence = @{$all_evidence->{$tag}};
      
      my $count = 0;	
      foreach (@evidence) {
	my $node = $_->{node};
	if ($count == 0) { # necessary on first iteration only. stoopid, I know
	  if ($display_tag) {
	    $link_tag = 1 if $node eq 'Evidence'; # hack for cases in which evidence is attached
	    #!!		    my $description = $link_tag ? $node :
	    #!!			ref $node && $node->class eq 'Gene_name' ?
	    #!!			a({-href=>Object2URL(GeneName2Gene($node))},$node)
	    #!!			: ObjectLink($node);
	    #!!		    $return .= $description;
	  }
	  $count++;
	}
	my $type = $_->{type};
	my $data = $_->{data};
	push @entries,($display_label) ? "via " . lc($type) . ': ' . $data : $data;
      }
    }
    $return .= join('; ',@entries);
  }
  return undef unless $return;
  return $return;
}

## Data is a collection of one or more phenotype
## hashes with top-level tags already extracted
## THIS COULD MOVE TO THE VIEW...
sub _parse_phenotype_hash {
  my ($self,$data) = @_;
  
  # These tags have a single entry following them
  # They should *not* have any evidence hashes, either
  # The contents of these entries can be fetched as
  # $tag->col
  my %evidence_only = map { $_ => 1 }
    qw/
	Not
	Recessive
	Semi_dominant
	Dominant
	Haplo_insufficient
	Paternal
      /;
  
  my %simple = map { $_ => 1 }
    qw/
	Quantity_description
      /;
  
  my %nested = map { $_ => 1 }
    qw/ 
	Penetrance
	Quantity
	Loss_of_function
	Gain_of_function
	Other_allele_type
	Temperature_sensitive
	Maternal
	Phenotype_assay
      /;
  
  my %is_row = map { $_ => 1 } qw/Quantity Range/;
  
  # Prioritize display of tags
  my @tags = qw/
		 Not
		 Penetrance Recessive Semi_dominant Dominant
		 Haplo_insufficient
		 Loss_of_function
		 Gain_of_function
		 Other_allele_type
		 Temperature_sensitive
		 Maternal
		 Paternal
		 Phenotype_assay
		 Quantity_description
		 Quantity
		 Paper_evidence
		 Person_evidence
		 Remark
	       /;
  
  my $stash = [];
  foreach my $entry (@$data) {    
    my @this_data = ();
    my $hash  = $entry->{hash};
    my $node  = $entry->{node};   # Node is the originating object

    foreach my $tag_priority (@tags) {
      next unless (my $tag = $hash->{$tag_priority});
      my $formatted_tag = $tag;
      $formatted_tag =~ s/_/ /g;
      
      # Fetch the first entries to the right of each tag
      my @sources = eval { $tag->col };
      # Add appropriate markup for each tag seen
      # Lots of redundancy here - first we parse the data, then add primary formatting
      # then secondary formatting (ie table, etc)
      
      if ($tag eq 'Paper_evidence') {
	# We will format the papers elswhere
#	@sources = _format_paper_evidence(\@sources);
      } elsif  ($tag eq 'Person_evidence' || $tag eq 'Curator_confirmed') {
      } elsif (defined $evidence_only{$tag}) {
	@sources = ( $tag );
      } elsif ($tag eq 'Remark' || $tag eq 'Quantity_description') {
      } elsif ($tag eq 'Phenotype_assay') {
	my @parsed;
	# Step into the Phenotype_assay object, displaying select tags.
	if (@sources) {
	  my ($cell,$evidence);
	  foreach my $condition (@sources) {
	    if ($data) {
	      # TODO: FETCH THE EVIDENCE FROM $data
	    }
	    push @parsed,"$condition: $data";
	  }
	  @sources = @parsed;
	}
	# Handle tags that contain substructure
      } elsif (defined $nested{$tag}) {
	my @subtags = $tag->col;
	
	@subtags = $tag if $tag eq 'Quantity';	
	my @cells;
	foreach my $subtag (@subtags) {
	  # Ignore the value if we have an Evidence hash
	  # to the right. All set to fetch evidence
	  my ($value,$evi);
	  if ($subtag->right =~ /evidence/) {   
	  } else {
	    # HACK - Range and Quantity are rows
	    if (defined ($is_row{$subtag})) {  
	      
	      my (@values) = $subtag->row;
	      $value = join("-",$values[1],$values[2]);
	      $value = '100%' if $value eq '100-100';
	    } else {
	      $value = $subtag->right;
	    }
	  }
	  
	  $subtag =~ s/_/ /g;

	  $formatted_tag = "$formatted_tag: $subtag";
	  @sources = ($value);
	}
      }
      push @this_data,[$formatted_tag,\@sources];
    }
    push @{$stash},{ node => $node,
		     rows => \@this_data };
    
  }
  return $stash;
}

# THIS PROBABLY BELONGS AS A COMPONENT OF THE VIEW INSTEAD OF THE MODEL
sub _parse_molecular_change_hash {
  my ($self,$entry,$tag) = @_;

  # Generically parse the hash
  my $data  = $self->_parse_hash($entry);
  return unless keys %{$data} >= 1;   # Nothing to build a table from
  
  my @types     = qw/Missense Nonsense Frameshift Silent Splice_site/;
  my @locations = qw/Intron Coding_exon Noncoding_exon Promoter UTR_3 UTR_5 Genomic_neighbourhood/;
    
  # Select items that we will try and translate
  # Currently, this needs to be
  # 1. Affects Predicted_CDS
  # 2. A missense or nonsense allele
  # 3. Contained in a coding_exon

  my %parameters_seen;
  my %do_translation = map { $_ => 1 } (qw/Missense Nonsense/);

  # Under no circumstances try and translate the following
  my %no_translation = map { $_ => 1 } (qw/Frameshift Deletion Insertion/);
  
  # The following entries should be examined for the presence
  # of associated Evidence hashes
  my @with_evidence = 
    qw/
	Missense
	Silent
	Nonsense
	Splice_site
	Frameshift
	Intron
	Coding_exon
	Noncoding_exon
	Promoter
	UTR_3
	UTR_5	
	Genomic_neighbourhood
      /; 
  
  my (@protein_effects,@contained_in);
  
  foreach my $entry (@$data) {  
    my $hash  = $entry->{hash};
    my $node  = $entry->{node};
    
    # Conditionally format the data for each type of evidence
    # Curation often has the type of change and its location
    
    # What type of change is this?
    foreach my $type (@types) {
      my $obj = $hash->{$type};
      my @data = eval { $obj->row };
      next unless @data;
      my $clean_tag = ucfirst($type);
      $clean_tag    =~ s/_/ /g;
      $parameters_seen{$type}++;
      
      my ($pos,$text,$evi,$evi_method,$kind);
      if ($type eq 'Missense') {
	($type,$pos,$text,$evi) = @data;
      } elsif ($type eq 'Nonsense' || $type eq 'Splice_site') {
	($type,$kind,$text,$evi) = @data;		
      } elsif ($type eq 'Frameshift') {
	($type,$text,$evi) = @data;
      } else { 
	($type,$text,$evi) = @data;
      }	    
      
      if ($evi) {
###	    ($evi_method) = GetEvidenceNew(-object => $text,
###					       -format => 'inline',
###					       -display_label => 1,
###					       );
      }
      push @protein_effects,[$clean_tag,$pos || undef,$text,
			     $evi_method ? " ($evi_method)" : undef];
    }
	
    # Where is this change located?
    foreach my $location (@locations) {
      my $obj = $hash->{$location};
      my @data = eval { $obj->col };
      next unless @data;
      $parameters_seen{$location}++;
#####
#####	    my ($evidence) = GetEvidenceNew(-object => $obj,
#####					    -format => 'inline',
#####					    -display_label => 1
#####					    );
      my $evidence;
      my $clean_tag = ucfirst($location);
      $clean_tag    =~ s/_/ /g;
      push @contained_in,[$clean_tag,undef,undef,
		   $evidence ? " ($evidence)" : undef];
    }
  }
    
  my $do_translation;
  foreach (keys %parameters_seen) {
    $do_translation++ if (defined $do_translation{$_}  && !defined $no_translation{$_});
  }
  return (\@protein_effects,\@contained_in,$do_translation);
}



# get the interpolated position of a sequence on the genetic map
# returns ($chromosome, $position,$error)
# position is in genetic map coordinates
# This MIGHT also be the actual experimental position
sub _get_interpolated_position {
  my ($self,$object) = @_;
  $object ||= $self->current_object;
  if ($object){
    if ($object->class eq 'CDS') {
      # Is it a query
      # wquery/genelist.def:Tag Locus_genomic_seq
      # wquery/new_wormpep.def:Tag Locus_genomic_seq
      # wquery/wormpep.table.def:Tag Locus_genomic_seq
      # wquery/wormpepCE_DNA_Locus_OtherName.def:Tag Locus_genomic_seq
      
      # Fetch the interpolated map position if it exists...
      # if (my $m = $object->get('Interpolated_map_position')) {
      if (my $m = eval {$object->get('Interpolated_map_position') }) {
	#my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
	my ($chromosome,$position) = $m->right->row;
	return ($chromosome,$position) if $chromosome;
      } elsif (my $l = $object->Gene) {
	return $self->_get_interpolated_position($l);
      }
    } elsif ($object->class eq 'Sequence') {
      #my ($chromosome,$position,$error) = $obj->Interpolated_map_position(1)->row;
      my $chromosome = $object->get(Interpolated_map_position=>1);
      my $position   = $object->get(Interpolated_map_position=>2);
      return ($chromosome,$position) if $chromosome;
    } else {
      my $chromosome = $object->get(Map=>1);
      my $position   = $object->get(Map=>3);
      return ($chromosome,$position) if $chromosome;
      if (my $m = $object->get('Interpolated_map_position')) {	     
	my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row unless $position;
	($chromosome,$position) = $m->right->row unless $position;
	return ($chromosome,$position,$error) if $chromosome;
      }
    }
  }
  return;
}


# Part of the old Best_BLAST_Hits table
sub _covered {
  my ($self,@starts) = @_;
  # linearize
  my @segs;
  for my $s (@starts) {
    my @ends = $s->col;
    # Major kludge for architecture-dependent Perl bug(?) in interpreting integers as strings
    $s = "$s.0";
    push @segs,map {[$s,"$_.0"]} @ends;
  }
  my @sorted = sort {$a->[0]<=>$b->[0]} @segs;
  my @merged;
  foreach (@sorted) {
    my ($start,$end) = @$_;
    if ($merged[-1] && $merged[-1][1]>$start) {
      $merged[-1][1] = $end if $end > $merged[-1][1];
    } else {
      push @merged,$_;
    }
  }
  my $total = 0;
  foreach my $merged (@merged) {
    $total += $merged->[1]-$merged->[0];
  }
  $total;
}


#################################################
#
#   REFERENCES
#
# References occur throughout the model.
#
# Note that the top level widget is called references.  
#
################################################

# This does not correspond to references proper in an AceDB model
# but a Reference or Paper tag for any object.
# Classes that DON'T use Reference: Interaction, Person, Author, Journal

# Web app: the references itself pulls in all four reference types by forward()).
sub get_references {
  my ($self,$filter) = @_;
  my $object = $self->current_object;
  
  # References are not standardized. They may be under the Reference or Paper tag.
  # Dynamically select the correct tag - this is a kludge until these are defined.
  my $tag = (eval {$object->Reference}) ? 'Reference' : 'Paper';
  
  my $dbh = $self->dbh_ace;
  
  my $class = $object->class;
  my @references;
  if ( $filter eq 'all' ) {
    @references = $object->$tag;
  } elsif ( $filter eq 'gazette_abstracts' ) {
    @references = $dbh->fetch(
			      -query => "find $class $object; follow $tag WBG_abstract",
			      -fill  => 1);
  } elsif ( $filter eq 'published_literature' ) {
    @references = $dbh->fetch(
			      -query => "find $class $object; follow $tag PMID",
			      -fill => 1);
    
    #    @filtered = grep { $_->CGC_name || $_->PMID || $_->Medline_name }
    #      @$references;
  } elsif ( $filter eq 'meeting_abstracts' ) {
    @references = $dbh->fetch(
			      -query => "find $class $object; follow $tag Meeting_abstract",
			      -fill => 1
			     );
  } elsif ( $filter eq 'wormbook_abstracts' ) {
    @references = $dbh->fetch(
			      -query => "find $class $object; follow $tag WormBook",
			      -fill => 1
			     );
    # Hmm.  I don't know how to do this yet...
    #    @filtered = grep { $_->Remark =~ /.*WormBook.*/i } @$references;
  }
  return \@references;
}

# This is a convenience method for returning all methods. It
# isn't a field itself and is not included in the References widget.
sub all_references {
  my $self = shift;
  my $references = $self->get_references('all');
  return $references;
}

sub published_literature {
  my $self = shift;
  my $references = $self->get_references('published_literarture');
  return $references;
}

sub meeting_abstracts {
  my $self = shift;
  my $references = $self->get_references('meeting_abstracts');
  return $references;
}

sub gazette_abstracts {
  my $self = shift;
  my $references = $self->get_references('gazette_abstracts');
  return $references;
}

sub wormbook_abstracts {
  my $self = shift;
  my $references = $self->get_references('wormbook_abstracts');
  return $references;
}



#################################################
#
#   SINGLETON TAGS
#
# AUTOLOAD simple methods that access a single
# tag from the object and do not manipulate
# the data in any way
#
# This corresponds to something like this:
#
# sub author {
#   my ($self) = @_;
#   my $object = $self->current_object;
#   return $object->Author;
# }
#
# NOTE: For the web app, you can only rely
# on AUTOLOAD when the field title corresponds
# to the object name!  If it diverges, AUTOLOAD
# will fail horribly.
#
# To circumvent this, I could have a field2tag mapping
# hash for presentation
#
################################################


sub AUTOLOAD {
  my ($self) = @_;

  my $type = ref($self);
#    or croak
#      "AUTOLOAD: $self is not an object. Web app: ensure that field name in config matches tag name in class";

  my $name = $AUTOLOAD;
  $name =~ s/.*://;  # Strip qualified portion
  
  # Not necessary - let's allow everything and capture errors by eval
  #  unless (exists $self->{_permitted}->{$name}) {
  #    croak "Can't access $name tag in class $type";
  #  }
  
  # TODO: This should also be able to handle accessors

  # This might be an accessor.
  if ($self->{$name}) {
    return $self->{$name};
  } else {

    # Otherwise it's a request for an ace tag.
    # Pull out the ace object
    my $ace_obj = $self->current_object;

    # Now fetch the tag, assuming array context.
    # Does this result in additional template overhead?
    # We will eval, too, just to capture tags that might not
    # exist in the current Class.
    my $method = ucfirst($name);
    my ($data) = eval { $ace_obj->$method };
    return $data;
  }
}


=head1 NAME

WormBase::Model - Model superclass

=head1 DESCRIPTION

The WormBase model superclass.  Methods that need to be accessed in
more than a single model belong here.

=head1 METHODS

=item $self->genetic_position($object)

 Returns : Hash reference containing keys of chromosome and position
 Widget  : location
 Tmpl    : generic/genetic_position.tt2

=item $self->interpolated_position($object)

 Returns : Hash reference containing keys of:
             chromosome
             position
             formatted_position 
 Widget  : location
 Tmpl    : generic/interpolated_position.tt2

=head1 MIGRATION NOTES

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
