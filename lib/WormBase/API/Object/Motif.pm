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
		'data' => $data_pack,
		'description' => 'title for the motif'
	};
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

=head3 database

This method will return a data structure with database information for the requested motif.

=head4 PERL API

 $data = $model->database();

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/database

=head5 Response example

<div class="response-example"></div>

=cut 

sub database  {
	my $self = shift;
    my $object = $self->object;
	my ($database,$accession1,$accession2) = $object->Database('@')->row if $object->Database;
	my $accession = $accession2 || $accession1;	
	my $data_pack = {'database' 	=> "$database",
					'accession' => "$accession"
	             };
	
	return {
		'data'=> $data_pack,
		'description' => 'database which contained info on motif, along with its accession number'
	};     
}


=head3 go

This method will return a data structure with go annotations for the requested motif.

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

curl -H content-type:application/json http://api.wormbase.org/rest/field/motif/(AAATG)n/go

=head5 Response example

<div class="response-example"></div>

=cut 

sub homologies {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	
    foreach (qw/DNA_homol Pep_homol Motif_homol Homol_homol/) {
		if (my @homol = $object->$_) {
			foreach (@homol) {
				my $id;
				my $label;
				my $class;
				my $homolog_data;
				if ($_ =~ /.*RepeatMasker/g) {
					$_ =~ /(.*):.*/;
					my $clone = $1;
					
					$homolog_data = {	
						'id'	=> "$clone",
						'label'	=> "$clone",
						'class' => 'Clone'
					};
				} else {
					$homolog_data = $self->_pack_obj($_);	
				}
				push @data_pack, $homolog_data;
			}
		}       
	}
	return {
		'data'=> \@data_pack,
		'description' => 'homology data for this motif'
	};
	
}

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

sub go  {
	my $self = shift;
    my $motif = $self->object;
	my @go_terms;
	my @data_pack;
	
	@go_terms = $motif->GO_term;
	
	foreach my $go_term (@go_terms) {	
		my $definition = $go_term->Definition;
		my ($evidence) = $go_term->right;
		my $term = $go_term->GO_term;
		my $go_data;
		my $term_data = $self->pack_obj($term);

		$go_data = {		
			'term_data' => $term_data,	
			'definition'=>$definition,
			'evidence'=>$evidence
			};	
		push @data_pack,$go_data;		
	}
	return {
		'data'=> \@data_pack,
		'description' => 'go terms to with which motif is annotated'
	};	
 }

1;

