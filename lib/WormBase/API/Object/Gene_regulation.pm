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
	$data{$method} = $nontext_tags{$method} ?
	    $self->_pack_objects([$method->col]) :
	{map {$_ => undef} $method->col};
	
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
	    $regulator{$_} = $self->_pack_objects($regulator{$_});
	}
    }
    
    return { description => 'regulators in the gene regulation entity',
	     data		=> %regulator ? \%regulator : undef,
    };
}

=head3 targets
    
This method returns a data structure containing
genes that are the target of regulation.

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
    my $self   = shift;
    my $object = $self->object;
    
    my $target_info = $self->_pack_objects($object->Expr_pattern); # Target_info->Expr_pattern
    
    my %targets;
    foreach my $target_type ($object->Target) {
	next unless $target_type eq 'Target_info';
	my $targets = $self->_pack_objects([$target_type->col]);
	$targets{$target_type} = $targets if %$targets;
    }
    
    return { description => 'genes that are targets of regulation',
	     data	 => {  target_info => $target_info ? $target_info : undef,
			       targets     => %targets ? \%targets : undef } };
}

=head3 type

Returns a data structure detailing the type
of regulation (whether positive, negative, or none).

=over

=item PERL API

 $data = $model->type();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_regulation/WBPaper00035152_bah-1/type

B<Response example>

<div class="response-example"></div>

=cut

sub type {
    my $self   = shift;
    my $object = $self->object;

    my %data;
    # Is regulation the right tag?
    foreach my $reg_type ($object->Result) {
	foreach my $condition_type ($reg_type->col) {
	    my %conditions = $self->_pack_objects($condition_type->col);
	    $data{$reg_type}{$condition_type} = %conditions ? \%conditions : undef;
	}
    }
    
    return {
	description => 'the type of regulation (positive, negative, none)',
	data	    => %data ? \%data : undef,
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
	my ($self) = @_;

	my $molecule_regs = $self->_pack_objects($self ~~ '@Molecule_regulator');
	return {
	    description => 'Molecule regulator',
	    data	=> %$molecule_regs ? $molecule_regs : undef,
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

