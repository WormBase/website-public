package WormBase::API::Object::Sequence;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';

use Bio::Graphics::Browser2::Markup;

=pod 

=head1 NAME

WormBase::API::Object::Sequence

=head1 SYNPOSIS

Model for the Ace ?Sequence class.

=head1 URL

http://wormbase.org/species/sequence

=cut


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

# Role?
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

sub _build_type {
    my ($self) = @_;
    my $s = $self->object;
    # figure out where this sequence comes from
    # should rearrange in order of probability
    my $type;
    if ($s =~ /^cb\d+\.fpc\d+$/) {
		$type = 'C. briggsae draft contig';
    }
	elsif (_is_gap($s)) {
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
	elsif (eval{_is_merged($s)}) {
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

=head2

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub taxonomy {}
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

=head3 sequence_type

This method will return a data structure containing
which type of sequence the requested object is.

=over

=item PERL API

 $data = $model->sequence_type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/sequence_type

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sequence_type {
    my ($self) = @_;
    return {
	description => 'the general type of the sequence',
	data        => $self->type,
    };
}

=head3 identity

This method will return a data structure containing
the brief identity of the requested object.

=over

=item PERL API

 $data = $model->identity();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/identity

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub identity {
    my ($self) = @_;
 
    # Cull a brief identification from each gene. Redundant with gene page and 
    # not necessarily accurate if we are looking at a splice variant.
    my $data = join(', ', @{$self->genes}, $self ~~ 'Brief_identification' || ());
    $data .= ' (pseudogene)' if $data && $self->type eq 'pseudogene';
    
    return { description => 'the identity of the sequence',
	     data        => $data || undef   };
}


# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

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
# The Region (Genomic) widget.
# Sort of redundant with location....
#
############################################################

=head2 Region

=head3 corresponding_gene

This method will return a data structure containing
the corresponding gene of the sequence object.

=over

=item PERL API

 $data = $model->corresponding_gene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/corresponding_gene

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub corresponding_gene {
    my $self   = shift;
    my $object = $self->object;
    my @genes = map { $self->_pack_obj($_) } $object->Gene;
    
    return { description => 'corresponding gene of the sequence, if known',
	     data        => @genes? \@genes : undef };
}

=head3 matching_transcript

This method will return a data structure containing
transcripts that match the current sequence.

=over

=item PERL API

 $data = $model->matching_transcript();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/matching_transcript

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub matching_transcript {
    my $self = shift;
    my $object = $self->object;
    my @transcripts = map { $self->_pack_obj($_) } $object->Matching_transcript // undef;
    return { description => 'matching transcripts of the sequence',
	     data        =>  @transcripts ? \@transcripts : undef };
}

=head3 matching_cds

This method will return a data structure containing
matching CDSs of the sequence.

=over

=item PERL API

 $data = $model->matching_cds();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/matching_cds

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub matching_cds {
    my $self   = shift;
    my $object = $self->object;
    my @cds = eval{ map { $self->_pack_obj($_) } $object->Matching_CDS };
    return { description => 'matching CDSs of the sequence',
	     data        => @cds ? \@cds : undef };
}

=head3 corresponding_protein

This method will return a data structure containing
proteins corresponding to the requested object.

=over

=item PERL API

 $data = $model->corresponding_protein();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/corresponding_protein

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub corresponding_protein {
    my ($self) = @_;
    my @proteins = map { $self->_pack_obj($_) } map { $_->Corresponding_protein } @{$self ~~ '@Matching_CDS'};
    return { description => 'the corresponding protein of the sequence',
	     data        => @proteins ? \@proteins : undef };
}

=head3 matching_cdnas

This method will return a data structure containing
CDNAs that match the requested object.

=over

=item PERL API

 $data = $model->matching_cdnas();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/matching_cdnas

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub matching_cdnas {
    my ($self) = @_;
    my @cDNA = map { $self->_pack_obj($_) } @{$self ~~ '@Matching_cDNA'};
    return { description => 'cDNAs that match the sequence',
	     data        => @cDNA ? \@cDNA : undef,
    };
}

=head3 transcripts

This method will return a data structure containing
transcripts corresponding to the requested object.

=over

=item PERL API

 $data = $model->transcripts();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/transcripts

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transcripts {
    my ($self) = @_;
    
    my @transcripts;
    if (($self ~~ 'Structure' || $self->_method eq 'Vancouver_fosmid') &&
	$self->type =~ /genomic|confirmed gene|predicted coding sequence/) {
	@transcripts = map { $self->_pack_obj($_) } sort {$a cmp $b } map {$_->info}
	map { $_->features('Transcript:Coding_transcript') }
	@{$self->_segments};
    }
    
    return { description => 'Transcripts in this region of the sequence',
	     data        => @transcripts ? \@transcripts : undef, #class Sequence
    };
}


############################################################
#
# The Location Widget
#
############################################################

=head2 Location

=cut

# sub genomic_position { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_position >>

sub _build_genomic_position {
    my ($self) = @_;
    my @positions = $self->_genomic_position($self->_segments);
    return {
        description => 'The genomic location of the sequence',
        data        => @positions ? \@positions : undef,
    };
}

# sub tracks {}
# Supplied by Role; POD will automatically be inserted here.
# << include tracks >>

sub _build_tracks {
    my ($self) = @_;

    return {
        description => 'tracks to display in GBrowse',
        data => $self->_parsed_species =~ /elegans/ ? [qw(NG CG CDS PG PCR SNP TcI MOS CLO)] : undef,
    };
}

# sub genomic_image { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_image >>

# note for AD:
# this one needs some reworking. it currently fetches the first segment
# in $self->segments, recomputes the start & stop, fetches more segments
# if the seq is a CDS or Transcript, and if more than 1 seg, selects the
# first one that matches the start and stop (or just the first one).
# throwing that segment back into genomic_position just wraps it up
sub _build_genomic_image {
    my ($self) = @_;
    my $seq = $self->object;
    return unless(defined $self->_segments && defined $self->_segments->[0] && $self->_segments->[0]->length< 100_0000);

    my $source = $self->_parsed_species;
    my $segment = $self->_segments->[0];

    my $ref   = $segment->ref;
    my $start = $segment->start;
    my $stop  = $segment->stop;

    # add another 10% to left and right
    $start = int($start - 0.05*($stop-$start));
    $stop  = int($stop  + 0.05*($stop-$start));
    my @segments;
    if ($seq->class eq 'CDS' or $seq->class eq 'Transcript') {
        my $gene = eval { $seq->Gene;} || $seq;
        @segments = $self->gff->segment(-class=>'Coding_transcript',-name=>$gene);
        @segments = grep {$_->method eq 'wormbase_cds'} $self->gff->fetch_group(CDS => $seq)
            unless @segments;	# CB discontinuity
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

    my ($position) = $self->_genomic_position([$new_segment || $segment || ()]);
    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $position,
    };
}

# sub genetic_position {}
# Supplied by Role; POD will automatically be inserted here.
# << include genetic_position >>



############################################################
#
# The Origin widget
#
############################################################

=head2 Origin

=cut

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

=head3 available_from

This method will return a data structure containing
available sources for the sequence.

=over

=item PERL API

 $data = $model->available_from();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/available_from

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub available_from {
    my $self   = shift;
    my $object = $self->object;
	
    my $data = $self->_method eq 'Vancouver_fosmid' && {
	label => 'GeneService',
	class => 'Geneservice_fosmids',
    };
    
    return { description => 'availability of clones of the sequence',
	     data        => "$data" || undef };
}

=head3 analysis

This method will return a data structure containing
the source analysis of the sequence.

=over

=item PERL API

 $data = $model->analysis();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/analysis

B<Response example>

<div class="response-example"></div>

=back

=cut 

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
    
    return { description => 'The Analysis info of the sequence',
	     data        => %so_data ? \%so_data : undef  };
}


############################################################
#
# The Reagents Widget
#
############################################################

=head2 Reagents

=head3 orfeome_assays

This method will return a data structure containing
orfeome_assays related to the sequence.

=over

=item PERL API

 $data = $model->orfeome_assays();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/orfeome_assays

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub orfeome_assays {
    my ($self) = @_;
    my (@orfeome,@pcr);
    if ($self->type =~ /gene|coding sequence|cDNA/) {
		@pcr     = map {$_->info} map { $_->features('PCR_product:GenePair_STS',
													 'structural:PCR_product') }
		           @{$self->_segments} if @{$self->_segments};
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


=head3 microarray_assays

This method will return a data structure containing
microarray assays related to the requested object.

=over

=item PERL API

 $data = $model->microarray_assays();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/microarray_assays

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub microarray_assays {
    my ($self) = @_;

	my @microarrays;
	if (($self ~~ 'Structure' || $self->_method eq 'Vancouver_fosmid') &&
		$self->type =~ /genomic|confirmed gene|predicted coding sequence/) {

		@microarrays = map {$self->_pack_obj($_)} sort {$a cmp $b } map {$_->info}
		               map { $_->features('reagent:Oligo_set') } @{$self->_segments};
	}

    return {
		description => 'The Microarray assays in this region of the sequence',
		data        => @microarrays ? \@microarrays : undef,	#class Oligo_set
	};
}



=head3 source_clone

This method will return a data structure containing
the source clone of the sequence.

=over

=item PERL API

 $data = $model->source_clone();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/source_clone

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub source_clone {
    my ($self) = @_;
    my $clone = $self ~~ 'Clone' || $self->sequence ? $self->sequence->Clone : undef;
    return { description => 'The Source clone of the sequence',
	     data        => $clone ? map {$self->_pack_obj($_)} $clone : undef };
}



############################################################
#
# The Sequence Widget
#
############################################################

=head2 Sequence

=head3 print_blast

This method will return a data structure containing
links to blast resources.

=over

=item PERL API

 $data = $model->print_blast();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/print_blast

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub print_blast {
    my ($self) = @_;
    my @target = ('Elegans genome');
    push @target,"Elegans protein" if ($self ~~ 'Coding');
    
    return { description => 'links to BLAST analyses',
	     data        =>  { source => $self ~~ 'name',
			       target => \@target,
	     },
    };
}

=head3 print_sequence

This method will return a data structure containing
the sequence of the sequence. Um, yeah.

=over

=item PERL API

 $data = $model->print_sequence();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/print_sequence

B<Response example>

<div class="response-example"></div>

=back

=cut 

# TODO: REWRITE THIS. This is very gory code. Some of it doesn't do what
#       one would expect due to some Perl details...
sub print_sequence {
    my ($self) = @_;
    my $s = $self->object;
    my %hash;
    my $gff = $self->gff || return;
    my $seq_obj;
    if ($self->_parsed_species =~ /briggsae/) {
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

		($seq_obj) = $seq_obj ? ($seq_obj) : sort {$b->length<=>$a->length}
		# 	grep {$_->method eq 'full_transcript'} $gff->fetch_group(Transcript => "$s.a");
		    grep {$_->method eq 'Transcript'} $gff->fetch_group(Transcript => "$s.a");
		($seq_obj) = $seq_obj ? ($seq_obj) : sort {$b->length<=>$a->length}
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
    return { description => 'the sequence of the sequence',
	     data        => %hash ? \%hash : undef };
}

=head3 print_homologies

This method will return a data structure containing
homologies of the requested object.

=over

=item PERL API

 $data = $model->print_homologies();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/print_homologies

B<Response example>

<div class="response-example"></div>

=back

=cut 

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
    return { description => 'homologous sequences',
	     data        => @rows ? \@rows : undef };
}

=head3 print_feature

This method will return a data structure listing
features contained within the sequence.

=over

=item PERL API

 $data = $model->print_feature();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Sequence ID (eg JC8.10a)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/print_feature

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub print_feature {
    my ($self) = @_;
    my $s = $self->object;
    my %hash;

    # NB: This is not completely functional - it doesn't display cloned, named genes
    # (The pre-WS116 version didn't either).
    # That is, transcripts like JC8.10 are not listed under Transcripts in Ace WS116
    if (my @genes = $s->get('Transcript')) {
# 		print 'Predicted Genes & Transcriptional Units';
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
			($desc)    ||= $class->Remark;
			($desc)    ||= $class->DB_remark;

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
# 		print "Other features";
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
    return { description => 'features contained within the sequence',
	     data        => %hash ? \%hash : undef };
}



############################################################
#
# PRIVATE METHODS
#
############################################################

sub _is_gap {
    return shift =~ /(\b|_)GAP(\b|_)/i;
}

sub _is_merged {
    return shift =~ /LINK|CHROMOSOME/i;
}

sub _build__segments {
	my ($self) = @_;
	my $object = $self->object;
    return [] unless $self->gff;
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
	return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object)];
}




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

__PACKAGE__->meta->make_immutable;

1;

