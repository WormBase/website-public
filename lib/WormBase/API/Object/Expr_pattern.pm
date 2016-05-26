package WormBase::API::Object::Expr_pattern;

use Moose;
use File::Spec;
use namespace::autoclean -except => 'meta';

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

# TODO:
#  Split _build_description (see comment down below)
#  Movie method?

=pod

=head1 NAME

WormBase::API::Object::Expr_pattern

=head1 SYNPOSIS

Model for the Ace ?Expr_pattern class.

=head1 URL

http://wormbase.org/species/*/expr_pattern

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

sub _build__common_name {
    my $self     = shift;
    my $object   = $self->object;
    my $gene     = $object->Gene;
    my $bestname = $gene->Public_name if $gene;

    return "Expression pattern for $bestname" if $bestname;
    return "Source Image";
#    return $self->object->name;
}

# description {}
# Supplied by Role

# is_bc_strain { }
# returns true, false or undef if no data WRT
# if this strain is from BC/VC

sub is_bc_strain {
    my ($self) = @_;

    my $lab = $self->laboratory->{data};
    return {
        description => 'Whether this is expression pattern for a BC strain',
        data        => $lab && ($lab eq 'BC' || $lab eq 'VC'),
    };
}

# subcellular_locations { }
# This method will return a data structure containing
# subcellular locations of this expression pattern.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/subcellular_locations

sub subcellular_locations {
    my ($self) = @_;
    my @subcellular_locs = map {"$_"} @{$self ~~ '@Subcellular_localization'};

    return {
        description	=> 'Subcellular locations of this expression pattern',
        data		=> @subcellular_locs ? \@subcellular_locs : undef,
    };
}

# historical_gene { }
# This mehtod will return a data structure containing the
# historical reocrd of the dead gene originally associated with this Expression pattern
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/historical_gene

sub historical_gene {
    my $self = shift;
    my $object = $self->object;

    my @historical_gene = map { {text => $self->_pack_obj($_),
                              evidence => $self->_get_evidence($_)} } $object->Historical_gene;
    return { description => 'Historical record of the dead genes originally associated with this expression pattern',
             data        => @historical_gene ? \@historical_gene : undef,
    };
}

# expression_image { }
# This method will return a data structure containing the string to use with
# /draw to retrieve the curated expression images, if they exist.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expression_image

sub expression_image {
    my ($self) = @_;
    my $object = $self->object;

	my $data;
	my $file = File::Spec->catfile($self->pre_compile->{image_file_base},$self->pre_compile->{expression_object_path}, "$object.jpg");
	$data = File::Spec->catfile($self->pre_compile->{expression_object_path},"$object.jpg") if (-e $file && !-z $file);

	return {
		description => 'Image of the expression pattern',
		data        => $data,
	};
}

sub ep_movies{
    my ($self) = @_;
    my $object = $self->object;

    my @movies = $object->Movie;
    my $reference = $object->Reference;
    my @filenames = map { my $name = $_->Public_name; "$reference/$name" } @movies;

    return {
        description => 'Movies showcasing this expression pattern',
        data        => @filenames ? \@filenames : undef
    };
}

sub database {
    my ($self) = @_;
    my $object = $self->object;

    my @dbs;
    foreach my $db ($object->DB_info) {
        # assuming we don't have any other fields other than id
        foreach my $id (map { $_->col } $db->col) {
            push @dbs, { class => "$db",
                         label => "$db",
                         id    => "$id" };
        }
    }

    return {
        description => 'Database for this expression pattern',
        data        => @dbs ? \@dbs : undef,
    }
}

# remarks {}
# Supplied by Role

#######################################
#
# The Details widget
#
#######################################

# expressed_by { }
# This method will return a data structure containing
# information on the gene or clone responsible for the
# expression pattern.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expressed_by

sub expressed_by {
	my ($self) = @_;
	my %data;

	foreach (qw(Gene Sequence Clone Protein)) {
		my $val = $self ~~ "\@$_";
		$data{lc $_} =  $self->_pack_objects($val) if @$val;
	}

	return {
		description => 'Items that exhibit this expression pattern',
		data		=> %data ? \%data : undef,
	};
}

# expressed_in { }
# This method will return a data structure containing
# the life stage in which the expression pattern is observed.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expressed_in

sub expressed_in {
	my ($self) = @_;

	my %data;
	foreach my $type (qw(Cell Cell_group Life_stage)) {
		my $packed_obj = $self->_pack_objects($self ~~ "\@$type");
		$data{lc $type} = $packed_obj if %$packed_obj;
	} # TODO: what to do about pedigree stuff?

	return {
		description => 'where the expression has been noted',
		data		=> %data ? \%data : undef
	};
}

# anatomy_ontology { }
# This method will return a data structure containing
# anatomy ontology entries associated with this expression pattern.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/anatomy_ontology

sub anatomy_ontology {
    my $self = shift;

    my @data = map {
        my $def = $_->Definition;
        {
            anatomy_term => $self->_pack_obj($_),
            definition   => $def && "$def",
        };
    } $self->object->Anatomy_term;

    return {
        description => 'anatomy ontology terms associated with this expression pattern',
        data	    => @data ? \@data : undef,
    };
}

# gene_ontology { }
# This method will return a data structure containing
# gene ontology entries associated with this expression pattern.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/gene_ontology

sub gene_ontology {
    my ($self) = @_;

    my @go_terms = map {
	my $name = $_->Definition->name;
	{
	  go_term => $self->_pack_obj($_),
	  definition => $name && "$name",
	};
    } $self->object->GO_term;

    return {
	description => 'gene ontology terms associated with this expression pattern',
	data	    => @go_terms ? \@go_terms : undef,
    };
}

# experimental_details { }
# This method will return a data structure containing
# experimental details about how the expression pattern
# was generated.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/experimental_details

sub experimental_details {
    my ($self) = @_;
    my %data;

    if (my @types = @{$self ~~ '@Type'}) {
        $data{types} = [map ["$_", $_->right . ''], @types];
    }

    foreach (qw(Antibody_info Transgene Construct Strain Author)) {
        my $val = $self ~~ "\@$_";
        my @vals_packed = map {
            my $v = $self->_pack_obj($_);
            my $summary = eval { $_->Summary };
            $summary ? ($v, "$summary") : ($v);
        } @$val;
        $data{lc($_)} = @vals_packed ? \@vals_packed : undef;
    }

    if (my $date = $self ~~ 'Date') {
	my $name = $date->name if $date;
        $data{date} = $name && "$name";
    }

    return {
        description => 'Experimental details of the expression pattern',
        data	    => %data ? \%data : undef,
    };
}



#######################################
#
# The Curated Images widget
#
#######################################

# curated_images { }
# This method will return a data structure containing
# curated expression pattern images in the Picture::image format.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/curated_images

sub curated_images { # Caveat: this is very tightly coupled with the Picture model
    my ($self) = @_;

    my %data;

    foreach my $pic ($self->_api->wrap(@{$self ~~ '@Picture'})) {
        my $img_data = $pic->image->{data}; # can't render the image if there is no file!
        next unless $img_data;

        my $id          = $pic->object->name;
        my $extsrc_data = $pic->external_source->{data};

        my $src_data = $pic->_source();


        # assumption: extsrc_data has 1 to 1 relation to src_data
        my $group = ($src_data && $src_data->{id}) || 'none';

        push @{$data{$group}}, {
            id              => $id,
            draw            => $img_data,
            external_source => $extsrc_data,
            source          => $src_data,
        };
    }

    return {
        description => 'Curated images of the expression pattern',
        data        => %data ? \%data : undef,
    };
}



# TODO; please add documentation when done.
sub movies {
	my ($self) = @_;
	my $data;

	return {
		description => 'TODO',
	};
}

############################################################
#
# PRIVATE METHODS
#
############################################################

__PACKAGE__->meta->make_immutable;

1;
