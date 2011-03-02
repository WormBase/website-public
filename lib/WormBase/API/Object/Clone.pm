package WormBase::API::Object::Clone;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod 

=head1 NAME

WormBase::API::Object::Clone

=head1 SYNPOSIS

Model for the Ace ?Clone class.

=head1 URL

http://wormbase.org/species/clone

=head1 METHODS/URIs

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


sub type {
	my ($self) = @_;

	my $type = $self ~~ 'Type';
	return {
		description => 'The type if this clone',
		data		=> $type && "$type",
	};
}

sub sequences {
	my ($self) = @_;

    # genomic data of the sequence can probably be refactored out somewhere...
    # see comment in genomic_picture
    my %sequences = map {
        my $map = $_->Interpolated_map_position(2);
        my ($start, $end, $refname, $ref) = $self->FindPosition($_);
        $_ => $self->_pack_obj(
            $_, undef,
            start   => $start,
            end     => $end,
            ref     => $ref,
            refname => $refname,
            chrom   => $self->_pack_obj($_->Interpolated_map_position),
            map     => $map && "$map",
        )
    } @{$self ~~ '@Sequence'};

	return {
		description => 'Sequences assocaited with this clone',
		data		=> %sequences ? \%sequences : undef,
	}
}

sub lengths {
	my ($self) = @_;

	my %data = map { $_ => $self ~~ "$_" } qw(Seq_length Gel_length);

	return {
		description => 'Lengths relevant to this clone',
		data		=> %data ? \%data : undef,
	};
}

sub maps {
	my ($self) = @_;

    # get Maps from object itself, otherwise try for Maps from Pmap
	my $map = $self ~~ '@Map';
	$map = eval {[$self->object->Pmap->Map] } unless @$map;

	return {
		description => 'Maps this Clone is assigned to',
		data		=> $map && @$map ? $self->_pack_objects($map) : undef,
	};
}

# Returns the sequence status of the clone. Each key represents a status
# and a status => undef pair represents no ?DateType or Text data for the status,
# but does not invalidate the status itself.
sub sequence_status {
	my ($self) = @_;

    # eval is in scalar context to force an undef instead of empty list
    my %status = map { $_ => scalar eval {$_->right->name}} @{$self ~~ '@Sequence_status'};
	return {
		description => 'Sequence status of clone',
		data		=> %status ? \%status : undef,
	};
}

sub canonical_for {
	my ($self) = @_;

	my $canonical = $self->_pack_objects($self ~~ '@Canonical_for');
	return {
		description => 'Canonical for',
		data		=> %$canonical ? $canonical : undef,
	};
}

sub canonical_parent {
	my ($self) = @_;

	my @canonical_parent = map {$self->_pack_obj($_)}  (
		$self ~~ 'Approximate_Match_to',
		$self ~~ 'Exact_Match_to',
		$self ~~ 'Funny_Match_to',
	   );

	return {
		description => 'Canonical parent for clone',
		data		=> @canonical_parent ? \@canonical_parent : undef,
	}
}


sub screened_positive {
	my ($self) = @_;

    my %weaks = map {$_ => 1} @{$self ~~ '@Pos_probe_weak'};
    my %data = map { $_ => $self->_pack_obj($_, undef, weak => $weaks{$_}) }
                   $self->object->Positive(2);

	return {
		description => 'Screened positive for',
		data		=> %data ? \%data : undef,
	};
}

sub screened_negative {
	my ($self) = @_;

	my $data = $self->_pack_objects([$self->object->Negative(2)]);
	return {
		description => 'Screened negative for',
		data		=> %$data ? $data : undef,
	};
}

sub gridded_on {
	my ($self) = @_;

	my $data = $self->_pack_objects($self ~~ '@Gridded');
	return {
		description => 'Grid this clone was gridded on',
		data		=> %$data ? $data : undef,
	};
}

sub references {
	my ($self) = @_;

	my $data = $self->_pack_objects($self ~~ '@Reference');
	return {
		description => 'References for this clone',
		data		=> %$data ? $data : undef,
	};
}

sub physical_picture { # TODO
    my ($self) = @_;

    # not what $PmapGFF translates to, e.g. $DBGFF --> $self->gff_dsn
    # see classic code seq/clone

    return {
        description => 'Physical picture data',
        data        => 'NOT IMPLEMENTED',
    };
}

sub genomic_picture {
    my ($self) = @_;

    my ($ref, $start, $stop);
    if (my $segment = $self->gff_dsn->segment(-class => 'region',
                                              -name => $self->object)) {
        # the following looks like something done in Object::genomic_position...
        # consider refactoring?
        my ($absref,           $absstart,           $absend)
         = ($segment->abs_ref, $segment->abs_start, $segment->abs_end);
        ($absstart, $absend) = ($absend, $absstart) if $absstart > $absend;

        ($ref, $start, $stop) = ($absref, int $absstart, int $absend);

        # the following appear in classic website but are commented out because
        # fore som reason it doesn't work. may wish to investigate later

        # my $new_segment = $self->gff_dsn->segment({
        #     -name => 'name',
        #     -class => 'Sequence'
        #     -start => $start,
        #     -stop => $stop,
        # });

    }

    return {
        description => 'Genomic picture data',
        data        => {
            ref   => $ref,
            start => $start,
            stop  => $stop,
        },
    };
}

########################################
## PRIVATE METHODS
########################################

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

1;
