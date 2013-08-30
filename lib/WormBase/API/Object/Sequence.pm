package WormBase::API::Object::Sequence;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
with 'WormBase::API::Role::Sequence';

use Bio::Graphics::Browser2::Markup;

=pod 

=head1 NAME

WormBase::API::Object::Sequence

=head1 SYNPOSIS

Model for the Ace ?Sequence class.

=head1 URL

http://wormbase.org/species/sequence

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

# Role?
has '_method' => (
    is		=> 'ro',
    lazy	=> 1,
    default => sub {
		my ($self) = @_;
		return $self ~~ 'Method';
    },
    );

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
	elsif ($s->Genomic_canonical(0)) {
		$type = 'genomic';
    }
	elsif ($self->_method eq 'Vancouver_fosmid') {
		$type = 'genomic -- fosmid';
    }
	elsif ($s->Pseudogene(0)) {
		$type = 'pseudogene';
    }
# 	elsif (eval { $s->RNA_Pseudogene(0) }) {
# 		$type = 'RNA_pseudogene';
#     }
#	elsif ($s->Locus) {
#		$type = 'confirmed gene';
#    }
	elsif ($s->get('cDNA')) {
		($type) = $s->get('cDNA');
    }
	elsif ($self->_method eq 'EST_nematode') {
		$type   = 'non-Elegans nematode EST sequence';
    }
# 	elsif ($s->AC_number) {
# 		$type = 'external sequence';
#     }
	elsif (eval{_is_merged($s)}) {
		$type = 'merged sequence entry';
    }
	elsif ($self->_method eq 'NDB') {
		$type = 'GenBank/EMBL Entry';
		# This is going to need more robust processing to traverse object structure
    }
	elsif ($s->RNA) {
		$type = $s->RNA . ' ' . $s->RNA->right;
    }
	else {
		$type = $s->Properties(1);
    }
    $type ||= 'unknown';
    return $type && "$type";
}


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

# name {}
# Supplied by Role

# taxonomy {}
# Supplied by Role

# description { }
# Supplied by Role

# sequence_type {}
# Supplied by Role

# identity {}
# Supplied by Role

# method {}
# Supplied by Role

# remarks {}
# Supplied by Role

# laboratory { }
# Supplied by Role

# available_from { }
# Supplied by Role

# analysis { }
# Supplied by Role

sub cdss{
    my ($self) = @_;
    my $obj = $self->object;
    my @cdss = $obj->Matching_CDS;
    return {
        description => "Matching CDSs",
        data => @cdss ? $self->_pack_objects(\@cdss) : undef
    }
}

sub transcripts{
    my ($self) = @_;
    my $obj = $self->object;
    my @transcripts = $obj->Matching_transcript;
    return {
        description => "Matching Transcripts",
        data => @transcripts ? $self->_pack_objects(\@transcripts) : undef
    }
}

sub pseudogenes{
    my ($self) = @_;
    my $obj = $self->object;
    my @pgs = $obj->Matching_pseudogene;
    return {
        description => "Matching Pseudogenes",
        data => @pgs ? $self->_pack_objects(\@pgs) : undef
    }
}


############################################################
#
# The External Links widget
#
############################################################ 

# xrefs {}
# Supplied by Role

############################################################
#
# The Location Widget
#
############################################################

# genomic_position { }
# Supplied by Role

# tracks {}
# Supplied by Role

sub _build_tracks {
    my ($self) = @_;

    return {
        description => 'tracks to display in GBrowse',
        data => $self->_parsed_species =~ /elegans/ ? [qw(PRIMARY_GENE_TRACK ESTB)] : undef,
    };
}

# genomic_image { }
# Supplied by Role

# note for AD:
# this one needs some reworking. it currently fetches the first segment
# in $self->segments, recomputes the start & stop, fetches more segments
# if the seq is a CDS or Transcript, and if more than 1 seg, selects the
# first one that matches the start and stop (or just the first one).
# throwing that segment back into genomic_position just wraps it up
sub _build_genomic_image {
    my ($self) = @_;
    my $seq = $self->object;
    return {
        description => 'The genomic image could not be found',
        data        => undef,
    } unless(defined $self->_segments && defined $self->_segments->[0] && $self->_segments->[0]->length< 100_0000);

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
        my $gene = $seq->Gene || $seq;
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

# genetic_position {}
# Supplied by Role

############################################################
#
# The Reagents Widget
#
############################################################

# orfeome_assays {}
# Supplied by Role

# microarray_assays {}
# Supplied by Role

# pcr_products {}
# Supplied by Role

# matching_cdnas {}
# Supplied by Role

# source_clone {}
# Supplied by Role

############################################################
#
# The Sequence Widget
#
############################################################

# print_blast {}
# Supplied by Role

# print_sequence {}
# Supplied by Role

# print_homologies {}
# Supplied by Role

# print_feature {}
# Supplied by Role

# strand {}
# Supplied by Role

# transcripts {}
# Supplied by Role

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

