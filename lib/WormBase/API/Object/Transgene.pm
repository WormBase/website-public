package WormBase::API::Object::Transgene;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Transgene

=head1 SYNPOSIS

Model for the Ace ?Transgene class.

=head1 URL

http://wormbase.org/species/*/transgene

=cut

#######################################
#
# CLASS METHODS
#
#######################################

{ # temporary fix. this should actually be cached for the entire class.
  # better yet, this should be designated as a class method, signaled at the
  # controller level for caching
    my $transgenes;
    
    sub tissue_specific_transgenes {
        my $self   = shift;
	
        return $transgenes ||= {
            description => 'tissue-specific transgenes',
            data        => [
                map {
		    my $marker_for = $_->Marker_for;
		    my $summary    = $_->Summary;
		    my $ref        = $marker_for->right(2);
		    
		    {
			transgene          => $self->_pack_obj($_),
			marker_for         => $self->_pack_obj($marker_for),
			summary            => "$summary",
			reference          => $self->_pack_obj($ref),
		    };
		} grep { $_->Marker_for }                
		$self->ace_dsn->dbh->fetch(-query => "find Transgene")
		], 
	};
    }
}




{ # temporary fix. this should actually be cached for the entire class.
  # better yet, this should be designated as a class method, signaled at the
  # controller level for caching
    my $transgenes;
    
    sub mapped_transgenes {
        my $self   = shift;
	
        return $transgenes ||= {
            description => 'mapped transgenes',
            data        => [
                map {
		    my $summary      = $_->Summary;
		    my $reporter_tag = $_->Reporter;
		    my $reporter;
		    if ($reporter_tag eq 'Gene') {
			$reporter = $self->_pack_obj($reporter_tag->Public_name);
		    } elsif ($reporter_tag) {
			$reporter = $reporter_tag->col;
		    } else {
			$reporter = 'unknown';
		    }
		    my $map_position = $_->Map;
		    my @expr         = map { $self->_pack_obj($_) } $_->Expr_pattern;
		    my @strains      = map { $self->_pack_obj($_) } $_->Strain;
		    my $gene         = $_->Driven_by_gene;

		    my (%unique_ao,@ao);
		    my (%unique_life_stage,@life_stage);
		    foreach my $exp ($_->Expr_pattern) {			    
			my @anatomy_terms = $exp->Anatomy_term;
			foreach (@anatomy_terms) {
			    $unique_ao{$_} = $_;
			}

			my @life_stage = $exp->Life_stage;
			foreach (@life_stage) {
			    $unique_life_stage{$_} = $_;
			}
		    }
		    foreach (keys %unique_ao) {
			push @ao,$self->_pack_obj($unique_ao{$_});
		    }		    

		    foreach (keys %unique_life_stage) {
			push @life_stage,$self->_pack_obj($unique_life_stage{$_});
		    }		    

		    my $marker_for   = $_->Marker_for;
		    my $ref          = $marker_for->right(2) if $marker_for;
		    
		    {
			transgene          => $self->_pack_obj($_),
			summary            => "$summary",
			map_position       => "$map_position",			
			reporter           => "$reporter",
			expression_patterns => \@expr,
			strains            => \@strains,
		        driven_by          => $self->_pack_obj($gene),
			ao                 => \@ao,
			life_stage         => \@life_stage,
			reference          => $self->_pack_obj($ref),
		    };
		} grep { $_->Map }                
		$self->ace_dsn->dbh->fetch(-query => "find Transgene")
		], 
	};
    }
}





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

# synonym { }
# This method will return a data structure containing
# a brief summary of the requested transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/synonym

sub synonym {
    my $self    = shift;
    my $object  = $self->object;
    my $synonym = $object->Synonym;
    return { description => 'a synonym for the transgene',
	     data        =>  "$synonym" || undef };
}

# summary { }
# Supplied by Role

# driven_by_gene { }
# This method will return a data structure containing
# the gene that drives the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_gene

sub driven_by_gene {
    my $self = shift;
    my $object = $self->object;

    return { description => 'gene that drives the transgene',
	     data        => $self->_pack_obj($object->Driven_by_gene),
    };
}

# driven_by_construct { }
# This method will return a data structure containing
# the construct driving the transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/driven_by_construct

sub driven_by_construct {
    my $self = shift;
    my $object = $self->object;
    
    my $construct = $object->Driven_by_construct;
    return { description => 'construct that drives the transgene',
	     data        => "$construct" || undef };
}

# remarks {}
# Supplied by Role

# reporter_construct { }
# This method will return a data structure of the 
# reporter construct driven by the transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/reporter_construct

sub reporter_construct {
    my $self   = shift;
    my $object = $self->object;
    my %reporters;
    foreach ($object->Reporter_product) {
	if ($_ eq 'Gene') {
	    $reporters{gene} = $self->_pack_obj($_);
	} elsif ($_ eq 'Other_reporter') {
	    my $val = $_->right;
	    $reporters{'other reporter'} = "$val";
	} else {
	    $reporters{$_} = "$_";
	}
    }
    
    return { description => 'reporter construct for this transgene',
	     data        => %reporters ? \%reporters : undef };
}


# strains { }
# This method will return a data structure of all
# strains carrying this transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/strains

sub strains {
    my $self = shift;
    my $object = $self->object;

    my @data = map {$self->_pack_obj($_)} $object->Strain;

    return {
	description => 'Strains associated with this transgene',
	data => @data ? \@data : undef,
    }
}

#######################################
#
# The Isolation Widget
#
#######################################

# author { }
# This method will return a data structure containing
# the author that constructed the transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/author

sub author {
    my $self   = shift;
    my $object = $self->object;
    my $author = $object->Author;

    my $person;  # WBPeople only; Sorry, Charlie.
    my $name;
    if ($author) {
	$person = $author->Possible_person;
	$name = $person->Standard_name if $person;
    }
    
    return { description => 'the person who created the transgene',
	     data        => $self->_pack_obj($person, "$name") };
}

# laboratory { }
# Supplied by Role

# clone { }
# This method will return a data structure containing
# information about the clone of this transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/clone

sub clone {
    my $self = shift;
    my $object = $self->object;

    return { description => 'the clone of this transgene',
	     data        => $self->_pack_obj($object->Clone) };
}


# fragment { }
# This method will return a data structure containing
# information about the clone fragments contained
# in this transgene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/fragment

sub fragment {
    my $self   = shift;
    my $object = $self->object;
    my $frag = $object->Fragment;
    return { description => 'clone fragments contained in this transgene',
	     data        => "$frag" || undef };
}



# injected_into_strains { }
# This method will return a data structure containing
# strains that the transgene has been injected into.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/injected_into_strains

# -not in the schema anymore? -AC
# sub injected_into_strains {
#     my $self   = shift;
#     my $object = $self->object;
#     my @cgc_strains = $object->Injected_into_CGC_strain;
#     my @data = map { $self->_pack_obj($_) } @cgc_strains;
#     push @data,map { "$_" } $object->Injected_into;
#     return { description => 'strains that the transgene has been injected into',
# 	     data        => @data ? \@data : undef};
# }

# integration_method { }
# This method will return a data structure containing
# how the transgene was integrated (if it was).
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_by

sub integration_method {    
    my $self   = shift;
    my $object = $self->object;
    my $method = $object->Integration_method;
    return { description => 'how the transgene was integrated (if it has been)',
	     data        => $method ? "$method" : undef };
}


# integrated_at { }
# This method will return a data structure containing
# the map position of the transgene if it has been integrated.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/integrated_at

sub integrated_at {    
    my $self   = shift;
    my $object   = $self->object;
    my $position = $object->Map;

    return { description => 'map position of the integrated transgene',
	     data        => $position ? "$position" : undef};
}

# rescues { }
# This method will return a data structure containing
# information about phenotypes the transgene may rescue.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/rescues

# This tag does not exists in the current ACeDB schema -AC
# sub rescues {    
#     my $self = shift;
#     my $object = $self->object;
# 
#     my @genes = map {$self->pack_obj($_) } $object->Rescue;
#     return { description => 'genes that may be rescued by this transgene',
# 	     data        => @genes ? \@genes : undef };
# }



#######################################
#
# The Phenotypes widget
#
#######################################

# phenotypes {}
# Supplied by Role

# phenotypes_not_observed {}
# Supplied by Role

#######################################
#
# The Expression widget
#
#######################################

# expression_patterns { }
# Supplied by Role

# marker_for { }
# This method will return a data structure of the 
# describing what the transgene is a marker for.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marker_for

sub marker_for {
    my $self   = shift;
    my $object = $self->object;
    my $marker = $object->Marker_for;
    return { description => 'string decribing what the transgene is a marker for',
	     data        =>  "$marker" || undef };
}


# marked_rearrangement { }
# This method will return a data structure of the
# rearrangmements that the transgene can be used for.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/marked_rearrangement

sub marked_rearrangement {
    my $self   = shift;
    my $object = $self->object;

    my @rearrangements    = map { $self->_pack_obj($_) } $object->Marked_rearrangement;
    return { description => 'rearrangements that the transgene can be used as a marker for',
	     data        =>  @rearrangements ? \@rearrangements : undef };
}

__PACKAGE__->meta->make_immutable;

1;

