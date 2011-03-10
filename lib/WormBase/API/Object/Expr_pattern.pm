package WormBase::API::Object::Expr_pattern;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod

=head1 NAME

WormBase::API::Object::Expr_pattern

=head1 SYNPOSIS

Model for the Ace ?Expr_pattern class.

=head1 URL

http://wormbase.org/species/expr_pattern

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget
#
#######################################

=head2 Overview

=cut

=head3 name

This method will return a data structure containing a prose
name of this expression pattern.

=over

=item PERL API

 $data = $model->name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/name

B<Response example>

<div class="response-example"></div>

=back

=cut

sub _build_name {
    my ($self) = @_;

	my $bestname = $self->bestname($self ~~ 'Gene');
    return {
        description => 'The name and WormBase internal ID of an Expr_pattern object',
        data        => $self->_pack_obj($self->object,
                                        $bestname && "Expression pattern for $bestname"),
    };
}

# sub description {}
# Supplied by Role; POD will automatically be inserted here.
# << include description >>

# TODO: this needs to be separated in the model but combined in template imo
# Override default description from Role::Object.
sub _build_description {
    my ($self) = @_;
    my %data;
    unless (($self ~~ 'Author') =~ /Mohler/) {
        $data{description} = [map {$_->name} @{$self ~~ '@Pattern'}];
        $data{remark}      = join ' ', @{$self ~~ '@Remark'};
        $data{check_bc}    = $self->_check_for_bc;
        %data = () unless @{$data{description}} || $data{remark} || $data{check_bc};
    }

    return {
        description => 'The description of the expression pattern',
        data        => %data ? \%data : undef,
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

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/subcellular_locations

B<Response example>

<div class="response-example"></div>

=back

=cut

sub subcellular_locations {
	my ($self) = @_;
	my $subcellular_loc = $self ~~ '@Subcellular_localization';

	return {
		description	=> 'TODO',
		data		=> @$subcellular_loc ? $subcellular_loc : undef,
	};
}

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

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/expressed_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub expressed_by {
	my ($self) = @_;
	my %data;

	foreach (qw(Gene Sequence Clone Protein)) {
		my $val = $self ~~ "\@$_";
		$data{$_} =  $self->_pack_objects($val) if @$val;
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

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/expressed_in

B<Response example>

<div class="response-example"></div>

=back

=cut

sub expressed_in {
	my ($self) = @_;

	my %data;
	foreach my $type (qw(Cell Cell_group Life_stage)) {
		my $packed_obj = $self->_pack_objects($self ~~ "\@$type");
		$data{ucfirst $type . 's'} = $packed_obj if %$packed_obj;
	} # TODO: what to do about pedigree stuff?

	return {
		description => 'TODO',
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

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/anatomy_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut

sub anatomy_ontology {
	my ($self) = @_;

	my @anatomy_terms = map {
		anatomy_term => $self->_pack_obj($_),
		definition => $_->Definition->name,
		location => $_->Term->name,
	}, @{$self ~~ '@Anatomy_term'};

	return {
		description => 'TODO',
		data		=> @anatomy_terms ? \@anatomy_terms : undef,
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

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/experimental_details

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
        $data{$_} = $self->_pack_objects($val) if @$val;
    }

    if (my $date = $self ~~ 'Date') {
        $data{date} = $date->name;
    }

    return {
        description => 'Experimental details of the expression pattern',
        data	    => %data ? \%data : undef,
    };
}


=head3 expression_image

This method will return a data structure containing
curated expression images, if they exist.

=over

=item PERL API

 $data = $model->expression_image();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/expression_image

B<Response example>

<div class="response-example"></div>

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

=head3 curated_images

This method will return a data structure containing
curated expression pattern images.

=over

=item PERL API

 $data = $model->curated_images();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expression pattern ID (eg Expr1213)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expression/Expr1213/curated_images

B<Response example>

<div class="response-example"></div>

=back

=cut

sub curated_images {
	my ($self) = @_;
	my $pictures = $self ~~ '@Picture';

	my @data = grep defined, map {$_->image->{data}} $self->wrap($pictures);

	return {
		description => 'Curated images of the expression pattern',
		data        => @data ? \@data : undef,
	};
}

sub movies { # TODO
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

# Is this a BC strain?
sub _check_for_bc {
	my ($self) = @_;

    # VC abd BC are the Baiilie and Moerman labs
    return scalar grep {$_ eq 'BC' || $_ eq 'VC'} @{$self ~~ '@Laboratory'};
}

1;
