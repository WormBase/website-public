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

=head1 CLASS LEVEL METHODS/URIs

=cut


#######################################
#
# INSTANCE METHODS
#
#######################################

=head1 INSTANCE LEVEL METHODS/URIs

=cut


################################################################################
#
# Overview widget
#
################################################################################

=head2 Overview

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here
# << include name >>

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

=head3 regulators
    
This method returns a data structure containing
the regulator gene in the described regulation entity.

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

=head3 reference_expression_pattern
    
This method returns a data structure containing
a reference expression pattern for where the gene
regulation is thought to occur.

=over

=item PERL API

 $data = $model->reference_expression_pattern();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/reference_expression_pattern

B<Response example>

<div class="response-example"></div>

=cut

sub reference_expression_pattern {
    my $self   = shift;
    my $object = $self->object;
    
    my @expr    = $object->Expr_pattern;
    my $linked  = $self->_pack_objects(\@expr); # Target_info->Expr_pattern
    return { description => 'the reference expression pattern for where the gene regulation occurs',
	     data	 => %$linked ? $linked : undef };
}

=head3 regulates

Returns a data structure detailing what the regulator regulates
and how (positive, negative, or none) with supporting evidence.

=over

=item PERL API

 $data = $model->regulates();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/regulates

B<Response example>

<div class="response-example"></div>

=cut

sub regulates {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;
    my $type = $object->Result;

    my %conditions;
    foreach my $condition_type ($type->col) {
#	$conditions{$condition_type} = map { $self->_pack_obj($_) } $condition_type->right;
	$conditions{$condition_type} = $self->_pack_objects( [ $condition_type->col ] );
    }

    foreach my $target_type ($object->Target) {
	next if $target_type eq 'Target_info';  # captured elsewhere as reference_expression_pattern
	my @targets = $target_type->col;
	foreach (@targets) {
	    push @data, { target          => $self->_pack_obj($_),
			  target_type     => "$target_type",
			  regulation_type => "$type",
			  conditions      => \%conditions,
	    }
	}
    }
    
    return {
	description => 'the type of regulation (positive, negative, none)',
	data	    => @data ? \@data : undef,
    };
}

=head3 type_of_change

This method returns a data structure containing the type 
of change effected by the regulation.

=over

=item PERL API

 $data = $model->type_of_change();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/type_of_change

B<Response example>

<div class="response-example"></div>

=cut

sub type_of_change {
    my ($self) = @_;
    
    my @types = map {$_->name} @{$self ~~ '@Type'};    
    return { description => 'types of change effected by the regulation',
	     data	 => @types ? \@types : undef,
    };
}

=head3 molecule_regulators

This method returns a data structure molecules
that regulate the regulation (?).

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
    my $self   = shift;
    my $object = $self->object;
    
    my @molecules = map { $self->pack_obj($_) } $object->Molecule_regulator;
    
#    my $molecule_regs = $self->_pack_objects( [ $self ~~ '@Molecule_regulator' ] );
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

=head2 References

=cut

# sub references {}
# Supplied by Role; POD will automatically be inserted here.
# << include references >>



__PACKAGE__->meta->make_immutable;

1;

