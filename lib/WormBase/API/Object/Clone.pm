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

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


#######################################
#
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 type

This method will return a data structure containing
the general type of this clone.

=over

=item PERL API

 $data = $model->type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/type

B<Response example>

<div class="response-example"></div>

=back

=cut

sub type {
    my ($self) = @_;
    
    my $type = $self ~~ 'Type';
    return { description => 'The type of this clone',
	     data		=> $type && "$type" };
}

=head3 sequences

This method will return a data structure containing
sequences corresponding to the clone in FASTA format.

=over

=item PERL API

 $data = $model->sequences();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequences

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sequences {
    my ($self) = @_;
    
    # this part looks suspiciously like it overlaps with _build__segments below...
    my %sequences;
    foreach my $seq (@{$self ~~ '@Sequence'}) {
        my $chrom = $self->_pack_obj($seq->Interpolated_map_position);
        my $map   = $seq->Interpolated_map_position(2);
	
        my ($ref, $start, $end);
        if (my ($coords) = $self->_seq2coords($seq)) {
            ($ref, $start, $end) = @$coords;
        }
	
        $sequences{$seq} = $self->_pack_obj(
            $seq, undef, # $seq and resolve label within _pack_obj
            start => $start,
            end   => $end,
            ref   => $ref,
            chrom => $chrom,
            map   => $map && "$map",
	    );
    }
    
    return {
        description => 'sequences associated with this clone',
        data		=> %sequences ? \%sequences : undef,
    }
}

sub _seq2coords {
    my ($self, @seqs) = @_;
    
    return map {[$_->abs_ref, $_->abs_start, $_->abs_stop]}
    map {my $db = $self->gff_dsn($self->_parsed_species($_));
	 $db->segment($_->class => $_)}
    @seqs;
}

=head3 lengths

This method will return a data structure containing
the lengths of clones as estimated by gel electrophoresis.

=over

=item PERL API

 $data = $model->lengths();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/lengths

B<Response example>

<div class="response-example"></div>

=back

=cut

sub lengths {
    my ($self) = @_;
    my %data = map { $_ => $self ~~ "$_" } qw(Seq_length Gel_length);
    return {
	description => 'lengths relevant to this clone',
	data   	    => %data ? \%data : undef,
    };
}


=head3 maps

This method will return a data structure containing
maps relevant to the requested clone.

=over

=item PERL API

 $data = $model->maps();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/maps

B<Response example>

<div class="response-example"></div>

=back

=cut

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


=head3 sequence_status

This method will return a data structure containing
the sequencing status of this clone.

=over

=item PERL API

 $data = $model->sequence_status();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/sequence_status

B<Response example>

<div class="response-example"></div>

=back

=cut

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

=head3 canonical_for

This method will return a data structure containing
clones that the requested clone is a canonical
representative of.

=over

=item PERL API

 $data = $model->canonical_for();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_for

B<Response example>

<div class="response-example"></div>

=back

=cut

sub canonical_for {
    my ($self) = @_;

    my $canonical = $self->_pack_objects($self ~~ '@Canonical_for');
    return {
	description => 'clones that the requested clone is a canonical representative of',
	data	    => %$canonical ? $canonical : undef,
    };
}

=head3 canonical_parent

This method will return a data structure containing
the canonical parent of this clone, if there is one.

=over

=item PERL API

 $data = $model->canonical_parent();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/canonical_parent

B<Response example>

<div class="response-example"></div>

=back

=cut

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

=head3 screened_positive

This method will return a data structure containing
entities that were shown to be contained within the clone.

=over

=item PERL API

 $data = $model->screened_positive();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_positive

B<Response example>

<div class="response-example"></div>

=back

=cut

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

=head3 screened_negative

This method will return a data structure containing
entities shown NOT to be contained within the requested
clone.

=over

=item PERL API

 $data = $model->screened_negative();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/screened_negative

B<Response example>

<div class="response-example"></div>

=back

=cut

sub screened_negative {
    my ($self) = @_;

    my $data = $self->_pack_objects([$self->object->Negative(2)]);
    return {
	description => 'entities shown to NOT be contained within the requested clone',
	data	    => %$data ? $data : undef,
    };
}


=head3 gridded_on

This method will return a data structure containing
gridding information of the clone during fingerprinting.

=over

=item PERL API

 $data = $model->gridded_on();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A clone id (eg JC8)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/clone/JC8/gridded_on

B<Response example>

<div class="response-example"></div>

=back

=cut

sub gridded_on {
    my ($self) = @_;

    my $data = $self->_pack_objects($self ~~ '@Gridded');
    return {
	description => 'grid this clone was gridded on during fingerprinting',
	data	    => %$data ? $data : undef,
    };
}



#######################################
#
# The External Links widget
#   template: shared/widgets/xrefs.tt2
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>



#######################################
#
# The Location Widget
#
#######################################

=head2 Location

=cut

# sub genomic_position { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_position >>

# sub genomic_image { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_image >>




#######################################
#
# The References Widget
#
#######################################

=head2 References

=cut

# sub references {}
# Supplied by Role; POD will automatically be inserted here.
# << include references >>



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
    return [$self->gff_dsn->segment(-class => 'region', -name => $self->object)];
}


# override default remarks from Role::Object
sub _build_remarks {
    my ($self) = @_;

    my @remarks = map { "$_" } (@{$self ~~ '@General_remark'},
                                @{$self ~~ '@Y_remark'},
                                @{$self ~~ '@PCR_remark'});

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

