package WormBase::API::Object::Wbprocess;

use Moose;
use WormBase::API::Object::Gene qw/classification/; 
use Switch;

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
	
	my @related_proc = map { 
		$self->_pack_obj($_)
		} $object->Related_process;
	
	return {
		description => "Processes related to this record",
		data	=> @related_proc ? \@related_proc : undef
	};
}

sub other_name{ 
	my ($self) = @_;
	my $object = $self->object;
	
	my $other_name = $object->Other_name;
		
	return {  
		description => "Term alias",
		data => "$other_name"
	};
}



#######################################
#
# Genes widget
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
# Used above. Processes a single gene record to be displayed with the build_data_table
# macro. Returns name and type
sub _process_gene {
	my ($self, $gene) = @_;
	my $type = WormBase::API::Object::Gene->
		classification($gene)->{data}->{type};
	

	my %data = (
		name 	=> $self->_pack_obj($gene),
		type	=> $type
	);

	return \%data;
}

#######################################
#
# Expression Clusters Widget
#
#######################################

sub expression_cluster {
	my ($self) = @_;
	my $object = $self->object;
	my @e_clusters = $object->Expression_cluster;
	
	
	my @data;
	foreach my $e_cluster(@e_clusters){
		push @data, $self->_process_e_cluster($e_cluster);
		#$log->debug( "JDJDJD".join(",",@data));
	}
	
	return {
		description => "Expression cluster(s) related to this process",
		data        => @data ? \@data : undef 
	};

}
sub _process_e_cluster{
	my ($self, $e_cluster) = @_;
	my $desc = $e_cluster->Description;
	my $evidence = $self->_get_evidence($e_cluster);
	
	my %data = (
		id				=> $self->_pack_obj($e_cluster),
		
		evidence		=> {
				evidence => $evidence,
				text	 => $desc
			}
	); 
	
	return \%data;
}

#######################################
#
# Interactions widget
#
#######################################

sub interaction {
	my ($self) = @_;
	my $object = $self->object;
	my @interactions = $object->Interaction;
	
	
	my @data;
	foreach my $interaction (@interactions){
		push @data, $self->_process_interaction($interaction);
	}
	
	return {
		description => "Interactions relating to this process",
		data        => @data ? \@data : undef 
	};

}
sub _process_interaction{
	my ($self, $interaction) = @_;
	my $type = $interaction->Interaction_type;
	my $summary = $interaction->Interaction_summary;
	
	my $log = $self->log;
	
	# Interactors
	# Different case for each kind of interaction
	my @interactors;
	my $interactor_type = $interaction->Interactor;
	switch ($interactor_type->name) {
		case("Interactor_overlapping_gene"){
			my @interacting_genes = $interaction->Interactor_overlapping_gene;
			foreach my $gene_obj (@interacting_genes){
				push (@interactors, $self->_pack_obj($gene_obj));
			}
		}
	}
	
	
	my %data = (
		type		=> $type,
		summary		=> $summary,
		interactors	=> \@interactors
	);
	
	return \%data;
}


#######################################
#
# GO widget
#
#######################################



sub go_term{
	my ($self) = @_;
	my $object = $self->object;
	my @go_objs = $object->GO_term;
	
	my @data;
	
	foreach my $go_obj ( @go_objs ){
		my $name 	= $go_obj->Term;
		my $type 	= $go_obj->Type;
		my $def		= $go_obj->Definition;
		
		push @data, {
			name	=> $self->_pack_obj($go_obj), 
			type	=> "$type",
			def		=> "$def"
		};
	}
		
#	use Data::Dumper;
#	my $dump =  Dumper(\%data);
#	die $dump;
	
	return {
		description => "Gene Ontology Term",
		data => \@data
	};

}

# Sample wrapper function to copy
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

