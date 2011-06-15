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

http://wormbase.org/species/*/expr_profile

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
# The Overview widget
#
#######################################

=head2 Overview

=cut

# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

# sub method {}
# Supplied by Role; POD will automatically be inserted here.
# << include method >>

#######################################
#
# The Details widget
#
#######################################

=head2 Details

=cut

=head3 pcr_data

This method will return a data structure 
with PCR data on the expression profile.

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
    my $dbgff   = $self->gff_dsn;
    my $db      = $self->ace_dsn;

    my $primer = $profile->PCR_product;
    my $seq    = $dbgff->segment($primer);
    $seq->absolute(1) if ($seq);

    my $chromosome = $seq->refseq if $seq;
    my ( $start, $stop ) = ( $seq->start, $seq->end ) if $seq;

    my $expr_map = $profile->Expr_map( -filled => 1 );
    my ( $x_coord, $y_coord, $mountain ) =
      ( $expr_map->X_coord, $expr_map->Y_coord, $expr_map->Mountain );
    my $radius = 4;
    return { data => {
        primer     => "$primer",
        seq        => "$seq",
        chromosome => $chromosome,
        start      => $start,
        stop       => $stop,
        x_coord    => "$x_coord",
        y_coord    => "$y_coord",
        mountain   => "$mountain",
        radius     => $radius
	     },
	    description => 'pcr data of the expression profile'
    };
}

=head3 profiles

This method will return a data structure 
with specific profiles of the expression profile object.

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
    my @data;
    my $dbgff = $self->gff_dsn;
    my $db    = $self->ace_dsn;
    
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
            push @data, $self->_pack_obj($p);
        }
    }
    return { data        =>  @data ? \@data : undef,
	     description => 'expression profiles for set of genes',
    };
}

=head3 pcr_products
    
This method will return a data structure with 
PCR products generated from the expression profile.
    
=over

=item PERL API

 $data = $model->pcr_products();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/pcr_products

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub pcr_products {
    my $self       = shift;
    my $object     = $self->object;
    my @pcrs       = $object->PCR_product;
    my $data       = $self->_pack_objects(\@pcrs);
    return { data        => $data || undef,
	     description => 'pcr_products for the expression profile',
    };
}

=head3 expression_map
    
This method will return a data structure 
containing the expression map associated with the
requested expression profile.
    
=over

=item PERL API

 $data = $model->expression_map();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/expr_profile/R10E9.2/expression_map

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expression_map {
    my $self       = shift;
    my $object     = $self->object;
    my $data       = $self->_pack_obj($object->Expr_map);
    return { data        => $data || undef,
	     description => 'expression map data for expr_profile'
    };
}

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
    my @data;
    foreach my $rnai ($object->RNAi_result) {
    	my $strain   = $self->_pack_obj($rnai->Strain) if $rnai->Strain;
    	my $genotype = $rnai->Genotype;
    	
    	push @data, {
	    rnai      => $self->_pack_obj($rnai),
	    strain    => $strain,
	    genotype  => "$genotype",
    	};
    }
    return { data => @data ? \@data : undef,
	     description => 'RNAis associated with this expression profile', };
}



__PACKAGE__->meta->make_immutable;

1;

