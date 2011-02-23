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
		$data{description} = [map {$_->name} @{$self ~~ '@Pattern'}];
		$data{remark} = join ' ', @{$self ~~ '@Remark'};
		$data{check_bc} = $self->_check_for_bc;
		%data = () unless @{$data{description}} ||
		  $data{remark} || $data{check_bc};
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
		data		=> %data ? \%data : undef,
	};
}

sub expressed_in {
	my ($self) = @_;

	my %data;
	foreach my $type (qw(Cell Cell_group Life_stage)) {
		my $packed_obj = $self->_pack_objects($self ~~ "\@$type");
		$data{ucfirst $type . 's'} = $packed_obj if %$packed_obj;
	} # TODO: what to do about pedigree stuff?

	return {
		description => 'TODO',
		data		=> %data ? \%data : undef
	};
}

sub anatomy_ontology {
	my ($self) = @_;

	my @anatomy_terms = map {
		anatomy_term => $self->_pack_obj($_),
		definition => $_->Definition->name,
		location => $_->Term->name,
	}, @{$self ~~ '@Anatomy_term'};

	return {
		description => 'TODO',
		data		=> @anatomy_terms ? \@anatomy_terms : undef,
	};
}

sub experimental_details {
	my ($self) = @_;
	my %data;

	if (my @types = @{$self ~~ '@Type'}) {
		$data{types} = [map ["$_", $_->right . ''], @types];
	}

	foreach (qw(Antibody_info Transgene Strain Author)) {
		my $val = $self ~~ "\@$_";
		$data{$_} = $self->_pack_objects($val) if @$val;
	}

	if (my $date = $self ~~ 'Date') {
		$data{date} = $date->name;
	}

	return {
		description => 'Experimental details of the expression pattern',
		data		=> %data ? \%data : undef,
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

1;
