package WormBase::API::Object::Expr_profile;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Expr_profile

=head1 SYNPOSIS

Model for the Ace ?Expr_profile class.

=head1 URL

http://wormbase.org/species/expr_profile

=head1 METHODS/URIs

=cut

#######################################
#
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

=head3 pcr_data

This method will return a data structure with pcr_data on the expr_profile.

=over

=item PERL API

 $data = $model->pcr_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expr_profile id (eg R10E9.2)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/pcr_data

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub pcr_data {

    my $self    = shift;
    my $profile = $self->object;
    my $dbgff   = $self->gff_dsn('c_elegans');
    my $db      = $self->ace_dsn();

    my $primer = $profile->PCR_product;
    my $seq    = $dbgff->segment($primer);
    $seq->absolute(1) if ($seq);

    my $chromosome = $seq->refseq if $seq;
    my ( $start, $stop ) = ( $seq->start, $seq->end ) if $seq;

    my $expr_map = $profile->Expr_map( -filled => 1 );
    my ( $x_coord, $y_coord, $mountain ) =
      ( $expr_map->X_coord, $expr_map->Y_coord, $expr_map->Mountain );
    my $radius = 4;
    my %data_pack;

    my $data_pack = {
        primer     => $primer,
        seq        => $seq,
        chromosome => $chromosome,
        start      => $start,
        stop       => $stop,
        x_coord    => $x_coord,
        y_coord    => $y_coord,
        mountain   => $mountain,
        radius     => $radius
    };
    return {
        'data'        => $data_pack,
        'description' => 'pcr data on the expression profile'
    };
}

=head3 profiles

This method will return a data structure with profiles for the expr_profile.

=over

=item PERL API

 $data = $model->profiles();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expr_profile id (eg R10E9.2)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/profiles

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub profiles {
    my $self    = shift;
    my $profile = $self->object;
    my @data_pack;
    my $dbgff = $self->gff_dsn('c_elegans');
    my $db    = $self->ace_dsn();
    
    if ( $profile->class eq 'Gene' ) {
        my $s;
        eval { $s = $dbgff->segment($profile); };
        my @p;
        eval {
            @p =
		map { $_->info }
	    $s->features('experimental_result_region:Expr_profile')
		if $s;
        };
        $profile = $p[0];
        undef $profile
	    unless @p;    # used as a flag that we fetched an appropriate object
        @p = map { $db->fetch( -class => 'Expr_profile', -name => $_->name ) } @p;
        foreach my $p (@p) {
            my $data_pack = $self->_pack_obj($p);
            push @data_pack, $data_pack;
        }
    }
    return {
        'data'        => \@data_pack,
        'description' => 'expression profiles for set of genes'
    };
}

=head3 pcr_product
    
This method will return a data structure with pcr_products generated from the expr_profile.
    
=over

=item PERL API

 $data = $model->pcr_product();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expr_profile id (eg R10E9.2)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/pcr_product

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub pcr_product {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->PCR_product;
    my $data_pack  = $self->_pack_obj($tag_object);
    return {
        'data'        => $data_pack,
        'description' => ''
    };
}

=head3 expr_map

This method will return a data structure with expr_map associated with the expr_profile.

=over

=item PERL API

 $data = $model->expr_map();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expr_profile id (eg R10E9.2)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/expr_map

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expr_map {
    my $self       = shift;
    my $object     = $self->object;
    my $tag_object = $object->Expr_map;
    my $data_pack  = $self->_pack_obj($tag_object);
    return {
        'data'        => $data_pack,
        'description' => ''
    };
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

=head3 rnai

This method will return a data structure with rnais associated with the expr_profile.

=over

=item PERL API

 $data = $model->rnai();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An Expr_profile id (eg R10E9.2)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/rnai

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rnai {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->RNAi_result;
    my @data_pack   = map { $_ = $self->_pack_obj($_) } @tag_objects
      if @tag_objects;
    return {
        'data'        => \@data_pack,
        'description' => ''
    };
}

1;
