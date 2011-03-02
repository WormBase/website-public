package WormBase::API::Object::Molecule;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

## headvar WormBase::API::Object::Molecule

=head1 SYNPOSIS

Model for the Ace ?Molecule class.

=head1 URL

http://wormbase.org/resources/molecule

=head1 TODO

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head2 synonym 

This method will return a data structure with synonym for the molecule name.

=head3 PERL API

 $data = $model->synonym();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Molecule ID D054852

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/synonym 

=head4 Response example

<div class="response-example"></div>

=cut

sub synonym {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Synonym; 
	return {
		'data'=> $data_pack,
		'description' => ''
	};
}

=head2 db

This method will return a data structure with db info for the molecule.

=head3 PERL API

 $data = $model->db();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Molecule ID D054852

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/db

=head4 Response example

<div class="response-example"></div>

=cut


sub db {
	my $self = shift;
    my $object = $self->object;
    my @db_data = $object->DB_info->col if $object->DB_info;
    my $db = $self->_pack_obj($db_data[0]);
    my $field = $self->_pack_obj($db_data[1]);
    my $accession_number = $self->_pack_obj($db_data[2]);
    
	my $data_pack = {
		'db' =>$db,
		'field' =>$field,
		'accession' => $accession_number
	};
	return {
		'data'=> $data_pack,
		'description' => ''
		};
}

=head2 affects

This method will return a data structure with classes affected by the molecule.

=head3 PERL API

 $data = $model->affects();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Molecule ID D054852

an object tag Variation Strain Transgene OR RNAi

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affects

=head4 Response example

<div class="response-example"></div>

=cut


sub affects {
	my $self = shift;
	my $tag = shift;
    my $object = $self->object;
	my @tag_objects = $object->$tag;
	my @data_pack = map {$_ = $self->_pack_obj($_)} @tag_objects if @tag_objects;
	return {
		'data'=> \@data_pack,
		'description' => ''
	};
}

=head2 gene_regulation

This method will return a data structure on the gene_regulation involving the molecule.

=head3 PERL API

 $data = $model->gene_regulation();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Molecule ID D054852

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/gene_regulation

=head4 Response example

<div class="response-example"></div>

=cut


sub gene_regulation {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Gene_regulation->right if $object->Gene_regulation;
	my $data_pack = $self->_pack_obj($tag_object);
	return {
		'data'=> $data_pack,
		'description' => ''
		};
}

=head2 molecule_use

This method will return a data structure info on the use of the molecule.

=head3 PERL API

 $data = $model->molecule_use();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Molecule ID D054852

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/molecule_use

=head4 Response example

<div class="response-example"></div>

=cut

sub molecule_use {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Molecule_use; 
	return {
		'data'=> $data_pack,
		'description' => ''
	};
}
1;