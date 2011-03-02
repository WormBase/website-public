package WormBase::API::Object::Expression_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expression_cluster

=head1 SYNPOSIS

Model for the Ace ?Expression_cluster class.

=head1 URL

http://wormbase.org/species/expresssion_cluster

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget
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
    my %ret;
    map { {$ret{"$_"} = $self->_pack_obj($_, $_->Public_name)}} $object->Gene;
    return { description => 'The corresponding gene',
         data        =>  \%ret, 
    };
}

# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

sub algorithm {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'Algorithm used to determine cluster',
         data        =>  $object->Algorithm, 
    };
    return $data;
}

sub microarray {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->Microarray_results;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'microarray results from expression cluster'
	};
}

sub sage_tag {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object-><TAG>;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => ''
	};
}

sub expr_pattern {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->Expr_pattern;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'expression patterns associated with this cluster'
	};
}

sub anatomy_term {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->Anatomy_term;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'anatomy term annotated with this expression cluster'
	};
}


1;
