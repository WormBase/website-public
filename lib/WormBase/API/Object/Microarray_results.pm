package WormBase::API::Object::Microarray_results;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod 

=head1 NAME

WormBase::API::Object::Microarray_results

=head1 SYNPOSIS

Model for the Ace ?Microarray_results class.

=head1 URL

http://wormbase.org/species/microarray_results

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


sub gene {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Gene;
    my $data = { description => 'The corresponding genes',
         data        => @data ? \@data : undef, 
    };
    return $data;
}

sub cds {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->CDS;
    my $data = {
	description => 'The corresponding cds',
	data        => @data ? \@data : undef,
    };
    return $data;
}

sub transcript {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Transcript;
    my $data = {
	description => 'The corresponding transcripts',
	data        => @data ? \@data : undef,
    };
    return $data;
}

sub pseudogene {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Pseudogene;
    my $data = {
	description => 'The corresponding pseudogene',
	data        => @data ? \@data : undef,
    };
    return $data;
}

sub microarray {
    my $self = shift;
    my $object = $self->object;

    my @data;
    foreach my $chip ($object->Microarray){
	my $type = $chip->Chip_type;
	my @info = map {"$_"} $chip->Chip_info;
	if (my @remarks = $chip->Remark){
	    push @info, '<b>Remarks:</b>', map {"$_"} @remarks;
	}
	my @papers = map {$self->_pack_obj($_)} $chip->Reference;
	my @experiments = $chip->Microarray_experiment;
	push @data, {
	    type => "$type",
	    info => @info ? \@info : undef,
	    papers => @papers ? \@papers : undef,
	    experiments => scalar @experiments,
	};
    }

    return {
	description => 'Details about the microarray',
	data        => @data ? \@data : undef,
    };
}

sub range {
    my $self = shift;
    my $object = $self->object;
    my %data;

    foreach my $bound ($object->Range){
	my $val = $bound->right;
	my $experiment = $val->right(1);
	$data{$bound} = {
	    val => "$val" || undef,
	    experiment => "$experiment" || undef,
	};
    }

    return {
	description => 'The range of the microarray results',
	data        => scalar keys %data ? \%data : undef,
    };
}

sub results {
    my $self = shift;
    my $object = $self->object;

    my @data;

    foreach my $experiment ($object->Results){
	my (@clusters, $temp, $life_stage);

	foreach my $tag ($experiment->col){	    
	    push @clusters, $self->_pack_obj($tag->right) if "$tag" eq 'Expression_cluster';
	}
	if (my $sample = $experiment->Microarray_sample){
	    $life_stage = $sample->Life_stage;
	    $temp = $sample->Temperature;
	}
	my @references = map {$self->_pack_obj($_)} $experiment->Reference;
	push @data, {
	    experiment	=> "$experiment",
	    clusters	=> @clusters ? \@clusters : undef,
	    references  => @references ? \@references : undef,
	    life_stage	=> $self->_pack_obj($life_stage),
	    temp	=> "$temp" || undef,
	}
    }
    return {
	description => 'The corresponding cds',
        data        => @data ? \@data : undef,
    };
}

__PACKAGE__->meta->make_immutable;

1;