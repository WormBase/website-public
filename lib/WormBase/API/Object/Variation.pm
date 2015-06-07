  package WormBase::API::Object::Variation;

use Moose;
use Bio::Graphics::Browser2::Markup;
use List::Util qw(first);
use Number::Format;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';

=pod

=head1 NAME

WormBase::API::Object::Variation

=head1 SYNPOSIS

Model for the Ace ?Variation class.

=head1 URL

http://wormbase.org/species/*/variation

=cut

has '_genes_affected' => (
    is      => 'ro',
    lazy    => 1,
    builder => 'features_affected',
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

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# other_names { }
# Supplied by Role

# THIS METHOD IS PROBABLY DEPRECATED
sub cgc_name {
    my ($self) = @_;

    return {
        description => 'The Caenorhabditis Genetics Center (CGC) name for the variation',
        data        => $self->_pack_obj($self ~~ 'CGC_name'),
    };
}


# variation_type { }
# This method returns a data structure containing
# the broad classification of the variation, eg SNP,
# Allele, etc.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/variation_type

# A unified classification of the type of variation
# general class: SNP, allele, etc
# physical class: deletion, insertion, etc
sub variation_type {
    my ($self) = @_;
    my $object = $self->object;

    my @types = map { $_ =~ s/_/ /g; "$_" } $object->Variation_type;

    my $physical_type = join('/', $object->Type_of_mutation); # what about text?
    if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
        $physical_type = 'Transposon insertion';
    }

    return {
        description => 'the general type of the variation',
        data        => {
            general_class  => @types ? \@types : undef,
            physical_class => $physical_type && "$physical_type",
        },
    };
}


sub evidence {
    my ($self) = @_;
    my $object = $self->object;
    my $ev = $object->get('Evidence');
    my $evidence = $self->_get_evidence($ev);

    return {
        description => 'Evidence for this Variation',
        data => $evidence ? { text => '', evidence => $evidence} : undef
    };

}

# remarks {}
# Supplied by Role

# status {}
# Supplied by Role

############################################################
#
# The External Links widget
#
############################################################

# xrefs {}
# Supplied by Role

# source_database { }
# This method returns a data structure containing
# the source database of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/source_database

# Q: How is this used? Is this used in conjunction with the various KO Consortium tags?
# CAN BE REPLACED WITH << xrefs >>
sub source_database {
    my ($self) = @_;

    my ($remote_url,$remote_text);
    if (my $source_db = $self ~~ 'Database') {
        my $name = $source_db->Name;
        my $id   = $self->object->Database(3);

        # Using the URL constructor in the database (for now)
        # TODO: Should probably pull these out and keep URLs in config
        my $url  = $source_db->URL_constructor;
        # Create a direct link to the external site

        if ($url && $id) {
            $name =~ s/_/ /g;
            $remote_url = sprintf($url,$id);
            $remote_text = "$name";
        }
    }

    return {
        description => 'remote source database, if known',
        data        => {
            remote_url => $remote_url,
            remote_text => $remote_text,
        }
    };
}






############################################################
#
# The Genetics Widget
#
############################################################

# gene_class { }
# This method returns a data structure containing
# the gene class that the gene has been assigned to, for
# example "unc", "vab", or "egl".
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/gene_class

sub gene_class {
    my ($self) = @_;

    return {
        description => 'the class of the gene the variation falls in, if any',
        data        => $self->_pack_obj($self ~~ 'Gene_class'),
    };
}

# corresponding_gene { }
# This method returns a data structure containing
# the gene that the variation is contained in, if any.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/corresponding_gene

# This should return the CGC name, sequence name (if name), and WBGeneID...
sub corresponding_gene {
    my ($self) = @_;
    my $object = $self->object;
    my $count = $self->_get_count($object, 'Gene');
    my @genes = map {
        my $suffix = $_->Reference_allele("$object") ? ' (reference allele)' : '';
        [$self->_pack_obj($_), $suffix];
    } $self->object->Gene if $count < 500;

    my $comment = sprintf("%d (Too many features to display. Download from <a href='/tools/wormmine/'>WormMine</a>.)", $count);

    return {
        description => 'gene in which this variation is found (if any)',
        data        => @genes ? \@genes : $count ? $comment : undef,
    };
}

# reference_allele { }
# This method returns a data structure containing
# the reference allele for the corresponding gene
# of the current variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/reference_allele

sub reference_allele {
    my ($self) = @_;
    my $object = $self->object;
    my $gene = $object->Gene;
    my $allele = eval {$gene->Reference_allele};
    my $data = {
            text => $self->_pack_obj($allele),
            evidence => { Reference_allele_for => $self->_pack_obj($gene)}
        } if $allele && $allele ne $object;  # set field to undef if reference allele of containing gene is same as $self->object, github #3201

    return {
        description => 'the reference allele for the containing gene (if any)',
        data        => $data
    };
}

# other_alleles { }
# This method returns a data structure containing
# other alleles of the corresponding gene of the
# variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/other_alleles

sub other_alleles {
    my ($self) = @_;

    my $name = $self ~~ 'name';
    my $data;
    foreach my $allele (eval {$self->Gene->Allele(-fill => 1)}) {
        next if $allele eq $name;

        my $packed_allele = $self->_pack_obj($allele);

        if ($allele->SNP) {
            push @{$data->{data}->{polymorphisms}}, $packed_allele;
        }
        elsif ($allele->Sequence || $allele->Flanking_sequences) {
            push @{$data->{data}->{sequenced_alleles}}, $packed_allele;
        }
        else {
            push @{$data->{data}->{sequenced_alleles}}, $packed_allele;
        }
    }

    return {
        description => 'other alleles of the containing gene (if known)',
        data        => $data,
    };
}

# strains { }
# This method returns a data structure containing
# strains carrying the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/strains

sub strains {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    my %count;
    foreach ($object->Strain) {
        my @genes = $_->Gene;
        my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;

        my $packed = $self->_pack_obj($_);
        my $genotype = $_->Genotype;
        $packed->{genotype} = $genotype && "$genotype";

        if (@genes == 1 && !$_->Transgene) {
          $cgc ? push @{$count{carrying_gene_alone_and_cgc}},$packed : push @{$count{carrying_gene_alone}},$packed;
        } else {
          $cgc ? push @{$count{available_from_cgc}},$packed : push @{$count{others}},$packed;
        }
    }

    return {
        description => 'strains carrying this gene',
        data       => %count ? \%count : undef,
    };
}


# rescued_by_transgene { }
# This method returns a data structure containing
# transgenes (if any) that rescue the mutant phenotype
# of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/rescued_by_transgene

sub rescued_by_transgene {
    my ($self) = @_;

    return {
        description => 'transgenes that rescue phenotype(s) caused by this variation',
        data        => $self->_pack_obj($self ~~ 'Rescued_by_Transgene'),
    };
}


############################################################
#
# The Isolation Widget
#
############################################################

# laboratory { }
# Supplied by Role

# external_source { }
# This method returns a data structure containing
# the external source of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/external_source

sub external_source {
    my ($self) = @_;

    my $hash;
    my ($remote_url,$remote_text);
    foreach my $dbsnp (@{$self ~~ '@Database'}) {
        next unless $dbsnp eq 'dbSNP_ss';
        $remote_text = $dbsnp->right(2);
        my $url  = $dbsnp->URL_constructor;
        # Create a direct link to the external site

        if ($url && $remote_text) {
            # 	    (my $name = $dbsnp) =~ s/_/ /g;
            $hash->{$dbsnp} = {
                remote_url => sprintf($url, $remote_text),
                remote_text => "dbSNP: $remote_text",
            };
        }
    }

    return {
        description => 'dbSNP ss#, if known',
        data        => $hash,
    };
}



# isolated_by_author { }
# This method returns a data structure containing
# the author that isolated the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_by_author

sub isolated_by_author {
    my ($self) = @_;

    return {
        description => 'the author credited with generating the mutation',
        data        => $self->_pack_obj($self ~~ 'Author'),
    };
}

# isolated_by { }
# This method returns a data structure containing
# the atuhor or person that isolated the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_by

sub isolated_by {
    my ($self) = @_;

    return {
        description => 'the person credited with generating the mutation',
        data        => $self->_pack_obj($self ~~ 'Person'),
    };
}

# date_isolated { }
# This method returns a data structure containing
# the date the variation was isolated, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/date_isolated

sub date_isolated {
    my ($self) = @_;

    my $date = $self ~~ 'Date';
    return {
        description => 'date the mutation was isolated',
        data        => $date && "$date",
    };
}

# mutagen { }
# This method returns a data structure containing
# the mutagen used to generate the variation, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/mutagen

sub mutagen {
    my ($self) = @_;

    my $mutagen = $self ~~ 'Mutagen';
    my $evidence = $self->_get_evidence($mutagen);
    return {
        description => 'mutagen used to generate the variation',
        data        => $evidence && %$evidence ? {text => $mutagen && "$mutagen", evidence => $evidence} : $mutagen && "$mutagen" || undef,
    };
}

# isolated_via_forward_genetics { }
# This method returns a data structure describing
# if the mutation was isolated via forward genetics.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_via_forward_genetics

# Q: What are the contents of this tag?
sub isolated_via_forward_genetics {
    my ($self) = @_;
    my $forward = $self ~~ 'Forward_genetics';
    my $evidence = $self->_get_evidence($forward);
    return {
        description => 'was the mutation isolated by forward genetics?',
        data        => $evidence && %$evidence ? {text => $forward && "$forward", evidence => $evidence} : $forward && "$forward" || undef,
    };
}

# isolated_via_reverse_genetics { }
# This method returns a data structure describing
# if the variation was isolated by reverse genetics.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/isolated_via_reverse_genetics

# Q: what are the contents of this tag? Text and evidence
sub isolated_via_reverse_genetics {
    my ($self) = @_;
    my $reverse = $self ~~ 'Reverse_genetics';
    my $evidence = $self->_get_evidence($reverse);
    return {
        description => 'was the mutation isolated by reverse genetics?',
        data        => $evidence && %$evidence ? {text => $reverse && "$reverse", evidence => $evidence} : $reverse && "$reverse" || undef,
    };
}

# transposon_excision { }
# This method returns a data structure describing
# if the variation was isolated by a transposon excision.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/transposon_excision

sub transposon_excision {
    my ($self) = @_;

    my $transposon = $self ~~ 'Transposon_excision';
    return {
        description => 'was the variation generated by a transposon excision event, and if so, of which family?',
        data        => $transposon && "$transposon",
    };
}

# transposon_insertion
# This method returns a data structure describing
# if the variation was generated by a transposon insertion event.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/transposon_insertion

sub transposon_insertion {
    my ($self) = @_;

    my $transposon = $self ~~ 'Transposon_insertion';
    return {
        description => 'was the variation generated by a transposon insertion event, and if so, of which family?',
        data        => $transposon && "$transposon",
    };
}



# derived_from { }
# This method returns a data structure containing
# what variation the variation in question was derived from.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/derived_from

sub derived_from {
    my ($self) = @_;

    return {
        description => 'variation from which this one was derived',
        data        => $self->_pack_obj($self ~~ 'Derived_from'),
    };
}


# derivative { }
# This method returns a data structure containing
# variations derived from this variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/derivative

sub derivative {
    my ($self) = @_;

    my $derivatives = $self->_pack_objects($self ~~ '@Derivative');
    return {
        description => 'variations derived from this variation',
        data => %$derivatives ? $derivatives : undef,
    };
}




############################################################
#
# The Location Widget
#
############################################################

# genomic_position {}
# Supplied by Role

# genetic_position {}
# Supplied by Role

# genomic_image {}
# Supplied by Role

sub _build_genomic_position {
    my ($self) = @_;

    my @positions = $self->_genomic_position($self->_segments, \&_pad_short_seg_simple);

    return {
        description => 'The genomic location of the sequence',
        data        => @positions ? \@positions : undef,
    };
}

sub _build_tracks {
    my ($self) = @_;
    my @tracks;
    if ($self->_parsed_species eq 'c_elegans') {
	@tracks = qw(GENES VARIATIONS_CLASSICAL_ALLELES VARIATIONS_HIGH_THROUGHPUT_ALLELES VARIATIONS_POLYMORPHISMS VARIATIONS_CHANGE_OF_FUNCTION_ALLELES VARIATIONS_CHANGE_OF_FUNCTION_POLYMORPHISMS VARIATIONS_TRANSPOSON_INSERTION_SITES VARIATIONS_MILLION_MUTATION_PROJECT);
    } elsif ($self->_parsed_species eq 'c_briggsae') {
	@tracks = qw(GENES VARIATIONS_POLYMORPHISMS);
    } else {
	@tracks = qw/GENES/;
    }

    return {
        description => 'tracks displayed in GBrowse',
        data => \@tracks
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
        ($segment) = $self->gff_dsn->segment($ref,$abs_start - $split, $abs_stop + $split);

        ($position) = $self->_genomic_position([$segment || ()]);
    }

    return {
        description => 'The genomic location of the sequence to be displayed by GBrowse',
        data        => $position,
    };
}

sub _build__segments {
    my ($self) = @_;
    my $object = $self->object;
    my @segments = grep { !("$_" =~ /PCoF/) } $self->gff_dsn->get_features_by_attribute( variation => $object );
    return \@segments;
}


############################################################
#
# MOLECULAR_DETAILS
#
############################################################

# sequencing_status { }
# This method returns a data structure containing
# the sequencing status of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/sequencing_status

sub sequencing_status {
    my ($self) = @_;

    my $status = $self ~~ 'SeqStatus';
    $status =~ s/_/ /g;
    return {
        description => 'sequencing status of the variation',
        data        => $status && "$status",
    };
}


# nucleotide_change { }
# This method returns a data structure containing
# both the wild type and mutant variants of the
# variation, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/nucleotide_change

# Returns a data structure containing
# wild type sequence - the wild type (or reference) sequence
# mutant sequence - the mutant sequence
# wild type label - the source (background) of the wild type sequence
# mutant label    - the source (background) of the mutation

sub nucleotide_change {
    my ($self) = @_;

    # Nucleotide change details (from ace)
    my @variations = $self->_compile_nucleotide_changes($self->object);

    return {
        description => 'raw nucleotide changes for this variation',
        data        => @variations ? \@variations : undef,
    };
}


# amino_acid_change { }
# This method returns a data structure containing the amino
# acid change (and transcript IDs) for nonsense and missense
# alleles.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/amino_acid_change

sub amino_acid_change {
    my ($self) = @_;

    # Amino acid changes (potentially) for each transcript.
    my $variations = $self->_compile_amino_acid_changes($self->object);
    return {
        description => 'amino acid changes for this variation, if appropriate',
        data        => $variations && @$variations ? $variations : undef,
    };
}

# flanking_sequences { }
# This method returns a data structure containing
# sequences immediately 5' and 3' of the variation,
# if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/flanking_sequences

sub flanking_sequences {
    my ($self) = @_;
    my $object = $self->object;

    my $left_flank  = $object->Flanking_sequences(1);
    my $right_flank = $object->Flanking_sequences(2);

    return {
        description => 'sequences flanking the variation',
        data        => {
            left_flank  => $left_flank && "$left_flank",
            right_flank => $right_flank && "$right_flank",
        },
    };
}

# cgh_deleted_probes { }
# This method returns a data structure containing
# deleted probes detected by comparative genome
# hybridization (CGH).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/cgh_deleted_probes

sub cgh_deleted_probes {
    my ($self) = @_;
    my $object = $self->object;

    my $left_flank  = $object->CGH_deleted_probes(1);
    my $right_flank = $object->CGH_deleted_probes(2);

    return {
        description => 'probes used for CGH of deletion alleles',
        data        => ($left_flank || $right_flank) ? {
            left_flank  => $left_flank && "$left_flank",
            right_flank => $right_flank && "$right_flank",
        } : undef,
    };
}

# cgh_flanking_probes { }
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/cgh_flanking_probes

sub cgh_flanking_probes {
    my ($self) = @_;
    my $object = $self->object;

    my $left_flank  = $object->CGH_flanking_probes(1);
    my $right_flank = $object->CGH_flanking_probes(2);

    return {
        description => 'probes used for CGH of deletion alleles',
        data        => ($left_flank || $right_flank) ? {
            left_flank  => $left_flank && "$left_flank",
            right_flank => $right_flank && "$right_flank",
        } : undef,
    };
}


# context { }
# This method returns a data structure containing
# strings reconstructing the sequence of the variation
# in genomic context (if known).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/context

# Show the variation in context.
sub context {
    my ($self) = @_;

    my $name   = $self ~~ 'Public_name';

    # Get start and end to calculate length before generating sequence string
    my (undef, undef, $start, $end) = $self->object->Source_location->row if $self->object->Source_location;

    # Display a formatted string that shows the mutation in context
    my $flank = 250;
    my $seqLen = abs($end - $start) + 1;
    my ($wt,$mut,$wt_full,$mut_full,$debug, $placeholder);
    if ($seqLen < 1000000){
        ($wt,$mut,$wt_full,$mut_full,$debug)  = $self->_build_sequence_strings;
    }else{
        my $nf = new Number::Format();
        $placeholder = $seqLen ? {seqLength => $nf->format_number($seqLen) } : undef;
    }
    return {
        description => 'wild type and variant sequences in genomic context',
        data        => ($wt || $wt_full || $mut || $mut_full || $placeholder) ? {
            wildtype_fragment => $wt,
            wildtype_full     => $wt_full,
            mutant_fragment   => $mut,
            mutant_full       => $mut_full,
            wildtype_header   => "Wild type N2, with $flank bp flanks",
            mutant_header     => "$name with $flank bp flanks",
            placeholder       => $placeholder
        } : undef,
    };
}

# deletion_verification { }
# This method returns a data structure containing
# whether or not a deletion allele has been verified.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/deletion_verification

sub deletion_verification {
    my ($self) = @_;
    my $deletion = $self ~~ 'Deletion_verification';
    my $evidence = $self->_get_evidence($deletion);
    return {
        description => 'the method used to verify deletion alleles',
        data        => $evidence ? {text => "$deletion", evidence => $evidence } : $deletion && "$deletion" || undef,
    };
}

# features_affected { }
# This method returns a data structure containing
# features affected by the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/features_affected

# Display the position of the variation within a number of features
# Foreach item that the variation is known to affect, display a table
# with variation coordinates relative to the feature
sub features_affected {
    my ($self) = @_;
    my $object = $self->object;

    # This is mostly constructed from Molecular_change hash associated with
    # tags in Affects, with the exception of Clone and Chromosome
    my $affects = {};

    # Clone and Chromosome are calculated, not provided in the DB.
    # Feature and Interactor are handled a bit differently.

    foreach my $type_affected ($object->Affects) {
        my @rows;
        my $count = $self->_get_count($object, $type_affected);
        my $comment;

        if( $count < 500){
            foreach my $item_affected ($type_affected->col) { # is a subtree
                my $affected_hash  = $self->_pack_obj($item_affected);
                $affected_hash->{item} = $self->_pack_obj($item_affected);
                # Genes ONLY have gene
                if ($type_affected eq 'Gene') {
                    $affected_hash->{entry}++;
                push(@rows, $affected_hash);
                    next;
                }

                my ($protein_effects, $location_effects, $do_translation)
                    = $self->_retrieve_molecular_changes($item_affected);

                $affected_hash->{protein_effects}  = $protein_effects if %$protein_effects;
                $affected_hash->{location_effects} = $location_effects if %$location_effects;

                # Display a conceptual translation, but only for Missense and
                # Nonsense alleles within exons
                if ($type_affected eq 'Predicted_CDS' && $do_translation) {
                    # $do_translation implies $protein_effects
                    if ($protein_effects->{Missense}) {
                        my ($wt_snippet,$mut_snippet,$wt_full,$mut_full)
                            = $self->_do_simple_conceptual_translation(
                                $item_affected,
                                $protein_effects->{Missense}
                              );
                        $affected_hash->{wildtype_conceptual_translation} = $wt_full;
                        $affected_hash->{mutant_conceptual_translation}   = $mut_full;
                    }
                    # what about the manual translation?
                }

                # Get the coordinates in absolute coordinates
                # the coordinates of the containing feature,
                # and the coordinates of the variation WITHIN the feature.
                @{$affected_hash}{qw(abs_start abs_stop fstart fstop start stop)}
                     = $self->_fetch_coords_in_feature($type_affected,$item_affected);
                push(@rows, $affected_hash);
            }
        } else {
            $comment = sprintf("%d (Too many features to display. Download from <a href='/tools/wormmine/'>WormMine</a>.)", $count);
        }
        $affects->{$type_affected} = @rows ? \@rows : ($count > 0) ? $comment : undef;
    } # end of FOR loop

    # Clone and Chromosome are not provided in the DB - we calculate them here.
    foreach my $type_affected (qw(Clone Chromosome)) {
        my @affects_this = $type_affected eq 'Clone'      ? $object->Sequence
                         : $type_affected eq 'Chromosome' ? eval {($object->Sequence->Interpolated_map_position)[0]}
                         :                        ();
        my @rows;
        foreach (@affects_this) {
            next unless $_;
            my $hash = $affects->{$type_affected}->{$_} = $self->_pack_obj($_);
            @{$hash}{qw(abs_start abs_stop fstart fstop start stop)}
                = $self->_fetch_coords_in_feature($type_affected,$_);
            $hash->{item} = $self->_pack_obj($_);
            push(@rows, $hash);
        }
        $affects->{$type_affected} = @rows ? \@rows : undef;
    }

    return {
        description => 'genomic features affected by this variation',
        data        => %$affects ? $affects : undef,
    };
}

# possibly_affects { }
# This method returns a data structure containing
# features that are possibly -- but haven't been
# demonstrated to -- be affected by the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/possibly_affects

sub possibly_affects {
    my ($self) = @_;

    return {
        description => 'genes that may be affected by the variation but have not been experimentally tested',
        data        => $self->_pack_obj($self ~~ 'Possibly_affects'),
    };
}

# flanking_pcr_products { }
# This method returns a data structure containing
# pcr products that flank the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/flanking_pcr_products

sub flanking_pcr_products {
    my ($self) = @_;

    my $packed = $self->_pack_objects($self ~~ '@PCR_product');
    return {
        description => 'PCR products that flank the variation',
        data        => %$packed ? $packed : undef,
    };
}

# affects_splice_site { }
# This method returns a data structure containing
# description if the variation affects splice sites.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/affects_splice_site

# TODO: Needs evidence
sub affects_splice_site {
    my ($self) = @_;

    my ($donor, $acceptor) = ($self ~~ 'Donor', $self ~~ 'Acceptor');
    return {
        description => 'Affects splice site',
        data        => {
            donor    => $donor && "$donor",
            acceptor => $acceptor && "$acceptor",
        },
    };
}

# causes_frameshift { }
# This method returns a data structure containing
# describing if the variation causes a frameshift.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/causes_frameshift

sub causes_frameshift {
    my ($self) = @_;

    my $frameshift = $self ~~ 'Frameshift';
    return {
        description => 'A variation that alters the reading frame',
        data         => $frameshift && "$frameshift",
    };
}

# detection_method { }
# This method returns a data structure containing
# available detection methods for the variation --
# particularly for SNPs.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/detection_method

sub detection_method {
    my ($self) = @_;

    my $detection_method = $self ~~ 'Detection_method';
    return {
        description => 'detection method for polymorphism, typically via sequencing or restriction digest.',
        data        => $detection_method && "$detection_method",
    };
}


############################################################
#
# POLYMORPHISM DETAILS (folded into Molecular Details widget)
#
############################################################

# polymorphism_type { }
# This method returns a data structure containing
# the broad classification of the variation if it is
# a polymorphism, for example (SNP|RFLP).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymoprhism_type

sub polymorphism_type {
    my ($self) = @_;
    my $object = $self->object;

    # What type of polymorphism is this?
    my $type = $object->SNP ? $object->RFLP ?  'SNP and RFLP' : 'SNP'
             : $object->Transposon_insertion ? $object->Transposon_insertion
                                               . ' transposon insertion'
             :                                 undef;

    return {
        description => 'the general class of this polymorphism',
        data        => $type,
    };
}

# polymorphism_status { }
# If the variation is a polymorphism, this method
# will return a data structure containing it's status.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymorphism_status

sub polymorphism_status {
    my ($self) = @_;
    my $object = $self->object;

    my $status = $self ~~ 'Confirmed_SNP' ? 'confirmed' : ($object->SNP || $object->RFLP || $object->Transposon_insertion) ? 'predicted' : undef;
    return {
        description => 'experimental status of this polymorphism',
        data        => $status,
    };
}

# reference_strain  { }
# If the variation is a polymorphism, this method
# will return the strains containing the polymorphism.
# NOTE: not really reference strain, but too late to change the subroutine name now
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/reference_strain

sub reference_strain {
    my ($self) = @_;
    my $object = $self->object;

    my @strains = $self->_pack_list([$object->Strain]);

    return {
        description => 'strains that this variant has been observed in',
        data        => @strains ? \@strains : undef,
    };
}

# polymorphism_assays { }
# For variations that are polymorphisms, this method
# will return assays useful for its detection.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/polymorphism_assays

# Details related to assaying polymorphisms
sub polymorphism_assays {
    my ($self) = @_;
    my $object = $self->object;

    my $data;

    my @ref_digests;
    foreach my $enz ($object->Reference_strain_digest(2)) {
        @ref_digests = map {[$enz, $_]} $enz->col;
    }

    my @poly_digests;
    foreach my $enz ($object->Polymorphic_strain_digest(2)) {
        @poly_digests = map {[$enz, $_]} $enz->col;
    }

    foreach my $pcr_product ($object->PCR_product) {
        # If this is an RFLP, extract digest conditions
        my $assay_table;
        my %pcr_data;

        if ($object->RFLP && @ref_digests) {
            my ($ref_digest,$ref_bands)   = @{shift @ref_digests};
            my ($poly_digest,$poly_bands) = @{shift @poly_digests};

            %pcr_data = (
                reference_strain_digest   => $ref_digest,
                reference_strain_bands    => $ref_bands,
                polymorphic_strain_digest => $poly_digest,
                polymorphic_strain_bands  => $poly_bands,

                assay_type                => 'rflp',
            );
        }
        else {
            %pcr_data = (assay_type => 'sequence');
        }

        my ($left_oligo,$right_oligo);
        if (my @oligos = $pcr_product->Oligo) {
            $left_oligo  = $oligos[0]->Sequence;
            $right_oligo = $oligos[1]->Sequence;
        }

        my $pcr_conditions = $pcr_product->Assay_conditions;

        # Fetch the sequence of the PCR_product
        my $sequence = $object->Sequence;

        my $dna;

        if ($sequence && (my $pcr_node = first {$_ eq $pcr_product} $sequence->PCR_product)) {
            my ($start, $stop) = $pcr_node->row or last;
            my $gffdb = $self->gff_dsn or last;
            # TODO: make sure this works with GFF3 - AC
            my ($segment) = eval { $gffdb->segment(
                -name   => $sequence,
                -offset => $start,
                -length => ($stop-$start)
            ) } or last;

            $dna = $segment->dna;
	    }

        $pcr_data{pcr_product} = $self->_pack_obj(
            $pcr_product, undef, # let _pack_obj resolve label
            left_oligo     => $left_oligo && "$left_oligo",
            right_oligo    => $right_oligo && "$right_oligo",
            pcr_conditions => $pcr_conditions && "$pcr_conditions",
            dna            => $dna && "$dna",
        );

        $data->{$pcr_product} = \%pcr_data;
    }

    return {
        description => 'experimental assays for detecting this polymorphism',
        data        => $data,
    };
}

# OOOH!  Need to handle this.
#++ 					 'variation and motif image',p(motif_picture(1,$entry)));



############################################################
#
# The Phenotype Widget
#
############################################################

# nature_of_variation { }
# This method returns a data structure containing
# the nature of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/nature_of_variation

sub nature_of_variation {
    my ($self) = @_;

    # WS230: Mary Ann is cleaning this up. For now we need to.
    # use this heuristic
    my $variation = $self->object;
    my $nature;
    if ($variation->Transposon_insertion(0) && !$variation->Allele(0)) {
	$nature = 'Transposon Insertion';
    } elsif ($variation->Natural_variant(0) && !$variation->SNP(0)) {
	$nature = 'Naturally Occurring Allele';
    } elsif ($variation->Natural_variant(0) && $variation->SNP(0)) {
	$nature = 'SNP';
    } elsif ($variation->Allele(0) && $variation->Natural_variant(0)) {
	$nature = 'Naturally Occurring Allele';
    } elsif ($variation->Allele(0) && $variation->Transposon_insertion(0)) {
	$nature = 'Transposon Insertion';
    } elsif ($variation->SNP(0)) {
	$nature = 'SNP';
    } else {
	$nature = 'Allele';
    }
    return {
	description => 'nature of the variation',
	data        => $nature && "$nature",
    };

#    my $nature = $self ~~ 'Nature_of_variation';
#    return {
#        description => 'nature of the variation',
#        data        => $nature && "$nature",
#    };
}

# dominance { }
# Describes if the variation is dominant or not.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/dominance

# Q: Model needs to be organized under a single Dominance tag
# Q: is this one or many?
sub dominance {
    my ($self) = @_;

    my $object = $self->object;
    my $dominance = $object->Recessive
                  || $object->Semi_dominant
                  || $object->Dominant
                  || eval{$object->Partially_penetrant}
                  || eval{$object->Completely_penetrant};
    # I don't see Partially_penetrant or Completely_penetrant in the model

    return {
        description => 'dominance of the variation',
        data        => $dominance && "$dominance",
    };
}

# phenotype_remark { }
# This method returns a data structure containing
# a brief remark on the phenotype of the variation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/phenotype_remark

sub phenotype_remark {
    my ($self) = @_;

    my $remark = $self ~~ 'Phenotype_remark';
    return {
        description => 'phenotype remark',
        data        => $remark && "$remark",
    };
}

# temperature_sensitivity { }
# This method returns a data structure containing
# the temperature sensitivity of the variation, if known.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/variation/WBVar00143133/temperature_sensitivity

# TODO: needs evidence
sub temperature_sensitivity {
    my ($self) = @_;
    my $object = $self->object;
    my $sensitivity = $object->Cold_sensitive || $object->Heat_sensitive;

    return {
        description => 'temperature sensitive',
        data        => $sensitivity && "$sensitivity",
    };
}

# phenotypes {}
# Supplied by Role

# phenotypes_not_observed {}
# Supplied by Role

############################################################
#
# PRIVATE METHODS
#
############################################################

{ # begin _retrieve_molecular_changes block
my %associated_meta = ( # this can be used to identify protein effects
    Missense    => [qw(position description)],
    Silent      => [qw(description)],
    Frameshift  => [qw(description)],
    Nonsense    => [qw(subtype description)],
    Splice_site => [qw(subtype description)],
    );

sub _retrieve_molecular_changes {
    my ($self, $changed_item) = @_; # actually, changed_item is a subtree

    my $do_translation;

    my (%protein_effects, %location_effects);
    foreach my $change_type ($changed_item->col) {
        $do_translation++ if $change_type eq 'Missense' || $change_type eq 'Nonsense';

        my @raw_change_data = $change_type->row;
        shift @raw_change_data; # first one is the type

        my %change_data;
        my $keys = $associated_meta{$change_type} || [];
        @change_data{@$keys, 'evidence_type', 'evidence'}
	= map {"$_"} @raw_change_data;

	# This should be handled by change_data above. Oh well.
	if ($change_type eq 'Missense') {
	    my ($aa_position,$aa_change_string) = $change_type->right->row;
	    $aa_change_string =~ /(.*)\sto\s(.*)/;
	    $change_data{aa_change} = "$1$aa_position$2";
	}  elsif ($change_type eq 'Nonsense') {
	    # "Position" here really one of Amber, Ochre, etc.
	    my ($aa_position,$aa_change) = $change_type->right->row;
	    $change_data{aa_change} = "$aa_change";
	}

        if ($associated_meta{$change_type}) { # only protein effects have extra data
            $protein_effects{$change_type} = \%change_data;
        }
        else {
            $location_effects{$change_type} = \%change_data;
        }
    }

    return (\%protein_effects, \%location_effects, $do_translation);
}
} # end of _retrieve_molecular_changes block



sub _compile_amino_acid_changes {
    my ($self, $object) = @_;

    my @data;
    foreach my $type_affected ($object->Affects) {
        foreach my $item_affected ($type_affected->col) { # is a subtree
            foreach my $change_type ($item_affected->col) {
                # This should be handled by change_data above. Oh well.
                my $aa_change;
                if($change_type->right){
                    if ($change_type eq 'Missense') {
                        my ($aa_position,$aa_change_string) = $change_type->right->row;
                        $aa_change_string =~ /(.*)\sto\s(.*)/;
                        $aa_change = "$1$aa_position$2";
                    }  elsif ($change_type eq 'Nonsense') {
                        # "Position" here really one of Amber, Ochre, etc.
                        if($change_type->right){
                            my ($aa_position,$aa_change_string) = $change_type->right->row;
                            $aa_change = $aa_change && "$aa_change";
                        }
                    }
                }
                if ($aa_change) {
                    push @data,{ transcript => $self->_pack_obj($item_affected),
                    amino_acid_change => "$aa_change" };
                }
            }
        }
    }
    return \@data;
}



# What is the length of the mutation?
sub _compile_nucleotide_changes {
    my ($self,$object) = @_;
    my @types = $object->Type_of_mutation;
    my @variations;

    # Some variation objects have multiple types
    foreach my $type (@types) {
        my ($mut,$wt,$mut_label,$wt_label);

        # Simple insertion?
        #     wt sequence = empty
        # mutant sequence = name of transposon or the actual insertion sequence
        if ($type =~ /insertion/i) {
            $wt = '';

            # Is this a transposon insertion?
            # mutant sequence just the name of the transposon
            if ($object->Transposon_insertion || $object->Method eq 'Transposon_insertion') {
                $mut = $object->Transposon_insertion;
                $mut ||= 'unknown' if $object->Method eq 'Transposon_insertion';
            }
            else {
                # Return the full sequence of the inertion.
                $mut = $type->right;
            }

        }
        elsif ($type =~ /deletion/i) {
            # Deletion.
            #     wt sequence = the deleted sequence
            # mutant sequence = empty
            $mut = '';

            # We need to extract the sequence from a GFF store.
            # Get a segment corresponding to the deletion sequence

            my $segment = $self->_segments->[0];
            if ($segment) {
                $wt  = $segment->dna;
            }

            # CGH tested deletions.
            $type = "definite deletion" if  ($object->CGH_deleted_probes(1));

            # Substitutions
            #     wt sequence = um, the wt sequence
            # mutant sequence = the mutant sequence
        }
        elsif ($type =~ /substitution/i) {
            my $change;
            if($change = $type->right) {
                ($wt,$mut) = eval { $change->row };

                # How to know if ntides need to be revcomped?
                # copy code from below, big ugly mess.
                # Maybe we should store strand info for substitutions in ace?
                my $species = $self->_parsed_species;
                my $db_obj  = $self->gff_dsn($species); # Get a WormBase::API::Service::gff object
                my $db      = $db_obj->dbh;

                my $segment    = $self->_segments->[0];

                return unless $segment;

                my $sourceseq  = $segment->seq_id;
                my ($chrom,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($segment);

                my ($full_segment) = $db->segment($sourceseq,$abs_start,$abs_stop);
                my $plus_strand_dna = $full_segment->dna;
                # # test if the wildtype seq matches its location in the dna
                if( uc($wt) ne uc($plus_strand_dna) ){
                    my $rc_wt = &reverse_complement($wt);
                    if( uc($rc_wt) eq uc($plus_strand_dna) ){
                        $wt = $rc_wt;
                        $mut = &reverse_complement($mut);
                    }else{
                       die "Neither wild type sequence [".$wt."] nor reverse complment matches DNA [".$plus_strand_dna."]";
                    }
                }
            }

            # Ack. Some of the alleles are still stored as A/G.
            unless ($wt && $mut) {
                $change =~ s/\[\]//g;
                ($wt,$mut) = split("/",$change);
            }
        }


        # Set wt and mutant labels
        # (simplified for #3201)
        # if ($object->SNP(0) || $object->RFLP(0)) {
        #     $wt_label = 'reference';
        #     $mut_label = $object->Strain; # CB4856, 4857, etc
        # }
        # else {
            $wt_label  = 'wild type';
            $mut_label = 'variant';
        # }

        push @variations, {
            type           => "$type",
            wildtype       => "$wt",
            mutant         => "$mut",
            wildtype_label => $wt_label,
            mutant_label   => "$mut_label",
        };
    }
    return @variations;
}


# Fetch the coordinates of the variation in a given feature
# Much in here could be generic
sub _fetch_coords_in_feature {
    my ($self,$tag,$entry) = @_;

    my $db = $self->gff_dsn;

    my $variation_segment = $self->_segments->[0] or return;

    # Kludge for chromosomes
    my $class = $tag eq 'Chromosome' ? 'Sequence' : $entry->class;
    # is it really okay to ignore multiple results and arbitarily use the first one?
    my ($containing_segment) = $db->segment($entry) or return;
    # consider caching results?

    # Set the refseq of the variation to the containing segment
    $variation_segment->refseq($containing_segment);

    my ($chrom,$fabs_start,$fabs_stop,$fstart,$fstop) = $self->_seg2coords($containing_segment);
    my ($var_chrom,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($variation_segment);
    ($start,$stop) = ($stop,$start) if ($start > $stop);
    return ($abs_start,$abs_stop,$fstart,$fstop,$start,$stop);
}

sub _do_simple_conceptual_translation {
    my ($self, $cds, $datahash) = @_;

    my ($pos, $formatted_aa_change) = @{$datahash}{'position', 'description' }
    or return;
    my $wt_protein = eval { $cds->Corresponding_protein->asPeptide }
    or return;

    my $object = $self->object;

    # De-FASTA
    $wt_protein =~ s/^>.*//;
    $wt_protein =~ s/\n//g;

    $formatted_aa_change =~ /(.*) to (.*)/;
    my $wt_aa  = $1;
    my $mut_aa = $2;

    # if ($type eq 'Nonsense') {
    #   $mut_aa = '*';
    # }

    # Substitute the mut_aa into the wildtype protein
    my $mut_protein = $wt_protein;
    my ($wt_aa_start, $wt_protein_fragment, $mut_protein_fragment);

    substr($mut_protein,($pos-1),1,$mut_aa);

    $wt_aa_start = $pos;

    # Create short strings of the proteins for display
    $wt_protein_fragment = ($pos - 19)
        . '...'
        . substr($wt_protein,$pos - 20,19)
        . ' '
        . '<b>' . substr($wt_protein,$pos-1,1) . '</b>'
        . ' '
        . substr($wt_protein,$pos,20)
        . '...'
        . ($pos + 19);
    $mut_protein_fragment = ($pos - 19)
        . '...'
        . substr($mut_protein,$pos - 20,19)
        . ' '
        . '<b>' . substr($mut_protein,$pos-1,1) . '</b>'
        . ' '
        . substr($mut_protein,$pos,20)
        .  '...'
        . ($pos + 19);

    my $wt_trans = "> $cds"
	. $self->_do_markup($wt_protein, $pos-1, $wt_aa, undef, 'is_peptide');
    my $mut_trans = "> $cds ($object: $formatted_aa_change)"
	. $self->_do_markup($mut_protein, $pos-1, $mut_aa, undef, 'is_peptide');

    return ($wt_protein_fragment, $mut_protein_fragment, $wt_trans, $mut_trans);
}


# Markup features relative to the CDS or to raw genomic features
sub _do_markup {
    my ($self,$seq,$var_start,$variation,$flank_length,$is_peptide) = @_;
    my $object = $self->object;

    # Here, variation might be a specially formatted string (ie '----' for a deletion)
    my @markup;
    my $markup = Bio::Graphics::Browser2::Markup->new;
    $markup->add_style('utr'  => 'FGCOLOR gray');
    $markup->add_style('cds0'  => 'BGCOLOR yellow');
    $markup->add_style('cds1'  => 'BGCOLOR orange');
    $markup->add_style('space' => ' ');
    $markup->add_style('unknown_mutation'       => 'background-color:#FF8080; text-transform:uppercase;');
    $markup->add_style('tandem_duplication'     => 'background-color:#FF8080; text-transform:uppercase;');
    $markup->add_style('substitution'     => 'background-color:#FF8080; text-transform:uppercase;');
    $markup->add_style('deletion'     => 'background-color:#FF8080; text-transform:uppercase;');
    $markup->add_style('insertion'     => 'background-color:#FF8080; text-transform:uppercase;');
    $markup->add_style('deletion_with_insertion'  => 'background-color: #FF8080; text-transform:uppercase');
    if ($object->Type_of_mutation eq 'Insertion') {
        $markup->add_style('flank' => 'background-color:yellow;font-weight:bold;text-transform:uppercase');
    }
    else {
        $markup->add_style('flank' => 'background-color:yellow');
    }
    # The extra space is required here when used in non-pre-formatted text!

    my $var_stop = length($variation) + $var_start;

    # Substitutions start and stop at the same position
    if ($var_stop == $var_start) {
      $seq = substr($seq, 0, $var_start) . '-' . substr($seq, $var_stop);
      $var_stop++;
    }

    # Markup the variation as appropriate
    push (@markup,[lc($object->Type_of_mutation || 'unknown_mutation'),$var_start,$var_stop]);

    # Add spacing for peptides
    if ($is_peptide) {
        for (my $i=0; $i < length $seq; $i += 10) {
            push @markup,[$i % 80 ? 'space' : 'space',$i];
        }
    }
    else {
        for (my $i=80; $i < length $seq; $i += 80) {
            push @markup,['space',$i];
        }
        #       push @markup,map {['newline',80*$_]} (1..length($seq)/80);
    }

    if ($flank_length) {
        push @markup,['flank',$var_start - $flank_length + 1,$var_start];
        push @markup,['flank',$var_stop,$var_stop + $flank_length];
    }

    $markup->markup(\$seq,\@markup);
    return $seq;
}

# Build short strings (wild type and mutant) flanking
# the position of the mutant sequence in support of the context() method.
# If a mutation sequence (insertion or deletion) exceeds
# INDEL_DISPLAY_LIMIT, a string will be inserted unless
# the --all option is supplied.
# Options:
# --all    Don't truncate long strings: return the full flank-mutant-flank
# --boldface Boldface the mutation
# --flank amount of flank to include. Defaults to SNIPPET_LENGTH
#
# Returns (wt(+), mut(+), wt(-), mut(-));
sub _build_sequence_strings {
    my ($self,@p) = @_;
    my ($with_markup,$flank);

    # Get a GFFdb handle - I'm not sure how to do this in the API.
    my $species = $self->_parsed_species;
    my $db_obj  = $self->gff_dsn($species); # Get a WormBase::API::Service::gff object
    my $db      = $db_obj->dbh;

    my $object     = $self->object;
    my $segment    = $self->_segments->[0];
    return unless $segment;

    my $sourceseq  = $segment->seq_id;
    my ($chrom,$abs_start,$abs_stop,$start,$stop) = $self->_seg2coords($segment);

    my $debug;

    # Coordinates are sometimes reported on the minus strand
    # We will report all sequence strings on the plus strand instead.
    my $strand = ($segment->strand > 0) ? '+' : '-';
    # Fetch a segment that spans the mutation with the appropriate flank
    # on the plus strand

    # The amount of flanking sequence to recover should be configurable
    # Right now, it is hardcoded for 500 bp
    my $offset = 500;
    my ($full_segment) = $db->segment($sourceseq, $abs_start - $offset, $abs_stop  + $offset);
    my $dna = $full_segment->dna;
     $dna = $db->fetch_sequence($sourceseq, $abs_start - $offset, $abs_stop  + $offset);

    # MOVE INTO TEST
    # $debug .= "WT SNIPPET DNA FROM GFF: $dna" . br if DEBUG_ADVANCED;
    # Visit each variation and create a formatted string
    my ($wt_fragment,$mut_fragment,$wt_plus,$mut_plus);
    my @variations = $self->_compile_nucleotide_changes($object);

    foreach my $variation (@variations) {
        my $type = $variation->{type};
        my $wt   = $variation->{wildtype};
        my $mut  = $variation->{mutant};
        my $extracted_wt;
        if ($type =~ /insertion/i) {
            $extracted_wt = '-';
        }
        else {

            my ($seg) = $db->segment($sourceseq,$abs_start,$abs_stop);
            $extracted_wt = $seg->dna;
        }

        # Does the sequence we have extracted match that stored in the
        # database?  Stated another way, is the mutation reported on the
        # plus strand?

        # Insertions will have no sequence and I should not be able to
        # extract any either (We use logical "or" here to check for the
        # $strand flag. Sometimes insertions or deletions will have no
        # sequence.

        if (($wt eq $extracted_wt && $strand ne '-') || ($type =~ /insertion/i)) {
            # Yes, it has.  Do nothing.
        }
        else {
            # MOVE INTO TEST
            # $debug .= "-----> TRANSCRIPT ON - strand; revcomping" if DEBUG_ADVANCED;

            # The variation and flanks have been reported on the minus strand
            # Reverse complement the mutant sequence
            $strand = '-';  # Set the $strand flag if not already set.
            unless ($mut =~ /transposon/i) {
                $mut = reverse $mut;
                $mut =~ tr/[acgt]/[tgca]/;

                $wt = reverse $wt;
                $wt =~ tr/[acgt]/[tgca]/;
            }
        }

        # Keep the full string of all variations on the plus strand
        $wt_plus  .= $wt;
        $mut_plus .= $mut;

        # What is the type of mutation? If deletion or insertion,
        # check the length of the partner, then format appropriately
        # TODO: The INDEL_DISPLAY_LIMIT is hard coded
        my $INDEL_DISPLAY_LIMIT = 100;
        if (length $mut > $INDEL_DISPLAY_LIMIT || length $wt > $INDEL_DISPLAY_LIMIT) {
            if ($type =~ /deletion/i) {
                my $target = length ($wt) . " bp " . lc($type);
                $wt_fragment  .= "[$target]";
                $mut_fragment .= '-' x (length ($target) + 2);
            }
            elsif ($type =~ /insertion/i) {
                my $target;
                if ($mut =~ /transposon/i) { # String representing transposon insertions
                    $target = $mut;
                }
                else {
                    $target = length ($mut) . " bp " . lc($type);
                }
                #  $mut_fragment .= '[' . a({-href=>$href,-target=>'_blank'},$target) . ']';
                $mut_fragment .= "[$target]";
                #  $wt_fragment  .= '-' x (length($mut_fragment) + 2);
                $wt_fragment  .= '-' x (length($mut_fragment));
            }
        }
        else {
            # We are less than 100 bp, go ahead and use it.
            $wt_fragment  .= ($wt  eq '-') ? '-' x length $mut  : $wt;
            $mut_fragment .= ($mut eq '-') ? '-' x length $wt : $mut;
        }
    }

    # Coordinates of the mutation within the segment
    my ($mutation_start,$mutation_length);
    if ($strand eq '-') {
        # This works for e205 substition (-)
        $mutation_start   = $offset;
        $mutation_length  = length($wt_plus);
    }
    else {
        # SETTING 1 - works for:
        #   ca16 indel(+)
        #   cxP622 insertion(+)
        $mutation_start  = $offset + 1;
        $mutation_length = length($wt_plus) - 1;

        # SETTING 2 - works for:
        #     tm728 (indel)
        #     ok431 (indel)
        $mutation_start  = $offset;
        $mutation_length = length($wt_plus) - 1;

        # SETTING 3 - works for:
        #     cn28 (unknown transposon insertion)
        #$mutation_start  = $offset + 2;
        #$mutation_length = length($wt_full) - 1;

        # SETTING 4 - works for:
        #      bm1 (indel)
        $mutation_start  = $offset;
        $mutation_length = length($wt_plus);
    }

    # test if the wildtype seq matches its location in the dna

    my $dna_span = substr($dna, $mutation_start, $mutation_length);
    if( uc($wt_plus) ne uc($dna_span) ){
        my $rc_wt_plus = &reverse_complement($wt_plus);
        if( uc($rc_wt_plus) eq uc($dna_span) ){
            $wt_plus = $rc_wt_plus;
            $mut_plus = &reverse_complement($mut_plus);
        }else{
            die "Neither wild type sequence [".$wt_plus."] nor reverse complment matches DNA [".$dna_span."]";
        }
    }

    # TODO: Make the snippet length configurable.
    my $SNIPPET_LENGTH = 100;
    $flank ||= $SNIPPET_LENGTH;

    my $insert_length = (length $wt_fragment > length $mut_fragment) ? length $wt_fragment : length $mut_fragment;
    my $flank_length = int(($flank - $insert_length) / 2);

    # The amount of flank to fetch is based on the middle segment
    my $left_flank  = substr($dna,$mutation_start - $flank_length,$flank_length);
    my $right_flank = substr($dna,$mutation_start + $mutation_length,$flank_length);

    # MOVE INTO TEST
    #    if (DEBUG_ADVANCED) {
    #   #      print "right flank : $right_flank",br;
    #   $debug .= "WT PLUS STRAND .................. : $wt_plus"  . br;
    #   $debug .= "MUT PLUS STRAND ................. : $mut_plus" . br;
    #     }

    # Mark up the reported flanking sequences in the full sequence
    my ($reported_left_flank,$reported_right_flank) = ($object->Flanking_sequences(1),$object->Flanking_sequences(2));
    #    my $left_length = length($reported_left_flank);
    #    my $right_length = length($reported_right_flank);
    $reported_left_flank = (length $reported_left_flank > 25) ? substr($reported_left_flank,-25,25) :  $reported_left_flank;
    $reported_right_flank = (length $reported_right_flank > 25) ? substr($reported_right_flank,0,25) :  $reported_right_flank;

    # Create a full length mutant dna string so that I can mark it up.
    my $mut_dna =
        substr($dna,$mutation_start - 500,500)
        . $mut_plus
        . substr($dna,$mutation_start + $mutation_length,500);


    my $wt_full = $self->_do_markup($dna,$mutation_start,$wt_plus,length($reported_left_flank));
    my $mut_full = $self->_do_markup($mut_dna,$mutation_start,$mut_plus,length($reported_right_flank));
    # TO DO: This markup belongs as part of the view, not here.
    # Return the full sequence on the plus strand
    # if ($with_markup) {
    #     my $wt_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},uc($wt_fragment)),
    #                       lc($right_flank));
    #     my $mut_seq = join(' ',lc($left_flank),span({-style=>'font-weight:bold'},
    #                                                 uc($mut_fragment)),lc($right_flank));
    #     return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    # }
    # else {
    my $wt_seq  = lc join('',$left_flank,$wt_plus,$right_flank);
    my $mut_seq = lc join('',$left_flank,$mut_plus,$right_flank);


    return ($wt_seq,$mut_seq,$wt_full,$mut_full,$debug);
    # }
}

sub reverse_complement {
        my $dna = shift;

    # reverse the DNA sequence
        my $revcomp = reverse($dna);

    # complement the reversed DNA sequence
        $revcomp =~ tr/ACGTacgt/TGCAtgca/;
        return $revcomp;
}

__PACKAGE__->meta->make_immutable;

1;
