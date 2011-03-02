package WormBase::API::Object::Gene_regulation;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

sub summary {
	my ($self) = @_;

	my $summary = $self ~~ 'Summary';
	return {
		description => 'Summary',
		data		=> $summary && "$summary",
	};
}

sub methods {
	my ($self) = @_;

	my %nontext_tags = map {$_ => 1} qw(Antibody_info Transgene);
	my %data;
	foreach my $method (@{$self ~~ '@Method'}) {
		$data{$method} = $nontext_tags{$method} ?
		                 $self->_pack_objects([$method->col]) :
						 {map {$_ => undef} $method->col};

		undef $data{$method} unless %{$data{$method}};
	}

	return {
		description => 'Method',
		data		=> %data ? \%data : undef,
	};
}

sub regulators {
	my ($self) = @_;

	my %regulator = map {$_ => [$_->col]} @{$self ~~ '@Regulator'};
	if (exists $regulator{Regulator_info}) {
		foreach (@{$regulator{Regulator_info}}) {
			$regulator{$_} = [$_->col];
		}
		delete $regulator{Regulator_info};
	}

	foreach (keys %regulator) {
		if ($_ eq 'Other_regulator') {
			$regulator{$_} = {map {$_ => undef} @{$regulator{$_}}};
		}
		else {
			$regulator{$_} = $self->_pack_objects($regulator{$_});
		}
	}

	return {
		description => 'Regulators',
		data		=> %regulator ? \%regulator : undef,
	};
}

sub targets {
	my ($self) = @_;

	my $target_info = $self->_pack_objects($self ~~ '@Expr_pattern'); # Target_info->Expr_pattern

	my %targets;
	foreach my $target_type (@{$self ~~ '@Target'}) {
		next unless $target_type eq 'Target_info';
		my $targets = $self->_pack_objects([$target_type->col]);
		$targets{$target_type} = $targets if %$targets;
	}

	my %data;
	$data{target_info} = $target_info if %$target_info;
	$data{targets}	   = \%targets if %targets;

	return {
		description => 'Targets',
		data		=> %data ? \%data : undef,
	};
}

sub regulation {
	my ($self) = @_;

	my %data;
	foreach my $reg_type (@{$self ~~ '@Result'}) {
		undef $data{$reg_type};

        # the presence of the undef above indicates that there is indeed
        # this kind of regulation. the following finds details about it.

		foreach my $condition_type ($reg_type->col) {
			my %conditions = $self->_pack_objects($condition_type->col);
			$data{$reg_type}{$condition_type} = %conditions ? \%conditions : undef;
		}
	}

	return {
		description => 'What kind of regulation (positive, negative, none)',
		data		=> %data ? \%data : undef,
	};
}

sub types {
	my ($self) = @_;

	my @types = map {$_->name} @{$self ~~ '@Type'};

	return {
		description => 'Type',
		data		=> @types ? \@types : undef,
	};
}

sub molecule_regulators {
	my ($self) = @_;

	my $molecule_regs = $self->_pack_objects($self ~~ '@Molecule_regulator');

	return {
		description => 'Molecule regulator',
		data		=> %$molecule_regs ? $molecule_regs : undef,
	};
}

sub references {
	my ($self) = @_;

	my $packed_refs = $self->_pack_objects($self ~~ '@Reference');

	return {
		description => 'References',
		data		=> %$packed_refs ? $packed_refs : undef,
	};
}


1;
