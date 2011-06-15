package WormBase::API::Object::Protein;

use Moose;
use Bio::Tools::SeqStats;
#use pICalculator;
use WormBase::Util::pICalculator;
use Bio::Graphics::Feature;
use Bio::Graphics::Panel;
use Digest::MD5 'md5_hex';
use JSON;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';
 
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

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


############################################################
#
# The Overview widget
#
############################################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub taxonomy { }
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

# sub central_dogma { }
# Supplied by Role; POD will automatically be inserted here.
# << include central_dogma >>


=head3 corresponding_gene

This method returns a data structure containing the 
corresponding gene of the protein.

=over

=item PERL API

 $data = $model->corresponding_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_gene

B<Response example>

<div class="response-example"></div>

=cut

sub corresponding_gene {
    my $self   = shift;

    # From a list of CDSs for the protein, get the corresponding gene(s)
    my @genes = grep{ $_->Method ne 'history'}  @{$self->cds};
    @genes = map { $self->_pack_obj($_) } @genes;
    return { description => 'The corressponding gene of the protein',
	     data        => @genes ? \@genes : undef }; 
}

=head3 corresponding_transcripts

This method returns a data structure containing
the corresponding transcripts of the protein.

=over

=item PERL API

 $data = $model->corresponding_transcripts();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_transcripts

B<Response example>

<div class="response-example"></div>

=cut

sub corresponding_transcripts {
    my $self = shift;
    my @cds = grep{$_->Method ne 'history'} @{$self->cds};
    my @transcripts = map { $self->_pack_obj($_) } map {$_->Corresponding_transcript}  @cds;
    return  { description => 'the corresponding transcripts of the protein',
	      data        => @transcripts ? \@transcripts : undef };
}


=head3 corresponding_cds

This method returns a data structure containing
the corresponding CDSs of the protein.

=over

=item PERL API

 $data = $model->corresponding_cds();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/corresponding_cds

B<Response example>

<div class="response-example"></div>

=cut

sub corresponding_cds {
    my $self = shift;
    my %seen;
    my @cds = grep{$_->Method ne 'history'} @{$self->cds};
    @cds = map { $self->_pack_obj($_) } @cds;
    return  { description => 'the corresponding CDSs of the protein',
	      data        => @cds ? \@cds : undef };
}


=head3 type (DEPRECATING!)

This method returns a data structure containing the 
the type of protein, if defined.

=over

=item PERL API

 $data = $model->type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/type

B<Response example>

<div class="response-example"></div>

=cut

sub type {
    my $self = shift;
    return { description => 'The type of the protein',
	     data        =>  eval {$self->cds->[0]->Method} || 'None' ,
    }; 
}

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub status { }
# Supplied by Role; POD will automatically be inserted here.
# << include status >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


############################################################
#
# The External Links widget
#
############################################################ 

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


############################################################
#
# The Molecular Details widget
#
############################################################

=head2 Molecular Details

=head3 sequence

This method returns a data structure containing the 
the sequence of the protein.

=over

=item PERL API

 $data = $model->sequence();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/sequence

B<Response example>

<div class="response-example"></div>

=cut

sub sequence {
    my $self    = shift;
    my $peptide = $self->peptide;
    return { description => 'the peptide sequence of the protein',
	     data        => { sequence => $peptide,
			      length   => length $peptide,			      
	     },
    };
}

=head3 estimated_molecular_weight

This method returns a data structure containing the 
estimated molecular weight of the protein.

=over

=item PERL API

 $data = $model->estimated_molecular_weight();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/estimated_molecular_weight

B<Response example>

<div class="response-example"></div>

=cut

sub estimated_molecular_weight{
    my $self   = shift;
    my $object = $self->object; 
    my $mw     = $object->Molecular_weight;
    return { description => 'the estimated molecular weight of the protein',
	     data        =>  $mw ? "$mw" : undef };
}

=head3 estimated_isoelectric_point
    
This method returns a data structure containing the 
estimated isoelectric point of the protein.

=over

=item PERL API

 $data = $model->estimated_isoelectric_point();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/estimated_isoelectric_point

B<Response example>

<div class="response-example"></div>

=cut

sub estimated_isoelectric_point {
    my $self = shift;
  
    my $pic     = WormBase::Util::pICalculator->new();
    my $seq     = Bio::PrimarySeq->new($self->peptide);
    $pic->seq($seq);
    my $iep     = $pic->iep;
    return { description => 'the estimated isoelectric point of the protein',
	     data        =>  $iep }; 
}

=head3 amino_acid_composition

This method returns a data structure containing the 
amino acid makeup of the protein.

=over

=item PERL API

 $data = $model->amino_acid_composition();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/amino_acid_composition

B<Response example>

<div class="response-example"></div>

=cut

sub amino_acid_composition {
    my $self = shift;
    return unless ($self->peptide);
    my $selenocysteine_count = 
	(my $hack_seq = $self->peptide)  =~ tr/Uu/Cc/;  # primaryseq doesn't like selenocysteine, so make it a cysteine

    my $seq     = Bio::PrimarySeq->new($hack_seq);
    my $stats   = Bio::Tools::SeqStats->new($seq);
    
    my %abbrev = (A=>'Ala',R=>'Arg',N=>'Asn',D=>'Asp',C=>'Cys',E=>'Glu',
		  Q=>'Gln',G=>'Gly',H=>'His',I=>'Ile',L=>'Leu',K=>'Lys',
		  M=>'Met',F=>'Phe',P=>'Pro',S=>'Ser',T=>'Thr',W=>'Trp',
		  Y=>'Tyr',V=>'Val',U=>'Sec*',X=>'Xaa');
    # Amino acid content
    my $composition = $stats->count_monomers;
    if ($selenocysteine_count > 0) {
	$composition->{C} -= $selenocysteine_count;
	$composition->{U} += $selenocysteine_count;
    }
    my %aminos = map {$abbrev{$_}=>$composition->{$_}} keys %$composition;
    return { description => 'The amino acid composition of the protein',
	     data        =>  \%aminos ,
    }; 
}

    
############################################################
#
# The Homology widget
#
############################################################

=head2 Homology

=head3 homology_groups

This method returns a data structure containing "KOGs"
or clusters of homology groups of this protein.

=over

=item PERL API

 $data = $model->homology_groups();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/homology_groups

B<Response example>

<div class="response-example"></div>

=cut

sub homology_groups {
    my $self   = shift;
    my $object = $self->object;
    my @kogs = $object->Homology_group;
    my @hg;
    foreach my $k (@kogs) {
	my $title = $k->Title;
	my $type  = $k->Group_type;
	push @hg ,{ type  => "$type"  || '',
		    title => "$title" || '',
		    id    => $self->_pack_obj($k),
	};
    }
    return { description => 'KOG homology groups of the protein',
	     data        => \@hg };
    
}

=head3 orthologs

This method returns a data structure containing 
genes orthologs to the current protein.

=over

=item PERL API

 $data = $model->orthologs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/orthologs

B<Response example>

<div class="response-example"></div>

=cut

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



=head3 homology_image

This method returns a data structure containing 
data for generating a schematic showing protein
domains versus exons.

=over

=item PERL API

 $data = $model->homology_image();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE02346/homology_image

B<Response example>

<div class="response-example"></div>

=cut

sub homology_image {
    my $self=shift;
    my $panel=$self->_draw_image($self->object,1);
    my $gd=$panel->gd;
    #show dynamic images
    return { description => 'a dynamically generated image representing homologous regions of the protein',
	     data        => $gd,
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

=head3 motifs

This method returns a data structure containing
motifs and motif homlogies identified in the protein.

=over

=item PERL API

 $data = $model->motifss();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/motifs

B<Response example>

<div class="response-example"></div>

=cut

sub motifs {
    my $self = shift;
    my (%motif);
#     my %hash;
    my @row;
    foreach (@{$self ~~ '@Motif_homol'}) {
      my $title = $_->Title;
      my ($database,$description,$accession) = $_->Database->row if $_->Database;
      $title||=$_;
      push @row,[("$database","$title",{ label=>"$_", id=>"$_", class=>$_->class})];
#       $hash{database}{$_} = $database;
#       $hash{description}{$_} = $title||$_;
#       $hash{accession}{$_} = { label=>$_, id=>$_, class=>$_->class};
    }
    return { description => 'motifs and motif homologies identified in the protein',
	     data        => @row ? \@row : undef };
}	  


=head3 pfam_graph

This method returns a data structure containing the 
coordinates for generating a PFAM domain cartoon.

=over

=item PERL API

 $data = $model->pfam_graph();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/pfam_graph

B<Response example>

<div class="response-example"></div>

=cut

{ # block for pfam graph
my @COLORS = map {"#$_"} qw(2dcf00 ff5353 e469fe ffa500 00ffff 86bcff ff7ff0 f2ff7f 7ff2ff);

sub pfam_graph {
    my $self = shift;
    my $motif_homol = $self ~~ '@Motif_homol';
    my $hash;
    my $length = length($self->peptide);

    for( my $i=0;my $feature=shift @$motif_homol;$i++) {
	    my $score = $feature->right(2);
	    my $start = $feature->right(3);
	    my $stop  = $feature->right(4);
	    my $type = $feature->right ||"";
	    $type  ||= 'Interpro' if $feature =~ /IPR/;

	    # Are the multiple occurences of this feature?
	    my @multiple = $feature->right->right->col;
	    @multiple = map {$_->right} $feature->right->col if(@multiple <= 1);

	    if (@multiple > 1) {
		my @scores = $feature->right->col;
		for( my $count=0; $start=shift @multiple;$count++) {
 		    $score= $scores[$count] if($#scores>=$count && $scores[$count]);
		    my $stop = $start->right;
		   push  @{$hash->{$type}} , {end=>"$stop",start=>"$start",score=>"$score",type=>"$type",feature=>$feature,length=>($stop-$start+1),colour=>$COLORS[$i % @COLORS]};
		}
	    } else {
		    push  @{$hash->{$type}} , {end=>"$stop",start=>"$start",score=>"$score",type=>"$type",feature=>$feature,length=>($stop-$start+1),colour=>$COLORS[$i % @COLORS]};

	    }
    }

    # extract the exons, then map them
    # onto the protein backbone.
    my $gene    = $self->cds->[0];
    my $gffdb = $self->gff_dsn;
    my ($seq_obj) = $gffdb->segment(CDS => $gene);

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
					 start=>$end_holder,
					 end=>$end,
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
					 start=>$obj->{start},
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
		$graph_hash->{text} = ucfirst(substr($desc,0,3));
		$graph_hash->{metadata}->{end} = $obj->{end};
	    }

	    push @{$graph->{$graph_type}} ,$graph_hash;
	}
	$graph->{length}= $length;
	push @{$graph->{markups}} ,@segmented_exons;
	$hash->{$type} = to_json ($graph);
    }

    return {
        description => 'The motif graph of the protein',
        data        => $hash,
    };
}
} # end of block for pfam_graph

=head3 motif_details

This method returns a data structure containing the 
details on motifs identified in the protein.

=over

=item PERL API

 $data = $model->motif_details();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/motif_details

B<Response example>

<div class="response-example"></div>

=cut
    
sub motif_details {
    my $self = shift;
    
    my $raw_features = $self ~~ '@Feature';
    my $motif_homol = $self ~~ '@Motif_homol';
    
    #  return unless $obj->Feature;
    
    # Summary by Motif
    my @tot_positions;
    
    if (@$raw_features > 0 || @$motif_homol > 0) {
	my %positions;
	
	foreach my $feature (@$raw_features) {
	    %positions = map {$_ => $_->right(1)} $feature->col;
	    foreach my $start (sort {$a <=> $b} keys %positions) {			
		my $stop =  $positions{$start};
		push @tot_positions,[ ( "$feature",'','',
					"$start",
					"$stop")
		];
	    }
	}
 	
	# Now deal with the motif_homol features
	foreach my $feature (@$motif_homol) {
	    my $score = $feature->right->col;
	    
	    my $start = $feature->right(3);
	    my $stop  = $feature->right(4);
	    my $type = $feature->right ||"";
	    $type  ||= 'Interpro' if $feature =~ /IPR/;
# 	    (my $label =$feature) =~ s/^[^:]+://;
	    my $label = "$feature";
	    $type = "$type";
	    my $desc = $feature->Title ||$feature ;
	    # Are the multiple occurences of this feature?
	    my @multiple = $feature->right->right->col;
	    @multiple = map {$_->right} $feature->right->col if(@multiple <= 1);
	    if (@multiple > 1) {
		foreach my $start (@multiple) {
		    my $stop = $start->right;
		    push @tot_positions,[  ({label=>$label,id=>$label,class=>$feature->class},$type,"$desc",
					    "$start",
					    "$stop")
		    ];
		}
	    } else {
		push @tot_positions,[  ({label=>$label,id=>$label,class=>$feature->class},$type,"$desc",
					"$start",
					"$stop")
		];
	    }
	}
	
    }
    my $data = { description => 'The motif details of the protein',
		 data        => \@tot_positions,
    }; 
    
}

=head3 blast_details

This method returns a data structure containing the 
details of all precomputed blastp hits of the protein.

=over

=item PERL API

 $data = $model->blast_details();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/blast_details

B<Response example>

<div class="response-example"></div>

=cut

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
      my $species = $self->id2species($h);
      $species  ||= $self->id2species($method);
      
      # Not all proteins are populated with the species 
      $species ||= $h->{hit}->Species;
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
      push @rows,[({label=>"$id",class=>"$class",id=>"$id_link"},$taxonomy,"$description",sprintf("%7.3g",10**-$eval),
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

=head2

=head3 history

This method returns a data structure containing the 
curatorial history of the protein.

=over

=item PERL API

 $data = $model->history();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A protein ID (eg WP:CE33017)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/protein/WP:CE33017/history

B<Response example>

<div class="response-example"></div>

=cut

sub history {
    my $self   = shift;
    my $object = $self->object;

    my @data;    
    foreach my $version ($object->History) {
	my ($event,$prediction)  = $version->row(1);
	push @data, { version    => "$version",
		      event      => "$event",
		      prediction => $self->_pack_obj($prediction), };
    }
    
    return { description => 'curatorial history of the protein',
	     data        =>  @data ? \@data : undef };
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
			  -name=>$obj,
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
  my $gffdb = $self->gff_dsn($self->_parsed_species);
# print $gffdb;
  my ($seq_obj) = $gffdb->dbh->segment(CDS => $gene);

  my (@exons,@segmented_exons);

  # Translate the bp start and stop positions into the approximate amino acid
  # contributions from the different exons.
  my ($count,$end_holder);
  
  if ($seq_obj) {
      @exons = $seq_obj->features('exon:curated');
      @exons = grep { $_->name eq $gene } @exons;
      
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
	  my $seg   = $ftr->new(-start=>$start,-end=>$positions{$start},
				-name=>"$type",-type=>$type);
	  # Create a hash of all the features, keyed by type;
	  push (@{$features{'Features-' . $type}},$seg);
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
  
  my %glyphs = (low_complexity => 'generic',
		transmembrane   => 'generic',
		signal_peptide  => 'generic',
		tmhmm           => 'generic'
      );
  
  my %labels   = ('low_complexity'       => 'Low Complexity',
		  'transmembrane'         => 'Transmembrane Domain(s)',
		  'signal_peptide'        => 'Signal Peptide(s)',
		  'tmhmm'                 => 'Transmembrane Domain(s)',
		  'wublastp_ensembl'      => 'BLASTP Hits on Human ENSEMBL database',
		  'wublastp_fly'          => 'BLASTP Hits on FlyBase database',
		  'wublastp_slimSwissProt'=> 'BLASTP Hits on SwissProt',
		  'wublastp_slimTrEmbl'   => 'BLASTP Hits on Uniprot',
		  'wublastp_worm'         => 'BLASTP Hits on WormPep',
      );
  
  my %colors   = ('low_complexity' => 'blue',
		  'transmembrane'  => 'green',
		  'signalp'        => 'gray',
		  'prosite'        => 'cyan',
		  'seg'            => 'lightgrey',
		  'pfam'           => 'wheat',
		  'motif_homol'    => 'orange',
		  'wublastp_remanei'      => 'blue'
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
#       local $^W = 0; #kill uninit variable warning
	  for my $feature ($best_only ? values %best : @{$features{'BLASTP Homologies'}}) {
	      my $homol = $HIT_CACHE{$feature->name};
	      my $species =  $homol->Species||"";
	      my $description = $species;
	      my $score       = sprintf("%7.3G",10**-$feature->score);
	      $description    =~ s/^(\w)\w* /$1. /;
	      $description   .= " ";
# 	my $desc= $homol->Description} || $homol->Gene_name || "";
	      $description   .= $homol->Description || $homol->Gene_name || "";
	      $description   .=  $homol->Corresponding_CDS->Brief_identification ||""
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
		  }
		  else{
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
			-font2color  => 'red',
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

