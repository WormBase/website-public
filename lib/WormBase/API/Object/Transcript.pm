package WormBase::API::Object::Transcript;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
with 'WormBase::API::Role::Sequence';

use Bio::Graphics::Browser2::Markup;

=pod 

=head1 NAME

WormBase::API::Object::Transcript

=head1 SYNPOSIS

Model for the Ace ?Transcript class.

=head1 URL

http://wormbase.org/species/transcript

=cut


has 'method' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_method',
    );

sub _build_method {
    my ($self) = @_;
    my $class = $self->object->class;
    my $method = $self ~~ 'Method';
    my $details = $method->Remark if $method;
    return {
        description => "the method used to describe the $class",
        data => ($method || $details) ? {
	    method => $method && "$method",
	    details => $details && "$details",
	} : undef
    };
}

has 'type' => (
    is  => 'ro',
    lazy_build => 1,
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
    elsif ($self->method eq 'Vancouver_fosmid') {
        $type = 'genomic -- fosmid';
    }
    elsif ($self ~~ '@Locus') {
        $type = 'confirmed gene';
    }
    elsif (eval { $s->Coding }) {
        $type = 'predicted coding sequence';
    }
    elsif ($s->get('cDNA')) {
        ($type) = $s->get('cDNA');
    }
    elsif ($self->method eq 'EST_nematode') {
        $type   = 'non-Elegans nematode EST sequence';
    }
    elsif (eval{_is_merged($s)}) {
        $type = 'merged sequence entry';
    }
    elsif ($self->method eq 'NDB') {
        $type = 'GenBank/EMBL Entry';
        # This is going to need more robust processing to traverse object structure
    }
    else {
        $type = $s->Properties(1);
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

# sub sequence_type {}
# Supplied by Role; POD will automatically be inserted here.
# << include sequence_type >>

# sub identity {}
# Supplied by Role; POD will automatically be inserted here.
# << include identity >>

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

# sub available_from { }
# Supplied by Role; POD will automatically be inserted here.
# << include available_from >>

# sub corresponding_all { }
# Supplied by Role; POD will automatically be inserted here.
# << include corresponding_all >>

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
# The Location Widget
#
############################################################

=head2 Location

=cut

# sub genomic_position { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_position >>

# sub tracks {}
# Supplied by Role; POD will automatically be inserted here.
# << include tracks >>

sub _build_tracks {
    my ($self) = @_;

    return {
        description => 'tracks to display in GBrowse',
        data => $self->_parsed_species =~ /elegans/ ? [qw(CG ESTB)] : undef,
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
    $start = int($start - 0.1*($stop-$start));
    $stop  = int($stop  + 0.1*($stop-$start));
    my @segments;
    if ($seq->class eq 'CDS' or $seq->class eq 'Transcript') {
        my $gene = eval { $seq->Gene;} || $seq;
        @segments = $self->gff->segment(-class=>'Coding_transcript',-name=>$gene);
        @segments = grep {$_->method eq 'wormbase_cds'} $self->gff->fetch_group(CDS => $seq)
            unless @segments;   # CB discontinuity
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
# The Reagents Widget
#
############################################################

=head2 Reagents

=cut

# sub orfeome_assays {}
# Supplied by Role; POD will automatically be inserted here.
# << include orfeome_assays >>

# sub microarray_assays {}
# Supplied by Role; POD will automatically be inserted here.
# << include microarray_assays >>

# sub pcr_products {}
# Supplied by Role; POD will automatically be inserted here.
# << include pcr_products >>

# sub matching_cdnas {}
# Supplied by Role; POD will automatically be inserted here.
# << include matching_cdnas >>

# sub source_clone {}
# Supplied by Role; POD will automatically be inserted here.
# << include source_clone >>

############################################################
#
# The Sequence Widget
#
############################################################

=head2 Sequence

# sub print_blast {}
# Supplied by Role; POD will automatically be inserted here.
# << include print_blast >>

# sub print_sequence {}
# Supplied by Role; POD will automatically be inserted here.
# << include print_sequence >>

# sub print_homologies {}
# Supplied by Role; POD will automatically be inserted here.
# << include print_homologies >>

# sub print_feature {}
# Supplied by Role; POD will automatically be inserted here.
# << include print_feature >>

# sub strand {}
# Supplied by Role; POD will automatically be inserted here.
# << include strand >>

# sub transcripts {}
# Supplied by Role; POD will automatically be inserted here.
# << include transcripts >>

# sub predicted_units {}
# Supplied by Role; POD will automatically be inserted here.
# << include predicted_units >>

=head3 predicted_exon_structure

This method will return a data structure listing
the exon structure contained within the sequence.

=over

=item PERL API

 $data = $model->predicted_exon_structure();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/transcript/JC8.10a/predicted_exon_structure

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub predicted_exon_structure {
    my ($self) = @_;
    my $s = $self->object;

    my $index = 1;
    my @exons = map { my ($es,$ee) = $_->row; 
                      { no=>$index++,
                        start=>"$es",
                        end=>"$ee",}; 
                    } $s->get('Source_Exons');

    return { description => 'predicted exon structure within the sequence',
             data        => @exons ? \@exons : undef };
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
                return [$union] if $union;
            }
        }
    }
    return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object)];
}

__PACKAGE__->meta->make_immutable;

1;
