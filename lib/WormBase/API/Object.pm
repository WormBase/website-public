package WormBase::API::Object;

use Moose;
use overload '~~' => \&_overload_ace, fallback => 1;

has '_api' => (
    is => 'ro',
);

=head1 NAME

WormBase::Model - Model superclass

=head1 DESCRIPTION

The WormBase model superclass.  Methods that need to be accessed in
more than a single model belong here.

=head1 METHODS

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub _overload_ace {
    my ($self,$param)=@_;
    if($param =~ s/^@//) {my @results=eval {$self->object->$param}; return \@results;}
    else { return eval {$self->object->$param};}
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
  my $object = $self->object;
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
    my $object = $self->object;
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
  my $object = $self->object;
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

# This is used in Gene::inparanoid_groups.
# This grosses me out.
sub wb_protein {
  my ($self,$species) = @_;

  return 1 if ($species =~ /elegans|briggsae|pacificus|brenneri|jacchus|hapla|japonica|remanei|malayi|brenneri|incognita|contortus/i);

  return 0;
}

# Map a given ID to a species (This might also be a method instead of an ID)
# Because of recpirocal BLASTing with elegans and briggsae and database XREFs
# always try to use the ID of the hit first when doing identifications
# This is used in Gene::inparanoid_groups();
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
  return 'Pristionchus pacificus'    if ($id =~ /^PP\:PP/);
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



# Generically construct a GBrowse img
# Args: Bio::DB::GFF segment,species, [ tracks ], { options }, width
# This is typically called by genomic_environs() ina subclass...
sub build_gbrowse_img {
  my ($self,$segment,$tracks,$options,$width) = @_;

  my $species = $self->_parsed_species();

  # open the browser for drawing pictures
  my $BROWSER = Bio::Graphics::Browser->new or die;

  # NOTE! The path to the configuration directory MUST be supplied by W::M::* adaptor!
  $BROWSER->read_configuration($self->{gbrowse_conf_dir}) or die "Couldn't read or find the gbrowse configuration directory";

  $BROWSER->source($species);
  $BROWSER->width($width || '500');

  $BROWSER->config->set('general','empty_tracks' => 'suppress');
  $BROWSER->config->set('general','keystyle'     => 'none');

  my $absref   = $segment->abs_ref;
  my $absstart = $segment->start;
  my $absend   = $segment->stop;
  ($absstart,$absend) = ($absend,$absstart) if $absstart>$absend;
  my $length = $segment->length;

  # add another 10% to left and right
  my $start = int($absstart - 0.1*$length);
  my $stop  = int($absend   + 0.1*$length);
  my $db    = $segment->factory;

  # TODO: does this work with GFF3?? Need to check. AC
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





# DEPRECATED?
#################################################
#  Phenotypes
#  (Was: DisplayPhenotypes, is_NOT_phene, FormatPhenotypeHash, etc)
# (ie used in RNAi, Seq, Variation)
#################################################
# Return a list of phenotypes observed
sub phenotypes_observed {
  my ($self) = @_;
  my $object = $self->object;
  my $phenes = $self->_get_phenotypes($object);
  return $phenes;
}

# Return a list of phenotypes not observed
sub phenotypes_not_observed {
  my ($self) = @_;
  my $object = $self->object;
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
  $name =  $phenotype->Short_name . " ($name)" if $phenotype->Short_name;
  return "$name";
}



# Was: ElegansSubs::AlleleDescription and MutantPhenotype
# TODO: Need to attach the evidence to each Remark
# TODO: This probably should be a function of the VIEW
sub phenotype_remark {
  my ($self) = @_;
  my $object = $self->object;

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
sub _parse_year {
    my ($self,$date) = @_;
	$date =~ /(\d\d\d\d)/;
    my $year = $1 || $date;
    return $year;
}


# sub _get_evidence
# Standard evidence method - handles the evidence hash in AceDB
# Arg[0] : The acedb node containing an evidence hash
# Arg[1] (optional) : The type of evidence to fetch (default: all evidence)
# Returns: A hash ref containing the evidence requested
#
sub _get_evidence {
    my ($self,$node,$evidence_type)=@_;
    my @nodes = eval{$node->col} ;
    return undef unless(@nodes);
    my %data;

    foreach my $type (@nodes) {

      next if ($type eq 'CGC_data_submission');
       #if only extracting one/more specific evidence types
      if(defined $evidence_type) {
        next unless(grep /^$type$/ , @$evidence_type);
      }

      my @evidences;

      #the goal is to deal label and link seperately?
      foreach my $evidence ($type->col) {
          my $label = $evidence;
          my $packed;
          my $class = eval { $evidence->class } ;
          if($type eq 'Inferred_automatically'){
              if($node eq 'IMP'){
                $evidence =~ s/\((WBPhenotype.*)\|(WBRNAi.*)\)//;
                my ($wb_phene,$wb_rnai) = ($1,$2);
                if($wb_phene){
                  $label = $self->_api->fetch({class=>"Phenotype",name=>$wb_phene})->_common_name;
                  push( @evidences, { id=>$wb_phene, label=>$label, class=>'phenotype'});
                }
                if($wb_rnai){
                    push( @evidences, { id=>$wb_rnai, label=>$wb_rnai, class=>'rnai'});
                }
                next;
              }elsif($node eq 'IEA'){
                ($class,$evidence) = split /:/, $evidence;
              }
          } elsif ($type eq 'Accession_evidence') {
              my $database = $evidence;

              foreach my $accession ($evidence->col){
                if(defined $accession || $database) {
                  if($accession =~ m/\D*\:(\d*)$/){
                    $accession = $1;
                  }
                  if($database =~ m/^(.*):(\d*)$/){
                    $accession = $2;
                    $database = $1;
                  }
                  ($evidence,$class) = ($accession,$database);
                  $label = "$database:$accession";
                  my $match = $self->_api->xapian->fetch({query => "$evidence", class => "sequence"});

                  push( @evidences, { id=> $match ? $match->{id} : "$evidence",
                                      label => "$label",
                                      class => $match ? "sequence" : "$class" });
                }
              }
              next;
          } elsif($type eq 'GO_term_evidence') {
              my $desc = $evidence->Term || $evidence->Definition;
              $label .= (($desc) ? "($desc)" : '');
          } elsif ($type eq 'Protein_id_evidence') {
              $class = "Entrezp";
          } elsif ($type eq 'RNAi_evidence') {
              $label =  $evidence->History_name? $evidence . ' (' . $evidence->History_name . ')' : $evidence;
          } elsif ($type eq 'Date_last_updated') {
              $label =~ s/\s00:00:00//;
              $class = 'text';
          } elsif ($type eq 'Affected_by'){
            foreach my $ev ($evidence) {
              push(@evidences, map {$self->_pack_obj($_)} $ev->col);
            }
            next;
          } elsif ($type eq 'Remark'){
              $packed = "$evidence";
          } else {
              $packed = $self->_pack_obj($evidence);
          }

          $class = (defined $class) ? "$class" : undef;
          push( @evidences, $packed ? $packed : { id=> "$evidence", label => "$label", class => $class });
      }
      $type =~ s/(Curator)_confirmed/$1/;
      $data{$type} = @evidences ? \@evidences : undef;
    }
    return %data ? \%data :undef;
}


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
    $total += $merged->[1]-$merged->[0]+1;
  }
  $total;
}


# The rearrange helper method
# CAN BE PURGED ONCE _parse_evidence_hash is dealt with
sub rearrange {
    my ($self,$order,@param) = @_;
    return unless @param;
    my %param;

    if (ref $param[0] eq 'HASH') {
      %param = %{$param[0]};
    } else {
      # Named parameter must begin with hyphen
      return @param unless (defined($param[0]) && substr($param[0],0,1) eq '-');

      my $i;
      for ($i=0;$i<@param;$i+=2) {
        $param[$i]=~s/^\-//;     # get rid of initial - if present
        $param[$i]=~tr/a-z/A-Z/; # parameters are upper case
      }

      %param = @param;                # convert into associative array
    }

    my(@return_array);

    local($^W) = 0;
    my($key)='';
    foreach $key (@$order) {
        my($value);
        if (ref($key) eq 'ARRAY') {
            foreach (@$key) {
                last if defined($value);
                $value = $param{$_};
                delete $param{$_};
            }
        } else {
            $value = $param{$key};
            delete $param{$key};
        }
        push(@return_array,$value);
    }
    push (@return_array,{%param}) if %param;
    return @return_array;
}





__PACKAGE__->meta->make_immutable;

1;
