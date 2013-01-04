package WormBase::API::Object::Wbprocess;

use Moose;

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

sub related_process{
	my ($self) = @_;
	my $object = $self->object;
	
	my @related_proc = map { $self->_pack_obj($_) } $object->Related_process;
	
	return {
		description => "Processes related to this record",
		data	=> \@related_proc
	};
}

sub process_term{
	my ($self) = @_;
	my $object = $self->object;
	
	my $process_term = 
		$object->Process_term; 
		
	return {
		description => "Term describing process",
		data => $process_term
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

sub remark{
	my ($self) = @_;
	my $object = $self->object;
	
	my $remark = $object->Remark;
		
	return {
		description => "remark",
		data => $remark
	};
}


<<'SAMPLE_FUNC';
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

