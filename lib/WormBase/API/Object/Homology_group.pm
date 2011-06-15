package WormBase::API::Object::Homology_group;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Homology_group

=head1 SYNPOSIS

Model for the Ace ?Homology_group class.

=head1 URL

http://wormbase.org/species/*/homology_group

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

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 title

This method will return a data structure with the title for the homology_group.

=over

=item PERL API

 $data = $model->title();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Homology_group id (eg InP_Cae_000935)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/title

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub title {
    my $self   = shift;
    my $object = $self->object;
    my $title  = $object->Title;
    return {data        => "$title" || undef,
	    description => 'title for this homology group'
    };
}

=head3 type

This method will return a data structure with the type of the homology_group.

=over

=item PERL API

 $data = $model->type();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Homology_group id (eg InP_Cae_000935)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/type

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub type {
    my $self           = shift;
    my $object         = $self->object;
    my $homology_group = $object->Homology_group;
    my $homology_code = $homology_group =~ /COG/ ? $object->COG_code : undef;
    return {data        => { homology_group => "$homology_group",
			     cog_code       => "$homology_code" },
	    description => 'type of homology group' };
}

=head3 gene_ontology_terms

This method will return a data structure containing 
the gene ontology terms associated with the homology group.

=over

=item PERL API

 $data = $model->gene_ontology_terms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Homology_group id (eg InP_Cae_000935)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/gene_ontology_terms

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gene_ontology_terms {
    my $self      = shift;
    my $object    = $self->object;
    my @data;
    foreach  ($object->GO_term) {
    	my $definition = $_->Definition;
    	push @data, {
	    go_term   => $self->_pack_obj($_),
	    definition => "$definition",
    	}
    } 	

    return { data => @data ? \@data : undef,
	     description => 'gene ontology terms associated to this homology group' };
}

=head3 proteins

This method will return a data structure containing
the proteins listed in the homology_group.

=over

=item PERL API

 $data = $model->proteins();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Homology_group id (eg InP_Cae_000935)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/proteins

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub proteins {
    my $self        = shift;
    my $object      = $self->object;
    my @data;
    foreach ($object->Protein) {
    	my $species = $self->_pack_obj($_->Species) if $_->Species;
    	my $description = $_->Description;
    	push @data, {
	    protein => $self->_pack_obj($_),
	    species => $species,
	    description => "$description",
    	}
    }
    return { data        => @data ? \@data : undef,
	     description => 'proteins related to this homology_group'
    };
}

#######################################
#
# The External Links widget
#   template: shared/widgets/xrefs.tt2
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


__PACKAGE__->meta->make_immutable;

1;

