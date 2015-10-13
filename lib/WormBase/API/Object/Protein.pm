package WormBase::API::Object::Protein;

use Moose;
use Bio::Tools::SeqStats;
#use pICalculator;
use WormBase::Util::pICalculator;
use Bio::Graphics::Feature;
use Bio::Graphics::Panel;
use Digest::MD5 'md5_hex';
use JSON;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';

use vars qw(%HIT_CACHE);
%HIT_CACHE=();


=pod

=head1 NAME

WormBase::API::Object::Protein

=head1 SYNPOSIS

Model for the Ace ?Protein class.

=head1 URL

http://wormbase.org/species/protein

=cut

has 'peptide' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
	my $self = shift;
	my $peptide = $self ~~ 'asPeptide';
	$peptide =~ s/^>.*//;
	$peptide =~ s/\n//g;
	return $peptide;
    }
    );

has 'cds' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
	my $self = shift;
	return $self ~~ '@Corresponding_CDS';
    }
    );


#######################################
#
# CLASS METHODS
#
#######################################

#######################################
#
# INSTANCE METHODS
#
#######################################

############################################################
#
# The Overview widget
#
############################################################

# name { }
# Supplied by Role

# taxonomy { }
# Supplied by Role

# central_dogma { }
# Supplied by Role

sub _build__common_name {
    my $self   = shift;
    my $object = $self->object;
    # More than one corresponding CDS? Can't be sure of which CDS we're looking at
    # so to avoid ambiguity, use the actual object identifier.
    my @corresponding_cds = $object->Corresponding_CDS;
    my $name;
    if (@corresponding_cds >= 2) {
        $name = "$object";
        $name =~ s/\n//g;
    } else {
	# Otherwise use the more human friendly Gene_name.
        $name = $object->Gene_name && $object->Gene_name->asString;
    }
    $name =~ s/\n//g if $name; # get rid of possible newlines that may/may not be lingering around
    return $name;
}

# corresponding_gene { }
# This method returns a data structure containing the
# corresponding gene of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_gene

sub corresponding_gene {
    my $self   = shift;

    # From a list of CDSs for the protein, get the corresponding gene(s)
    my @genes = grep{ $_->Method ne 'history'}  @{$self->cds};
    @genes = map { $self->_pack_obj($_->Gene) } @genes;
    return { description => 'The corressponding gene of the protein',
	     data        => @genes ? \@genes : undef };
}

# corresponding_transcripts { }
# This method returns a data structure containing
# the corresponding transcripts of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_transcripts

sub corresponding_transcripts {
    my $self = shift;
    my @cds = grep{$_->Method ne 'history'} @{$self->cds};
    my @transcripts = map { $self->_pack_obj($_) } map {$_->Corresponding_transcript}  @cds;
    return  { description => 'the corresponding transcripts of the protein',
	      data        => @transcripts ? \@transcripts : undef };
}


# corresponding_cds { }
# This method returns a data structure containing
# the corresponding CDSs of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_cds

sub corresponding_cds {
    my $self = shift;
    my @cds = grep{$_->Method ne 'history'} @{$self->cds};
    @cds = map { $self->_pack_obj($_) } @cds;
    return  { description => 'the corresponding CDSs of the protein',
	      data        => @cds ? \@cds : undef };
}



sub corresponding_all {
    my $self = shift;
    my $protein = $self->object;
    my @cds = grep{$_->Method ne 'history'} @{$self->cds};
    my @rows;

    foreach my $cds ( sort { $a cmp $b } @cds ) {
        my %data  = ();
        my $gff   = $self->_fetch_gff_gene($cds) or next;

        my @sequences = $cds->Corresponding_transcript;
        my $len_spliced   = 0;

        # TODO: update in WS240
        # note from Kevin - WormBase may be splitting to
        # WormBase_protein_coding, WormBase_ncRNA, etc in WS240
        # Also: WHY ARE THE NUMBERS DIFFERENT FROM GFF2 ??!?
        map { $len_spliced += $_->length } $gff->get_SeqFeatures('CDS:WormBase');

        $len_spliced ||= '-';

        $data{length_spliced}   = $len_spliced;

        my @lengths = map { $self->_get_transcript_length("$_", ''. $_->Method) . "<br />";} @sequences;
        $data{length_unspliced} = @lengths ? \@lengths : undef;


        my $peplen = $protein->Peptide(2);
        my $aa     = "$peplen";
        $data{length_protein} = $aa if $aa;

        my $gene = $cds->Gene;

        my $status = $cds->Prediction_status if $cds;
        $status =~ s/_/ /g if $status;
        $status = $status . ($cds->Matching_cDNA ? ' by cDNA(s)' : '');

        my $type = @sequences ? $sequences[0]->Method : '';
        $type =~ s/_/ /g;
        @sequences =  map {$self->_pack_obj($_)} @sequences;
        $data{type} = $type && "$type";
        $data{model}   = \@sequences;
        $data{protein} = $self->_pack_obj($protein, undef, style => 'font-weight:bold');
        $data{cds} = $status ? { text => ($cds ? $self->_pack_obj($cds) : '(no CDS)'), evidence => { status => "$status"} } : ($cds ? $self->_pack_obj($cds) : '(no CDS)');
        $data{gene} = $self->_pack_obj($gene);
        push @rows, \%data;
    }

    return {
        description => 'corresponding cds, transcripts, gene for this protein',
        data        => @rows ? \@rows : undef
    };
}


# type (DEPRECATING!)
# This method returns a data structure containing the
# the type of protein, if defined.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/type

sub type {
    my $self = shift;
    my $data = eval {$self->cds->[0]->Method};
    return { description => 'The type of the protein',
	     data        =>  $data && "$data",
    };
}


# best_human_match { }
# This method returns a data structure containing the
# best human blast hit for the protein
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/best_human_match

sub best_human_match {
    my ($self) = @_;
    my $object = $self->object;
    my @pep_homol =  grep { $_ =~ /^ENSEMBL/ } $object->Pep_homol;

    my $best;
    for my $hit (@pep_homol) {
        my $score = $hit->right(2);

        my $prev_score = (!$best) ? $score : $best->{score};
        $prev_score = ($prev_score =~ /\d+\.\d+/) ? $prev_score . '0'
                                                  : "$prev_score.0000";
        my $curr_score = ($score =~ /\d+\.\d+/) ? $score . '0'
                                                : "$score.0000";
        $best =
          {score => $score, hit => $hit}
          if !$best || $prev_score < $curr_score;
    }

    return {
        description => 'best human BLASTP hit',
        data        => $best->{hit} ? {
                hit         => $self->_pack_obj($best->{hit}),
                description => sprintf($best->{hit}->Description) || sprintf($best->{hit}->Gene_name),
                evalue      => sprintf("%7.3g", 10**-$best->{score})
            } : undef
    };
}

# description { }
# Supplied by Role

# status { }
# Supplied by Role

# remarks {}
# Supplied by Role


############################################################
#
# The External Links widget
#
############################################################

# xrefs {}
# Supplied by Role

############################################################
#
# The Molecular Details widget
#
############################################################

# sequence { }
# This method returns a data structure containing the
# the sequence of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/sequence

sub sequence {
    my $self    = shift;
    my $peptide = $self->peptide;
    return { description => 'the peptide sequence of the protein',
	     data        => { sequence => $peptide,
			      length   => length $peptide,
			      type => 'aa',
	     },
    };
}

# estimated_molecular_weight { }
# This method returns a data structure containing the
# estimated molecular weight of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/estimated_molecular_weight

sub estimated_molecular_weight{
    my $self   = shift;
    my $object = $self->object;
    my $mw     = $object->Molecular_weight;
    return { description => 'the estimated molecular weight of the protein',
	     data        =>  $mw ? "$mw" : undef };
}

# estimated_isoelectric_point { }
# This method returns a data structure containing the
# estimated isoelectric point of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/estimated_isoelectric_point

sub estimated_isoelectric_point {
    my $self = shift;

    my $pic     = WormBase::Util::pICalculator->new();
    my $seq     = Bio::PrimarySeq->new($self->peptide);
    $pic->seq($seq);
    my $iep     = $pic->iep;
    return { description => 'the estimated isoelectric point of the protein',
	     data        =>  $iep };
}

# amino_acid_composition { }
# This method returns a data structure containing the
# amino acid makeup of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/amino_acid_composition

sub amino_acid_composition {
    my $self = shift;
    return unless ($self->peptide);
    my $seq     = Bio::PrimarySeq->new($self->peptide);
    my $stats   = Bio::Tools::SeqStats->new($seq);

    my %abbrev = (A=>'Ala',R=>'Arg',N=>'Asn',D=>'Asp',C=>'Cys',E=>'Glu',
		  Q=>'Gln',G=>'Gly',H=>'His',I=>'Ile',L=>'Leu',K=>'Lys',
		  M=>'Met',F=>'Phe',O=>'Pyl*', P=>'Pro',S=>'Ser',T=>'Thr',W=>'Trp',
		  Y=>'Tyr',V=>'Val',U=>'Sec*',X=>'Xaa**');
    # Amino acid content
    my $composition = $stats->count_monomers;

    delete $composition->{O} unless $composition->{O};
    delete $composition->{U} unless $composition->{U};
    my @aminos;
    map { push @aminos, { aa=>$abbrev{$_}, comp=>$composition->{$_} }} keys %$composition;

    return { description => 'The amino acid composition of the protein',
	     data        =>  @aminos ? \@aminos :undef,
    };
}


############################################################
#
# The Homology widget
#
############################################################

# homology_groups { }
# This method returns a data structure containing "KOGs"
# or clusters of homology groups of this protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/homology_groups

sub homology_groups {
    my $self   = shift;
    my $object = $self->object;
    my @hg;
    foreach my $k ($object->Homology_group) {
      my $title = $k->Title;
      my $type  = join(':', ($k->Group_type,$k->Group_type->right(2))) if $k->Group_type;
      push @hg ,{ type  => "$type",
              title => "$title" || '',
              id    => $self->_pack_obj($k),
      };
    }
    return { description => 'KOG homology groups of the protein',
	     data        => @hg ? \@hg : undef };

}

# orthologs { }
# This method returns a data structure containing
# genes orthologs to the current protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/orthologs

sub orthologs {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Ortholog_gene) {
	push @data, { species => $self->_split_genus_species($_->Species),
		      gene    => $self->_pack_obj($_) };
    }

    return { description => 'orthologous genes of the protein',
	     data        =>  @data ? \@data : undef };
}


# homology_image { }
# This method returns a data structure containing
# data for generating a schematic showing protein
# domains versus exons.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/homology_image

sub homology_image {
    my $self=shift;
#     my $panel=$self->_draw_image($self->object,1);
#     return unless $panel;
#     my $gd=$panel->gd;
    #show dynamic images
    return { description => 'a dynamically generated image representing homologous regions of the protein',
# 	     data        => $gd ? $gd->png : undef,
	     data => 1,
    };
=pod print image as file
    my ($suffix,$img,$boxes);
    if ($gd->isa('Ace::Object')) {
	$suffix = 'gif';
	($img,$boxes) = $gd->asGif(@_);
    } else {
	$suffix  = $gd->can('png') ? 'png' : 'gif';
	$img     = $gd->can('png') ? $gd->png : $gd->gif;
    }
    my $basename = md5_hex($img);
    my $dirs = substr($basename,0,6) ;
    $dirs    =~ s!^(.{2})(.{2})(.{2})!$1/$2/$3!g;

    # Fetch the full path to the file
    my $path = $self->tmp_image_dir($dirs) . "/$basename.$suffix";

    # Write out the file unless it already exists
    unless (-s $path) {
	open (F,">$path") ;
	print F $img;
	close F;
    }

    # Return the URI to the temporary image file.
    # It should be something like
     my $data = { description => 'The homology image of the protein',
 		 data        => $self->tmp_image_uri($path),
     };
     return $data;
=cut
}


sub rest_homology_image {
    my $self=shift;
    my $panel=$self->_draw_image($self->object,1);
    return unless $panel;
    my $gd=$panel->gd;
    #show dynamic images
    return $gd->png;

}


# pfam_graph { }
# This method returns a data structure containing the
# coordinates for generating a PFAM domain cartoon.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/pfam_graph

{ # block for pfam graph
my @COLORS = map {"#$_"} qw(2dcf00 ff5353 e469fe ffa500 00ffff 86bcff ff7ff0 f2ff7f 7ff2ff);

sub pfam_graph {
    my $self = shift;
    my $motif_homol = $self ~~ '@Motif_homol';
    my $hash;
    my $length = length($self->peptide);
    my $ret = { description => "The motif graph of the protein",
                data => undef};


    for( my $i=0;my $feature=shift @$motif_homol;$i++) {
	    my $score = $feature->right(2);
	    my $start = $feature->right(3);
	    my $stop  = $feature->right(4);
	    my $type = $feature->right ||"";
        my $label = $feature->Title;
        map { $label = $_->right if ($_ && "$_" eq 'short_name')} eval { $feature->DB_info->right->col };
	    $type  ||= 'Interpro' if $feature =~ /IPR/;

	    # Are the multiple occurences of this feature?
	    my @multiple = $feature->right->right->col;
	    @multiple = map {$_->right} $feature->right->col if(@multiple <= 1);

	    if (@multiple > 1) {
		my @scores = $feature->right->col;
		for( my $count=0; $start=shift @multiple;$count++) {
 		    $score= $scores[$count] if($#scores>=$count && $scores[$count]);
		    my $stop = $start->right;
		   push  @{$hash->{$type}} , {end=>"$stop",start=>"$start",score=>"$score",type=>"$type",feature=>$feature,length=>($stop-$start+1),colour=>$COLORS[$i % @COLORS],label=>"$label"};
		}
	    } else {
		    push  @{$hash->{$type}} , {end=>"$stop",start=>"$start",score=>"$score",type=>"$type",feature=>$feature,length=>($stop-$start+1),colour=>$COLORS[$i % @COLORS],label=>"$label"};

	    }
    }

    # extract the exons, then map them
    # onto the protein backbone.
    my $gene    = $self->cds->[0];
    my $gffdb = $self->gff_dsn || return $ret;
    my ($seq_obj) = eval{$gffdb->segment($gene)}; return if $@;

    my (@exons,@segmented_exons);
    # Translate the bp start and stop positions into the approximate amino acid
    # contributions from the different exons.

    if ($seq_obj) {
	@exons = $seq_obj->features('exon:curated');
	@exons = grep { $_->name eq $gene } @exons;
	my $end_holder=0;
	my $mod=0;
	my $count=0;
	foreach my $exon (sort { $a->start <=> $b->start } @exons) {

	    $count++;
	    my $start = $exon->start;
	    my $stop  = $exon->stop;
	    my $length = ($stop - $start + $mod +1) / 3;
	    $mod= ($stop - $start + $mod +1) % 3;
	    my $end = int($length) + $end_holder-1;

	    push @segmented_exons,{  colour => "#000000",
				     start=>$end_holder,
				     end=>$end,
				     v_align=>"bottom",
				     metadata => {
					 type=>"exon".$count,
				     },
	    };
	    $end_holder = $end+1;
	}
    }

    my @markups;
    foreach my $type (sort keys %$hash){
	my @array = grep { $_->{length} >1  } @{$hash->{$type}};
	unless(@array) {
	    push @markups, @{$hash->{$type}} ;
	    delete $hash->{$type};
	}
    }

    foreach my $type (sort keys %$hash){
	if (@markups) {
	    push @{$hash->{$type}}, @markups;
	    undef @markups;
	}
	my $graph;
	my @sort = sort { $b->{length} <=> $a->{length} } @{$hash->{$type}};
	foreach my $obj (@sort) {

	    my $feature = $obj->{feature};
	    (my $label = $feature) =~ s/.*://;
	    my $desc = $feature->Title ||$feature ;
	    $feature =~ m/(.*):(.*)/;
	    my $href= "$1/$2";
	    my $identifier="$feature(e-value:".$obj->{score}.")";
	    my $graph_hash= { 	     colour => $obj->{colour},
				     start=>$obj->{start},
				     href=>$href,
				     metadata => {
					 database=>$obj->{type},
					 description=>"$desc",
					 identifier=>$identifier,
				     },
	    };
	    my $graph_type = "regions";
	    if($obj->{length} == 1 ) {
		$graph_type = "markups";
		$graph_hash->{headStyle} = "diamond";

	    } else {
		$graph_hash->{end} = $obj->{end};
		$graph_hash->{startStyle} = "straight";
		$graph_hash->{endStyle} = "straight";

        # use short_name for label
		$graph_hash->{text} = $obj->{label};
		$graph_hash->{metadata}->{end} = $obj->{end};
	    }

	    push @{$graph->{$graph_type}} ,$graph_hash;
	}
	$graph->{length}= $length;
	push @{$graph->{markups}} ,@segmented_exons;
	$hash->{$type} = to_json ($graph);
    }

    $ret->{data} = scalar keys %$hash ? $hash : undef;
    return $ret;
}
} # end of block for pfam_graph

# motif_details { }
# This method returns a data structure containing the
# details on motifs identified in the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/motif_details

sub motif_details {
    my $self = shift;
    my $object = $self->object;
    my @motif_homol = $object->Motif_homol;

    # Summary by Motif
    my @data = ();

    if (@motif_homol > 0) {

        # Now deal with the motif_homol features
        foreach my $motif_homol (@motif_homol) {

            my $source_db = $motif_homol->right;
            my ($source_id) = "$motif_homol" =~ m/[^\:]*\:(.+)/ or ("$motif_homol");
            my $source = {
                id => $source_id,
                db => "$source_db",
            };

            my $desc = $motif_homol->Title || $motif_homol;

            my @scores = $motif_homol->col(2);

            foreach my $score (@scores) {
                # some motif mappings don't have a score, so $score->col() gets all these mappings,
                # by getting their start positions first
                my @start_positions = $score->col();
                foreach my $start (@start_positions){
                    my $stop = $start->right;

                    push( @data, {
                        feat	=>
                        $self->_pack_obj($motif_homol,"$motif_homol"),
                        start	=> "$start",
                        stop	=> "$stop",
                        score	=> "$score",
                        source	=> $source,
                        desc	=> "$desc"
                    });

                }
            }

        }

    }

    my $data = { description => 'The motif details of the protein',
        data => @data ? \@data : undef
    };
    return $data;

}

# blast_details { }
# This method returns a data structure containing the
# details of all precomputed blastp hits of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/blast_details

sub blast_details {
  my $self = shift;
#   local $^W = 0;  # to avoid loads of uninit variable warnings

  my $homol = $self ~~ '@Pep_homol';
  # wrestle blast hits into a workable data structure!!
  my @hits = wrestle_blast($homol);
  # sort by score
#   @hits = sort {$b->{score}<=>$a->{score} || $a->{source}<=>$b->{source}} @hits;
  my @rows;
  for my $h (@hits) {
#     my ($url,$id) = hit_to_url($h->{hit}) or next;
      my $id = $h->{hit};
      next if ($id =~ /^MSP/); # skip for mass-spec objects, not sure if this is right?
      my $method = $h->{type};

      # Try fetching the species first with the identification
      # then method then the embedded species
      my $species = $h->{hit}->Species || $self->id2species($h) || $self->id2species($method);

      # Not all proteins are populated with the species
      $species =~ s/^(\w)\w* /$1. /;
      $species =~ /(.*)\.(.*)/;

      my $taxonomy = {genus=>$1,species=>$2};


      my $description = $h->{hit}->Description || $h->{hit}->Gene_name;
      my $class;

      # this doesn't seem optimal... maybe there should be something in config?
      if ($method =~ /worm|briggsae|remanei|japonica|brenneri|pristionchus/) {
	  $description ||= eval{$h->{hit}->Corresponding_CDS->Brief_identification};
	  # Kludge: display a description using the CDS
	  if (!$description) {
	      for my $cds (eval { $h->{hit}->Corresponding_CDS }) {
		  next if $cds->Method eq 'history';
		  $description ||= "gene $cds";
	      }
	  }
	  $class = 'protein';
      }

      my $id_link = $id;
      if ($id =~ /(\w+):(.+)/) {
	  my $prefix    = $1;
	  my $accession = $2;
	  $id_link = $accession unless $class;
	  $class = $prefix unless $class;
      }

      # warn "$h->{hit} is bad" if $method =~ /worm|briggsae/ && ! $h->{hit}->Corresponding_CDS;
      my $eval = $h->{score};
      push @rows,[($self->_pack_obj($h->{hit}),$taxonomy,"$description",sprintf("%7.3g",10**-$eval),
		   $h->{source},
		   $h->{target})];

  }
  return { description => 'The Blast details of the protein',
	   data        => @rows ? \@rows : undef };
}





############################################################
#
# The History Widget (template supplied by shared/widgets/history.tt2)
#
############################################################

# history { }
# This method returns a data structure containing the
# curatorial history of the protein.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/history

sub history {
    my $self   = shift;
    my $object = $self->object;

    my @data;
    foreach my $version ($object->History) {
        my $event  = $version->right;

        my @genes = $version->right->col;
        foreach my $gene (@genes){
            push @data, {
                version    => "$version" || undef,
                event      => "$event" || undef,
                prediction => $gene ? {id=>"$gene", class=>'gene'} : undef,
            };
        }
    }


    return { description => 'curatorial history of the protein',
	     data        =>  @data ? \@data : undef };
}

############################################################
#
# Location Widget (template supplied by shared/widgets/location.tt2)
#
############################################################

# Overridden from 'Position'. Returns true, so that a genomic image
# is returned for each genomic position recorded for this feature.
sub _make_multiple_genomic_images {
    return 1;
}

sub _build_genomic_position {
    my ($self) = @_;
    my @genes = grep{ defined blessed($_) and $_->Method ne 'history'} @{$self->cds};
    if (not @genes || scalar(@genes) == 0) {
        return { description => 'No genomic position data available.', data => undef };
    }

    my @positions = ();
    foreach my $gene (@genes) {
        my $position = $self->_api->wrap($gene)->_build_genomic_position;
        if ($position->{'data'} && $position->{'data'}->[0]){
            push(@positions, $position->{'data'}->[0]);
        }
    }

    return {
        description => "Genomic position of the genes that are coding the protein",
        data => @positions ? \@positions : undef
    };
}

sub _build_genetic_position {
    my ($self) = @_;

    my @genes = grep{ defined blessed($_) and $_->Method ne 'history'}  @{$self->cds};
    if (not @genes || scalar(@genes) == 0) {
        return { description => 'No genetic position data available.', data => undef };
    }

    my @positions = ();
    foreach my $gene (@genes) {
        my ($chromosome,$position,$error) = $self->_api->wrap($gene)->_get_interpolated_position();
        my $genetic_position = $self->make_genetic_position_object('Protein', $self->object, $chromosome, $position, $error, 'interpolated');
        push(@positions, $genetic_position->{'data'});
    }

    return {
        description => "Genetic positions of the genes that are coding the protein",
        data => @positions ? \@positions : undef
    };
}

sub _build_genetic_position_interpolated {
    my ($self) = @_;

    return $self->_build_genetic_position();
}

sub _build__segments {
    my ($self) = @_;
    my @segments;

    my $dbh = $self->gff_dsn() || return \@segments;

    if (@segments = $dbh->segment($self->object)
        or @segments = map {$dbh->segment($_)} $self->cds
        or @segments = map { $dbh->segment( $_) } $self->corresponding_transcripts()->{data} # RNA transcripts (lin-4, sup-5)
    ) {
        return \@segments;
    }

    return \@segments;
}

sub _build_tracks {
    my ($self) = @_;

    return {
        description => 'Protein specific tracks to display in GBrowse.',
        data => [qw(GENES PROTEIN_MOTIFS)]
    };
}

############################################################
#
# PRIVATE METHODS
#
############################################################

sub _draw_image {
    my $self = shift;
    my $obj = shift;
    my $best_only = shift;

    # Get out the length;
    my $length = length($self->peptide);

    # Setup the panel, using the protein length to establish the box as a guide
    my $ftr = 'Bio::Graphics::Feature';
    my $segment = $ftr->new(-start=>1,-end=>$length,
        -name=>"$obj",
        -type=>'Protein');

    my $panel = Bio::Graphics::Panel->new(-segment   =>$segment,
        -key       =>'Protein Features',
        -key_style =>'between',
        -key_align =>'left',
        -grid      => 1,
        -width     =>'650');

    # Get out the gene - will use to extract the exons, then map them
    # onto the protein backbone.
    my $gene    = $self->cds->[0];
    my $gffdb = $self->gff_dsn($self->_parsed_species) || return;
    # print $gffdb;
    my $dbh = $gffdb->dbh || return;
    my ($seq_obj) = $dbh->segment("$gene");

    my (@exons,@segmented_exons);

    # Translate the bp start and stop positions into the approximate amino acid
    # contributions from the different exons.
    my ($count,$end_holder);

    if ($seq_obj) {
        @exons = $seq_obj->features('exon:WormBase');
#        @exons = grep { $_->name eq $gene } @exons;

        #   local $^W = 0;  # kill uninitialized variable warning
        $end_holder=0;
        foreach my $exon (sort { $a->start <=> $b->start } @exons) {

            $count++;
            my $start = $exon->start;
            my $stop  = $exon->stop;

            # Calculate the difference of the start and stop to figure
            # to figure out how many amino acids it corresponds to
            my $length = (($stop - $start) / 3);

            my $end = $length + $end_holder;
            my $seg = $ftr->new(-start=>$end_holder,-end=>$end,
                  -name=>"exon $count",-type=>'exon');
            push @segmented_exons,$seg;
            $end_holder = $end;
        }
    }


    ## Structural motifs (this returns a list of feature types)
    my %features;
    my @features = $obj->Feature;
    # Visit each of the features, pushing into an array based on its name
    foreach my $type (@features) {
      # 'Tis dangereaux - could lose some features if the keys overlap...
      my %positions = map {$_ => $_->right(1)} $type->col;
      foreach my $start (keys %positions) {
        my $seg = $ftr->new(-start=>"$start",-end=>$positions{"$start"},
            -name=>"$type",-type=>"$type");
        # Create a hash of all the features, keyed by type;
        push (@{$features{'Features-' . "$type"}},$seg);
      }
    }

    ## A protein ruler
    $panel->add_track(arrow => [ $segment ],
        -label => 'amino acids',
        -arrowstyle=>'regular',
        -tick=>5,
        #		    -tkcolor => 'DarkGray',
    );

    ## Print the exon boundaries
    $panel->add_track(generic=>[ @segmented_exons ],
        -glyph     => 'generic',
        -key       => 'exon boundaries',
        -bump      => 0,
        -height    => 6,
        -spacing   => 50,
        -linewidth =>1,
        -connector =>'none',
    ) if @segmented_exons;

    my %glyphs = (  low_complexity  => 'generic',
                    transmembrane   => 'generic',
                    signal_peptide  => 'generic',
                    tmhmm           => 'generic'
    );

    my %labels   = ('low_complexity'        => 'Low Complexity',
                    'transmembrane'         => 'Transmembrane Domain(s)',
                    'signal_peptide'        => 'Signal Peptide(s)',
                    'tmhmm'                 => 'Transmembrane Domain(s)',
                    'wublastp_ensembl'      => 'BLASTP Hits on Human ENSEMBL database',
                    'wublastp_fly'          => 'BLASTP Hits on FlyBase database',
                    'wublastp_slimSwissProt'=> 'BLASTP Hits on SwissProt',
                    'wublastp_slimTrEmbl'   => 'BLASTP Hits on Uniprot',
                    'wublastp_worm'         => 'BLASTP Hits on WormPep',
    );

    my %colors = (  'low_complexity'    => 'blue',
                    'transmembrane'     => 'green',
                    'signalp'           => 'gray',
                    'prosite'           => 'cyan',
                    'seg'               => 'lightgrey',
                    'pfam'              => 'wheat',
                    'motif_homol'       => 'orange',
                    'wublastp_remanei'  => 'blue'
    );

    foreach ($obj->Homol) {
        my (%partial,%best);
        my @hits = $obj->get($_);
        my %motif_ranges = ();

        # Pep_homol data structure is a little different
        if ($_ eq 'Pep_homol') {
            my @features = wrestle_blast(\@hits,1);

            # Sort features by type.  If $best_only flag is true, then we only keep the
            # best ones for each type.
            my %best;
            for my $f (@features) {
                next if $f->name eq $obj;
                my $type = $f->type;
                if ($best_only) {
                    next if $best{$type} && $best{$type}->score > $f->score;
                    $best{$type} = $f;
                } else {
                    push @{$features{'BLASTP Homologies'}},$f;
                }
            }

            # add descriptive information for each of the best ones
            # local $^W = 0; #kill uninit variable warning
            for my $feature ($best_only ? values %best : @{$features{'BLASTP Homologies'}}) {
                my $homol = $HIT_CACHE{$feature->name};
                my $species =  $homol->Species||"";
                my $description = $species;
                my $score       = sprintf("%7.3G",10**-$feature->score);
                $description    =~ s/^(\w)\w* /$1. /;
                $description   .= " ";
                # my $desc = $homol->Description} || $homol->Gene_name || "";
                $description   .= $homol->Description || $homol->Gene_name || "";
                $description   .=  $homol->Corresponding_CDS ? $homol->Corresponding_CDS->Brief_identification ||"" : ""
                if $species =~ /elegans|briggsae/;
                my $t = $best_only ? "best hit, " : '';
                $feature->desc("$description (${t}e-val=$score)") if $description;
            }

            if ($best_only) {
                for my $type (keys %best) {
                    push @{$features{'Selected BLASTP Homologies'}},$best{$type};
                }
            }

            # these are other homols
        } else {
            for my $homol (@hits) {
                my $title = eval {$homol->Title};
                my $type  = $homol->right or next;
                my @coord = $homol->right->col;
                my $name  = $title ? "$title ($homol)" : $homol;

                ### filter out duplicate segments ####
                foreach my $segment (@coord) {
                    my ($start,$stop) = $segment->right->row;
                    my $range = $start."_to_".$stop;


                    if ($motif_ranges{$range}){
                        next;
                    } else {
                        my $seg  = $ftr->new(-start=>$start,
                            -end =>$stop,
                            -name =>$name,
                            -type =>$type);
                        push (@{$features{'Motifs'}},$seg);
                        # print "<pre>$range</pre>";
                        $motif_ranges{$range} = 1;;
                    }
                }
            }
        }
    }

    foreach my $key (sort keys %features) {
        # Get the glyph
        my $type  = $features{$key}[0]->type;

        my $label = $labels{$key}  || $key;
        my $glyph = $glyphs{$key}  || 'graded_segments';
        my $color = $colors{lc($type)} || 'green';
        my $connector = $key eq 'Pep_homol' ? 'solid' : 'none';

        $panel->add_track(segments     => $features{$key},
            -glyph       => $glyph,
            -label       => ($label =~ /Features/) ? 0 : 1,
            -bump        => 1,
            -sort_order  => 'high_score',
            -bgcolor     => $color,
            -font2color  => 'grey',
            -height      => 6,
            -linewidth   => 1,
            -description => 1,
            -min_score   => -50,
            -max_score   => 100,
            -key         => $label,
            -description => 1,
        );
    }

    return $panel;
}

sub wrestle_blast {
    my $hits = shift;
    my $as_features = shift;

    my (@hits,%cached_features);
    my %seen;
    for my $homol (@$hits) {
	for my $type ($homol->col) {
	    for my $score ($type->col) {
		for my $start ($score->col) {
		    for my $end ($start->col) {
			my ($tstart,$tend) = $end->row(1);

			next if ($seen{"$start$end$homol"}++);

			$HIT_CACHE{$homol} = $homol;

			if ($as_features) {
			    my $f = $cached_features{$type}{$homol};
			    if (!$f) {
				$f
				    = $cached_features{$type}{$homol}
				= Bio::Graphics::Feature->new(-name     => "$homol",   # quotes and +0 stringifies ace object
							      -type     => "$type",
							      -score    => $score+0);
				push @hits,$f;
			    }
			    $f->add_segment(Bio::Graphics::Feature->new(-start => $start+0,
									-end   => $end+0,
									-score => $score+0,
					    ));
			} else {
			    push @hits,{hit=>$homol,type=>$type,score=>$score,source=>"$start..$end",target=>"$tstart..$tend"};
			}
		    }
		}
	    }
	}
    }
    @hits;
}

sub hit_to_url {
    my $name = shift;
    $name =~ /(\w+):(\w+)/ or return; # was $name =~ /(\w+):(.+)/ or return;
    my $prefix    = $1;
    my $accession = $2;
    # Hack for flybase IDs
    $accession =~ s/CG/00/ if ($prefix =~ /FLYBASE/);
    return ($prefix,$accession);
}


__PACKAGE__->meta->make_immutable;

1;
