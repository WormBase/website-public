package WormBase::API::Object::Rnai;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Rnai

=head1 SYNPOSIS

Model for the Ace ?Rnai class.

=head1 URL

http://wormbase.org/species/*/rnai

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
# The Overview Widget
#
#######################################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 historical_name

This method will return a data structure containing
the historical name of the RNAi.

=over

=item PERL API

 $data = $model->historical_name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/historical_name

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub historical_name {
    my $self = shift;
    my $object = $self->object;
    my $name   = $object->History_name;
    return { description => 'historical name of he rnai',
	     data        => "$name" || undef };
}

# sub taxonomy { }
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>

=head3 targets

This method will return a data structure with targets for the RNAi.

=over

=item PERL API

 $data = $model->targets();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/targets

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub targets {
    my ($self) = @_;
    my $object = $self->object;

    my %seen;    
    my @genes = $object->Gene;
    push @genes, grep { !$seen{$_}++ } $object->Predicted_gene;
    
    my @data;
    foreach my $gene (@genes) {
        my @types = $gene->col;
	
        foreach (@types) {
            my ($remark) = $_->col;
	    push @data, {target_type => $remark =~ /primary/ ? 'Primary target' : 'Secondary target',
			 gene        => $self->_pack_obj($gene)
	    };
        }
    }
    
    return { description => 'gene targets of the RNAi experiment',
	     data        => @data ? \@data : undef };
}


=head3 movies

This method will return a data structure with links to 
movies demonstrating the phenotype observed in the RNAi
experiment.

=over

=item PERL API

 $data = $model->movies();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/movies

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub movies {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Supporting_data->col if $object->Supporting_data;
    my @data        = map { $_ = $self->_pack_obj($_) } @tag_objects if @tag_objects;
    return { data        => @data ? \@data : undef,
	     description => 'movies documenting effect of rnai' };
}


# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


#######################################
#
# The Details Widget
#
#######################################

=head2 Overview

=head3 reagent

This method will return a data structure with reagents used with the RNAi.

=over

=item PERL API

 $data = $model->reagent();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/reagent

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub reagent {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->PCR_product;
    my @data        = map { $_ = $self->_pack_obj($_) } $object->PCR_product;
    return { data        => @data ? \@data : undef,
	     description => 'prc products used to generate this RNAi'
    };
}

=head3 sequence

This method will return a data structure with the sequence of the RNAi.

=over

=item PERL API

 $data = $model->sequence();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/sequence

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sequence {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Sequence_info->right;
    my @data   = map { "$_" } @tag_objects;
    return { data        => @data ? \@data : undef,
	     description => 'rnai sequence'
    };
}

=head3 assay

This method will return a data structure with assay for the RNAi.

=over

=item PERL API

 $data = $model->assay();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/assay

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub assay {
    my $self      = shift;
    my $object    = $self->object || shift;
    my $data      = $object->PCR_product  ? 'PCR product' : 'Sequence';
    return {data        => $data ? "$data" : undef,
	    description => 'assay performed on the rnai' };
}


=head3 genotype

This method will return a data structure with the genotype background of the RNAi.

=over

=item PERL API

 $data = $model->genotype();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/genotype

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub genotype {
    my $self   = shift;
    my $object = $self->object;
    my $genotype = $object->Genotype;
    return { description => 'genotype of rnai strain',
	     data        => "$genotype" || undef };
}

=head3 strain

This method will return a data structure with the strain containing the RNAi.

=over

=item PERL API

 $data = $model->strain();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/strain

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub strain {
    my $self   = shift;
    my $object = $self->object;
    return { description => 'strain of origin of rnai',
	     data        => $self->_pack_obj( $object->Strain) };
}

=head3 interactions

This method will return a data structure with interactions associated with the RNAi.

=over

=item PERL API

 $data = $model->interactions();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/interactions

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub interactions {
    my ($self) = @_;
    my @data = map { $self->_pack_obj($_) } @{ $self ~~ '@Interaction' };
    return {
        description => 'interactions the rnai is involved in',
        data        => @data ? \@data : undef,
    };
}

=head3 treatment

This method will return a data structure with treatments involving the RNAi.

=over

=item PERL API

 $data = $model->treatment();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/treatment

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub treatment {
    my $self   = shift;
    my $object = $self->object;
    my $treatment = $object->Treatment;
    return {
        description => 'experimental conditions for rnai analysis',
        data        => "$treatment" || undef };
}

=head3 life_stage

This method will return a data structure with the life_stage associated with the RNAi.

=over

=item PERL API

 $data = $model->life_stage();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/life_stage

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub life_stage {
    my ($self) = @_;

    return {
        description => 'life stage in which rnai is observed',
        data        => $self->_pack_obj( $self ~~ 'Life_stage' ),
    };
}

=head3 delivered_by

This method will return a data structure desribing
how the RNAi was delivered to the organism.

=over

=item PERL API

 $data = $model->delivered_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An RNAi id (eg WBRNAi00000001)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/delivered_by

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub delivered_by {
    my $self   = shift;
    my $object = $self->object;
    my $delivered = $object->Delivered_by;
    return { description => 'how the RNAi was delivered to the animal',
	     data        => "$delivered" || undef };
}

############################################################
#
# The Phenotypes widget
#
############################################################

# sub phenotypes {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes>>

# sub phenotypes_not_observed {}
# Supplied by Role; POD will automatically be inserted here.
# <<include phenotypes_not_observed>>

############################################################
#
# The External Links widget
#
############################################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


__PACKAGE__->meta->make_immutable;

1;

