package WormBase::API::Object::Wbprocess;

use Moose;
use WormBase::API::Object::Gene;
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
		description => "Expression cluster",
		data        => @data ? \@data : undef 
	};

}
sub _process_e_cluster{
	my ($self, $e_cluster) = @_;
	my $desc = $e_cluster->Description;
	
	my %data = (
		id				=> $self->_pack_obj($e_cluster),
		description 	=> $desc
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
		description => "Interaction",
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
				my $gene_name = $gene_obj->Public_name;
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

sub term {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Term;
    return {
        'data'        => $self->_pack_obj($object, $tag_object && "$tag_object"),
        'description' => 'GO term'
    };
}

# definition { }
# This method will return a data structure with the definition of the go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/definition

sub definition {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Definition;
    return {
        'data'        => $data_pack && "$data_pack",
        'description' => 'term definition'
    };
}

# type { }
# This method will return a data structure with the type of go_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/go_term/GO:0032502/type
sub type {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Type;
    $data_pack =~ s/\_/\ /;
    return {
        'data'        => $data_pack,
        'description' => 'type for this term'
    };
}


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

