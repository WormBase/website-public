package WormBase::API::Object::Transcript;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
with 'WormBase::API::Role::Sequence';
with 'WormBase::API::Role::Expression';
with    'WormBase::API::Role::Feature';

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
        $type = 'WormBase transcript';
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

# corresponding_all { }
# Supplied by Role

sub feature {
    my ($self) = @_;
    my $obj = $self->object;

    my @features = $obj->Associated_feature;
    my @data;
    foreach my $feature (@features){
        push @data, $self->_pack_obj($feature, $feature->Description);
    }

    return {
        description => 'feature associated with this transcript',
        data => scalar @data > 0 ? {map {$_ => $self->_pack_obj($_, $_->Description)} @features} : undef
    };

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
        data => $self->_parsed_species =~ /elegans/ ? [qw(GENES EST_BEST)] : undef,
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
        @segments = $self->gff->segment($gene);
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

# predicted_units {}
# Supplied by Role

# predicted_exon_structure { }
# This method will return a data structure listing
# the exon structure contained within the sequence.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transcript/JC8.10a/predicted_exon_structure

sub predicted_exon_structure {
    my ($self) = @_;
    my $s = $self->object;

    my $index = 1;
    my @exons = map {
		my ($es,$ee) = $_->row;
		{
			no		=> $index++,
			start	=> "$es" || undef,
			end		=> "$ee" || undef,
			len 	=> "$es" && "$ee" ? $ee-$es+1 : undef
		};
	} $s->get('Source_Exons');

    return { description => 'predicted exon structure within the sequence',
             data        => @exons ? \@exons : undef };
}

#######################################
#
# The Features Widget
#
#######################################

# features {}
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

sub _build__gene {
    my ($self) = @_;
    my $object = $self->object;
    my $gene = $object->Gene;

    return $gene;
}

sub _build_sequences {
    my $self = shift;
    my $gene = $self->object; # this is actually a TRANSCRIPT here.
    my %seen;
    my @seqs = grep { !$seen{$_}++} $gene->Corresponding_transcript;
    
    # Let's just ensue that we're actually evaluating the *transcript* too
    # It looks like this method was cut-and-pasted from gene; it's not
    # customized for the transcript class.
    push @seqs, grep { !$seen{$_}++} $gene;

    for my $cds ($gene->Corresponding_CDS) {
        next if defined $seen{$cds};
        my @transcripts = grep {!$seen{$cds}++} $cds->Corresponding_transcript;

        push (@seqs, @transcripts ? @transcripts : $cds);
    }
    return \@seqs if @seqs;
    return [$gene->Corresponding_pseudogene];
}

__PACKAGE__->meta->make_immutable;

1;
