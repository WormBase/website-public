package WormBase::API::Object::Gene_cluster;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Gene_cluster

=head1 SYNPOSIS

Model for the Ace ?Gene_cluster class.

=head1 URL

http://wormbase.org/species/*/gene_cluster

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



############################
#
# The Overview Widget
#
############################

=head2 Overview

=cut

# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>
 
=head3 title

This method will return a data structure with title for the gene_cluster.

=over

=item PERL API

 $data = $model->title();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene_cluster id (eg HIS3_cluster)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_cluster/HIS3_cluster/title

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub title {
    my $self      = shift;
    my $object    = $self->object;
    my $title     = $object->Title;
    return { data        => "$title",
	     description => 'title of the gene cluster'
    };
}


# sub description { }
# Supplied by Role; POD will automatically be inserted here.
# << include description >>


=head3 contains_genes

This method will return a data structure with genes in the gene_cluster.

=over

=item PERL API

 $data = $model->contains_genes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A Gene_cluster id (eg HIS3_cluster)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_cluster/HIS3_cluster/contains_genes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub contains_genes {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Contains_gene) {
	push @data,$self->_pack_obj($_);
    }
    return { data => \@data,
	     description => 'genes that are found in this gene cluster' };
}

__PACKAGE__->meta->make_immutable;

1;
