package WormBase::API::Object::Antibody;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Antibody

=head1 SYNPOSIS

Model for the Ace ?Antibody class.

=head1 URL

http://wormbase.org/species/*/antibody

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

# other_names { }
# Supplied by Role

# summary { }
# This method will return a data structure 
# containing a summary of the requested antibody.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/summary

sub summary {
    my $self   = shift;
    my $object = $self->object;
    my $summary = $object->Summary;
    return { description => 'summary description of the antibody',
	     data        => "$summary" || undef };
}

# corresponding_gene { }
# This method will return a data structure containing
# the corresponding gene for this antibody.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/corresponding_gene

sub corresponding_gene {
    my $self   = shift;
    my $object = $self->object;
    my $gene   = $object->Gene;
    return { description => 'the corresponding gene the antibody was generated against',
	     data        => $self->_pack_obj($gene)};
}

# antigen { }
# This method will return a data structure 
# containing the antigen that this antibody
# was generated against.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/antigen

sub antigen {
    my $self   = shift;
    my $object = $self->object;
    my ($type,$comment) = $object->Antigen->row if $object->Antigen;
    $type =~ s/_/ /g;
    return { description => 'the type and decsription of antigen this antibody was generated against',
	     data        => { type    => "$type" || undef,
			      comment => "$comment" || undef },
    };
}

# animal { }
# This method will return a data structure containing
# the animal the antibody was generated.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/animal

sub animal {
    my $self = shift;
    my $animal = $self->object->Animal;

    if ($animal eq 'Other_animal') {
        $animal = $animal->right || $animal;
    }

    return {
        description => 'the animal the antibody was generated in',
        data        => $animal && "$animal",
    };
}

# clonality { }
# This method will return a data structure containing
# the clonality of this antibody.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/clonality

sub clonality {
    my $self      = shift;
    my $object    = $self->object;
    my $clonality = $object->Clonality;
    return { description => 'the clonality of the antibody',
	     data        => "$clonality" || undef };
}

# laboratory { }
# Supplied by Role

# constructed_by { }
# This method will return a data structure containing
# the person who isolated the antibody.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/constructed_by

sub constructed_by {
    my $self      = shift;
    my $object    = $self->object;
    my $person    = $object->Person;
    my $name      = $person->Standard_name if $person;
    return { description => 'the person who constructed the antibody',
	     data        => $self->_pack_obj($person, $name && "$name")};
}

# remarks {}
# Supplied by Role

#######################################
#
# The Expression widget
#
#######################################

# expression_patterns {}
# Supplied by Role


__PACKAGE__->meta->make_immutable;

1;

