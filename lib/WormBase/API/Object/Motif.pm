package WormBase::API::Object::Motif;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';

=pod

=head1 NAME

WormBase::API::Object::Motif

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/resources/motif

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

#######################################
#
# The Overview Widget
#
#######################################

# name { }
# Supplied by Role

# title { }
# This method will return a data structure of the
# title for the requested motif.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/title

sub title {
    my $self 	= shift;
    my $object 	= $self->object;
    my $title   = $object->Title;
    return {
	data        => "$title" || undef,
	description => 'title for the motif'
    };
}


# remarks {}
# Supplied by Role

#######################################
#
# The Gene Ontology Widget
#
#######################################

# gene_ontology { }
# This method will return a data structure with
# gene ontology (GO) annotations for the requested motif.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/gene_ontology

sub gene_ontology  {
    my $self     = shift;
    my $motif    = $self->object;

    my @data;
    foreach my $go_term ($motif->GO_term) {
	my $definition = $go_term->Definition;
	my ($evidence) = $go_term->right;

	push @data,{
	    go_term  => $self->_pack_obj($go_term),
	    definition => $definition && "$definition",
	    evidence   => $evidence? {text=>"$evidence",evidence=>$self->_get_evidence($evidence)}:undef,
	};
    }
    return { data        => @data ? \@data : undef,
	     description => 'go terms to with which motif is annotated',
    };
}


#######################################
#
# The Homology widget
#
#######################################

# homologies { }
# This method will return a data structure with homology information on the requested motif.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/homologies

sub homologies {
    my $self   = shift;
    my $object = $self->object;
    my @data;

    my $types = {
    	DNA_homol 	=> 'DNA',
    	Pep_homol 	=> 'Peptide',
    	Motif_homol => 'Motif',
    	Homol_homol => 'Other',
    };

    foreach my $homology_type (keys %$types) {
        if (my @homol = $object->$homology_type) {
            foreach my $homologous_object (@homol) {
                my $type = $types->{$homology_type};
                my $species = eval { $homologous_object->Species };
                push @data,	{
                    homolog => $self->_pack_obj($homologous_object),
                    type => "$type" || undef,
                    species => $self->_pack_obj($species),
                }
            }
        }
    }

    return { data => @data ? \@data : undef,
	     description  => 'homology data for this motif'
    };
}


#######################################
#
# The External Links widget
#
#######################################

# xrefs {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;
