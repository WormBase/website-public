package WormBase::API::Object::Clone;

use Moose;

extends 'WormBase::API::Object';
with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Position';

=pod

=head1 NAME

WormBase::API::Object::Clone

=head1 SYNPOSIS

Model for the Ace ?Clone class.

=head1 URL

http://wormbase.org/species/*/clone

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
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# type { }
# This method will return a data structure containing
# the general type of this clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/type

sub type {
    my ($self) = @_;
    
    my $type = $self ~~ 'Type';
    return { description => 'The type of this clone',
	     data		=> $type && "$type" };
}

sub url {
    my ($self) = @_;
    
    my $url = $self ~~ 'Url';
    return { description => 'The website for this clone',
         data       => $url && "$url" };
}

sub in_strain {
    my ($self) = @_;
    
    my $strain = $self ~~ 'In_strain';
    return { description => 'The current clone is found in this strain',
         data       => $self->_pack_obj($strain) };
}

# sequences { }
# This method will return a data structure containing
# sequences corresponding to the clone in FASTA format.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequences

sub sequences {
    my ($self) = @_;
    my @sequences = map { $self->_pack_obj($_) } @{$self ~~ '@Sequence'};
    
    return {
        description => 'sequences associated with this clone',
        data		=> @sequences ? \@sequences : undef,
    }
}

# genomic_positions { }
# This method will return a data structure containing
# genomic positions for features on this clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/genomic_positions

sub genomic_positions {
    my ($self) = @_;
    
    # this part looks suspiciously like it overlaps with _build__segments below...
    my @positions;
    foreach my $seq (@{$self ~~ '@Sequence'}) {
        my $chrom = $self->_pack_obj($seq->Interpolated_map_position);
        my $map   = $seq->Interpolated_map_position(2);
    
        my ($ref, $start, $end);
        if (my ($coords) = $self->_seq2coords($seq)) {
            ($ref, $start, $end) = @$coords;
        }
        my $label    = $self->_format_coordinates(ref => $ref, start => $start, stop => $end);
        my $position = $self->_format_coordinates(ref => $ref, start => $start, stop => $end, pad_for_gbrowse => 1);
        next unless $position;
        push(@positions, {
            label      => $position,
            id         => $self->_parsed_species . '/?name=' . $position, # looks like a template thing...
            class      => 'genomic_location',
            pos_string => $position, # independent from label -- label may change in the future
        });
    }
    
    return {
        description => 'genomic positions of the sequences associated with this clone',
        data        => (@positions > 0) ? \@positions : undef,
    }
}

sub _seq2coords {
    my ($self, @seqs) = @_;
    
    return map {[$_->abs_ref, $_->abs_start, $_->abs_stop]}
    map {my $db = $self->gff_dsn($self->_parsed_species($_));
	 $db->segment($_->class => $_)}
    @seqs;
}

# lengths { }
# This method will return a data structure containing
# the lengths of clones as estimated by gel electrophoresis.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/lengths

sub lengths {
    my ($self) = @_;
    my %data;
    map { if(my $len = $self ~~ "$_") { $data{$_} = $len; } } qw(Seq_length Gel_length);
    return {
      description => 'lengths relevant to this clone',
      data   	    => %data ? \%data : undef,
    };
}


# maps { }
# This method will return a data structure containing
# maps relevant to the requested clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/maps

sub maps {
    my ($self) = @_;
    
    # get Maps from object itself, otherwise try for Maps from Pmap
    my $map = $self ~~ '@Map';
    $map = eval {[$self->object->Pmap->Map] } unless @$map;
    
    return {
	description => 'maps assigned to this clone',
	data	    => $map && @$map ? $self->_pack_objects($map) : undef,
    };
}

# sequence_status { }
# This method will return a data structure containing
# the sequencing status of this clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequence_status

# Returns the sequence status of the clone. Each key represents a status
# and a status => undef pair represents no ?DateType or Text data for the status,
# but does not invalidate the status itself.
sub sequence_status {
    my ($self) = @_;

    # eval is in scalar context to force an undef instead of empty list
    my %status = map { $_ => scalar eval {$_->right->name}} @{$self ~~ '@Sequence_status'};
    return {
	description => 'sequencing status of clone',
	data	    => %status ? \%status : undef,
    };
}

# canonical_for { }
# This method will return a data structure containing
# clones that the requested clone is a canonical
# representative of.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_for

sub canonical_for {
    my ($self) = @_;

    my $canonical = $self->_pack_objects($self ~~ '@Canonical_for');
    return {
	description => 'clones that the requested clone is a canonical representative of',
	data	    => %$canonical ? $canonical : undef,
    };
}

# canonical_parent { }
# This method will return a data structure containing
# the canonical parent of this clone, if there is one.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_parent

sub canonical_parent {
    my ($self) = @_;
    my $obj = $self->object;

    # the following abuses the list context behaviour of the autogen'd accessors
    # i.e. no data results in ()
    my @canonical_parent = map {$self->_pack_obj($_)}  (
        $obj->Approximate_match_to,
        $obj->Exact_match_to,
        $obj->Funny_match_to,
    );

    return {
	description => 'canonical parent for clone',
	data	    => @canonical_parent ? \@canonical_parent : undef,
    }
}

# screened_positive { }
# This method will return a data structure containing
# entities that were shown to be contained within the clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_positive

sub screened_positive {
    my ($self) = @_;

    my %weaks = map {$_ => 1} @{$self ~~ '@Pos_probe_weak'};
    my %data = map { $_ => $self->_pack_obj($_, undef, weak => $weaks{$_}) }
    $self->object->Positive(2);

    return {
	description => 'entities shown to be contained within this clone',
	data		=> %data ? \%data : undef,
    };
}

# screened_negative { }
# This method will return a data structure containing
# entities shown NOT to be contained within the requested
# clone.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_negative

sub screened_negative {
    my ($self) = @_;

    my $data = $self->_pack_objects([$self->object->Negative(2)]);
    return {
	description => 'entities shown to NOT be contained within the requested clone',
	data	    => %$data ? $data : undef,
    };
}

# gridded_on { }
# This method will return a data structure containing
# gridding information of the clone during fingerprinting.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/gridded_on

sub gridded_on {
    my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Gridded');
    return {
	description => 'grid this clone was gridded on during fingerprinting',
	data	    => %$data ? $data : undef,
    };
}


sub pcr_product {
    my ($self) = @_;
    my $object = $self->object;
    my $PCR_product = $object->PCR_product;
    my $pcr = $self->_api->fetch({class=>'Pcr_oligo',name=>"$PCR_product"}) if $PCR_product;
    return {
      description => 'PCR product associated with this clone',
      data        => $PCR_product ? 
        { pcr_product => $self->_pack_obj($PCR_product),
          oligos      => $pcr->oligos() }: undef,
    };
}

#######################################
#
# The External Links widget
#
#######################################

# xrefs {}
# Supplied by Role

#######################################
#
# The Location Widget
#
#######################################

# genomic_position { }
# Supplied by Role

# genomic_image { }
# Supplied by Role



#######################################
#
# The References Widget
#
#######################################

# references {}
# Supplied by Role



########################################
## PRIVATE METHODS
########################################
sub _build_tracks {
    return {
        description => 'tracks',
        data        => [qw(NG CG CLO LINK CANONICAL)]
    };
}

sub _build__segments {
    my ($self) = @_;
    # TH: I don't think it's correct to use the method "region" here.  
    # It needs to be either Sequence or Clone.
    # return [$self->gff_dsn->segment(-class => 'region', -name => $self->object)];

    my $dsn = $self->gff_dsn;
    my $object = $self->object;
    my @segs = $dsn->segment(-name => "$object");
    return \@segs;
}


# override default remarks from Role::Object
sub _build_remarks {
    my ($self) = @_;
    my $object = $self->object;

    my @remarks = $object->General_remark;
    @remarks = push(@remarks, $object->Y_remark) if $object->Y_remark;
    @remarks = push(@remarks, $object->PCR_remark) if $object->PCR_remark;

#     @remarks = map { {text => "$_"} } ($self ~~ 'Y_remark',
#                                 $self ~~ 'PCR_remark');
    @remarks = map { {text => "$_"} } @remarks;

    return {
        description => 'Remarks',
        data        => @remarks ? \@remarks : undef,
    };
}



########################################
## DEPRECATED METHODS
########################################

sub physical_picture { # TODO (TH: And probably not necessary)
    my ($self) = @_;

    # not what $PmapGFF translates to, e.g. $DBGFF --> $self->gff_dsn
    # see classic code seq/clone

    return {
        description => 'Physical picture data',
        data        => 'NOT IMPLEMENTED',
    };
}




__PACKAGE__->meta->make_immutable;

1;

