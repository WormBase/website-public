package WormBase::API::Object::Sequence;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

use Bio::Graphics::Browser2::Markup;
use vars qw($CHROMOSOME_TABLE_LENGTH);
$CHROMOSOME_TABLE_LENGTH = 2_000_000;

has 'type' => (
    is  => 'ro',
    lazy_build => 1,
   );

has 'length' => (
    is  => 'rw',
   );

has 'gff' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		return $self->gff_dsn;
    }
   );

has 'sequence' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		return $self ~~ 'Sequence';
    }
   );

has '_method' => (
    is		=> 'ro',
    lazy	=> 1,
    default => sub {
		my ($self) = @_;
		return $self ~~ 'Method';
    },
   );

has 'genes' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		my %seen;
		return [grep {!$seen{$_}++} @{$self ~~ '@Locus'}];
    },
   );

has 'segments' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		my @seg = $self->_get_segments;
		return \@seg;
    }
   );

has 'pic_segment' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		my $seq = $self->object;
		return unless(defined $self->segments && $self->segments->[0]->length< 100_0000);

		my $source = $self->species;
		my $segment = $self->segments->[0];

		my $ref   = $segment->ref;
		my $start = $segment->start;
		my $stop  = $segment->stop;

		# add another 10% to left and right
		$start = int($start - 0.05*($stop-$start));
		$stop  = int($stop  + 0.05*($stop-$start));
		my @segments;
		if ($seq->class eq 'CDS' or $seq->class eq 'Transcript') {
			my $gene = eval { $seq->Gene;};
			$gene ||= $seq;
			@segments = $self->gff->segment(-class=>'Coding_transcript',-name=>$gene);
			@segments      = grep {$_->method eq 'wormbase_cds'} $self->gff->fetch_group(CDS => $seq) unless @segments;	# CB discontinuity
		}
		# In cases where more than one segment is retrieved
		# (ie with EST or OST mappings)
		# choose that which matches the original segment.
		# This is slightly bizarre but expedient fix.
		my $new_segment;
		if (@segments > 1) {
			foreach (@segments) {
				if ($_->start == $start && $_->stop == $stop) {
					$new_segment = $_;
					last;
				}
			}
		}
		$new_segment ||= $segments[0];
		$new_segment ||= $segment;
		return  $new_segment;
    }
   );


has 'tracks' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
		my ($self) = @_;
		my @type = $self->species =~ /elegans/ ? qw/NG CG CDS PG PCR SNP TcI MOS CLO/:qw//;
		return \@type;
    }
   );

sub _build_type {
    my ($self) = @_;
    my $s = $self->object;
    # figure out where this sequence comes from
    # should rearrange in order of probability
    my $type;
    if ($s =~ /^cb\d+\.fpc\d+$/) {
		$type = 'C. briggsae draft contig';
    }
	elsif (is_gap($s)) {
		$type = 'gap in genomic sequence -- for accounting purposes';
    }
	elsif (eval { $s->Genomic_canonical(0) }) {
		$type = 'genomic';
    }
	elsif ($self->_method eq 'Vancouver_fosmid') {
		$type = 'genomic -- fosmid';
    }
	elsif (eval { $s->Pseudogene(0) }) {
		$type = 'pseudogene';
    }
	elsif (eval { $s->RNA_Pseudogene(0) }) {
		$type = 'RNA_pseudogene';
    }
	elsif (eval { $s->Locus }) {
		$type = 'confirmed gene';
    }
	elsif (eval { $s->Coding }) {
		$type = 'predicted coding sequence';
    }
	elsif ($s->get('cDNA')) {
		($type) = $s->get('cDNA');
    }
	elsif ($self->_method eq 'EST_nematode') {
		$type   = 'non-Elegans nematode EST sequence';
    }
	elsif (eval { $s->AC_number }) {
		$type = 'external sequence';
    }
	elsif (eval{is_merged($s)}) {
		$type = 'merged sequence entry';
    }
	elsif ($self->_method eq 'NDB') {
		$type = 'GenBank/EMBL Entry';
		# This is going to need more robust processing to traverse object structure
    }
	elsif (eval { $s->RNA} ) {
		$type = eval {$s->RNA} . ' ' . eval {$s->RNA->right};
    }
	else {
		$type = eval {$s->Properties(1)};
    }
    $type ||= 'unknown';
    return $type;
}


############################################################
#
# The Overview widget
#
############################################################
=head3 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene ID (gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head5 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

sub description {
    my ($self) = @_;
    return {
		description => 'the description of the sequence, if available',
		data		=> $self ~~ 'Title',
	};
}

sub sequence_type {
	my ($self) = @_;

	return {
		description => 'the general type of the sequence',
		data        => $self->type,
	};
}

sub identity {
	my ($self) = @_;

	my $data = join(', ', @{$self->genes}, $self ~~ 'Brief_identification' || ());
	$data .= ' (pseudogene)' if $data && $self->type eq 'pseudogene';

	return {
		description => 'the identity of the sequence',
		data        => $data || undef,
	};
}

# I think these really only applies to coding sequences
sub status {
	my ($self) = @_;

	my $status = $self ~~ 'Prediction_status';
	return {
		description => 'prediction status (only applicable to coding sequences)',
		data        => $status ? "$status" : undef,
	};
}

sub method {
    my ($self) = @_;

	my $method = $self->_method;
	return {
		description => 'the method used to describe the sequence',
		data        => $method ? "$method" : undef,
    };
}


sub remarks {
    my ($self) = @_;
	my @remarks = map ucfirst, grep defined, map {$self ~~ $_} qw(Remark DB_remark);

	return {
		description => 'The Remarks of the sequence',
		data        => @remarks ? \@remarks : undef,
	};
}



############################################################
#
# Genomic Region / Related sequences
#
############################################################
sub corresponding_gene {
    my ($self) = @_;
	my @genes = map { $self->_pack_obj($_, $_->Public_name) } @{$self ~~ '@Gene'};

	return {
		description => 'Corresponding gene of the sequence, if known',
		data        => @genes? \@genes : undef,
	};
}

sub matching_transcript {
	my ($self) = @_;

    return {
		description => 'The matching transcript of the sequence',
		data        =>  $self ~~ 'Matching_transcript',
	};
}

sub matching_cds {
	my ($self) = @_;

    return {
		description => 'The matching CDS of the sequence',
		data        => $self ~~ 'Matching_CDS',
	};
}

sub corresponding_protein {
    my ($self) = @_;
	my @proteins = map { $self->_pack_obj($_) } map { $_->Corresponding_protein }
	                                            @{$self ~~ '@Matching_CDS'};
    return {
		description => 'the corresponding protein of the sequence',
		data        => @proteins ? \@proteins : undef,
	};
}

sub matching_cdnas {
    my ($self) = @_;
	my @cDNA = map { $self->_pack_obj($_) } @{$self ~~ '@Matching_cDNA'};

    return {
		description => 'cDNAs that match the sequence',
		data        => @cDNA ? \@cDNA : undef,
	};
}


# Eh?
sub transcripts {
    my ($self) = @_;

	my @transcripts;
	if (($self ~~ 'Structure' || $self->_method eq 'Vancouver_fosmid') &&
		$self->type =~ /genomic|confirmed gene|predicted coding sequence/) {
		@transcripts = map { $self->_pack_obj($_) } sort {$a cmp $b } map {$_->info}
					   map { $_->features('Transcript:Coding_transcript') }
					   @{$self->segments};
	}

    return {
		description => 'Transcripts in this region of the sequence',
		data        => @transcripts ? \@transcripts : undef, #class Sequence
	};
}

############################################################
#
# The Origin widget (origin, location, etc)
#
############################################################
sub origin {
	my ($self) = @_;
	my $origin = $self ~~ 'From_Laboratory';
	my $data = $origin && $self->_pack_obj($origin, $origin->Mail);

    return {
		description => 'The origin of the sequence',
		data        => $data || undef,
    };
}

sub available_from { # looks like the returned data should be part of the template...
	my ($self) = @_;

	my $data = $self->_method eq 'Vancouver_fosmid' && {
		label => 'GeneService',
		class => 'Geneservice_fosmids',
	};

	return {
		description => 'The Vancouver_fosmid source of the sequence',
	    data => $data || undef,
	};
}

sub orfeome_assays {
    my ($self) = @_;
    my (@orfeome,@pcr);
    if ($self->type =~ /gene|coding sequence|cDNA/) {
		@pcr     = map {$_->info} map { $_->features('PCR_product:GenePair_STS',
													 'structural:PCR_product') }
		           @{$self->segments} if @{$self->segments};
		@orfeome = grep {/^mv_/} @pcr;
    }

    my %data;
    foreach my $id (@orfeome) {
		$data{id}    = $id;
		$data{label} = $id. " (".($id->Amplified(1) ? "PCR assay amplified"
								  : font({-color=>'red'},"PCR assay did NOT amplify")).")";
		$data{class} ='pcr';
    }

	return {
		description => 'The ORFeome Assays of the sequence',
		data        => %data ? \%data : undef,
	};
}

sub source_clone {
    my ($self) = @_;
    my $clone = $self ~~ 'Clone' || $self->sequence->Clone;
    return {
		description => 'The Source clone of the sequence',
		data        => $clone ? $clone->name : undef,
	};
}

sub genomic_position {
    my ($self) = @_;

	if ($self ~~ 'Structure' || self->_method eq 'Vancouver_fosmid') {
		# the following description relies on SUPER::genomic_position.
		# perhaps the above check is unnecessary or the description
		# can be pulled from SUPER?
		return {
			description => 'The Genomic Location of the sequence',
			data		=> undef,
		};
	}
    return $self->SUPER::genomic_position;
}

sub genetic_position {
    my ($self) = @_;

	my %data;
	if ($self ~~ 'Structure' || $self->_method eq 'Vancouver_fosmid') {
		my ($chrom,$pos) = $self->GetInterpolatedPosition($self->object);
		if ($chrom && $pos) {
			$pos = "$chrom:$pos";
			%data = (
				class => $chrom->class, #should be Map?
				label => $pos,
				id	  => "$chrom",
			   );
		}
	}

	return {
		description => 'The Interpolated Genetic Position of the sequence',
		data		=> %data ? \%data : undef,
	};
}



sub microarray_assays {
    my ($self) = @_;

	my @microarrays;
	if (($self ~~ 'Structure' || $self->_method eq 'Vancouver_fosmid') &&
		$self->type =~ /genomic|confirmed gene|predicted coding sequence/) {

		@microarrays = map {$self->_pack_obj($_)} sort {$a cmp $b } map {$_->info}
		               map { $_->features('reagent:Oligo_set') } @{$self->segments};
	}

    return {
		description => 'The Microarray assays in this region of the sequence',
		data        => @microarrays ? \@microarrays : undef,	#class Oligo_set
	};
}

sub transgene_constructs {
    my ($self) = @_;
    my %seen;
    my @transgenes = map {$self->_pack_obj($_)} grep {!$seen{$_}++}
	                     ($self ~~ 'Drives_Transgene',  $self ~~ 'Transgene_product');
    return {
		description => 'The Transgene constructs of the sequence',
		data        => @transgenes ? \@transgenes : undef,
	};
}

############################################################
#
# The Details widget
#
############################################################

=pod
sub genomic_picture {
    my ($self) = @_;
    my $seq = $self->object;
    return unless(defined $self->segments && $self->segments->[0]->length< 100_0000);

    my $source = $self->species;
    my $segment = $self->segments->[0];

    my $ref   = $segment->ref;
    my $start = $segment->start;
    my $stop  = $segment->stop;

    # add another 10% to left and right
    $start = int($start - 0.05*($stop-$start));
    $stop  = int($stop  + 0.05*($stop-$start));
    my @segments;
    if ($seq->class eq 'CDS' or $seq->class eq 'Transcript') {
	my $gene = eval { $seq->Gene;};
	$gene ||= $seq;
	@segments = $self->gff->segment(-class=>'Coding_transcript',-name=>$gene);
	@segments      = grep {$_->method eq 'wormbase_cds'} $self->gff->fetch_group(CDS => $seq) unless @segments;  # CB discontinuity
    }
    # In cases where more than one segment is retrieved
    # (ie with EST or OST mappings)
    # choose that which matches the original segment.
    # This is slightly bizarre but expedient fix.
    my $new_segment;
    if (@segments > 1) {
    foreach (@segments) {

	if ($_->start == $start && $_->stop == $stop) {
	  $new_segment = $_;
	  last;
	}
      }
    }
    $new_segment ||= $segments[0];
    $new_segment ||= $segment;
    return unless $new_segment;

    my $type = $source =~ /elegans/ ? "t=NG;t=CG;t=CDS;t=PG;t=PCR;t=SNP;t=TcI;t=MOS;t=CLO":"";
    my $position = (defined $start)?"$ref:$start..$stop":$ref;

    my $link_gb=$self->parsed_species."?name=$position;$type;width=700";
    my $id="name=$position;source=".$self->parsed_species;
    my $data = { description => 'The Inline Image of the sequence',
		 data        => {  class => 'genomic_location',
				   label => $link_gb,
				   id	=> $id,
				},
    };

    return $data;
}
=cut

sub external_links {
    my ($self) = @_;
    my $s = $self->object;

    my $ac_number = find_ac($s,'NDB');
    my $ac_protein = eval { $s->Protein_id(2);};
    my $swissprot = find_swissprot($s);
    my $wormpd_id = find_wormpd($s);
    my $uniprot    = find_ac($s,'UniProt');
    my %ac_hash = %$uniprot;

    my %hash;
    if ( keys(%{$ac_number}) > 0 ) {
		$hash{'GenBank/EMBL'}{label}=$ac_number->{GI_number};
		$hash{'GenBank/EMBL'}{id}=$ac_number->{GI_number};
		$hash{'GenBank/EMBL'}{class}='Entrez';

    }
	else {
		$ac_number = find_ac($s, 'EMBL');
		$ac_number = find_ac($s, 'GenBank') if( keys(%{$ac_number}) == 0 );

		# Get the longtext for the DB. Should probably include the URL constructor too, oh well.
		my ($source,@rest) = $s->DB_annotation if $s->class eq 'Sequence';
		my $details;
		if ($source) {
			my ($text)  = $source->col if ($source);
			$details = { label=>'',
						 class=>$text->class,
						 id=>$text->name,
					 };
		}

		if ( keys(%{$ac_number}) > 0 ) {
			$hash{'GenBank/EMBL'}{label}=$ac_number->{NDB_AC};
			$hash{'GenBank/EMBL'}{id}=$ac_number->{NDB_AC};
			$hash{'GenBank/EMBL'}{class}='Entrez';
			$hash{'GenBank/EMBL'}{detail}=$details;
		}
    }

    if ($ac_protein) {
		$hash{'GenPep'}{label}=$ac_protein;
		$hash{'GenPep'}{id}=$ac_protein;
		$hash{'GenPep'}{class}='Entrezp';
    }
    if (defined $uniprot->{UniProtAcc}) {
		$hash{'Uniprot Accession number'}{label}=$uniprot->{UniProtAcc};
		$hash{'Uniprot Accession number'}{id}=$uniprot->{UniProtAcc};
		$hash{'Uniprot Accession number'}{class}='Trembl';
    }
    if (eval { $s->Coding(0) }) {
		$hash{'Intronerator'}{label}=$s;
		$hash{'Intronerator'}{id}=$s;
		$hash{'Intronerator'}{class}='Intronerator';
    }

    if ($swissprot) {
		$hash{'SwissProt/TrEMBL'}{label}=$swissprot;
		$hash{'SwissProt/TrEMBL'}{id}=$swissprot;
		$hash{'SwissProt/TrEMBL'}{class}='Uniprot';
    }
    if ($self->type eq 'predicted coding sequence' or $self->type eq 'confirmed gene') {
		$hash{'Eugenes'}{label}="ACEPRED:$s";
		$hash{'Eugenes'}{id}=$s;
		$hash{'Eugenes'}{class}='Meow_predicted';

		$hash{'NextDB'}{label}=$s;
		$hash{'NextDB'}{id}=$s;
		$hash{'NextDB'}{class}='Nextdb';
    }
    if ($s =~ /^OST/) {
		$hash{'ORFeome Project'}{label}="WORFDB: $s";
		$hash{'ORFeome Project'}{id}=$s;
		$hash{'ORFeome Project'}{class}='Orfeome';
    }
	if ($wormpd_id) {
		$hash{'WormPD (fee required)'}{label}=$wormpd_id;
		$hash{'WormPD (fee required)'}{id}="$wormpd_id.html";
		$hash{'WormPD (fee required)'}{class}='Proteome';
    }

    # RSTs. Yuck.
    if ($s =~ /^RST/) {
		$hash{'RACE project page at WORFDB'}{label}=$s;
		$hash{'RACE project page at WORFDB'}{id}="";
		$hash{'RACE project page at WORFDB'}{class}='WORFDB';
    }

    my $parent = $self->sequence;
    my $clone = eval { $s->Clone };
    $clone ||= eval { $parent->Clone } if $parent;

    if ($clone && $s->From_laboratory eq 'YK') {
		$clone =~ s/YK//i;		# Strip the YK from the ID
        $hash{'NextDB EXPRESSION'}{label}=$clone;
		$hash{'NextDB EXPRESSION'}{id}=$clone;
		$hash{'NextDB EXPRESSION'}{class}='Nextdb_EXPRESSION';
    }

    return {
		description => 'The External Links of the sequence',
		data        => %hash ? \%hash : undef,
	};
}

### to be written...... ####
#sub print_long_description {
#
#}


############## this is deprecated? ################
# TH 2010.08.01: No, just not widly supported
sub analysis {
    my ($self) = @_;

	my %so_data;
	if (my $analysis = $self ~~ 'Analysis') {
		$so_data{'Object'} = $analysis;
		$so_data{'Description'} = $analysis->Description;
		$so_data{'DB Info'} = $analysis->DB_info;
		$so_data{'WB Release'} = $analysis->Based_on_WB_Release;
		$so_data{'DB Release'} = $analysis->Based_on_DB_Release;
		$so_data{'Sample'} = $analysis->Sample;
		$so_data{'Paper'} = $analysis->Reference;
		$so_data{'Conducted y'} = $analysis->Conducted_by;
		$so_data{'Url'} = $analysis->URL;
	}

    return {
		description => 'The Analysis info of the sequence',
		data        => %so_data ? \%so_data : undef,
	};
}
############################################################
#
# The Sequence widget
#
############################################################

## returns 1 ??
sub print_link_parts {
    my ($self) = @_;

    return {
		description => 'The Analysis info of the sequence',
		data        =>  1,
	};
}

sub print_blast {
    my ($self) = @_;
    my @target = ('Elegans genome');
    push @target,"Elegans protein" if ($self ~~ 'Coding');

	return {
		description => 'The Analysis info of the sequence',
		data        =>  {
			source => $self ~~ 'name',
			target => \@target,
		},
	};
}

# TODO: REWRITE THIS. This is very gory code. Some of it doesn't do what
#       one would expect due to some Perl details...
sub print_sequence {
    my ($self) = @_;
    my $s = $self->object;
    my %hash;
    my $gff = $self->gff;
    my $seq_obj;
    if ($self->species =~ /briggsae/) {
		($seq_obj) = sort {$b->length<=>$a->length}
		$self->type =~ /^(genomic|confirmed gene|predicted coding sequence)$/i
		? grep {$_->method eq 'wormbase_cds'} $gff->fetch_group(Transcript => $s),
	    : '';
    }
	else {
		($seq_obj) = sort {$b->length<=>$a->length}
		# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => $s);
		grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => $s);
		# BLECH!  If provided with a gene ID and alt splices are present just guess
		# and fetch the first CDS or Transcript
		# We really should display a list for all of these.

		# NOTE: THE FOLLOWING DOES NOT DO WHAT YOU EXPECT IT TO.
		($seq_obj) ||= sort {$b->length<=>$a->length}
		# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => "$s.a");
		grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => "$s.a");
		($seq_obj) ||= sort {$b->length<=>$a->length}
		# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => "$s.1");
		grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => "$s.1");
    }

    ($seq_obj) ||= $gff->fetch_group(Pseudogene => $s);
    # Haven't fetched a GFF segment? Try Ace.
    if (!$seq_obj || length($seq_obj->dna) < 2) { # miserable broken workaround
		# try to use acedb
		if (my $fasta = $s->asDNA) {
			$hash{dna} = { 	header=>"FASTA Sequence",
							content=>"$fasta\n"
						   };	##$fasta;

			$self->length(length $fasta);
		}
		else {
			$hash{dna} =  "<p>Sequence unavailable.  If this is a cDNA, try searching for $s.5 or $s.3</p>";
		}
		goto END;
    }

	#     print_genomic_position($s,$type);

    $hash{est} = "name=$s;class=CDS";


    if (eval { $s->Properties eq 'cDNA'} ) {
		# try to use acedb
		if (my $fasta = $s->asDNA) {
			$hash{dna}  = $fasta;
		}
		goto END;
    }

    my $unspliced = lc $seq_obj->dna;
    my $length = length($unspliced);
    if (eval { $s->Coding_pseudogene } || eval {$s->Coding} || eval {$s->Corresponding_CDS}) {
		my $markup = Bio::Graphics::Browser2::Markup->new;
		$markup->add_style('utr'  => 'FGCOLOR gray');
		$markup->add_style('cds'  => 'BGCOLOR cyan');
		$markup->add_style('cds0' => 'BGCOLOR yellow');
		$markup->add_style('cds1' => 'BGCOLOR orange');
		$markup->add_style('uc'   => 'UPPERCASE');
		$markup->add_style('newline' => "\n");
		$markup->add_style('space'   => ' ');
		my %seenit;

		my @features;
		if ($s->Species =~ /briggsae/) {
			$seq_obj->ref($seq_obj); # local coordinates
			@features = sort {$a->start <=> $b->start}
			grep { $_->info eq $s && !$seenit{$_->start}++ }
			$seq_obj->features('coding_exon:curated','UTR');
		}
		else {
			$seq_obj->ref($seq_obj); # local coordinates
			# Is the genefinder specific formatting cruft?
			@features =
			sort {$a->start <=> $b->start}
			grep { $_->info eq $s && !$seenit{$_->start}++ }
			($s->Method eq 'Genefinder') ?
			$seq_obj->features('coding_exon:' . $s->Method,'five_prime_UTR','three_prime_UTR')
			:
		    $seq_obj->features(qw/five_prime_UTR:Coding_transcript exon:Pseudogene coding_exon:Coding_transcript three_prime_UTR:Coding_transcript/);
		}
		$hash{unspliced} = _print_unspliced($markup,$seq_obj,$unspliced,@features);
		$hash{spliced} = _print_spliced($markup,@features);
		$hash{protein} = _print_protein($markup,\@features) unless eval { $s->Coding_pseudogene };
    }
	else {
		# Otherwise we've got genomic DNA here
		$hash{dna} =  _to_fasta($s,$unspliced);
    }
    $self->length($length);

  END:
    my $data = { description => 'The Analysis info of the sequence',
				 data        => \%hash,
			 };
    return $data;
}




sub print_homologies {
    my ($self) = @_;
    my $seq = $self->object;

    # Restructuring into the ?CDS class partially kills this query
    # Transcripts are not sequence features any more...
    my $gff = $self->ace_dsn->raw_query("gif seqget $seq -coords 1 ".$self->length." ; seqfeatures")
	if $self->length > 0;
    return unless $gff;

    my ($origin,$extent,%HITS);
    foreach (split("\n",$gff)) {
		next if m!^//!;			# ignore comments
		next if m!^\0!;			# ignore ACEDB noise/grunge
		if (/^\#\#sequence-region \S+ (\d+) (\d+)/) {
			($origin,$extent) = ($1,$2);
			next;
		}
		next if /^\#/;
		my ($junk,$description,$type,@data) = split("\t"); # parse
		# This might be broken with WS121 restructuring
		next unless $type eq 'similarity';
		push @{$HITS{$description}},\@data;
    }

    my (%hit_objs);
    my ($dnas,$proteins);		# jalview flags
    my @rows;
    for my $type (sort keys %HITS) {
		my $label = $type=~ /hmmfs/ ? 'Motif' : $type;
		# without stepping through whole array, figure out whether
		# we have any protein or DNA alignments to display.
		my ($class) = $HITS{$type}->[0]->[$#{$HITS{$type}->[0]}] =~ /^([^:]+)/;
		$dnas++      if $class eq 'Sequence';
		$proteins++  if $class eq 'Protein';

		for my $hit (sort {$a->[0] <=> $b->[0] } @{$HITS{$type}}) {
			my ($s_start,$s_end,$score,$strand,$frame,$packed_stuff) = @$hit;
			my (undef,$xref,$t_start,$t_end) = split(/\s+/,$packed_stuff);

			# obscure feature in gff 1a format: the name of the hit
			# is preceded by the name of the class and a colon
			my $class;
			($class,$xref) = $xref =~ /"([^:]+):(.+)"/;
			$class ||= 'Homol';
			$s_start -= ($origin - 1);
			$s_end   -= ($origin - 1);

			my ($title);
			my $obj = $hit_objs{"$class:$xref"} ||= $self->ace_dsn->fetch(-class=>$class,-name=>$xref,-fill=>1);
			if (ref($obj)) {
				$title = $obj->get(Title=>1) ||
				$obj->get(DB_remark=>1) ||
				$obj->get(Remark=>1);
			}

			$title ||= 'Genomic' if $type =~ /brig/i;
			$title ||= 'EST'     if $type =~ /EST/;
			$title ||= 'Genomic' if $type =~ /cosmid/i;
			$title ||= 'Protein' if $type =~ /blastx/i;
			$title ||= '&nbsp;';

			push @rows, {	method => $label,
							similarity => ref($obj) ?  {label => $obj, id=>$obj, class=>$obj->class}: $obj,
							type => $title,
							score => $score,
							genomic_region => "$s_start&nbsp;-&nbsp;$s_end",
							hit_region => "$t_start&nbsp;-&nbsp;$t_end",
							strand => $strand,
							frame => $frame,
						};


		}
    }
    my $data = { description => 'The Homology info of the sequence',
				 data        => \@rows,
			 };
    return $data;

}



sub print_feature {
    my ($self) = @_;
    my $s = $self->object;
    my %hash;

    # NB: This is not completely functional - it doesn't display cloned, named genes
    # (The pre-WS116 version didn't either).
    # That is, transcripts like JC8.10 are not listed under Transcripts in Ace WS116
    if (my @genes = $s->get('Transcript')) {
		print h3('Predicted Genes & Transcriptional Units');
		my %data = map {$_=>$_} $s->follow(-tag=>'Transcript',-filled=>1);
		my @rows;
		foreach (sort {$a->right <=> $b->right} @genes) {
			my $gene = $data{$_};
			# 	my $href = a({ -href=>Object2URL($gene) },$gene);
			next unless defined $gene;
			my $CDS    = $gene->Corresponding_CDS;

			# Fetch the information from the CDS if it exists, else from the transcript
			my $class = ($CDS) ? $CDS : $gene;
			my $locus  = eval { $class->Locus };
			my ($desc) = $class->Brief_identification;
			($desc)    ||= $class->Remark ;
			($desc)    ||= $class->DB_remark ;

			# this sounds like important information - why is it undef'd?
			#  undef $desc if $desc =~ /possible trans-splice site at \d+/;
			$desc ||= '&nbsp;';
			my ($start,$end)=$_->right->row;
			push @rows, {	start=>$start,
							end=>$end,
							name=>{	label => $gene, id=>$gene, class=>$gene->class},
							gene=>$locus ? {label => $locus, id=>$locus, class=>$locus->class} : '-',
							predicted_type=>=> $gene || '?',
							comment=>$desc,
						};
		}
		$hash{predicted_units}{rows}=\@rows;
    }

    if (my @exons = $s->get('Source_Exons')) {
		my ($start,$orientation,$parent) = $self->_get_parent_coords($s);

		# This is just 1 or -1. Should have better formatting.
		#    print p("orientation is $orientation");
		my $index = 1;
		my $last;
		my @rows;
		foreach (@exons) {
			my ($es,$ee) = $_->row;
			my $as = $orientation >= 0 ? $start+$es-1 : $start-$es+1;
			my $ae = $orientation >= 0 ? $start+$ee-1 : $start-$ee+1;
			my $last = $ee;

			push @rows, {	no=>$index++,
							start=>$es,
							end=>$ee,
							ref_start=>$as,
							ref_end=>=> $ae,
						};
		}
		$hash{exons}={ rows=>\@rows, parent=>$parent, orientation=>$orientation};
    }


    my @feature = $s->get('Feature');
    if (@feature) {
		print h3("Other features");
		my @rows;
		for my $f (@feature) {
			(my $label = $f) =~ s/(inverted|tandem)/$1 repeat/;
			for my $i ($f->col) {
				my @fields = $i->row;
				push @rows, {
					start=>$fields[0],
					end=>$fields[1],
					score=>$fields[2],
					comment=>=> $fields[3],
				};
			}
			$hash{features}={ rows=>\@rows, label =>$label};
		}

    }
    my $data = { description => 'The Feature info of the sequence',
				 data        => \%hash,
			 };
    return $data;
}

############################################################
#
# The Map position widget
#
############################################################

############################################################
#
# The Similarities widget
#
############################################################


############################################################
#
# PRIVATE METHODS
#
############################################################

sub is_gap {
    return shift =~ /(\b|_)GAP(\b|_)/i;
}

sub is_merged {
    return shift =~ /LINK|CHROMOSOME/i;
}

sub _get_segments {
	my ($self) = @_;
	my $object = $self->object;
	# special case: return the union of 3' and 5' EST if possible
	if ($self->type =~ /EST/) {
		if ($object =~ /(.+)\.[35]$/) {
			my $base = $1;
			my ($seg_start) = $self->gff->segment(Sequence => "$base.3");
			my ($seg_stop)  = $self->gff->segment(Sequence => "$base.5");
			if ($seg_start && $seg_stop) {
				my $union = $seg_start->union($seg_stop);
				return $union if $union;
			}
		}
	}
	return  map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object);
}

sub find_ac {
	my ($s,$node) = @_;
	my %ids;
	my @dbs = $s->Database;
	foreach (@dbs) {
		if ($_ eq $node) {
			foreach my $col ($_->col) {
				$ids{$col} = $col->right;
			}
		}
	}
	return (\%ids);
}

sub find_swissprot {
    my $s = shift;
    my @dbs = $s->Database;
    foreach (@dbs) {
		next unless $_ eq 'TREMBL' or $_ eq 'SwissProt';
		if ($_ eq 'SwissProt') {
			my @ids = $_->col;
			foreach (@ids) {
				return $_->right if ($_ eq 'SwissProt_AC');
			}
		}
		return $_->right(2);
    }

    # If there wasn't a TREMBL or SWISSPROT entry associated with
    # the main sequence, try to get it from an associated protein

    # Can I get rid of this?
    # follow the tags to the swissprot entry
    my %protein_dbs = map {$_ => $_->right(2)} eval { $s->Corresponding_protein('Database') };
    return unless $protein_dbs{'SwissProt'};
    (my $swissprot = $protein_dbs{'SwissProt'}) =~ s/\W//g;
    return $swissprot;
}

sub find_wormpd {
	my $s = shift;
	return unless eval { $s->Coding };
	my @genes = eval { $s->Locus };
	return $genes[0] if @genes; # oh well
	return $s;
}

=pod already displayed genomic location(s) in the overview widgets... is this redundent?
sub print_genomic_position {
  my ($self) = @_;
  my $s = $self->object;
  my ($begin,$end,$reference) = $self->find_position($s);
  my $ref = $reference;
  my %hash ;
#   my $positions = $self->find_position($self->object);
  my @array;
  if ($begin) {
    foreach (@$positions) {
      my ($begin,$end,$reference) = @$_;
      my $ref = $reference;

	my $subscript = ('a'..'z')[$begin/$CHROMOSOME_TABLE_LENGTH];
	(my $anchor = $s) =~ s/\..*$//;
	my $href = "$reference$subscript.html#$anchor";

      my %entry;
      $entry{chrom}{class} = 'Chromosome_tables';
      $entry{chrom}{id} = $href;
      $entry{chrom}{label} = $reference;

      $entry{browse}{class} = 'genomic_location';
      $entry{browse}{id} = "?name=$s";
      $entry{browse}{label} = '[Search for this Sequence on Genome]';
      print li("$ref: $begin-$end. ",
	       a({-href=>hunter_url($reference,$begin,$end)},' [Browse map] '),
	       eval { $s->Coding } ?
	       a({-href=>Url('aligner',"name=$s;class=CDS"),-target=>"_blank"},' [View EST alignments]')
	       : ''
	      );
      push @array,$entry;
    }
  } else {
    my %entry;
    $entry{browse}{class} = 'genomic_location';
    $entry{browse}{id} = "?name=$s";
    $entry{browse}{label} = '[Search for this Sequence on Genome]';
    push @array,$entry;

  }
  $hash{content} = \@array;
  return \%hash;
}
=cut

sub _print_unspliced {
	my ($markup,$seq_obj,$unspliced,@features) = @_;
	my $name = $seq_obj->info . ' (' . $seq_obj->start . '-' . $seq_obj->stop . ')';

	my $length   = length $unspliced;
	if ($length > 0) {
		# mark up the feature locations

		my @markup;
		my $offset = $seq_obj->start;
		my $counter = 0;
		for my $feature (@features) {
			my $start    = $feature->start - $offset;
			my $length   = $feature->length;
			my $style = $feature->method eq 'CDS'  ? 'cds'.$counter++%2
			: $feature->method =~ /exon/ ? 'cds'.$counter++%2
			: $feature->method =~ 'UTR' ? 'utr' : '';
			push @markup,[$style,$start,$start+$length];
			push @markup,['uc',$start,$start+$length] unless $style eq 'utr';
		}
		push @markup,map {['space',10*$_]}   (1..length($unspliced)/10);
		push @markup,map {['newline',80*$_]} (1..length($unspliced)/80);
		my $download = _to_fasta("$name|unspliced + UTR - $length bp",$unspliced);
		$markup->markup(\$unspliced,\@markup);
		return {
			#download => $download,
			header=>"unspliced + UTR - $length bp",
			content=>">$name (unspliced + UTR - $length bp)\n".$unspliced,
		};
	}
}

# Fetch and markup the spliced DNA
# markup alternative exons
sub _print_spliced {
	my ($markup,@features) = @_;
	my $spliced = join('',map {$_->dna} @features);
	my $splen   = length $spliced;
	my $last    = 0;
	my $counter = 0;
	my @markup  = ();
	my $prefasta = $spliced;
	for my $feature (@features) {
		my $length = $feature->stop - $feature->start + 1;
		my $style  = $feature->method =~ /UTR/i ? 'utr' : 'cds' . $counter++ %2;
		my $end = $last + $length;
		push @markup,[$style,$last,$end];
		push @markup,['uc',$last,$end] if $feature->method =~ /exon/;
		$last += $length;
	}

	push @markup,map {['space',10*$_]}   (1..length($spliced)/10);
	push @markup,map {['newline',80*$_]} (1..length($spliced)/80);
	my $name = eval { $features[0]->refseq->name } ;
	my $download=_to_fasta("$name|spliced + UTR - $splen bp",$spliced);
	$markup->markup(\$spliced,\@markup);

	return {					# download => $download ,
		header=>"spliced + UTR - $splen bp",
		content=>">$name (spliced + UTR - $splen bp)\n".$spliced,
	} if $name;

}

sub _print_protein {
	my ($markup,$features,$genetic_code) = @_;
	my @markup;
	my $trimmed = join('',map {$_->dna} grep {$_->method eq 'coding_exon'} @$features);
	return unless $trimmed;		# Hack for mRNA
	my $peptide = Bio::Seq->new(-seq=>$trimmed)->translate->seq;
	my $change  = $peptide =~/\w+\*$/ ? 1 : 0;
	my $plen = length($peptide) - $change;

	@markup = map {['space',10*$_]}      (1..length($peptide)/10);
	push @markup,map {['newline',80*$_]} (1..length($peptide)/80);
	my $name = eval { $features->[0]->refseq->name };
	my $download=_to_fasta("$name|conceptual translation - $plen aa",$peptide);
	$markup->markup(\$peptide,\@markup);
	$peptide =~ s/^\s+//;

	return {					# download => $download,
		header=>"conceptual translation - $plen aa",
		content=>">$name (conceptual translation - $plen aa)\n".$peptide,
	};
}

##use this or template to format sequence?

sub _to_fasta {
    my ($name,$dna) = @_;
    $dna ||= '';
    my @markup;
    for (my $i=0; $i < length $dna; $i += 10) {
		push (@markup,[$i,$i % 80 ? ' ':"\n"]);
    }
    _markup(\$dna,\@markup);
    $dna =~ s/^\s+//;
    $dna =~ s/\*$//;
    return  { 	header=>"Genomic Sequence",
	     		content=>"&gt;$name\n$dna"
			   };
}

# insert HTML tags into a string without disturbing order
sub _markup {
	my $string = shift;
	my $markups = shift;
	for my $m (sort {$b->[0]<=>$a->[0]} @$markups) { #insert later tags first so position remains correct
		my ($position,$markup) = @$m;
		next unless $position <= length $$string;
		substr($$string,$position,0) = $markup;
	}
}
# get coordinates of parent for exons etc
sub _get_parent_coords {
	my ($self,$s) = @_;
	my ($parent) = $self->sequence;
	return unless $parent;
	#  my $subseq = $parent->get('Subsequence');  # prevent automatic dereferencing

	# Escape the sequence name for fetching
	$s =~ s/\./\\./g;
	# We may be dealing with transcripts, too.
	my $se;
	foreach my $tag (qw/CDS_child Transcript/) {
		my $subseq = $parent->get($tag); # prevent automatic dereferencing
		if ($subseq) {
			$se = $subseq->at($s);
			if ($se) {
				my ($start,$stop) = $se->right->row;
				my $orientation = $start <=> $stop;
				return ($start,-$orientation,$parent);
			}
		}
	}
	return;
}

1;
