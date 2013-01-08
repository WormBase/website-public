package WormBase::API::Object::Gene_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Gene_cluster

=head1 SYNPOSIS

Model for the Ace ?Gene_cluster class.

=head1 URL

http://wormbase.org/species/*/gene_cluster

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


############################
#
# The Overview Widget
#
############################

# name { }
# Supplied by Role
 
# title { }
# This method will return a data structure with title for the gene_cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_cluster/HIS3_cluster/title

sub title {
    my $self      = shift;
    my $object    = $self->object;
    my $title     = $object->Title;
    return { data        => "$title" || undef,
	     description => 'title of the gene cluster'
    };
}


# description { }
# Supplied by Role

# contains_genes { }
# This method will return a data structure with genes in the gene_cluster.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_cluster/HIS3_cluster/contains_genes

sub contains_genes {
    my $self   = shift;
    my $object = $self->object;
    my @data = map {$self->_pack_obj($_)} $object->Contains_gene;
    
    return { data => @data ? \@data : undef,
	     description => 'genes that are found in this gene cluster' };
}

__PACKAGE__->meta->make_immutable;

1;
