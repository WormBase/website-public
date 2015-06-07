package WormBase::API::Role::Sequence;
use Bio::DB::SeqFeature::Segment;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################

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

has 'genes' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        my %seen;
        return [grep {!$seen{$_}++} @{$self ~~ '@Locus'}];
    },
   );

has '_method' => (
    is		=> 'ro',
    lazy	=> 1,
    default => sub {
		my ($self) = @_;
		return eval { $self ~~ 'Method' };
    },
    );

has '_seq_obj' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_seq_obj',
);

has 'is_coding' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        my $s = $self->object;
        my $coding = eval { $s->Coding_pseudogene } || eval {$s->Coding} || eval {$s->Corresponding_CDS};
        return $coding;
    },
);

has '_cds_and_utr' => (
    is => 'ro',
    lazy => 1,
    builder => '_build_cds_and_utr',
);

#######################################################
#
# Generic methods, shared across Sequence, CDS, and Transcript classes.
#
#######################################################

##Overview Widget

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

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/sequence_type

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

sub library {
    my ($self) = @_;
    my $library = $self ~~ 'Library';
    return {
    description => 'Library for the sequence',
    data        => $library ? { name => "$library",
                               description => $library->Description,
                                vector => $self->_pack_obj($library->Vector)  } : undef,
    };
}

sub subsequence {
    my ($self) = @_;
    my $object = $self->object;
    my @subsequence = map { $self->_pack_obj($_) } $object->Subsequence;
    return {
    description => 'end sequence reads used for initially placing the Fosmid on the genome ',
    data        => (@subsequence > 0) ? \@subsequence : undef,
    };
}

sub paired_read {
    my ($self) = @_;
    my $pr = $self ~~ 'Paired_read';
    return {
    description => 'paired read of the sequence',
    data        => $pr ? $self->_pack_obj($pr) : undef,
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

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/identity

B<Response example>

<div class="response-example"></div>

=back

=cut

sub identity {
    my ($self) = @_;
    my $description = $self->object->get('Brief_identification')
        && $self->object->Brief_identification;
    my $evidence = $self->_get_evidence($description);

    $description = $description || join(', ', @{$self->genes});
    $description .= ' (pseudogene)' if $description && $self->type eq 'pseudogene';

    return {
      description => 'Brief description of the ' . $self->type,
      data        => $description ? $evidence? { text => "$description", evidence => $evidence } : "$description" : undef
    };
}

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

a class and an object ID.

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transcript/JC8.10a/available_from

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

a class and an object ID.

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
    my $analysis = $self ~~ 'Analysis';

    return {
	description=> 'The Analysis info of the sequence',
	data => $self->_pack_obj($analysis),
    };
}

=head3 corresponding_all

This method will return a data structure containing
the corresponding objects (transcripts, cds, protein).

=over

=item PERL API

 $data = $model->corresponding_all();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/[CLASS]/[OBJECT]/corresponding_all

B<Response example>

<div class="response-example"></div>

=back

=cut

sub corresponding_all {
    my $self = shift;
    my $object = $self->object;
    my @rows;

    my $cds;
    if($object->class eq 'CDS'){
        $cds = $object;
    }else{
        $cds = eval { $object->Corresponding_CDS };
    }

    my %data  = ();

    if( defined($cds) ){
        my $gff   = $self->_fetch_gff_gene($cds) or next;
        my $protein = $cds->Corresponding_protein if $cds;
        my @sequences = $cds->Corresponding_transcript;

        my $len_spliced   = 0;
        map { $len_spliced += $_->length } map { $_->get_SeqFeatures } $gff->get_SeqFeatures('CDS:WormBase');

        $len_spliced ||= '-';

        $data{length_spliced}   = $len_spliced;

        my @lengths = map { $self->_fetch_gff_gene($_)->length . "<br />";} @sequences;
        $data{length_unspliced} = @lengths ? \@lengths : undef;


        my $peplen = $protein->Peptide(2) if $protein;
        my $aa     = "$peplen";
        $data{length_protein} = $aa if $aa;

        my $gene = $cds->Gene;

        my $status = $cds->Prediction_status if $cds;
        $status =~ s/_/ /g if $status;
        $status = $status . ($cds->Matching_cDNA ? ' by cDNA(s)' : '');

        my $type = $sequences[0]->Method if @sequences;
        $type =~ s/_/ /g;
        @sequences =  map {$self->_pack_obj($_, undef, style => ($_ == $object) ? 'font-weight:bold' : 0)} @sequences;
        $data{type} = $type && "$type";
        $data{model}   = @sequences ? \@sequences : undef;
        $data{protein} = $self->_pack_obj($protein);
        $data{cds} = $cds ? $self->_pack_obj($cds, undef, style => ($cds == $object) ? 'font-weight:bold': 0 ) : '(no CDS)';
        $cds = ($cds ? $self->_pack_obj($cds, undef, style => ($cds == $object) ? 'font-weight:bold': 0) : '(no CDS)');
        $data{cds} = $status ? { text => $cds, evidence => { status => "$status"} } : $cds;

        $data{gene} = $self->_pack_obj($gene);
        push @rows, \%data;
    }else{
        if($object->class eq 'Transcript'){ # if caller is an ncRNA
            my $gene = $object->Gene;
            $data{gene} = $self->_pack_obj($gene);
            my @sequences = $gene->Corresponding_transcript;
            $data{model}   = @sequences ?
                [ map {$self->_pack_obj($_, undef, style => ($_ == $object) ? 'font-weight:bold' : 0)} @sequences ]
                : undef;
            my @lengths = map { $self->_fetch_gff_gene($_)->length . "<br />";} @sequences;
            $data{length_unspliced} = @lengths ? \@lengths : undef;
            $data{cds} = '(no CDS)';
            my $type = $sequences[0]->Method if @sequences;
            $type =~ s/_/ /g;
            $data{type} = $type && "$type";

            push @rows, \%data;
        }

    }

    # add historical gene to table
    map {
        push @rows, { gene => $self->_pack_obj($_) };
    } $object->Gene_history;

    return {
        description => 'corresponding cds, transcripts, gene for this protein',
        data        => @rows ? \@rows : undef
    };
}

############################################################
#
# The Reagents Widget
#
############################################################

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

		@pcr     = map {$_->info} map { eval {$_->features('PCR_product:GenePair_STS', 'structural:PCR_product')} }
		           @{$self->_segments}  ;
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
		               map { eval{ $_->features('reagent:Oligo_set')} } @{$self->_segments};
	}

    return {
		description => 'The Microarray assays in this region of the sequence',
		data        => @microarrays ? \@microarrays : undef,	#class Oligo_set
	};
}

=head3 pcr_products

This method will return a data structure containing
PCR products related to the requested object.

=over

=item PERL API

 $data = $model->pcr_products();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/pcr_products

B<Response example>

<div class="response-example"></div>

=back

=cut

sub pcr_products {
    my $self = shift;
    my @pcr = map { $self->_pack_obj($_) } @{$self ~~ '@PCR_product'};
    return { description => 'PCR products for the sequence',
	     data        => @pcr ? \@pcr : undef,
    };
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

    my $clone = $self ~~ 'Clone' ||( $self->sequence ? $self->sequence->Clone : undef );
    return { description => 'The Source clone of the sequence',
	     data        =>  $clone ? map {$self->_pack_obj($_)} $clone : undef};
}

############################################################
#
# The Sequence Widget
#
############################################################

# fetch SeqFeature from GFF
sub _build_seq_obj {
    my ($self) = @_;
    my $s = $self->object;
    my $gff = $self->gff or return;

    my $seq_obj;

    # Genomic clones need to be fetched a bit differently.
    unless ($s->class =~ /Sequence|Clone/i) {
        ($seq_obj) = sort {$b->length<=>$a->length}
                        grep {$_->primary_tag eq 'mRNA'} $gff->get_features_by_name($s);

        # BLECH!  If provided with a gene ID and alt splices are present just guess
        # and fetch the first CDS or Transcript
        # We really should display a list for all of these.

        ($seq_obj) = $seq_obj ? ($seq_obj) : sort {$b->length<=>$a->length}
                grep {$_->primary_tag eq 'mRNA'} $gff->get_features_by_name("$s.a");
        ($seq_obj) = $seq_obj ? ($seq_obj) : sort {$b->length<=>$a->length}
                grep {$_->primary_tag eq 'mRNA'} $gff->get_features_by_name("$s.1");
    }

    return $seq_obj;
}

# get CDS SeqFeatures if applicable (like is_coding)
sub _build_cds_and_utr {
    my ($self) = @_;
    my $seq_obj = $self->_seq_obj;
    my @cds = ();

    if ($seq_obj && $self->is_coding){
        @cds = grep { $_->primary_tag ne 'intron' && $_->primary_tag ne 'exon'}
            map { $_->primary_tag eq 'CDS' ? ($_->get_SeqFeatures) : ($_) }
                $seq_obj->get_SeqFeatures();

        # sort by stop if on -ve strand
        @cds = ($seq_obj->strand > 0) ? sort { $a->start <=> $b->start } @cds : sort { $b->stop <=> $a->stop } @cds;
    }

    return \@cds;
}

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
			       target => @target ? \@target : undef,
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

    my @data;
    my $seq_obj = $self->_seq_obj;

    # Haven't fetched a GFF segment? Try Ace.
    # miserable broken workaround
    if (!$seq_obj || eval{ length($seq_obj->dna) } < 2 || eval { $s->Properties eq 'cDNA'}) {
        # try to use acedb
        if (my $fasta = $s->asDNA) {
            $fasta =~ s/^\s?>(.*)\n//;
            $fasta =~ s/\s//g;
            my $len = length($fasta);
            if($len > 0){
                push @data,{
                    header=>"Sequence",
                    sequence=>$fasta && "$fasta",
                    length=>$len,
                };
            }
        } else {
            push @data, "Sequence unavailable.  If this is a cDNA, try searching for $s.5 or $s.3";
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
        $markup->add_style('flank'=> 'BGCOLOR beige');
        $markup->add_style('newline' => "\n");
        $markup->add_style('space'   => '');
        my %seenit;

        # local coordinates
        $seq_obj->ref($seq_obj);

        my @features = @{$self->_cds_and_utr};

        push @data, _print_unspliced($markup,$seq_obj,$unspliced,\@features);
        push @data, _print_spliced($markup,@features);
        push @data, _print_protein($markup,\@features) unless eval { $s->Coding_pseudogene };

        if ($s->{class} eq 'Transcript') {
            my ($flanked_seq,$flanked_seq_range, @flankings) = $self->_get_flanking_region(2000, 2000);
            push @data, _print_flanked_unspliced($markup, $flanked_seq_range, $flanked_seq,
                                                 \@features, \@flankings);
        }

    } else {
        # Otherwise we've got genomic DNA here
        push @data, {
            header => "Genomic Sequence",
            sequence => "$unspliced",
            length => $length,
        };
    }
    $self->length($length);

    END:
    return { description => 'the sequence of the sequence',
             data        => @data ? \@data : undef };
}

# get the upstream and downstream of a SeqFeature object
# args:
#   -length of the upstream ond downstream to be constructed
#   -[optionally]: a SeqFeature object, otherwise use the one based on $self
# returns:
#   - the dna that spans the upstream, the feature, and the downstream
#   - three segments (in the following order):
#     - the long segment including up- and downstream
#     - the upstream segment, if not length 0
#     - the downstream segment, if not length 0
sub _get_flanking_region {
    my ($self, $x_upstream, $x_downstream, $seq_obj) = @_;
    $seq_obj = $seq_obj || $self->_seq_obj;

    my @flanking_types = ();
    push @flanking_types, 'upstream' if $x_upstream;
    push @flanking_types, 'downstream' if $x_downstream;

    my ($seq_start, $seq_end) = ($seq_obj->start, $seq_obj->stop);

    my $flank_coords = $seq_obj->strand > 0 ?
        { 'upstream' => [$seq_start - $x_upstream, $seq_start - 1],
          'downstream' => [$seq_end + 1, $seq_end + $x_downstream]}
      : { 'upstream' => [$seq_end + 1, $seq_end + $x_upstream],
          'downstream' => [$seq_start - $x_downstream, $seq_start - 1] };

    my @flankings = ();
    foreach my $flank_type (@flanking_types){
        my ($flank_start, $flank_end) = @{$flank_coords->{$flank_type}};
        my $flank_id = $seq_obj->name . '_' . $flank_type;
        my $segment = Bio::DB::SeqFeature::Segment->new($seq_obj->object_store(),
                                                        $flank_id,
                                                        $flank_start,
                                                        $flank_end,
                                                        $seq_obj->strand);

        # ensure not to fetch flanking region beyond assembled region ($contig)
        my ($contig) = $self->gff->segment($seq_obj->name)->features(-types => ['assembly_component']);
        $segment = $contig->intersection($segment);
        $segment->name($flank_id);
        $segment->primary_tag($flank_type);
        push @flankings, $segment;
    }

    my $long_seg = $seq_obj->union(@flankings);  #with absolute coords
    $long_seg->strand($seq_obj->strand);

    # To get dna for the long sequence that includes up and downstrem.

    # Ideally, one would use absolute coordinates to get the segment, but
    # the code commented out below doesn't work for me.
    # my $long_seg_rel = $self->gff->segment(-name=>$seq_obj->name,
    #                                        -start=>$long_seg->start,
    #                                        -end=>$long_seg->end,
    #                                        -absolute=>1);

    # So find $long_seg's relative coords to original $seq_obj's start OR end
    # depending on strand
    my ($start_rel, $end_rel) = $seq_obj->strand > 0 ?
        ($long_seg->start - $seq_obj->start + 1,
         $long_seg->end - $seq_obj->start + 1)
      : (- $long_seg->end + $seq_obj->end + 1,
         - $long_seg->start + $seq_obj->end + 1);

    my $long_seg_rel = $self->gff->segment($seq_obj->name, $start_rel, $end_rel);
    # its strand is set based on $seq_obj automatically
    my $long_seg_dna = $long_seg_rel->dna;

    return ($long_seg_dna, $long_seg, $flankings[0], $flankings[1]);

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
    return { description => 'homologous sequences', data => undef } unless $gff;

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

			push @rows, {   no=>$index++,
							start=>$es && "$es",
							end=>$ee && "$ee",
							ref_start=>$as && "$as",
							ref_end=>=> $ae && "$ae",
						};
		}
		$hash{exons}={ rows=>\@rows, parent=>$parent, orientation=>$orientation} if @exons;
    }

    my @feature = $s->get('Feature');
    if (@feature) {
# 		print "Other features";
		my @rows;
		for my $f (@feature) {
			(my $label = $f) =~ s/(inverted|tandem)/$1 repeat/;
			for my $i ($f->col) {
				my @fields = $i->row;
				my $start = $fields[0];
				my $end = $fields[1];
				my $score = $fields[2];
				my $comment = $fields[3];
				push @rows, {
					start=>$start && "$start",
					end=>$end && "$end",
					score=>$score && "$score",
					comment=>=> $comment && "$comment",
				};
			}
			$hash{features}={ rows=>\@rows, label =>$label} if @rows;
		}

    }
    return { description => 'features contained within the sequence',
	     data        => keys %hash ? \%hash : undef };
}

=head3 predicted_units

This method will return a data structure listing
features contained within the sequence.

=over

=item PERL API

 $data = $model->predicted_units();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/predicted_units

B<Response example>

<div class="response-example"></div>

=back

=cut

sub predicted_units {
    my ($self) = @_;
    my $s = $self->object;
    my @rows;
    # NB: This is not completely functional - it doesn't display cloned, named genes
    # (The pre-WS116 version didn't either).
    # That is, transcripts like JC8.10 are not listed under Transcripts in Ace WS116
    if (my @genes = $s->get('Transcript')) {

#       print 'Predicted Genes & Transcriptional Units';
        my %data = map {$_=>$_} $s->follow(-tag=>'Transcript',-filled=>1);
#         my @rows;
        foreach (sort {$a->right <=> $b->right} @genes) {
            my $gene = $data{$_};
            #   my $href = a({ -href=>Object2URL($gene) },$gene);
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
            push @rows, {   start=>$start && "$start",
                            end=>$end && "$end",
                            name=>$self->_pack_obj($gene),
                            gene=>$locus ? $self->_pack_obj($locus) : '-',
                            predicted_type=>=> "$gene" || '?',
                            comment=>$desc && "$desc",
                        };
        }
    }

    return { description => 'features contained within the sequence',
         data        => @rows ? \@rows : undef };
}


=head3 strand

This method will return a string indicating the orientation of the sequence

=over

=item PERL API

 $data = $model->strand();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/sequence/JC8.10a/strand

B<Response example>

<div class="response-example"></div>

=back

=cut

sub strand {
    my ($self) = @_;
    my $strand = $self->_segments->[0]->strand if $self->_segments->[0];
    return { description => 'strand orientation of the sequence',
         data        => $strand ? ($strand > 0) ? "+" : "-" : undef
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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transcript/JC8.10a/transcripts

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
    map { eval {$_->features('protein_coding_primary_transcript:Coding_transcript')} }
    @{$self->_segments};
    }

    return { description => 'Transcripts in this region of the sequence',
         data        => @transcripts ? \@transcripts : undef, #class Sequence
    };
}

############################################################
#
# Private Methods
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
            my ($seg_start) = $self->gff->segment("$base.3");
            my ($seg_stop)  = $self->gff->segment("$base.5");
            if ($seg_start && $seg_stop) {
                my $union = $seg_start->union($seg_stop);
                return [$union] if $union;
            }
        }
    }
    return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object)];
}

sub _print_unspliced {
    my ($markup,$seq_obj,$unspliced,$features, $header) = @_;
    my $name = $seq_obj . ' (' . $seq_obj->start . '-' . $seq_obj->stop . ')';
    my $length_all   = length $unspliced;
    if ($length_all > 0) {
        # mark up the feature locations
        my @markup;
        my $offset = $seq_obj->start;
        my $counter = 0;
        for my $feature (@$features) {
            my $start    = $seq_obj->strand > 0 ? $feature->start - $offset : $length_all - ($feature->stop - $offset + 1);
            my $length   = abs($feature->stop - $feature->start) + 1;
            my $style = $feature->primary_tag eq 'CDS'  ? 'cds'.$counter++%2
                : $feature->primary_tag =~ /exon/ ? 'cds'.$counter++%2
                : $feature->primary_tag =~ 'UTR' ? 'utr'
                : $feature->primary_tag =~ /.+stream/ ? 'flank'
                : '';
            # print ("\n   " . $feature->primary_tag  . " " . $feature->start . " " . $feature->stop . " $style $start $length");
            push @markup,[$style,$start,$start+$length];
            push @markup,['uc',$start,$start+$length] unless $style =~ 'utr|flank';
        }
        push @markup,map {['space',10*$_]}   (1..length($unspliced)/10);
        push @markup,map {['newline',80*$_]} (1..length($unspliced)/80);
        $markup->markup(\$unspliced,\@markup);
        return {
            header=> $header || "unspliced + UTR",
            sequence=>$unspliced,
            length => $length_all,
            style=> 1,
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
        # print ("\n   $feature, primary_tag:" . $feature->primary_tag . ", source: " . $feature->source . ", strand:" . $feature->strand);
        my $length = abs($feature->stop - $feature->start) + 1;
        my $style  = $feature->primary_tag =~ /UTR/i ? 'utr' : 'cds' . $counter++ %2;
        my $end = $last + $length;
        push @markup,[$style,$last,$end];
        push @markup,['uc',$last,$end] unless $style eq 'utr';
        $last += $length;
    }

    push @markup,map {['space',10*$_]}   (1..length($spliced)/10);
    push @markup,map {['newline',80*$_]} (1..length($spliced)/80);
    $markup->markup(\$spliced,\@markup);
    return {
        header=>"spliced + UTR",
        sequence=>$spliced,
        length=> $splen,
        style=> 1,
    };

}

sub _print_protein {
    my ($markup,$features,$genetic_code) = @_;
#   my @markup;
    my $trimmed = join('',map {$_->dna} grep {$_->primary_tag eq 'CDS'} @$features);
    return unless $trimmed;     # Hack for mRNA
    my $peptide = Bio::Seq->new(-seq=>$trimmed)->translate->seq;
    my $change  = $peptide =~/\w+\*$/ ? 1 : 0;
    my $plen = length($peptide) - $change;

#   @markup = map {['space',10*$_]}      (1..length($peptide)/10);
#   push @markup,map {['newline',80*$_]} (1..length($peptide)/80);
    my $name = eval { $features->[0]->refseq->name };
#   $markup->markup(\$peptide,\@markup);
    $peptide =~ s/^\s+//;

    return {
        header=>"conceptual translation",
        sequence=>$peptide,
        type => "aa",
        length => $plen,
    };
}

# print flanking regions plus the unspliced sequence
# Note: it calls _print_unspliced underneath
sub _print_flanked_unspliced {
    my ($markup, $flanked_seq_range, $flanked_seq, $features, $flankings) = @_;

    my @flanked_features =  (@$features, @$flankings);  # concat
    # make a title
    my $title = 'unspliced + UTR';
    my @flank_titles = map {
        $_->length() .' '. $_->primary_tag;
    } @$flankings;
    $title = join(' + ', ($title, @flank_titles));

    return _print_unspliced($markup,
                            $flanked_seq_range,
                            $flanked_seq,
                            \@flanked_features,
                            $title);
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
    return  {   header=>"Genomic Sequence",
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
