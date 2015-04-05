package WormBase::API::Object::Feature;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::Position';
with    'WormBase::API::Role::Sequence';
with    'WormBase::API::Role::Feature';


# Some good examples: WBsf000001, WBsf027925

=pod

=head1 NAME

WormBase::API::Object::Feature

=head1 SYNPOSIS

Model for the Ace ?Feature class.

=head1 URL

http://wormbase.org/species/*/feature

=cut



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


#######################################
#
# The Overview widget
#
#######################################

# name { }
# Supplied by Role

# method { }
# Supplied by Role

# flanking_sequences { }
# This method will return a data structure containing sequences adjacent to the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/flanking_sequences

sub flanking_sequences {
    my $self   = shift;
    my $object = $self->object;
    my $method = $object->Method;

    # This array holds accumulated sequences with comments and possible highlights:
    my @sequences = ();

    # If a feature specific sequence exists, then it will be kept in
    # $feature_sequence and $comment is set to describe the composition
    # of the sequence.
    my $feature_sequence = '';
    my $comment = 'flanking sequence';

    # Get flanking sequences:
    my ($seq, @flanks);
    @flanks = ('', ''); # Default flanks, in case they cannot be retrieved.
    if (my ($flanking_seq) = $self->object->Flanking_sequences) {
        (@flanks) = $flanking_seq->row;
        $seq = $self->_pack_obj($object->Mapping_target);
        @flanks = map {"$_"} @flanks;
    }

    # Some features have sequences associated with them that denote splice sites
    # or other removed genomic content. In those cases, there is no sequence as
    # such. And the coordinates mark bases before and after the site, a bit misleading.
    unless ($method eq 'SL1' || $method eq 'SL2' || $method eq 'polyA_site' || $method eq 'history_feature') {
        my $fasta = $object->Sequence->asDNA;
        my @fasta_sequences = (split "\n", $fasta);
        shift @fasta_sequences;
        my $sequence = join '', @fasta_sequences;
        my $feature_accession = $object->Sequence->at("SMap.S_child.Feature_object.$object");
        my $start_coordinate = $feature_accession->right;

        # There might be no coordinates associated with the feature.
        if ($start_coordinate) {
            my $end_coordinate = $start_coordinate->right;

            # Translate coordinates from objects to integers:
            $start_coordinate = int((split /\D/, $start_coordinate->asString)[0]) - 1;
            $end_coordinate = int($end_coordinate->asString) - 1;

            # Offset and sequence length within the FASTA sequence:
            my $offset = $start_coordinate > $end_coordinate ? $end_coordinate : $start_coordinate;
            my $length = $start_coordinate > $end_coordinate ? $start_coordinate - $offset + 1: $end_coordinate - $offset + 1;

            # Actual sequence of the feature within the FASTA sequence:
            $feature_sequence = uc substr $sequence, $offset, $length;
            $comment = 'upper case: feature sequence; lower case: flanking sequences';

            # Determine feature strand and whether the sequence needs to be reverse complemented:
            my $reverse = undef;
            if ($flanks[0] ne '' && length($flanks[0]) <= $offset) {
                if (lc(substr($sequence, $offset - length($flanks[0]), length($flanks[0]))) eq lc($flanks[0])) {
                    if (length($sequence) > $offset + ($length - 1) + length($flanks[1]) &&
                        lc(substr($sequence, $offset + $length, length($flanks[1]))) eq lc($flanks[1])) {
                        # Alright, flanks match. $feature_sequence does not need modifying.
                    } else {
                        # One flank matched, but the other one did not? Okay, might happen. Reverse complement $feature_sequence.
                        $reverse = 1;
                     }
                 } else {
                    # Okay, first flank already mismatching. Reverse complement $feature_sequence.
                    $reverse = 1;
                }
            } elsif ($flanks[1] ne '' && length($sequence) > $offset + length($flanks[1])) {
                if (lc(substr($sequence, $offset + $length, length($flanks[1]))) eq lc($flanks[1])) {
                    # Second flank matches. $feature_sequence does not need modifying.
                } else {
                    # Okay, second flank mismatching. Reverse complement $feature_sequence.
                    $reverse = 1;
                }
            } else {
                # Dunno. Need to have flanks to determine orientation.
            }

            # Carry out the actual reverse complement, if needed.
            if ($reverse) {
                $feature_sequence = reverse $feature_sequence;
                $feature_sequence =~ tr/[acgtACGT]/[tgcaTGCA]/;
            }

            push(@sequences,
                {
                    sequence => $flanks[0] . $feature_sequence . $flanks[1],
                    comment => $comment,
                    highlight => {
                        offset => length($flanks[0]),
                        length => length($feature_sequence)
                    }
                }
            );
        }
    }

    if ($feature_sequence eq '') {
        # If there are only flanks, then have them displayed as separate FASTA sequences:
        push(@sequences, { sequence => $flanks[0], comment => "$comment (upstream)" });
        push(@sequences, { sequence => $flanks[1], comment => "$comment (downstream)" });
    }

    return {
        description => 'sequences flanking the feature',
        data        => $seq && {
            seq    => $seq,
            flanks => @flanks ? \@flanks : undef,
            feature_seq => $feature_sequence,
            sequences => \@sequences
        }
    };
}

# description { }
# Supplied by Role

# annotation { }
# This method will return a data structure
# containing annotation info on the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/annotation

# TODO: confirm if any Annotation tag is replaced by something else
sub annotation {
    my $self   = shift;
    my $object = $self->object;

    my $annotation;
    if ($annotation = $object->Annotation) {
        $annotation = $annotation->right;
    }

    return { description => 'annotation of the feature',
	     data        => $annotation && "$annotation", };
}

# remarks {}
# Supplied by Role

# taxonomy {}
# Supplied by Role

# sequence_ontology_terms { }
# This method will return a data structure
# containing sequence ontology terms on the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence_ontology_terms

sub sequence_ontology_terms {
    my $self   = shift;
    my $object = $self->object;

    my @terms = map {{
        id       => "$_",
        label    => "$_",
        class    => 'so_term'
    }} $object->SO_term;
    return { description => 'sequence ontology terms describing the feature',
	     data        => @terms ? \@terms : undef, };
}

# sequence { }
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/sequence

sub sequence {
    my ($self) = @_;

    return {
        description => 'TODO',
        data => $self->_pack_obj($self ~~ 'Sequence'),
    };
}

sub dna_text {
    my ($self) = @_;

    return {
        description => 'DNA text of the sequence feature',
        data => $self ~~ 'DNA_text',
    };
}

sub associated_gene {
    my $self   = shift;
    my $object = $self->object;
    my @data = map { $self->_pack_obj($_) } $object->Associated_with_gene;

    return { description => 'Associated gene of the sequence feature',
	     data        => @data ? \@data : undef, };
}

#######################################
#
# The Associations widget
#
#######################################

# defined_by { }
# This method returns a data structure detailing
# how the sequence feature was defined.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/defined_by

sub defined_by {
    my $self   = shift;
    my $object = $self->object;

    my @data;
    foreach my $definer ($object->Defined_by) {
    	foreach my $definer_object ($definer->col) {
	    (my $label = "$definer") =~ s/Defined_by_(.)/\u$1/;
	    push @data, {
		'object' 	=> $self->_pack_obj($definer_object),
		'label' 	=> $label && "$label",
	    };
    	}
    }

    return { description => 'how the sequence feature was defined',
	     data        => @data ? \@data : undef, };
}

# associations { }
# This method will return a data structure listing
# sequences associated with this feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/associations

sub associations {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my @association_types = $object->Associations;

    foreach my $assoc_type (@association_types) { # assoc_type is tag
    	foreach my $association_object ($assoc_type->col) {
	    (my $label = "$assoc_type") =~ s/Associated_with_(.)/\u$1/;
	    push @data, { association 	=> $self->_pack_obj($association_object),
			  label 	=> $label && "$label"      };
	}
    }
    return { description => 'objects that define this feature',
	     data        => @data ? \@data : undef,
    };
}


# binds_gene_product { }
# This method will return a data structure containing
# the gene whose product binds the feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/binds_gene_product

sub binds_gene_product {
    my $self   = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Bound_by_product_of;
    return { data => @data ? \@data : undef,
	     description => 'gene products that bind to the feature' };
}


# transcription_factor { }
# This method will return a data structure containing
# the transcription factors that associate with this feature.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/feature/WBsf000753/transcription_factor

sub transcription_factor {
    my $self   = shift;
    my $object = $self->object;

    return { description => 'Transcription factor of the feature',
	     data        => $self->_pack_obj($object->Transcription_factor) };
}

sub _build__segments {
    my ($self) = @_;
    my $object = $self->object;
    return [] unless $self->gff;
    return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object)];
}

#######################################
#
# The History widget
#
#######################################

sub history_lite {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my @actions = $object->History;

    foreach my $action (@actions) {
      (my $a = $action) =~ s/_/ /;
      my @hist_entries;
      if ($object->$action){
          @hist_entries = map {
              my $evidence = $self->_get_evidence($_);
              my $remark = $evidence ?
                  { text => $self->_pack_obj($_), evidence => $evidence } : $self->_pack_obj($_);

              { action  => $a,
                remark    => $remark }
          } $object->$action;
      } else {
          @hist_entries = ({ action => $a, remark => undef });
      }

      push @data, @hist_entries;
    }

    return {
        description => 'the curatorial history of the gene',
        data        => @data ? \@data : undef,
    };
}

#######################################
#
# The Location Widget
#
#######################################

# genomic_position {}
# Supplied by Role

# genetic_position {}
# Supplied by Role

# genomic_image {}
# Supplied by Role

sub _build_genomic_position {
    my ($self) = @_;

    my @positions = $self->_genomic_position($self->_segments,
                                             \&_pad_short_seg_simple);
    return {
        description => 'The genomic location of the sequence',
        data        => @positions ? \@positions : undef,
    };
}

sub _build_tracks {
    my ($self) = @_;
    return {
        description => 'tracks displayed in GBrowse',
        data        => [qw/GENES RNASEQ_ASYMMETRIES RNASEQ RNASEQ_SPLICE POLYSOMES MICRO_ORF DNASEI_HYPERSENSITIVE_SITE REGULATORY_REGIONS PROMOTER_REGIONS HISTONE_BINDING_SITES TRANSCRIPTION_FACTOR_BINDING_REGION TRANSCRIPTION_FACTOR_BINDING_SITE GENOME_SEQUENCE_ERROR_CORRECTED BINDING_SITES_PREDICTED BINDING_SITES_CURATED BINDING_REGIONS GENOME_SEQUENCE_ERROR/],
    };
}

sub _build_genomic_image {
    my ($self) = @_;

    # TO DO: MOVE UNMAPPED_SPAN TO CONFIG
    my $UNMAPPED_SPAN = 1000;

    my $position;
    if (my $segment = $self->_segments->[0]) {
        my ($ref,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($segment);

        # Generate a link to the genome browser
        # This is hard-coded and needs to be cleaned up.

        my $split  = $UNMAPPED_SPAN / 2;
        ($segment) = $self->gff_dsn->segment($ref,$abs_start-$split,$abs_stop+$split);

        ($position) = $self->_genomic_position([$segment || ()]);
    }

    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $position,
    };
}


#######################################
#
# The Features Widget
#
#######################################

# override _build_features {}
# Supplied by Role

sub _build_features {
    my $self = shift;
    my $feature_tag_name = 'Associated_with_Feature';
    my @data = $self->_get_feature_associations($feature_tag_name);

    return {
        description => 'Other sequence features associated with it',
        data        => @data ? \@data : undef,
    };
}

__PACKAGE__->meta->make_immutable;

1;
