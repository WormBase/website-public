package WormBase::API::Object::Wbprocess;

use Moose;
use WormBase::API::Object::Gene;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=pod

=head1 NAME

WormBase::API::Object::WBProcess

=head1 SYNPOSIS

Model for the Ace ?WBProcess class.

=head1 URL

http://wormbase.org/species/*

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
# The Genome Assemblies widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>




# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

#######################################
#
# The Overview widget
#
#######################################


sub related_process{
	my ($self) = @_;
	my $object = $self->object;
	
	my @related_proc = map { $self->_pack_obj($_) } $object->Related_process;
	
	return {
		description => "Processes related to this record",
		data	=> \@related_proc
	};
}

sub other_name{ 
	my ($self) = @_;
	my $object = $self->object;
	
	my $other_name = $object->Other_name;
		
	return {  
		description => "Term alias",
		data => $other_name
	};
}

sub public_name{  
	my ($self) = @_;
	my $object = $self->object;
	
	my $public_name = $object->Public_name;
		
	return {
		description => "public_name",
		data => $public_name 
	};
}


#######################################
#
# The Entities widget
#
#######################################

sub genes{ 
    my $self   = shift;
    my $object = $self->object;
    my @genes = $object->Gene;

    my @data;
    foreach my $gene (@genes) {
		push @data, $self->_process_gene($gene);
    }
    
    return { 
		description => 'alleles found within this gene',
	    data        => @data ? \@data : undef 
	};
}

# Processes a single gene record to be displayed with the build_data_table
# macro.  Returns name and type
sub _process_gene {
	my ($self, $gene) = @_;
	my $name = $gene->Public_name; 
	my $type = WormBase::API::Object::Gene->
		classification($gene)->{data}->{type};


	my %data = (
		name 	=> $name,
		type	=> $type
	);

	return \%data;
}



# Sample passthrough function to copy
# replace the xxx's with stuff
0 if <<'SAMPLE_FUNC';
sub xxx{
	my ($self) = @_;
	my $object = $self->object;
	
		
	return {
		description => "xxx",
		data => xxx
	};
}
SAMPLE_FUNC

############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;

