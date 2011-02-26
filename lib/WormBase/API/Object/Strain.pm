package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Strain

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/strain

=head1 TODO

=cut

###########
## OVERVIEW
############

=head2 name

This method will return a data structure with the name of this antibody .

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/name

=head4 Response example

<div class="response-example"></div>

=cut

sub name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
					'label' => "$object",
					'class' => 'Strain',
					'id' => "$object"
				};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

=head2 id

<headvar>This method will return a data structure re: id of this strain.

=head3 PERL API

 $data = $model->id();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/id

=head4 Response example

<div class="response-example"></div>

=cut

sub id {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
					'label' => "$object",
					'class' => 'Strain',
					'id' => "$object"
				};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

=head2 description

This method will return a data structure re: description of this strain.

=head3 PERL API

 $data = $model->description();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/description

=head4 Response example

<div class="response-example"></div>

=cut


sub description {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
					'common_name' => $object,
					'class' => 'Strain',
					'ace_id' => $object
				};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

##############
## GENOTYPE
############

=head2 genotype

<headvar>This method will return a data structure re: genotype of this strain.

=head3 PERL API

 $data = $model->genotype();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/genotype

=head4 Response example

<div class="response-example"></div>

=cut


sub genotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'genotype of the strain';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Genotype;

	####
	

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

##############
## CONTAINS
############

=head2 gene

<headvar>This method will return a data structure re: genes in this strain.

=head3 PERL API

 $data = $model->gene();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/gene

=head4 Response example

<div class="response-example"></div>

=cut

sub gene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @genes = $object->Gene;
	foreach my $gene (@genes) {
	
		my $gene_name = public_name($gene,'Gene'); ## common_name($gene)
		push @data_pack, {
							'id' => "$gene",
							'common_name' => "$gene_name",
							'class' => 'Gene'
							};	
	}

	####
	
	$data{'data'} = \@data_pack; ## 
	$data{'description'} = $desc;
	return \%data;
}

=head2 allele

This method will return a data structure re: alleles this strain.

=head3 PERL API

 $data = $model->allele();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/allele

=head4 Response example

<div class="response-example"></div>

=cut

sub allele {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	
	my $allele = $object->Variation;
	my $allele_name = $allele->Public_name;
	

	$data_pack = {
	
		'id' =>"$allele",
		'label' =>"$allele_name",
		'Class' => 'Variation'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

=head2 rearrangement

This method will return a data structure re: rearrangement observed in this strain.

=head3 PERL API

 $data = $model->rearrangement();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/rearrangement

=head4 Response example

<div class="response-example"></div>

=cut


sub rearrangement {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Rearrangement;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

=head2 <headvar>

<headvar>This method will return a data structure re: this strain.

=head3 PERL API

 $data = $model-><headvar>();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Strain ID DR2

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/<headvar>

=head4 Response example

<div class="response-example"></div>

=cut

sub clone {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Clone;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub transgene {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Transgene;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

##############
## PROPERTIES
############

### sub species

sub males {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Males;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub reference_strain {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $ref_strain = $object->Reference_strain;
	
	$data_pack = {
	
		'id' =>"$ref_strain",
		'label' =>"$ref_strain",
		'Class' => 'Strain'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub mutagen {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Mutagen;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub outcrossed {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Outcrossed;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub date_received {

	my $self = shift;
    my $strain = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;
	my $date;

	
	#### data pull and packaging
	
	$date   = $strain->CGC_received;
	$date =~ s/ 00:00:00$//;
	$data_pack = $date;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub properties  {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $strain;
	$strain = eval { $object->Species->name; };
	
	## phenotype data:  Basic package for now, will add details once phenotype.pm comes inline
	my @phenotypes = $object->Phenotype;
	my $phenotype_package = basic_package(\@phenotypes);
	
	$data_pack = {
	
				'species'  =>  $strain,
				'males'    => $object->Males,
				'reference_strain' => $object->Reference_strain,
				'outcrossed' => $object->Outcrossed,
				'mutagen'    => $object->Mutagen,
				'received_at_CGC' => $object->CGC_received,
				'phenotype' => %$phenotype_package
				};	
	
	
	####

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @phenotypes = $object->Phenotype;

	foreach my $phenotype (@phenotypes) {
	
		my $phene_name = $phenotype ; ## common_name($gene)
		
		push @data_pack, {
							'label' => "$phene_name",
							'class' => 'Phenotype',
							'id' => "$phenotype"
							};	
	}

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}



##############
## LOCATION
############

sub location {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Location;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


##############
## MADE BY
############

sub made_by {


	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'developer of the strain';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Made_by;

	####
	

	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;


}

# sub remarks { }



1;
