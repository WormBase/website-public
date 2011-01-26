package WormBase::API::Object::Expr_pattern;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub name {
    my $self = shift;
    my $data = {
		description => 'The object name of the paper',
		data => {
					id		=> $self ~~ 'name',
					label	=> $self ~~ 'name',
					class	=> $self ~~ 'class'
		},
	};
    return $data;
}


############################################################
#
# The Overview widget
#
############################################################

sub expression_image { # may put this in another function...
	my $self = shift;
	
	my $field = {
		description => 'The image',
	};
	
	my $file = $self->pre_compile->{expr_object}."/".$self->object.".jpg";
	$field->{data} = 'jpg?class=expr_object&id=' . $self->object 
		if -e $file && ! -z $file;

	return $field;
}

sub summary {
	my $self = shift;
	my %data;
	my $remark;
	
	unless (($self ~~ 'Author') =~ /Mohler/) {
		$data{description} = $self ~~ '@Pattern';
		$data{remarks} = join(' ', @{$self ~~ '@Remark'});
		$data{check_bc} = $self->_check_for_bc;
	}

	$data{subcellular} = $self ~~ '@Subcellular_localization';

	my $field = {
		description	=> 'The description of the expression pattern',
		data		=> \%data,
	};
	return $field;
}

sub expressed_by {
	my $self = shift;
	my %data;
	
	foreach (qw(Gene Sequence Clone Protein)) {
		my $val = $self ~~ "\@$_";
		$data{$_ . 's'} =  $self->_pack_objects($val) if @$val;
	} # TODO: AD: $_ . 's'... i don't like it
	
	my $field = {
		description => 'TODO',
		data		=> \%data,
	};
	return $field;
}

sub expressed_in {
	my $self = shift;
	
	my %data = (
		cells => $self->_pack_objects($self ~~ '@Cell'),
		cell_groups => $self->_pack_objects($self ~~ '@Cell_group'),
		life_stages => $self->_pack_objects($self ~~ '@Life_stage'), # majority
	); # TODO: the above is insufficient for cells and cell groups -- they will
	   #       likely require special handling (pedigree stuff?)...
	
	my $field = {
		description => 'TODO',
		data		=> \%data,
	};
	return $field;
}

sub anatomy_ontology {
	my $self = shift;
	
	my $data = $self->_ao_table;
	
	my $field = {
		description => 'TODO',
		data		=> $data,
	};
	return $field;
}

sub experimental_details {
	my $self = shift;
	my %data;
	
	@{$data{types}} = map [$_, $self ~~ $_], @{$self ~~ '@Type'};
	
	foreach (qw(Antibody_info Transgene Strain Author)) {
		my $val = $self ~~ "\@$_";
		$data{lc $_ . 's'} = $self->_pack_objects($val) if @$val;
	} # will require doing each one separately if tailoring required
	  # TODO: AD: again with the $_ . 's'... this time with lc too!
	  #           I am unsettled about this.
	  
	if (my $date = $self ~~ 'Date') {
		$data{date} = $date;
	}
	
	my $field = {
		description => 'TODO',
		data		=> \%data,
	};
	return $field;
}


############################################################
#
# PRIVATE METHODS
#
############################################################

=head2 check_for_bc

 Title   : _check_for_bc
 Usage   : $expr->_check_for_bc
 Function: checks if this is a BC consortium strain
 Returns : integer
 Args    : 

=cut

# Is this a BC strain?
sub _check_for_bc {
    my $self = shift;

    # VC abd BC are the Baiilie and Moerman labs
    return scalar grep {$_ eq 'BC' || $_ eq 'VC'} @{$self ~~ '@Laboratory'};
}

=head2 ao_table

 Title		: _ao_table
 Usage		: _ao_table($ep)
 Function	: ... TODO
 Returns	: ArrayRef
 Args		: 

=cut

sub _ao_table {
	my $self = shift;
	my $aterms = $self ~~ '@Anatomy_term';
	my @data;

	for my $aterm (@$aterms) {
		push @data, {	
						anatomy_term	=> WormBase::API::Role::Object->_pack_obj($aterm),
										 #  ^ that's ugly!
						definition		=> $aterm->Definition,
						location		=> $aterm->Term,
					};
	}

	return \@data;
}


1;
