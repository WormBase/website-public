package WormBase::API::Object::Strain;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Strain

<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Strain.pm
=head1 SYNPOSIS
=======
=head3 name
>>>>>>> /tmp/Strain.pm~other.7nZLzV

<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Strain.pm
Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/species/strain

=head1 TODO

=cut
=======
This method will return a data structure of the 
name and ID of the requested transgene.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene ID (gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head5 Response example
>>>>>>> /tmp/Strain.pm~other.7nZLzV

<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Strain.pm
###########
## OVERVIEW
############

=head3 name

This method will return a data structure with the name of this antibody .

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/name

=head5 Response example

<div class="response-example"></div>

=cut

sub name {
=======
<div class="response-example"></div>
>>>>>>> /tmp/Strain.pm~other.7nZLzV

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

   

=head3 id

<headvar>This method will return a data structure re: id of this strain.

=head4 PERL API

 $data = $model->id();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/id

=head5 Response example

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

=head3 description

This method will return a data structure re: description of this strain.

=head4 PERL API

 $data = $model->description();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/description

=head5 Response example

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

=head3 genotype

<headvar>This method will return a data structure re: genotype of this strain.

=head4 PERL API

 $data = $model->genotype();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/genotype

=head5 Response example

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

=head3 gene

<headvar>This method will return a data structure re: genes in this strain.

=head4 PERL API

 $data = $model->gene();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/gene

=head5 Response example

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

=head3 allele

This method will return a data structure re: alleles this strain.

=head4 PERL API

 $data = $model->allele();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/allele

=head5 Response example

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

=head3 rearrangement

This method will return a data structure re: rearrangement observed in this strain.

=head4 PERL API

 $data = $model->rearrangement();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/rearrangement

=head5 Response example

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

=head3 <headvar>

<headvar>This method will return a data structure re: this strain.

=head4 PERL API

 $data = $model-><headvar>();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Strain ID DR2

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/strain/DR2/<headvar>

=head5 Response example

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
