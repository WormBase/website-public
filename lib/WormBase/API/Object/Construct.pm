package WormBase::API::Object::Construct;
use Moose;

with 'WormBase::API::Role::Object';
with 'WormBase::API::Role::Expr_pattern';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::Construct

=head1 SYNPOSIS

Model for the Ace ?Construct class.

=head1 URL

http://wormbase.org/species/*/construct

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
# The Overview widget
#
#######################################

# name { }
# Supplied by Role

# summary { }
# Supplied by Role

# TODO: sequence_feature, purificatin_tag, recombination_site, dna_text

# driven_by_gene { }
sub driven_by_gene {
    my $self = shift;
    my $object = $self->object;

    my @genes = map { $self->_pack_obj($_) } $object->Driven_by_gene ;
    return { description => 'gene that drives the construct',
	     data        => @genes ? \@genes : undef,
    };
}


# gene_product { }
sub gene_product {
    my $self = shift;
    my $object = $self->object;
    my @genes = map { $self->_pack_obj($_); } $object->Gene;
    return { description => 'gene products for this construct',
             data        => @genes ? \@genes : undef };
}


# type_of_construct { }
sub type_of_construct {
    my $self   = shift;
    my $object = $self->object;
    my @types  = map { "$_"; } $object->Type_of_construct;
    return { description => 'type of construct',
             data        => @types ? \@types : undef };
}

# fusion_reporter {}
sub fusion_reporter {
    my $self   = shift;
    my $object = $self->object;
    my $reporter = $object->Fusion_reporter;
    return { description => 'reporter construct for this construct',
	     data        => $reporter ? "$reporter" : undef };
}

# other_reporter {}
sub other_reporter {
    my $self   = shift;
    my $object = $self->object;
    my $reporter = $object->Other_reporter;
    return { description => 'other reporters of this construct',
	     data        => $reporter ? "$reporter" : undef };
}


# utr { }
sub utr {
    my $self = shift;
    my $object = $self->object;
    my @utr = map { $self->_pack_obj($_); } $object->get('3_UTR'); #$object->get('3_UTR')->fetch();
    return { description => '3\' UTR for this transgene',
             data        => @utr ? \@utr : undef };
}

# selection_marker { }
sub selection_marker {
    my $self = shift;
    my $object = $self->object;
    my @marker = map { "$_" } $object->Selection_marker;
    return { description => 'Coinjection marker for this transgene',
             data        => @marker ? \@marker : undef };
}

# construction_summary { }
sub construction_summary {
    my $self = shift;
    my $object = $self->object;

    my $summary = $object->Construction_summary;
    return { description => 'Construction details for the transgene',
         data        => $summary && "$summary"};
}

# historical_gene { }
sub historical_gene {
    my $self = shift;
    my $object = $self->object;

    my @historical_gene = map { {text => $self->_pack_obj($_),
                              evidence => $self->_get_evidence($_)} } $object->Historical_gene;
    return { description => 'Historical record of the dead genes originally associated with this transgene',
             data        => @historical_gene ? \@historical_gene : undef,
    };
}

# remarks {}
# Supplied by Role

#######################################
#
# The Isolation Widget
#
#######################################

# person {}
sub person {
    my $self   = shift;
    my $object = $self->object;
    my $person = $object->Person;

    my $name;
    if ($person) {
	$name = $person->Standard_name if $person;
    }

    return { description => 'the person who created the construct',
	     data        => $self->_pack_obj($person, $name && "$name") };
}

# laboratory { }
# Supplied by Role

# clone { }
sub clone {
    my $self = shift;
    my $object = $self->object;

    return { description => 'the clone of this construct',
	     data        => $self->_pack_obj($object->Clone) };
}





# recombindation_site {}
sub recombination_site {
    my $self   = shift;
    my $object   = $self->object;
    my $position = $object->Recombination_site;

    return { description => 'map position of the integrated transgene',
	     data        => $position ? "$position" : undef};
}


#######################################
#
# The Transgene widget
#
#######################################

has 'transgenes' => (
    is         => 'ro',
    lazy => 1,
    builder => '_build__transgenes',
);

sub _build__transgenes {
    my $self   = shift;
    my $object   = $self->object;
    my @data;
    foreach my $tg ($object->Transgene_construct) {
        my @tg_strains = map { $self->_pack_obj($_) } $tg->Strain;
        my @tg_refs = map { $self->_pack_obj($_) } $tg->Reference;
        my $summary = $tg->Summary;
        push @data, {
            transgene => $self->_pack_obj($tg),
            summary   => "$summary",
            strain    => \@tg_strains,
            reference => \@tg_refs
        };
    }

    return { description => 'Transgenes generated by this construct',
             data        => @data ? \@data : undef};
}

#######################################
#
# The Expression widget
#
#######################################

# expression_patterns { }
# Supplied by Role

sub _build_expr_pattern_tag_name { return 'Expression_pattern'; };

# marker_for { }
sub marker_for {
    my $self   = shift;
    my $object = $self->object;
    my $marker = $object->Marker_for;
    return { description => 'string decribing what the transgene is a marker for',
	     data        =>  $marker && "$marker" };
}



__PACKAGE__->meta->make_immutable;

1;
