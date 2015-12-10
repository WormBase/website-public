package WormBase::API::Object::Pseudogene;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';
with 'WormBase::API::Role::Variation';
with 'WormBase::API::Role::Sequence';
with 'WormBase::API::Role::Feature';


=pod

=head1 NAME

WormBase::API::Object::Pseudogene

=head1 SYNPOSIS

Model for the Ace ?Pseudogene class.

=head1 URL

http://wormbase.org/species/*

=cut

has '_alleles' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__alleles',
);

sub _build__alleles {
    my ($self) = @_;
    my $object = $self->object;

    my $count = $self->_get_count($object, 'Variation');
    my @alleles;
    my @polymorphisms;
    unless ($count > 5000) {
      my @all = $object->Variation;

      if($count < 1000){
          foreach my $allele (@all) {
              (grep {/SNP|RFLP/} $allele->Variation_type) ?
                    push(@polymorphisms, $self->_process_variation($allele)) :
                    push(@alleles, $self->_process_variation($allele));
          }
      }else{
          foreach my $allele (@all) {
              (grep {/SNP|RFLP/} $allele->Variation_type) ?
                    push(@polymorphisms, $self->_pack_obj($allele)) :
                    push(@alleles, $self->_pack_obj($allele));
          }
      }
    }

    return {
        alleles        => @alleles ? \@alleles : $count,
        polymorphisms  => @polymorphisms ? \@polymorphisms : $count,
    };

}

has '_length' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__length',
);

sub _build__length{
    my ($self) = shift;
    my $object = shift || $self->object;

    my $length = 0;
    my @exons = $object->Source_exons;
    foreach my $exon (@exons){
        my $start =  $exon;
        my $end = $exon->right;
        $length += $end - $start + 1;
    }
    return $length;
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



=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>




# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

#######################################
#
# The Overview widget
#
#######################################

# parent_sequence { }
# This method will return a data structure containing
# the parent sequence of the pseudogene

sub parent_sequence {
    my $self      = shift;
    my $object = $self->object;
    return {
        description => 'parent sequence of this gene',
        data        => $self->_pack_obj($object->Sequence),
    };
}

# taxonomy {}
# Supplied by Role

# from_lab {}
# This returns the laboratory of origin
sub from_lab{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "The laboratory of origin",
        data => $self->_pack_obj($object->From_laboratory)
    };
}

sub gene{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "Gene corresponding to this pseudogene",
        data => $self->_pack_obj($object->Gene)
    };
}

sub transposon{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "Transposon corresponding to this pseudogene",
        data => $self->_pack_obj($object->Corresponding_transposon)
    };
}

sub brief_id{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "Short identification for this pseudogene",
        data => $object->Brief_identification ?
            ''. $object->Brief_identification : undef
    };
}

sub type{
    my ($self) = @_;
    my $object = $self->object;

    my $type = $object->Type;
    if($type){
        $type =~ s/_/ /g;
    }

    return {
        description => "The type of the pseudogene",
        data => "$type" ? "$type" : undef
    };
}

sub related_seqs{
    my ($self) = @_;
    my $object = $self->object;

    my @rows = ();

    my @genes = $object->Gene;
    foreach my $gene (@genes){
        foreach my $pg ($gene->Corresponding_pseudogene){
            my %data = ();
            my $gff   = $self->_fetch_gff_gene($gene) or next;

            push( @rows, {
                gene_len    => $gff->stop - $gff->start + 1,
                pg_len      => $self->_build__length($pg),
                gene        => $self->_pack_obj($gene),
                pseudogene  => $self->_pack_obj($pg)
            } );
        }
    }

    return {
        description => "Sequences related to this pseudogene",
        data => @rows ? \@rows : undef
    };
}

#######################################
#
# The Expression widget
#
#######################################

sub microarray_results{
    my ($self) = @_;
    my $object = $self->object;

    return {
        description => "Microarray results",
        data => $self->_pack_objects([$object->Microarray_results])
    };
}

#######################################
#
# The Genetics widget
#
#######################################

# alleles { }
# This method will return a complex data structure
# containing alleles of the gene (but not including
# polymorphisms or other natural variations.
sub alleles{
    my ($self) = @_;
    my $object = $self->object;

    my $count = $self->_alleles->{alleles};
    my @alleles = @{$count} if(ref($count) eq 'ARRAY');

    return {
        description => "Alleles associated with this pseudogene",
        data        => @alleles ? \@alleles : $count > 0 ? "$count found" : undef
    };
}

# polymorphisms { }
# This method will return a complex data structure
# containing polymorphisms and natural variations
sub polymorphisms{
    my ($self) = @_;
    my $object = $self->object;

    my $count = $self->_alleles->{polymorphisms};
    my @polymorphisms = @{$count} if(ref($count) eq 'ARRAY');

    return {
        description => "Polymorphisms associated with this pseudogene",
        data        => @polymorphisms ? \@polymorphisms : $count > 0 ? "$count found" : undef
    };

}

#######################################
#
# The Reagents widget
#
#######################################

# matching_cdnas { }
# This method will return a data structure containing
# a list of cDNAs mapped to the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/matching_cdnas

sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %unique;
    my @mcdnas = map {$self->_pack_obj($_)} grep {!$unique{$_}++} $object->Matching_cDNA ;
    return { description => 'cDNAs matching this pseudogene',
             data        => @mcdnas ? \@mcdnas : undef };
}

# sage_tags { }
# This method will return a data structure containing
# Serial Analysis of Gene Expresion (SAGE) tags
# that map to the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/sage_tags

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;

    my @sage_tags = map {$self->_pack_obj($_)} $object->SAGE_tag;

    return {  description =>  "SAGE tags identified",
              data        =>  @sage_tags ? \@sage_tags : undef
    };
}

#######################################
#
# The Sequences widget
#
#######################################

# print_sequence {}
# Supplied by Role

# strand {}
# Supplied by Role

# predicted_exon_structure { }
# This method will return a data structure listing
# the exon structure contained within the sequence.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transcript/JC8.10a/predicted_exon_structure

sub predicted_exon_structure {
    my ($self) = @_;
    my $object = $self->object;

    my $index = 1;
    my @exons = map {
        my ($es,$ee) = $_->row;
        {
            no      => $index++,
            start   => "$es" || undef,
            end     => "$ee" || undef,
            len     => "$es" && "$ee" ? $ee-$es+1 : undef
        };
    } $object->get('Source_Exons');

    return { description => 'predicted exon structure within the sequence',
             data        => @exons ? \@exons : undef };
}


#######################################
#
# The Location Widget
#
#######################################

# genomic_position { }
# Supplied by Role

sub _build_genomic_position {
    my ($self) = @_;
    my @pos = $self->_genomic_position([ $self->_longest_segment || () ]);
    return {
        description => 'The genomic location of the sequence',
        data        => @pos ? \@pos : undef,
    };
}

# genetic_position { }
# Supplied by Role

# sub genomic_image { }
# Supplied by Role


# Sample wrapper function to copy
# replace the xxx's with stuff
0 if <<'SAMPLE_FUNC';
sub xxx{
    my ($self) = @_;
    my $object = $self->object;


    return {
        description => "xxx",
        data => xxx
    };
}
SAMPLE_FUNC

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
    return [map {$_->absolute(1);$_} sort {$b->length<=>$a->length} $self->gff->segment($object->class => $object)];
}

# Find the longest GFF segment
sub _longest_segment {
    my ($self) = @_;
    # Uncloned genes will NOT have segments associated with them.
    my ($longest)
        = sort { $b->stop - $b->start <=> $a->stop - $a->start}
    @{$self->_segments} if $self->_segments;

    return $longest;
}

sub _build_tracks {
    my ($self) = @_;

    print $self->_parsed_species,"\n"; # DELETE

    return {
        description => 'tracks to display in GBrowse',
        data => $self->_parsed_species =~ /elegans/ ? [qw(GENES)] : undef,
    };
}


__PACKAGE__->meta->make_immutable;

1;
