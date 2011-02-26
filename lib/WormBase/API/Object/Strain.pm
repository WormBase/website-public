package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Strain

=head1 SYNPOSIS

Model for the Ace ?Strain class.

=head1 URL

http://wormbase.org/species/strain

=head1 TODO

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget 
#
#######################################6

=head2 Overview

=head3 name

This method will return a data structure of the 
name and ID of the requested strain.

=over

=item PERL API

 $data = $model->name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/name

B<Response example>

<div class="response-example"></div>

=back

=cut

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

=head3 taxonomy

This method will return a data structure containing
the taxonomy of the requested strain.

=over

=item PERL API

 $data = $model->taxonomy();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/taxonomy

B<Response example>

<div class="response-example"></div>

=back

=cut

# Taxonomy is provided by Object.pm
# It is provided here for completeness of the documentation.
# sub taxonomy {}


=head3 other_names

This method will return a data structure containing
other names that have been used to refer to the strain.

=over

=item PERL API

 $data = $model->other_names();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/other_names

B<Response example>

<div class="response-example"></div>

=back

=cut

# Other_name is provided by Object.pm.
# Retain pod for completeness of documentation.
# sub other_names { }

=head3 description

This method will return a data structure containing
a description of the requested strain.

=over

=item PERL API

 $data = $model->description();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/description

B<Response example>

<div class="response-example"></div>

=back

=cut

# Supplied by Object.pm; retain pod for complete documentation of API
# sub description {}

=head3 genotype

This method will return a data structure containing 
the genotype of the strain as a string.

=over

=item PERL API

 $data = $model->genotype();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/genotype

B<Response example>

<div class="response-example"></div>

=back

=cut

sub genotype {
    my $self     = shift;
    my $object   = $self->object;
    my $genotype = $object->Genotype;
    return { description => 'the genotype of the strain',
	     data        => "$genotype" };
}

=head3 genes

This method will return a data structure 
containing the genes in this strain.

=over

=item PERL API

 $data = $model->genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/genes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub genes {
    my $self   = shift;
    my $object = $self->object;
    
    my @genes = map { $self->_pack_obj($_,$_->Public_name) } $object->Gene;
    return { description => 'genes contained in the strain',
	     data        => @genes ? \@genes : undef };
}

=head3 alleles

This method will return a data structure 
containing alleles contained in this strain.

=over

=item PERL API

 $data = $model->alleles();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/alleles

B<Response example>

<div class="response-example"></div>

=back

=cut

sub alleles {
    my $self   = shift;
    my $object = $self->object;

    my @alleles = map { $self->_pack_obj($_,$_->Public_name) } $object->Variation;
    return { description => 'alleles contained in the strain',
	     data        => @alleles ? \@alleles : undef };

}

=head3 rearrangements

This method will return a data structure 
containing rearrangements contained in this strain, if any.

=over

=item PERL API

 $data = $model->rearrangements();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/rearrangements

B<Response example>

<div class="response-example"></div>

=back

=cut

sub rearrangements {
    my $self   = shift;
    my $object = $self->object;

    my @rearrange = map { $self->_pack_obj($_) } $object->Rearrangement;
    return { description => 'rearrangements contained in the strain',
	     data        => @rearrange ? \@rearrange : undef };

}

=head3 clones

This method will return a data structure containing
clones that rescue this strain (?? HOW IS THIS USED? )

=over

=item PERL API

 $data = $model->clones();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/clones

B<Response example>

<div class="response-example"></div>

=back

=cut

sub clones {
    my $self   = shift;
    my $object = $self->object;

    my @clone = map { $self->_pack_obj($_) } $object->Clone;
    return { description => 'clones contained in the strain',
	     data        => @clone ? \@clone : undef };

}

=head3 transgenes

This method will return a data structure containing
transgenes carried by the requested strain

=over

=item PERL API

 $data = $model->transgenes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/transgenes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub transgenes {
    my $self   = shift;
    my $object = $self->object;

    my @transgenes = map { $self->_pack_obj($_) } $object->Transgene;
    return { description => 'transgenes carried by the strain',
	     data        => @transgenes ? \@transgenes : undef };

}


=head3 reference_strain

This method will return a data structure containing
the reference strain of the strain in question.

=over

=item PERL API

 $data = $model->reference_strain();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/reference_strain

B<Response example>

<div class="response-example"></div>

=back

=cut

sub reference_strain {
    my $self   = shift;
    my $object = $self->object;

    my ($strain) = map { $self->_pack_obj($_) } $object->Reference_strain;
    return { description => 'reference strain for the current strain',
	     data        => $strain || undef };   
}


=head3 mutagen

This method will return a data structure containing
the reference strain of the strain in question.

=over

=item PERL API

 $data = $model->mutagen();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/mutagen

B<Response example>

<div class="response-example"></div>

=back

=cut

sub mutagen {
    my $self   = shift;
    my $object = $self->object;
    my $mutagen = $object->Mutagen;

    return { description => 'the mutagen used to generate this stain',
	     data        => "$mutagen" || undef };

}

=head3 outcrossed

This method will return a data structure containing
the number of times a strain has been outcrossed.

=over

=item PERL API

 $data = $model->outcrossed();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/outcrossed

B<Response example>

<div class="response-example"></div>

=back

=cut

sub outcrossed {
    my $self   = shift;
    my $object = $self->object;
    my $outcrossed = $object->Outcrossed;
    return { description => 'extent to which the strain has been outcrossed',
	     data        => "$outcrossed" || undef };

}

=head3 throws_males

This method will return a data structure containing
information whether the strain throws males at a higher
than expected frequency.

=over

=item PERL API

 $data = $model->throws_males();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/throws_males

B<Response example>

<div class="response-example"></div>

=back

=cut

sub throws_males {
    my $self   = shift;
    my $object = $self->object;

    my $males = $object->Males;
    my @males = map { $self->_pack_obj($_) } $object->Males;
    return { description => 'does the strain throw males at a higher than expected frequency?',
	     data        => "$males" || undef };
}

=head3 phenotypes

This method will return a data structure containing
phenotypes observed in the strain.

=over

=item PERL API

 $data = $model->phenotypes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/phenotypes

B<Response example>

<div class="response-example"></div>

=back

=cut

sub phenotypes {
    my $self = shift;
    my $object = $self->object;

    my $data = $self->_pack_phenotypes('Phenotype_not_observed');
    return { description => 'phenotypes observed in this strain',
	     data        => @$data ? $data : undef };
}


=head3 phenotypes_not_observed

This method will return a data structure containing
phenotypes observed in the strain.

=over

=item PERL API

 $data = $model->phenotypes_not_observed();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/phenotypes_not_observed

B<Response example>

<div class="response-example"></div>

=back

=cut

sub phenotypes_not_observed {
    my $self = shift;
    my $object = $self->object;
    my $data = $self->_pack_phenotypes('Phenotype_not_observed');

    return { description => 'phenotypes NOT observed in this strain',
	     data        => @$data ? $data : undef };
}

sub _pack_phenotypes {
    my ($self,$tag) = @_;
    my $object = $self->object;
    my @phenotypes = $object->$tag;
    my @data;
    foreach my $phenotype (@phenotypes) {
	my $short = $phenotype->Short_name;
	push @data,
	{ phenotype => $self->_pack_obj($phenotype,$phenotype->Primary_name),
	  short_name => "$short",
	};
    }	
    return \@data;
}

=head3 remarks

This method will return a data structure containing
curator remarks about the transgene.

=over

=item PERL API

 $data = $model->remarks();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Transgene (eg gmIs13)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/remarks

B<Response example>

<div class="response-example"></div>

=back

=cut 

# Provided by Object.pm; retain POD for completeness of documentation.
# sub remarks { }


#######################################
#
# The Origin widget 
#
#######################################6

=head2 Origin

=head3 laboratory

This method will return a data structure containing
the laboratory (and name of the lab representative)
that generated the strain.

=over

=item PERL API

 $data = $model->laboratory();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/laboratory

B<Response example>

<div class="response-example"></div>

=back

=cut

# laboratory() is provided by Object.pm. It is included here for completeness of documentation.
# sub laboratory {}

=head3 made_by

This method will return a data structure containing
the person who built the strain.

=over

=item PERL API

 $data = $model->made_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/made_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub made_by {
    my $self   = shift;
    my $object = $self->object;
    my $made_by = $object->Made_by;
    return { description => 'the person who built the strain',
	     data        => $made_by ? $self->_pack_obj($made_by,$made_by->Standard_name) : undef };
}

=head3 contact

This method will return a data structure containing
the person who built the strain.

=over

=item PERL API

 $data = $model->contact();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/contact

B<Response example>

<div class="response-example"></div>

=back

=cut

sub contact {
    my $self   = shift;
    my $object = $self->object;
    my $made_by = $object->Contact;
    return { description => 'the person who built the strain',
	     data        => $made_by ? $self->_pack_obj($made_by,$made_by->Standard_name) : undef };
}

=head3 date_received

This method will return a data structure containing
the date the strain was received at the CGC.

=over

=item PERL API

 $data = $model->date_received();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/date_received

B<Response example>

<div class="response-example"></div>

=back

=cut

sub date_received {
    my $self   = shift;
    my $object = $self->object;
    
    my $date = $object->CGC_received;
    $date =~ s/ 00:00:00$//;
    return { description => 'date the strain was received at the CGC',
	     data        => $date || undef,
    };
}
    

#######################################
#
# The Isolation widget
#
#######################################6

=head2 Isolation

=head3 gps_coordinates

This method will return a data structure containing
the gps coordinates from where the strain was isolated.

=over

=item PERL API

 $data = $model->gps_coordinates();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/gps_coordinates

B<Response example>

<div class="response-example"></div>

=back

=cut

sub gps_coordinates {
    my $self = shift;
    my $object = $self->object;
    my ($lat,$lon) = $object->GPS;
    return { description => 'GPS coordinates of where the strain was isolated',
	     latitude    => "$lat" || undef,
	     longitude   => "$lon" || undef,
    };    
}


=head3 place

This method will return a data structure containing
the place where the strain was isolated.

=over

=item PERL API

 $data = $model->place();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/place

B<Response example>

<div class="response-example"></div>

=back

=cut

sub place {
    my $self = shift;
    my $object = $self->object;
    my $place  = $object->Place;
    return { description => 'the place where the strain was isolated',
	     data        => "$place" || undef,
    };
}

=head3 landscape

This method will return a data structure containing
the general type of landscape where the strain was isolated.

=over

=item PERL API

 $data = $model->landscape();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/landscape

B<Response example>

<div class="response-example"></div>

=back

=cut

sub landscape { 
    my $self   = shift;
    my $object = $self->object;
    my $landscape  = $object->Landscape;
    return { description => 'the general landscape where the strain was isolated',
	     data        => "$landscape" || undef,
    };
}

=head3 substrate

This method will return a data structure containing
the substrate that the stain was found on.

=over

=item PERL API

 $data = $model->substrate();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/subtrate

B<Response example>

<div class="response-example"></div>

=back

=cut

sub substrate { 
    my $self   = shift;
    my $object = $self->object;
    my $substrate  = $object->Substrate;
    return { description => 'the substrate the strain was isolated on',
	     data        => "$substrate" || undef,
    };
}

=head3 associated_organisms

This method will return a data structure containing
other organisms present when the strain was isolated.

=over

=item PERL API

 $data = $model->associated_organisms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/associated_organisms

B<Response example>

<div class="response-example"></div>

=back

=cut

sub associated_organisms { 
    my $self = shift;
    my $object = $self->object;
    my @orgs  = map { "$_" } $object->Associated_organisms;
    return { description => 'the place where the strain was isolated',
	     data        => @orgs ? \@orgs : undef };
}

=head3 life_stage

This method will return a data structure containing
the life stage the strain was in when isolated.

=over

=item PERL API

 $data = $model->life_stage();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/life_stage

B<Response example>

<div class="response-example"></div>

=back

=cut

sub life_stage { 
    my $self = shift;
    my $object = $self->object;
    my $life_stage  = $object->Life_stage;
    return { description => 'the life stage the strain was in when isolated',
	     data        => $life_stage ? $self->_pack_obj($life_stage) : undef,
    };   
}

=head3 log_size_of_population

This method will return a data structure containing
the log size of the population.

=over

=item PERL API

 $data = $model->log_size_of_population();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/log_size_of_population

B<Response example>

<div class="response-example"></div>

=back

=cut

sub log_size_of_population {
    my $self = shift;
    my $object = $self->object;
    my $size   = $object->Log_size_of_population;
    return { description => 'thelog size of the population when isolated',
	     data        => "$size" || undef,
    };
}

=head3 sampled_by

This method will return a data structure containing
the person who sampled the strain.

=over

=item PERL API

 $data = $model->sampled_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/sampled_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub sampled_by {
    my $self = shift;
    my $object   = $self->object;
    my $sampled  = $object->Sampled_by;
    return { description => 'the person who sampled the strain',
	     data        => "$sampled" || undef,
    };
}

=head3 isolated_by

This method will return a data structure containing
the person who isolated the strain.

=over

=item PERL API

 $data = $model->isolated_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/isolated_by

B<Response example>

<div class="response-example"></div>

=back

=cut

sub isolated_by {
    my $self    = shift;
    my $object  = $self->object;
    my $person  = $object->Isolated_by;
    return { description => 'the person who isolated the strain',
	     data        => $person ? $self->_pack_obj($person,$person->Standard_name) : undef };
}

=head3 date_isolated

This method will return a data structure containing
the date the strain was isolated.

=over

=item PERL API

 $data = $model->date_isolated();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Strain ID (eg CB1)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/CB1/date_isolated

B<Response example>

<div class="response-example"></div>

=back

=cut

sub date_isolated {
    my $self = shift;
    my $object = $self->object;
    my $date   = $object->Date;
    return { description => 'the date the strain was isolated',
	     data        => "$date" || undef,
    };
}


1;
