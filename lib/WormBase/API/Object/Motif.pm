package WormBase::API::Object::Motif;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Motif

=head1 SYNPOSIS

Model for the Ace ?Motif class.

=head1 URL

http://wormbase.org/resources/motif

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


=head3 title

This method will return a data structure of the 
title for the requested motif.

=over

=item PERL API

 $data = $model->title();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Motif ID ((AAATG)n)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/title

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub title {
    my $self 	= shift;
    my $object 	= $self->object;
    my $title   = $object->Title;
    return {
	data        => "$title" || undef,
	description => 'title for the motif'
    };
}


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>


#######################################
#
# The Gene Ontology Widget
#
#######################################

=head2 Gene Ontology

=cut

=head3 gene_ontology

This method will return a data structure with 
gene ontology (GO) annotations for the requested motif.

=over

=item PERL API

 $data = $model->gene_ontology();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Motif ID ((AAATG)n)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/gene_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut 
    
sub gene_ontology  {
    my $self     = shift;
    my $motif    = $self->object;

    my @data;
    foreach my $go_term ($motif->GO_term) {
	my $definition = $go_term->Definition;
	my ($evidence) = $go_term->right;
	my $term       = $go_term->GO_term;
	my $go_data;
	my $term_data  = $self->pack_obj($term);
	
	push @data,{		
	    go_term  => $term_data,	
	    definition => $definition,
	    evidence   => $evidence
	};	
    }
    return { data        => @data ? \@data : undef,
	     description => 'go terms to with which motif is annotated',
    };
}


#######################################
#
# The Homology widget
#
#######################################

=head2 Homology

=cut

=head3 homologies

This method will return a data structure with homology information on the requested motif.

=over

=item PERL API

 $data = $model->homologies();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a Motif ID ((AAATG)n)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/homologies

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub homologies {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    
    my $types = {
    	DNA_homol 	=> 'DNA',
    	Pep_homol 	=> 'Peptide',
    	Motif_homol => 'Motif',
    	Homol_homol => 'Other',
    };
    
    foreach my $homology_type (qw/DNA_homol Pep_homol Motif_homol Homol_homol/) {
	if (my @homol = $object->$homology_type) {
	    foreach my $homologous_object (@homol) {	
		my $homolog = $self->_pack_obj($homologous_object);
		push @data,	{
		    homolog => $homolog,
		    type => "$types->{$homology_type}",	    	
		}	
	    }
	}
    }
    
    return { data => @data ? \@data : undef,
	     description  => 'homology data for this motif'
    };
}


#######################################
#
# The External Links widget
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


__PACKAGE__->meta->make_immutable;

1;


