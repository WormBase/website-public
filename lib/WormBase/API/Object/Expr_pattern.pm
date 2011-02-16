package WormBase::API::Object::Expr_pattern;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my ($self) = @_;
	my $bestname = $self->bestname($self ~~ 'Gene');
	$bestname = defined $bestname ?
	  "Expression pattern for $bestname" : $self ~~ 'name';

	return {
		description => 'The object name of the paper',
		data => {
			id		=> $self ~~ 'name',
			label	=> $bestname,
			class	=> $self ~~ 'class'
		},
	};
}


############################################################
#
# The Overview widget
#
############################################################

sub description {
	my ($self) = @_;
	my %data;
	unless (($self ~~ 'Author') =~ /Mohler/) {
		$data{description} = $self ~~ '@Pattern';
		$data{remarks} = join(' ', @{$self ~~ '@Remark'});
		$data{check_bc} = $self->_check_for_bc;
		%data = () unless @{$data{description}} ||
		  $data{remarks} || $data{check_bc};
	}

	return {
		description => 'The description of the expression pattern',
		data => %data ? \%data : undef,
	};
}

sub subcellular_locations {
	my ($self) = @_;
	my $subcellular_loc = $self ~~ '@Subcellular_localization';

	return {
		description	=> 'TODO',
		data		=> @$subcellular_loc ? $subcellular_loc : undef,
	};
}

sub expressed_by {
	my ($self) = @_;
	my %data;

	foreach (qw(Gene Sequence Clone Protein)) {
		my $val = $self ~~ "\@$_";
		$data{$_} =  $self->_pack_objects($val) if @$val;
	}

	return {
		description => 'Items that exhibit this expression pattern',
		data		=> \%data,
	};
}

sub expressed_in {
	my ($self) = @_;

	my %data = (
		cells => $self->_pack_objects($self ~~ '@Cell'),
		cell_groups => $self->_pack_objects($self ~~ '@Cell_group'),
		life_stages => $self->_pack_objects($self ~~ '@Life_stage'), # majority
	); # TODO: the above is insufficient for cells and cell groups -- they will
	   #       likely require special handling (pedigree stuff?)...

	return {
		description => 'TODO',
		data		=> \%data,
	};
}

sub anatomy_ontology {
	my ($self) = @_;

	my $data = $self->_ao_table;

	return {
		description => 'TODO',
		data		=> $data,
	};
}

sub experimental_details {
	my ($self) = @_;
	my %data;

	$data{types} = [map [$_, $self ~~ $_], @{$self ~~ '@Type'}];

	foreach (qw(Antibody_info Transgene Strain Author)) {
		my $val = $self ~~ "\@$_";
		$data{$_} = $self->_pack_objects($val) if @$val;
	}


	if (my $date = $self ~~ 'Date') {
		$data{date} = $date;
	}

	return {
		description => 'Experimental details of the expression pattern',
		data		=> \%data,
	};
}

sub expression_image {
	my ($self) = @_;

	my $data;
	my $file = $self->pre_compile->{expr_object}."/".$self->object.".jpg";
	$data = 'jpg?class=expr_object&id=' . $self->object if (-e $file && !-z $file);

	return {
		description => 'Image of the expression pattern',
		data => $data,
	};
}

sub curated_images {
	my ($self) = @_;
	my $pictures = $self ~~ '@Picture';

	my @data = grep defined, map {$_->image->{data}} $self->wrap($pictures);

	return {
		description => 'Curated images of the expression pattern',
		data => @data ? \@data : undef,
	};
}

sub movies { # TODO
	my ($self) = @_;
	my $data;

	return {
		description => 'TODO',
	};
}

############################################################
#
# PRIVATE METHODS
#
############################################################

# Is this a BC strain?
sub _check_for_bc {
	my ($self) = @_;

    # VC abd BC are the Baiilie and Moerman labs
    return scalar grep {$_ eq 'BC' || $_ eq 'VC'} @{$self ~~ '@Laboratory'};
}

sub _ao_table {
	my ($self) = @_;

	return [map {
		anatomy_term => $self->_pack_obj($_),
		definition => $_->Definition,
		location => $_->Term,
    }, @{$self ~~ '@Anatomy_term'}];
}


1;
