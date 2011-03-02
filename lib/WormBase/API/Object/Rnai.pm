package WormBase::API::Object::Rnai;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Rnai

=head1 SYNPOSIS

Model for the Ace ?Rnai class.

=head1 URL

http://wormbase.org/species/rnai

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

# sub taxonomy { }
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

sub targets {
	my ($self) = @_;
	my %data;
	my $targets_hr = _classify_targets($self->object);
	foreach my $target_type ('Primary targets','Secondary targets') {
		my $genes = eval {$targets_hr->{$target_type}};
		$data{$target_type} = $genes; # are the key,value pair important? otherwise omit...
  	}
	return {
		description => 'notes',
		data => %data || undef,
	};
}

sub identification {
	my ($self) = @_;
    my $exp = $self->object;

	my $targets_hr = _classify_targets($exp);
	my @reagents = $exp->PCR_product;
	my $sequence = $exp->Sequence_info->right;
	my $assay = ($exp->PCR_product) ? 'PCR product' : 'Sequence';

	my %targets;
	foreach my $target_type ('Primary targets','Secondary targets') {
		$targets{$target_type} = eval {$targets_hr->{$target_type}};
  	}


	return {
		description => 'notes',
		data		=> {
			ace_id	 => $exp,
			class	 => 'RNAi',
			targets	 => \%targets,
			reagents => \@reagents,
			sequence => $sequence,
			assay	 => $assay,
		},
	};
}





sub history_name {
	my ($self) = @_;
	return {
		description => 'notes',
		data => $self ~~ 'History_name' || $self->object,
	};
}


# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


sub genotype {
	my ($self) = @_;

	return {
		description => 'notes',
		data		=> $self ~~ 'Genotype',
	};
}

sub strain {
	my ($self) = @_;

	return {
		description => 'notes',
		data		=> $self->_pack_obj($self ~~ 'Strain'),
	};
}

sub interactions {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_)} @{$self ~~ '@Interaction'};

	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}

sub treatment {
	my ($self) = @_;

	return {
		description => 'notes',
		data => $self ~~ 'Treatment',
	};
}

sub life_stage {
	my ($self) = @_;

    return {
		description => 'notes',
		data => $self->_pack_obj($self ~~ 'Life_stage'),
	};
}

sub delivered_by {
	my ($self) = @_;
	return {
		description => 'notes',
		data => $self ~~ 'Delivered_by',
	};
}

sub phenotypes {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype'};
	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}


sub phenotype_nots {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype_not_observed'};
	return {
		description => 'notes',
		data => @data ? \@data : undef,
	};
}

###############
## INTERNAL
###############

sub _classify_targets {
  	my $exp = shift;
  	my %seen;
  	my %categories;
	my @genes = grep { !$seen{$_->Molecular_name}++ } $exp->Gene;
  	push @genes, grep { !$seen{$_}++ } $exp->Predicted_gene;

  	foreach my $gene (@genes) {
    	my @types = $gene->col;

    	foreach (@types) {
			my ($remark) = $_->col;
			my $status = ($remark =~ /primary/) ? 'Primary targets' : 'Secondary targets';
			push @{$categories{$status}},$gene;
    	}
  	}
	return \%categories;
}


1;
