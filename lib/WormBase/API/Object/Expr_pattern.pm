package WormBase::API::Object::Expr_pattern;

use Moose;

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
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

sub _build__common_name {
    my $self     = shift;
    my $object   = $self->object;
    my $gene     = $object->Gene;
    my $bestname = $gene->Public_name if $gene;
    
    return "Expression pattern for $bestname" if $bestname;
    return "Source Image";
#    return $self->object->name;
}

# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

sub is_bc_strain { # returns true, false, or undef (if no data)
    my ($self) = @_;

    my $lab = $self->laboratory->{data};
    return {
        description => 'Whether this is expression pattern for a BC strain',
        data        => $lab && ($lab eq 'BC' || $lab eq 'VC'),
    };
}

=head3 subcellular_locations

This method will return a data structure containing
subcellular locations of this expression pattern.

=over

=item PERL API

 $data = $model->subcellular_locations();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/subcellular_locations

B<Response example>

<div class="response-example"></div>

=back

=cut

sub subcellular_locations {
    my ($self) = @_;
    my @subcellular_locs = map {"$_"} @{$self ~~ '@Subcellular_localization'};
    
    return {
	description	=> 'Subcellular locations of this expression pattern',
	data		=> @subcellular_locs ? \@subcellular_locs : undef,
    };
}

=head3 expression_image

This method will return a data structure containing the string to use with
/draw to retrieve the curated expression images, if they exist.

=over

=item PERL API

 $data = $model->expression_image();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expression_image

B<Response example>

<div class="response-example"></div>

B<Usage example>

http://wormbase.org/draw/$data

=back

=cut

sub expression_image {
    my ($self) = @_;

	my $data;
	my $file = $self->pre_compile->{expr_object}."/".$self->object.".jpg";
	$data = 'jpg?class=expr_object&id=' . $self->object if (-e $file && !-z $file);

	return {
		description => 'Image of the expression pattern',
		data        => $data,
	};
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


#######################################
#
# The Details widget
#
#######################################

=head2 Details

=cut

=head3 expressed_by

This method will return a data structure containing
information on the gene or clone responsible for the
expression pattern.

=over

=item PERL API

 $data = $model->expressed_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expressed_by

B<Response example>

<div class="response-example"></div>

=back

=cut

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

=head3 expressed_in

This method will return a data structure containing
the life stage in which the expression pattern is observed.

=over

=item PERL API

 $data = $model->expressed_in();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/expressed_in

B<Response example>

<div class="response-example"></div>

=back

=cut

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

=head3 anatomy_ontology

This method will return a data structure containing
anatomy ontology entries associated with this expression pattern.

=over

=item PERL API

 $data = $model->anatomy_ontology();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/anatomy_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut

sub anatomy_ontology {
    my $self = shift;
    my $object = $self->object;
    my @terms  = $object->Anatomy_term;

    my @data;
    foreach (@terms) {
	push @data,{ 
	    anatomy_term => $self->_pack_obj($_),
	    definition   => $_->Definition,
	};
    }
    
    return {
	description => 'anatomy ontology terms associated with this expression pattern',
	data	    => @data ? \@data : undef,
    };
}


=head3 gene_ontology

This method will return a data structure containing
gene ontology entries associated with this expression pattern.

=over

=item PERL API

 $data = $model->gene_ontology();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/gene_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut

sub gene_ontology {
    my ($self) = @_;
    
    my @go_terms = map {
	go_term => $self->_pack_obj($_),
	definition => $_->Definition->name,
    }, @{$self ~~ '@GO_term'};
    
    return {
	description => 'gene ontology terms associated with this expression pattern',
	data	    => @go_terms ? \@go_terms : undef,
	};
}

=head3 experimental_details

This method will return a data structure containing
experimental details about how the expression pattern
was generated.

=over

=item PERL API

 $data = $model->experimental_details();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/experimental_details

B<Response example>

<div class="response-example"></div>

=back

=cut

sub experimental_details {
    my ($self) = @_;
    my %data;

    if (my @types = @{$self ~~ '@Type'}) {
        $data{types} = [map ["$_", $_->right . ''], @types];
    }

    foreach (qw(Antibody_info Transgene Strain Author)) {
        my $val = $self ~~ "\@$_";
        $data{lc($_)} = $self->_pack_objects($val) if @$val;
    }

    if (my $date = $self ~~ 'Date') {
        $data{date} = $date->name;
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

=heads2

=head3 curated_images

This method will return a data structure containing
curated expression pattern images in the Picture::image format.

=over

=item PERL API

 $data = $model->curated_images();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr12)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr12/curated_images

B<Response example>

<div class="response-example"></div>

=back

=cut

sub curated_images { # Caveat: this is very tightly coupled with the Picture model
    my ($self) = @_;
    
    my %data;
    
    foreach my $pic ($self->_wrap(@{$self ~~ '@Picture'})) {
        my $img_data = $pic->image->{data}; # can't render the image if there is no file!
        next unless $img_data;
	
        my $id          = $pic->object->name;
        my $extsrc_data = $pic->external_source->{data};
        my $src_data    = $pic->reference->{data} || $pic->contact->{data};
	
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



# TODO
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

