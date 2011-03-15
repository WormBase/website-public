package WormBase::API::Object::Gene_regulation;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  better descriptions for data returned (in datapack)

=pod

=head1 NAME

WormBase::API::Object::Gene_regulation

=head1 SYNOPSIS

Model for the Ace ?Gene_regulation class.

=head1 URL

http://wormbase.org/species/gene_regulation

=head1 METHODS/URIs

=cut

################################################################################
#
# Overview widget
#
################################################################################

=head2 Overview

=cut

# sub summary {}
# Supplied by Role; POD will automatically be inserted here
# << include summary >>

=head3 methods

Returns a datapack containing the experimental approach used to determine
the gene regulation.

=over

=item PERL API

 $data = $model->methods();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/methods

B<Response example>

<div class="response-example"></div>

=cut

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

=head3 regulators

Returns a datapack with the regulator involved in gene regulation.

=over

=item PERL API

 $data = $model->regulators();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/regulators

B<Response example>

<div class="response-example"></div>

=cut

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

=head3 targets

Returns a datapack containing what the regulator regulates.

=over

=item PERL API

 $data = $model->targets();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/targets

B<Response example>

<div class="response-example"></div>

=cut

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

=head3 regulation

Returns a datapack detailing the kind of regulation (whether positive, negative,
or none). The presence of a key indicates that kind of regulation -- the
associated value may or may not be undef.

=over

=item PERL API

 $data = $model->regulation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/regulation

B<Response example>

<div class="response-example"></div>

=cut

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

=head3 types

Returns a datapack containing the type of change effected by the regulation.

=over

=item PERL API

 $data = $model->types();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/types

B<Response example>

<div class="response-example"></div>

=cut

sub types {
	my ($self) = @_;

	my @types = map {$_->name} @{$self ~~ '@Type'};

	return {
		description => 'Type',
		data		=> @types ? \@types : undef,
	};
}

=head3 molecule_regulators

Returns a datapack with the ?Molecule involved in the regulation.

=over

=item PERL API

 $data = $model->molecule_regulators();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/molecule_regulators

B<Response example>

<div class="response-example"></div>

=cut

sub molecule_regulators {
	my ($self) = @_;

	my $molecule_regs = $self->_pack_objects($self ~~ '@Molecule_regulator');

	return {
		description => 'Molecule regulator',
		data		=> %$molecule_regs ? $molecule_regs : undef,
	};
}

=head3 references

Returns a datapack containing reference papers.

=over

=item PERL API

 $data = $model->references();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene regulation ID (eg WBPaper00035152_bah-1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/references

B<Response example>

<div class="response-example"></div>

=cut

sub references {
	my ($self) = @_;

	my $packed_refs = $self->_pack_objects($self ~~ '@Reference');

	return {
		description => 'References',
		data		=> %$packed_refs ? $packed_refs : undef,
	};
}


1;
