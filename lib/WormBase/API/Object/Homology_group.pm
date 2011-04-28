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

http://wormbase.org/species/homology_group

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
    my $self      = shift;
    my $object    = $self->object;
    my $data_pack = $object->Title;
    return {
        'data'        => $data_pack ? "$data_pack" : undef,
        'description' => 'title for this homology_group'
    };
}

=head3 group_type

This method will return a data structure with the group_type of the homology_group.

=over

=item PERL API

 $data = $model->group_type();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/group_type

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub group_type {
    my $self           = shift;
    my $object         = $self->object;
    my $homology_group = $object->Homology_group;
    my $homology_code;

    if ($homology_group =~ /COG/ ) {
        $homology_code = $object->COG_code;
    }
    my $data_pack = {
        'homology_group' => "$homology_group",
        'cog_code'       => $homology_code
    };
    
    my @contents = values %$data_pack;
    return {
        'data'        => @contents ? $data_pack : undef,
        'description' => 'type of homology_group'
    };
}

=head3 go_term

This method will return a data structure with the go_terms associated with the homology_group.

=over

=item PERL API

 $data = $model->go_term();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/go_term

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub go_term {
    my $self      = shift;
    my $object    = $self->object;
    my @tag_objects  = $object->GO_term;
    my @data_pack;
    foreach my $tag_object (@tag_objects) {
    	my $tag_data = $self->_pack_obj($tag_object);
    	my $definition = $tag_object->Definition;
    	push @data_pack, {
    		go_term => $tag_data,
    		definition => "$definition",
    	}
    } 	

    return {
        'data' => @data_pack ? \@data_pack : undef,
        'description' => 'go terms related to this homology group'
    };
}

=head3 protein

This method will return a data structure with the proteins in the homology_group.

=over

=item PERL API

 $data = $model->protein();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/homology_group/InP_Cae_000935/protein

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub protein {
    my $self        = shift;
    my $object      = $self->object;
    my @tag_objects = $object->Protein;
    my @data_pack;
    foreach my $tag_object (@tag_objects) {
    	my $tag_data = $self->_pack_obj($tag_object);
    	my $species = $self->_pack_obj($tag_object->Species) if $tag_object->Species;
    	my $description = $tag_object->Description;
    	push @data_pack, {
    		protein => $tag_data,
    		species => $species,
    		description =>"$description",
    	}
    }
    return {
        'data' => @data_pack ? \@data_pack : undef,
        'description' => 'proteins related to this homology_group'
    };
}

__PACKAGE__->meta->make_immutable;

1;

