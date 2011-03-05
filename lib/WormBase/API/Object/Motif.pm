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

http://wormbase.org/species/motif

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


=head3 title

This method will return a data structure of the 
title for the requested motif.

=head4 PERL API

 $data = $model->title();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Motif ID ((AAATG)n)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/title

=head5 Response example

<div class="response-example"></div>

=cut 

sub title {
    my $self 	= shift;
    my $object 	= $self->object;
    my $data_pack = $object->Title;
    return {
	data        => "$title",
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

This method will return a data structure with gene ontology (GO) annotations for the requested motif.

=head4 PERL API

 $data = $model->go();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Motif ID ((AAATG)n)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/gene_ontology

=head5 Response example

<div class="response-example"></div>

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
	    term_data  => $term_data,	
	    definition => $definition,
	    evidence   => $evidence
	};	
    }
    return { data        => \@data,
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

=head4 PERL API

 $data = $model->homologies();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Motif ID ((AAATG)n)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/homologies

=head5 Response example

<div class="response-example"></div>

=cut 

sub homologies {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    
    foreach (qw/DNA_homol Pep_homol Motif_homol Homol_homol/) {
	if (my @homol = $object->$_) {
	    foreach (@homol) {		
		if ($_ =~ /.*RepeatMasker/g) {
		    $_ =~ /(.*):.*/;
		    my $clone = $1;
		    
		    push @data, {
			'id'	=> "$clone",
			'label'	=> "$clone",
			'class' => 'Clone'
		    };
		} else {
		    push @data,$self->_pack_obj($_);	
		}
	    }
	}
    }
    
    return { data         => \@data,
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


1;

