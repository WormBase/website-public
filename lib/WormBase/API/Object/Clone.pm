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
		data		=> $type && $type->name,
	};
}

sub sequences {
	my ($self) = @_;

	my $sequences = $self->_pack_objects($self ~~ '@Sequence');
	# TODO: there's some bit of extra Sequence data displayed in classic...
	return {
		description => 'Sequences assocaited with this clone',
		data		=> %$sequences ? $sequences : undef,
	}
}

sub length {
	my ($self) = @_;

	my %data;
	foreach (qw(Seq_length Gel_length)) {
		my $length = $self ~~ $_;
		$data{lc $_} = $length if $length;
	}

	return {
		description => 'Lengths relevant to this clone',
		data		=> %data ? \%data : undef,
	};
}

sub map { # needs a look
	my ($self) = @_;

	my $map = $self ~~ '@Map';
	$map = eval {[$self->object->Pmap->Map] } unless @$map;

	return {
		description => 'Maps this Clone is assigned to',
		data		=> $map && @$map ? $self->_pack_objects($map) : undef,
	};
}


sub sequence_status {
	my ($self) = @_;

	my @status = map { $_->name } @{$self ~~ '@Sequence_status'};
	return {
		description => 'Sequence status of clone',
		data		=> @status ? \@status : undef,
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

	my $data = $self->_pack_objects([$self->object->Positive(2)]);
	# TODO: "weak" logic from classic...
	return {
		description => 'Screened positive for',
		data		=> %$data ? $data : undef,
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

1;
