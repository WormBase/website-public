package WormBase::API::Object::Pcr_oligo;

use Moose;

with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
extends 'WormBase::API::Object';

# TODO:
#  Split according to widgets? (May be hard for this aggregated class)
#  Consider merging the overlaps_* methods
#  segment & _segment method similar to Role::Position requirements? maybe redo

=pod

=head1 NAME

WormBase::API::Object::Pcr_oligo

=head1 SYNPOSIS

Aggregate model for the Ace ?PCR_product, ?Oligo_set, and ?Oligo classes.
Documentation will henceforth refer to these collectively as "product", except
when specific to a single Ace model.

=head1 URL

http://wormbase.org/resources/pcr_oligo

=cut

has '_oligos' => (
	is => 'ro',
	required => 1,
	lazy => 1,
	default => sub {
		my ($self) = @_;
		return $self ~~ '@Oligo';
	},
);

has '_object_class' => (
	is => 'ro',
    lazy_build => 1
);

sub _build__object_class {
    (my $class = shift ~~ 'class') =~ s/_/ /go;
    return $class;
}


sub _build_tracks {
    my ($self) = @_;
    my @tracks = qw/GENES MICROARRAY_OLIGO_PROBES PCR_PRODUCTS ORFEOME_PCR_PRODUCTS CLONES/;

    return {
        description => 'tracks displayed in GBrowse',
        data => \@tracks
    };
}



# satisfy Role::Position requirements
sub _build__segments {
    my $self = shift;
    my $object = $self->object;
    # my $class = $object->class;

    my $dbh = $self->gff_dsn();

    # $class .= ':reagent' if $class eq 'Oligo_set';

    my @segments = $dbh->segment($object);

    return \@segments;
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

################################################################################
# Methods pertaining to all three classes
################################################################################

# name { }
# Supplied by Role

# remarks { }
# Supplied by Role

# canonical_parent { }
# Returns a datapack containing the parent of the product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/canonical_parent

sub canonical_parent {
	my ($self) = @_;

	return {
		description => 'Canonical parent of this ' . $self->_object_class,
		data		=> $self->_pack_obj($self ~~ 'Canonical_parent'),
	};
}

# oligos { }
# Returns a datapack containing the oligos of the product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/oligos

sub oligos {
	my ($self) = @_;

	my @data;
	foreach (@{$self->_oligos}) {
		my $seq = $_->Sequence;
		push @data, {
			obj => $self->_pack_obj($_),
			sequence => $seq && "$seq",
		};
	}

	return {
		description => 'Oligos of this' . $self->_object_class,
		data		=> @data ? \@data : undef,
	};
}

# overlapping_genes { }
# Returns a datapack containing the genes overlapping the product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlapping_genes

sub overlapping_genes {
	my ($self) = @_;
    my @results = map { $self->_pack_obj($_) } map {$_->Gene} $self->object->get('Overlaps_CDS');

	return {
		description => 'Overlapping genes of this ' . $self->_object_class,
		data		=> @results ? \@results : undef,
	};
}


# overlaps_CDS { }
# Returns a datapack containing the CDS(s) that the product overlaps.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_CDS

sub overlaps_CDS {
	my ($self) = @_;
    my $object = $self->object;
	my @CDSs = map { $self->_pack_obj($_) } $object->get('Overlaps_CDS');

	return {
		description => 'CDSs that this ' . $self->_object_class . ' overlaps',
		data		=> @CDSs ? \@CDSs : undef,
	};
}

# overlaps_transcript { }
# Returns a datapack containing the transcript(s) that the product overlaps.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_transcript

sub overlaps_transcript {
    my ($self) = @_;
    my $object = $self->object;
    my @transcripts = map { $self->_pack_obj($_) } $object->get('Overlaps_Transcript');

    return {
        description => 'Transcripts that this ' . $self->_object_class . ' overlaps',
        data        => @transcripts ? \@transcripts : undef,
    };
}

# overlaps_pseudogene { }
# Returns a datapack containing the pseudogene(s) that the product overlaps.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_pseudogene

sub overlaps_pseudogene {
    my ($self) = @_;
    my $object = $self->object;
    my @pseudogenes = map { $self->_pack_obj($_) } $object->get('Overlaps_Pseudogene');

    return {
        description => 'Pseudogenes that this ' . $self->_object_class . ' overlaps',
        data        => @pseudogenes ? \@pseudogenes : undef,
    };
}

# overlaps_variation { }
# Returns a datapack containing the variation(s) that the product overlaps.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/overlaps_variation

sub overlaps_variation {
    my ($self) = @_;
    my $object = $self->object;
    my @variations = map { $self->_pack_obj($_) } $object->get('Variation');

    return {
        description => 'Variations that this ' . $self->_object_class . ' overlaps',
        data        => @variations ? \@variations : undef,
    };
}

# on_orfeome_project { }
# Returns a datapack containing information to find the product on the ORFeome project.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/on_orfeome_project

# classic site note: MRC Genesevice and Open Biosystems links are invalid now
sub on_orfeome_project {
	my ($self) = @_;
    my $data;
	if($self->object->name =~ /^mv_(.*)/){
	   $data = $1;
    }

	return {
		description => 'Finding this ' . $self->_object_class . ' on the ORFeome project',
		data		=> $data,
	};
}

# microarray_results { }
# Returns a datapack containing the microarray result(s) using/containing the product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/microarray_results

sub microarray_results {
	my ($self) = @_;

	my $results = $self->_pack_objects($self ~~ '@Microarray_results');
	return {
		description => 'Microarray results involving this ' . $self->_object_class,
		data => %$results ? $results : undef,
	};
}

# segment { }
# Returns a datapack containing a packaged GFF segment corresponding to the product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/segment

sub segment {
	my ($self) = @_;

	my %data;
	if (my ($segment) = @{$self->_segments}) {
		%data = map { $_ => $segment->$_ }
            qw(refseq ref start end start stop length);
        $data{dna} = lc ($segment->dna);
	} elsif(my $l = $self->object->get('Length', 1)) {
          my $dna = $self->object->get('Sequence', 1);
          $data{length} = "$l";
          $data{dna} = "$dna";
    }

	return {
		description => 'Sequence/segment data about this ' . $self->_object_class,
		data		=> %data ? \%data : undef,
	};
}


########################################
## Methods pertaining to PCR_product
########################################

# amplified { }
# Returns a datapack containing the number of times amplification to product the
# PCR product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/amplified

sub amplified {
	my ($self) = @_;

	my $amplified = $self ~~ 'Amplified';
	return {
		description => 'Whether this PCR product is amplified',
		data		=> $amplified && $amplified->name,
	};
}

# laboratory { }
# Supplied by Role

# SNP_loci { }
# Returns a datapack containing SNP locus information of the PCR product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/SNP_loci

sub SNP_loci {
	my ($self) = @_;

	my @loci = map {$self->_pack_obj($_)} @{$self ~~ '@SNP_locus'};
	return {
		description => 'SNP loci for this PCR product',
		data		=> @loci ? \@loci : undef,
	};
}

# assay_conditions { }
# Returns a datapack containing details of the assay conditions of the experiment
# involving the PCR product.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/assay_conditions

sub assay_conditions {
	my ($self) = @_;
	my $conditions = $self ~~ 'Assay_conditions';
  my $text = $conditions && $conditions->right;
  $text =~ s/^\n+// if $text;
  $text =~ s/\n/\<br\>/g if $text;

	return {
		description => 'Assay conditions for this PCR product',
		data		=> $text && "$text",
	};
}

# rnai { }
# Returns a list of all associated rnai experiemnts
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/rnai

sub rnai {
    my ($self) = @_;
    my $object = $self->object;
    my @rnai = map { $self->_pack_obj($_); } eval {$object->RNAi};

    return {
        description => 'associated RNAi experiments',
        data        => @rnai ? \@rnai : undef,
    };
}


# source { }
# Returns text for linking to MRC_geneservice
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/pcr_oligo/mv_F25B5.5/source

sub source {
    my ($self) = @_;
    my $object = $self->object;
    my $gene_service_id = eval { $object->Clone->Database(3); };

    return {
        description => 'MRC geneservice reagent',
        data        => $gene_service_id ? "$gene_service_id" : undef,
    };
}

########################################
## Methods pertaining to Oligo_set
########################################

########################################
## Methods pertaining to Oligo
########################################

sub in_sequences {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} eval {$object->In_sequence};

    return {
	description => 'Sequences containing this oligonucleotide',
	data        => @data ? \@data : undef,
    }
}

sub pcr_products {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} eval {$object->PCR_product};

    return {
	description => 'PCR prodcuts associateed with this oligonucleotide',
	data        => @data ? \@data : undef,
    }
}

########################################
## Private Methods
########################################

__PACKAGE__->meta->make_immutable;

1;
