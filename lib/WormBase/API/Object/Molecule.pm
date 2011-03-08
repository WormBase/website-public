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

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 synonym

This method will return a data structure with synonyms for the molecule name.

=over

=item PERL API

 $data = $model->synonym();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/synonym

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub synonym {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Synonym;
    return {
        'data'        => $data_pack,
        'description' => 'synonyms for the molecule name'
    };
}

=head3 db

This method will return a data structure with db information for the molecule.

=over

=item PERL API

 $data = $model->db();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/db

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub db {
    my $self             = shift;
    my $object           = $self->object;
    my @db_data          = $object->DB_info->col if $object->DB_info;
    my $db               = $self->_pack_obj( $db_data[0] );
    my $field            = $self->_pack_obj( $db_data[1] );
    my $accession_number = $self->_pack_obj( $db_data[2] );

    my $data_pack = {
        'db'        => $db,
        'field'     => $field,
        'accession' => $accession_number
    };
    return {
        'data'        => $data_pack,
        'description' => 'database information for external resources'
    };
}

=head3 gene_regulation

This method will return a data structure with gene_regulation processes involving the molecule.

=over

=item PERL API

 $data = $model->gene_regulation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/gene_regulation

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gene_regulation {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Gene_regulation->right
      if $object->Gene_regulation;
    my $data_pack = $self->_pack_obj($tag_object);
    return {
        'data'        => $data_pack,
        'description' => 'gene regulation involving the molecule'
    };
}

=head3 molecule_use

This method will return a data structure with information on molecule_use.

=over

=item PERL API

 $data = $model->molecule_use();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/molecule_use

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub molecule_use {
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Molecule_use;
    return {
        'data'        => $data_pack,
        'description' => 'uses for the molecule'
    };
}

############################
#
# The Phenotype Widget
#
############################

=head3 affected_variation

This method will return a data structure with variations affected by the molecule.

=over

=item PERL API

 $data = $model->affected_variation();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_variation

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub affected_variation {
    my $self      = shift;
    my $data_pack = _affects('Variation');

    return {
        data        => $data_pack,
        description => 'variations affected by molecule'

    };
}

=head3 affected_strain

This method will return a data structure with strains affected by the molecule.

=over

=item PERL API

 $data = $model->affected_strain();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_strain

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub affected_strain {
    my $self      = shift;
    my $data_pack = _affects('Strain');

    return {
        data        => $data_pack,
        description => 'strain affected by molecule'
    };
}

=head3 affected_transgene

This method will return a data structure with transgenes affected by the molecule.

=over

=item PERL API

 $data = $model->affected_transgene();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_transgene

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub affected_transgene {
    my $self      = shift;
    my $data_pack = _affects('Transgene');

    return {
        data        => $data_pack,
        description => 'transgenes affected by molecule'
    };
}

=head3 affected_rnai

This method will return a data structure with rnais affected by the molecule.

=over

=item PERL API

 $data = $model->affected_rnai();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Molecule id (eg D054852)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/molecule/D054852/affected_rnai

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub affected_rnai {
    my $self      = shift;
    my $data_pack = _affects('RNAi');

    return {
        data        => $data_pack,
        description => 'rnai affected by molecule'
    };
}

##########################
#
# Internal methods
#
##########################

sub _affects {
    my $self        = shift;
    my $tag         = shift;
    my $object      = $self->object;
    my @tag_objects = $object->$tag;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return @data_pack ? \@data_pack : undef;
}

1;
