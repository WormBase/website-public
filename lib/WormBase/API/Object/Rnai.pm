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

=head2 targets

This method will return a data structure with targets for the rnai.

=head3 PERL API

 $data = $model->targets();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/targets

=head4 Response example

<div class="response-example"></div>

=cut

sub targets {
	my ($self) = @_;
	my %data;
	my $targets_hr = _classify_targets($self->object);
	foreach my $target_type ('Primary targets','Secondary targets') {
		my $genes = eval {$targets_hr->{$target_type}};
		$data{$target_type} = $genes; # are the key,value pair important? otherwise omit...
  	}
	return {
		description => 'notes',
		data => %data || undef,
	};
}

=head2 reagent

This method will return a data structure reagents for analysis of the rnai.

=head3 PERL API

 $data = $model->reagent();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/reagent

=head4 Response example

<div class="response-example"></div>

=cut

sub reagent {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->PCR_product;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'prc products off this rnai'
	};
}

=head2 sequence

This method will return a data structure with the sequence of the rnai.

=head3 PERL API

 $data = $model->sequence();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/sequence

=head4 Response example

<div class="response-example"></div>

=cut

sub sequence {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->Sequence_info->right;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'rnai sequence'
	};
}

=head2 assay>

This method will return a data structure with assays for the rnai.

=head3 PERL API

 $data = $model->assay();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/assay

=head4 Response example

<div class="response-example"></div>

=cut

sub assay {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = ($object->PCR_product) ? 'PCR product' : 'Sequence'; 
	return {
		'data'=> $data_pack,
		'description' => 'assay performed on the rnai'
	};
}

=head2 history_name

This method will return a data structure with the history_name of the rnai.

=head3 PERL API

 $data = $model->history_name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/history_name

=head4 Response example

<div class="response-example"></div>

=cut

sub history_name {
	my ($self) = @_;
	return {
		description => 'history ofthe rnai',
		data => $self ~~ 'History_name' || $self->object,
	};
}

=head2 movies

This method will return a data structure with movies documenting the effects of the rnai.

=head3 PERL API

 $data = $model->movies();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/movies

=head4 Response example

<div class="response-example"></div>

=cut


sub movies {
	my $self = shift;
    my $object = $self->object;
	my @tag_objects = $object->Supporting_data->col;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => 'movies documenting effect of rnai'
	};
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head2 genotype

This method will return a data structure with the genotype of the strain with the rnai.

=head3 PERL API

 $data = $model->genotype();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/genotype

=head4 Response example

<div class="response-example"></div>

=cut

sub genotype {
	my ($self) = @_;

	return {
		description => 'genotype of rnai strain',
		data		=> $self ~~ 'Genotype',
	};
}

=head2 strain

This method will return a data structure with strain contaning the rnai.

=head3 PERL API

 $data = $model->strain();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/strain

=head4 Response example

<div class="response-example"></div>

=cut

sub strain {
	my ($self) = @_;
	return {
		description => 'strain of origin of rnai',
		data		=> $self->_pack_obj($self ~~ 'Strain'),
	};
}

=head2 interactions

This method will return a data structure with interactions involving the rnai.

=head3 PERL API

 $data = $model->interactions();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/interactions

=head4 Response example

<div class="response-example"></div>

=cut

sub interactions {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_)} @{$self ~~ '@Interaction'};

	return {
		description => 'interactions the rnai is involved in',
		data => @data ? \@data : undef,
	};
}

=head2 treatment

This method will return a data structure with experimental treatments with the rnai.

=head3 PERL API

 $data = $model->treatment();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/treatment

=head4 Response example

<div class="response-example"></div>

=cut

sub treatment {
	my ($self) = @_;

	return {
		description => 'experimental conditions for rnai analysis',
		data => $self ~~ 'Treatment',
	};
}

=head2 life_stage

This method will return a data structure the life_stage in which the rnai is observed.

=head3 PERL API

 $data = $model->life_stage();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/life_stage

=head4 Response example

<div class="response-example"></div>

=cut

sub life_stage {
	my ($self) = @_;

    return {
		description => 'life stage in which rnai is observed',
		data => $self->_pack_obj($self ~~ 'Life_stage'),
	};
}

=head2 delivered_by

This method will return a data structure with the sources of the rnai.

=head3 PERL API

 $data = $model->delivered_by();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/delivered_by

=head4 Response example

<div class="response-example"></div>

=cut

sub delivered_by {
	my ($self) = @_;
	return {
		description => 'origing of rnai',
		data => $self ~~ 'Delivered_by',
	};
}

=head2 phenotypes

This method will return a data structure with phenotypes observed with the rnai.

=head3 PERL API

 $data = $model->phenotypes();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotypes
=head4 Response example

<div class="response-example"></div>

=cut

sub phenotypes {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype'};
	return {
		description => 'phenotypes observed with rnai',
		data => @data ? \@data : undef,
	};
}

=head2 phenotype_nots 

This method will return a data structure with phenotypes not observed with the rnai.

=head3 PERL API

 $data = $model->phenotype_nots ();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a RNAi ID WBRNAi00000001

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/rnai/WBRNAi00000001/phenotype_nots 

=head4 Response example

<div class="response-example"></div>

=cut

sub phenotype_nots {
	my ($self) = @_;
	my @data = map {$self->_pack_obj($_, scalar $_->Primary_name)}
	               @{$self ~~ '@Phenotype_not_observed'};
	return {
		description => 'phenotypes not observed with rnai',
		data => @data ? \@data : undef,
	};
}

###############
## INTERNAL
###############

sub _classify_targets {
  	my $exp = shift;
  	my %seen;
  	my %categories;
	my @genes = grep { !$seen{$_->Molecular_name}++ } $exp->Gene;
  	push @genes, grep { !$seen{$_}++ } $exp->Predicted_gene;

  	foreach my $gene (@genes) {
    	my @types = $gene->col;

    	foreach (@types) {
			my ($remark) = $_->col;
			my $status = ($remark =~ /primary/) ? 'Primary targets' : 'Secondary targets';
			push @{$categories{$status}},$gene;
    	}
  	}
	return \%categories;
}


1;
