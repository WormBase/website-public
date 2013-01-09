package WormBase::API::Object::Gene_regulation;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::Gene_regulation

=head1 SYNOPSIS

Model for the Ace ?Gene_regulation class.

=head1 URL

http://wormbase.org/species/*/gene_regulation

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

################################################################################
#
# Overview widget
#
################################################################################


# name {}
# Supplied by Role

# summary {}
# Supplied by Role

# methods { }
# Returns a datapack containing the experimental approach used to determine
# the gene regulation.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/methods

sub methods {
    my $self   = shift;
    my $object = $self->object;
    
    my %nontext_tags = map {$_ => 1} qw(Antibody_info Transgene);
    my %data;
    foreach my $method ($object->Method) {
	if ($nontext_tags{$method}) {
	    my @col = $method->col;
	    $data{$method} = $self->_pack_objects(\@col);
	} else {
	    $data{$method} = {map {$_ => undef} $method->col};
	}
	undef $data{$method} unless %{$data{$method}};
    }
    
    return { description => 'the method used to determine the gene regulation',
	     data	 => %data ? \%data : undef,
    };
}

# regulators { }
# This method returns a data structure containing
# the regulator gene in the described regulation entity.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/regulators

sub regulators {
    my $self   = shift;
    my $object = $self->object;
    
    my %regulator = map {$_ => [$_->col]} $object->Regulator;

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
	    my @regulators = @{$regulator{$_}};
	    $regulator{$_} = $self->_pack_objects(\@regulators);
	}
    }
    
    return { description => 'regulators in the gene regulation entity',
	     data		=> %regulator ? \%regulator : undef,
    };
}

# reference_expression_pattern { }
# This method returns a data structure containing
# a reference expression pattern for where the gene
# regulation is thought to occur.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/reference_expression_pattern

sub reference_expression_pattern {
    my $self   = shift;
    my $object = $self->object;
    
    my @expr    = $object->Expr_pattern;
    my $linked  = $self->_pack_objects(\@expr); # Target_info->Expr_pattern
    return { description => 'the reference expression pattern for where the gene regulation occurs',
	     data	 => %$linked ? $linked : undef };
}

# regulates { }
# Returns a data structure detailing what the regulator regulates
# and how (positive, negative, or none) with supporting evidence.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/regulates

sub regulates {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;

    my %conditions;

    foreach my $type ($object->Result) {
	foreach my $condition_type ($type->col) {
	    if ("$condition_type" eq 'Subcellular_localization') {
		my @values = map {"$_"} $condition_type->col;
		$conditions{$condition_type} = @values ? \@values : undef;
	    } else {
		$conditions{$condition_type} = $self->_pack_objects( [ $condition_type->col ] );
	    }
	}

	my $regtype;
	if ("$type" eq 'Positive_regulate') { $regtype = 'Positively regulates' }
	elsif ("$type" eq 'Negative_regulate') { $regtype = 'Negatively regulates' }
	else { $regtype = 'Does not regulate' }

	foreach my $target_type ($object->Target) {
	    next if $target_type eq 'Target_info';  # captured elsewhere as reference_expression_pattern
	    my @targets = $target_type->col;
	    foreach (@targets) {
		push @data, { target          => $self->_pack_obj($_),
			      target_type     => "$target_type" || undef,
			      regulation_type => "$regtype" || undef,
			      conditions      => scalar keys %conditions ? \%conditions : undef,
		}
	    }
	}
    }

    return {
	description => 'the type of regulation (positive, negative, none)',
	data	    => @data ? \@data : undef,
    };
}

# type_of_change { }
# This method returns a data structure containing the type 
# of change effected by the regulation.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/type_of_change

sub type_of_change {
    my ($self) = @_;
    
    my @types = map {"$_"} @{$self ~~ '@Type'};    
    return { description => 'types of change effected by the regulation',
	     data	 => @types ? \@types : undef,
    };
}

# molecule_regulators { }
# This method returns a data structure molecules
# that regulate the regulation (?).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/molecule_regulators

sub molecule_regulators {
    my $self   = shift;
    my $object = $self->object;
    
    my @molecules = map { $self->_pack_obj($_) } $object->Molecule_regulator;
    return {
	description => 'Molecule regulator',
	data	=> @molecules ? \@molecules : undef,
    };
}

#######################################
#
# The References Widget
#
#######################################

# references {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;

