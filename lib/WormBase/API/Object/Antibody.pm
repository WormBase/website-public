package WormBase::API::Object::Antibody;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Antibody

=head1 SYNPOSIS

Model for the Ace ?Antibody class.

=head1 URL

http://wormbase.org/species/antibody

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

# sub other_names { }
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>

############
## SUMMARY
############

=head3 summary

This method will return a data structure with a summary re: this antibody.

=head4 PERL API

 $data = $model->summary();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/summary

=head5 Response example

<div class="response-example"></div>

=cut 

sub summary {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Summary;
	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the position matrix'
				};
	return $data;
}

# sub laboratory { }
# Supplied by Role; POD will automatically be inserted here.
# << include laboratory >>





=head3 antigen

<headvar>This method will return a data structure re: the antigen for this antibody

=head4 PERL API

 $data = $model->antigen();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/WBPmat00000001/antigen

=head5 Response example

<div class="response-example"></div>

=cut

sub antigen {
	my $self = shift;
    my $antibody = $self->object;
	my ($type,$comment) = $antibody->Antigen->row if $antibody->Antigen;
  	$type =~ s/_/ /g;
  	my $data_pack = $type . (($comment) ? " ($comment)" : '') if ($type);
	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the position matrix'
	};
	return $data;
}

=head3 animal

<headvar>This method will return a data structure re: the animal source of this antibody .

=head4 PERL API

 $data = $model->animal();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/animal

=head5 Response example

<div class="response-example"></div>

=cut

sub animal {

	my $self = shift;
    my $object = $self->object;

	### data pull ####

	my $data_pack = $object->Animal;
	
	### package ######
	
	my $data = {
				'data'=> $data_pack,
				'description' => 'the animal source of this antibody'
				};
	return $data;
}

=head3 clonality

<headvar>This method will return a data structure re: clonality of this antibody .

=head4 PERL API

 $data = $model->clonality();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/clonality

=head5 Response example

<div class="response-example"></div>

=cut

sub clonality {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Clonality;
	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the clonality of the antibody'
				};
	return $data;
}

# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>









=head3 target

<headvar>This method will return a data structure re: gene target for this antibody.

=head4 PERL API

 $data = $model->target();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/target

=head5 Response example

<div class="response-example"></div>

=cut

sub target {
	my $self = shift;
    my $object = $self->object;
	my $gene =	$object->Gene;
	my $data_pack = $self->_pack_obj($gene);
	my $data = {
		'data'=> $data_pack,
		'description' => 'target of the antibody'
		};
	return $data;
}


######################
## EXPRESSION PATTERN
######################

=head3 expression_pattern

<headvar>This method will return a data structure re: expression_pattern test by this antibody .

=head4 PERL API

 $data = $model->expression_pattern();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Antibody ID [cgc2018]:mec-7

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/expression_pattern

=head5 Response example

<div class="response-example"></div>

=cut

sub expression_pattern {
	my $self = shift;
    my $antibody = $self->object;
	my @data_pack;
	my @expr_patterns = $antibody->Expr_pattern;

	foreach my $expr_pattern (@expr_patterns) {
		my $date = $expr_pattern->Date || '';
		my $author = $expr_pattern->Author || ''; ## data for link to be added(?)
		my $pattern = $expr_pattern->Pattern || $expr_pattern->Subcellular_localization || $expr_pattern->Remark;
		my $ep_info = _pack_obj($expr_pattern);
		
		push @data_pack, {
				'ep_info' => $ep_info,					
				'date' => $date,
				'author' => $author,
				'pattern' => $pattern
			};
	}
	my $data = {
				'data'=> \@data_pack,
				'description' => 'expression_pattern antibody is used in'
				};
	return $data;
}


#####
## REFERENCES
####

#sub references {
#
#	my $self = shift;
#    my $antibody = $self->object;
#	my %data;
#	my $desc = 'notes';
#	my %data_pack;
#
#	#### data pull and packaging
#	
#	my @references = $antibody->Reference;
#	
#	foreach my $reference (@references) {
#	
#		$data_pack{$reference} = {
#								'ace_id' => $reference,
#								'class' => 'Reference' 
#								### add details from format_references
#								};
#	}
#	
#	####
#
#	$data{'data'} = \%data_pack;
#	$data{'description'} = $desc;
#	return \%data;
#}

#
#sub print_bibliography {
#
#  StartSection('References');
#  
#  format_references(-references=>\@references,-format=>'long',-pubmed_link=>'image',-curator=>url_param('curator'));
#  EndSection;
#}


#####
## INTERNAL
#####

1;
