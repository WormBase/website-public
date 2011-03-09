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

http://wormbase.org/species/rnai

=head1 METHODS/URIs

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
    my %data;
    my $targets_hr = _classify_targets( $self->object );
    foreach my $target_type ( 'Primary targets', 'Secondary targets' ) {
        my $genes = eval { $targets_hr->{$target_type} };
        $data{$target_type} =
          $genes;    # are the key,value pair important? otherwise omit...
    }
    return {
        description => 'notes',
        data        => %data || undef,
    };
}

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
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data' => @data_pack ? \@data_pack : undef,
        'description' => 'prc products off this rnai'
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
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data' => @data_pack ? \@data_pack : undef,
        'description' => 'rnai sequence'
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
    my $object    = $self->object;
    my $data_pack = ( $object->PCR_product ) ? 'PCR product' : 'Sequence';
    return {
        'data'        => $data_pack,
        'description' => 'assay performed on the rnai'
    };
}

=head3 history_name

This method will return a data structure with history for the RNAi name.

=over

=item PERL API

 $data = $model->history_name();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/history_name

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub history_name {
    my ($self) = @_;
    return {
        description => 'history ofthe rnai',
        data        => $self ~~ 'History_name' || $self->object,
    };
}

=head3 movies

This method will return a data structure with movie data on the RNAi.

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
    my @tag_objects = $object->Supporting_data->col;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data' => @data_pack ? \@data_pack : undef,
        'description' => 'movies documenting effect of rnai'
    };
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

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
    my ($self) = @_;

    return {
        description => 'genotype of rnai strain',
        data        => $self ~~ 'Genotype',
    };
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
    my ($self) = @_;
    return {
        description => 'strain of origin of rnai',
        data        => $self->_pack_obj( $self ~~ 'Strain' ),
    };
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
    my ($self) = @_;

    return {
        description => 'experimental conditions for rnai analysis',
        data        => $self ~~ 'Treatment',
    };
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

This method will return a data structure with delivered_by associations to the RNAi.

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
    my ($self) = @_;
    return {
        description => 'origing of rnai',
        data        => $self ~~ 'Delivered_by',
    };
}

=head3 phenotypes

This method will return a data structure with phenotypes associated with the RNAi.

=over

=item PERL API

 $data = $model->phenotypes();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotypes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotypes {
    my ($self) = @_;
    my @data =
      map { $self->_pack_obj( $_, scalar $_->Primary_name ) }
      @{ $self ~~ '@Phenotype' };
    return {
        description => 'phenotypes observed with rnai',
        data        => @data ? \@data : undef,
    };
}

=head3 phenotype_nots

This method will return a data structure with phenotypes not associated with the RNAi.

=over

=item PERL API

 $data = $model->phenotype_nots();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotype_nots

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub phenotype_nots {
    my ($self) = @_;
    my @data =
      map { $self->_pack_obj( $_, scalar $_->Primary_name ) }
      @{ $self ~~ '@Phenotype_not_observed' };
    return {
        description => 'phenotypes not observed with rnai',
        data        => @data ? \@data : undef,
    };
}

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

###############
## INTERNAL
###############

sub _classify_targets {
    my $exp = shift;
    my %seen;
    my %categories;
    my @genes = grep { !$seen{ $_->Molecular_name }++ } $exp->Gene;
    push @genes, grep { !$seen{$_}++ } $exp->Predicted_gene;

    foreach my $gene (@genes) {
        my @types = $gene->col;

        foreach (@types) {
            my ($remark) = $_->col;
            my $status =
              ( $remark =~ /primary/ )
              ? 'Primary targets'
              : 'Secondary targets';
            push @{ $categories{$status} }, $gene;
        }
    }
    return \%categories;
}

1;
