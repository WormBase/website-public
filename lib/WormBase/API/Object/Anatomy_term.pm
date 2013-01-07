package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Anatomy_term

=head1 SYNPOSIS

Model for the Ace ?Anatomy_term class.

=head1 URL

http://wormbase.org/species/*/anatomy_term

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

# term { }
# Return a term in the Anatomy Ontology

sub term {
    my ($self) = @_;

    return {
	data        => $self->_pack_obj($self ~~ 'Term'),
	description => 'Term in the Anatomy ontology',
    };
}


# definition { }
# This method will return a data structure containing a prose
# definition of this term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/definition

sub definition {
    my $self   = shift;
    my $data   = $self ~~ 'Definition';

    return {
        data        => $data ? "$data" : undef,
        description => 'definition of the anatomy term',
    };
}

# synonyms { }
# This method will return a data structure containing the 
# synonyms of this anatomy term object.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/synonyms

sub synonyms {
    my $self = shift;
    my @data = map {"$_"} @{$self ~~ '@Synonym'};

    return {
        description => 'synonyms that have been used to describe the anatomy term',
        data => @data ? \@data : undef
    };
}

# remarks {}
# Supplied by Role

#######################################
#
# The Assocations Widget
#
#######################################

# transgenes { }
# This method will return a data structure of 
# transgenes annotated with this anatomy term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/transgenes

sub transgenes {
    my $self   = shift;
    my $term = $self->object;
    my @transgenes;
    eval {
        @transgenes =
          map { $_->Transgene }
          grep { /marker/i && defined $_->Transgene } $term->Expr_pattern;
    };
    my @data_pack = map { $_ = $self->_pack_obj($_) } @transgenes;
    return {
        'data'        => @data_pack ? \@data_pack : undef,
        'description' => 'transgenes annotated with this anatomy_term'
    };
}

# expression_clusters { }
# This method will return a data structure expression_clusters associated with this anatomy_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/expression_clusters

sub expression_clusters {
    my $self   = shift;
    my $object = $self->object;
    my @data_pack;

    foreach my $expression_cluster ($object->Expression_cluster) {
        my $ec_description = $expression_cluster->Description;
        push @data_pack,
          {
            'ec_data'     => $self->_pack_obj($expression_cluster),
            'description' => $ec_description && "$ec_description",
          };
    }
    return {
        'data'        => @data_pack ? \@data_pack : undef,
        'description' => 'expression_clusters associated with this anatomy_term'
    };
}

# expression_patterns {}
# Supplied by Role

# gene_ontology { }
# This method will return a data structure containing go terms for this anatomy_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/gene_ontology

sub gene_ontology {
    my $self = shift;

    my @data = map {
        term    => $self->_pack_obj($_), # will this be needed?
        ao_code => $self->_pack_obj($_->right), # or does View expect text?
    }, @{$self ~~ '@GO_term'}; # array of hashes -- note the comma

    return {
        data        => @data ? \@data : undef,
        description => 'go_terms associated with this anatomy_term',
    };
}

# anatomy_functions { }
# This method will return a data structure anatomy_functions associated with this anatomy_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/anatomy_functions

sub anatomy_functions {
    my ($self) = @_;

    my $data = $self->_anatomy_function('Anatomy_function');
    return {
        data        => @$data ? $data : undef,
        description => 'anatomy_functions associatated with this anatomy_term',
    };
}

# anatomy_function_nots { }
# This method will return a data structure ... of this anatomy_term.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/eg WBbt:0005175/anatomy_function_nots

sub anatomy_function_nots {
    my $self      = shift;

    my $data = $self->_anatomy_function('Anatomy_function_not');
    return {
        'data'        => @$data ? $data : undef,
        'description' => 'anatomy_functions associatated with this anatomy_term'
    };
}


#######################################
#
# The External Links widget
#
#######################################

# xrefs {}
# Supplied by Role

## sub anatomy {}  figure out image displaying functions

#######################################
#
# Internal Methods
#
#######################################

sub _anatomy_function {
    my ($self, $tag) = @_;
    my $object = $self->object;
    my @data_pack;
    foreach ($object->$tag){
	my @bp_inv = map { if ("$_" eq "$object") {my $term = $_->Term; { text => $term && "$term", evidence => $self->_get_evidence($_)}}
			   else { { text => $self->_pack_obj($_), evidence => $self->_get_evidence($_)}}
			  } $_->Involved;
	my @bp_not_inv = map { if ("$_" eq "$object") {my $term = $_->Term; { text => $term && "$term", evidence => $self->_get_evidence($_)}}
               else { { text => $self->_pack_obj($_), evidence => $self->_get_evidence($_)}}
			  } $_->Not_involved;

	# Genotype removed from the evidence hash in WS234?
	my @assay = map { my $as = $_->right;
			  if ($as) {
			      my @geno = $as->Genotype; 			      
			      {evidence => { genotype => join('<br /> ', @geno) },
			       text => "$_",}
			  }
	} $_->Assay;
	my $pev;
	push @data_pack, {
            af_data   => $_ && "$_",
            phenotype => ($pev = $self->_get_evidence($_->Phenotype)) ? 
                          { evidence => $pev,
                           text => $self->_pack_obj(scalar $_->Phenotype)} : $self->_pack_obj(scalar $_->Phenotype),
            gene      => $self->_pack_obj(scalar $_->Gene),
        assay    => @assay ? \@assay : undef,
	    bp_inv    => @bp_inv ? \@bp_inv : undef,
	    bp_not_inv=> @bp_not_inv ? \@bp_not_inv : undef,
	    reference => $self->_pack_obj(scalar $_->Reference),
	    };
    } # array of hashes -- note the comma

    return \@data_pack;
}

__PACKAGE__->meta->make_immutable;

1;


