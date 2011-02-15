package WormBase::API::Object::Life_stage;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


# The original LifeStage CGI presented a number of secondary screens

# TODO: Handling of big lists of objects
# Should not be returing objects in data struct
# Bring an Anatomy term
# Graphical representation of life stage following and preceeding


#######################################
#
# The Overview widget 
#
#######################################
sub name {
    my $self   = shift;
    my $object = $self->object;
    my $data = { description => 'A life stage in the development of C. elegans',
		 data        =>  { id    => "$object",
				   label => "$object",
				   class => $object->class
		 },
    };    
    return $data;
}

sub substages {
    my $self = shift;
    my $object = $self->object;
    my @substages = map { $self->_pack_obj($_) } $object->Sub_stage;
    return { data => { substages => \@substages },
	     description => 'sublife stage' };
}

sub definition {
    my $self = shift;
    my $object = $self->object;
    return { data => { definition => $object->Definition },
	     description => 'brief description  of the life stage', };
}

sub other_name {
    my $self = shift;
    my $object = $self->object;
    my $ther_name = $object->Other_name;
    
    my @other_names = map { $self->_pack_obj($_) } $object->Other_name;
    my $data = { data => { other_names => \@other_names },
		 description => 'other possible names for this lifestage' };
    return $data;
}

sub remarks {
    my $self    = shift;
    my $object  = $self->object;
    my @remarks = $object->Remark;
    
    # TODO: handling of Evidence nodes
    my $data    = { description  => 'curatorial remarks',
		    data         => \@remarks,
    };
    return $data;
}   

#######################################
#
# Expression Patterns (needs work)
#
#######################################
sub expression_patterns {
    my $self = shift;
    my $object = $self->object;

    # Oy. Really? We are just displaying a count in the UI and linking to search.
    my @patterns = map { $self->_pack_objects($_) } $object->Expr_pattern;
    return { description => 'expression patterns associated with this life stage',
	     data        => \@patterns  };
#    my $dbh = $self->dbh_ace;
#    my $count = $dbh->fetch({-query=>qw/

}


#######################################
#
# Cells
#
#######################################

# No longer used.
sub cells {
    my $self = shift;
    my $object = $self->object;
    my @cells = $object->Cell;
    return { description => 'cells at this lifestage',
	     data        => { cells => \@cells },
    };
}
		 
sub cell_group {
    my $self   = shift;
    my $object = $self->shift;
    my $cell_group = map { $self->_pack_obj($_, "$_", { class => $_->class}) } $object->Cell_group;
    return { description => 'The prominent cell group for this life stage',
	     data        => { cell_group => $cell_group } };
}

#######################################
#
# Timing
#
#######################################
sub contained_in_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Contained_in;
    return { description => 'contained in life stage',
	     data        => { contained_in_life_stage => \@stages } };
}

sub preceded_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Preceded_by;
    return { description => 'preceded by life stage',
	     data        => { preceded_by_life_stage => \@stages } };
}

sub followed_by_life_stage {
    my $self   = shift;
    my $object = $self->object;
    my @stages = map { $self->_pack_obj($_) } $object->Followed_by;
    return { description => 'next life stage after this',
	     data        => { followed_by_life_stage => \@stages } };
}


1;












1;
