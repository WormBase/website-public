package WormBase::API::Object::Antibody;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=head2 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head4 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

=pod 

=head1 NAME

## headvar WormBase::API::Object::Antibody

=head1 SYNPOSIS

Model for the Ace ?Antibody class.

=head1 URL

http://wormbase.org/species/antibody

=head1 TODO

=cut

############
## SUMMARY
############

=head2 summary

This method will return a data structure with a summary re: this antibody.

=head3 PERL API

 $data = $model->summary();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/summary

=head4 Response example

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

=head2 source

This method will return a data structure with info re: the This method will return a data structure with info re: the source of this antibody.

=head3 PERL API

 $data = $model->source();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/position_matrix/WBPmat00000001/source

=head4 Response example

<div class="response-example"></div>

=cut

sub source {
	my $self = shift;
    my $antibody = $self->object;
    my @data_pack;
 
	foreach my $location (sort {$a cmp $b } $antibody->Location) {
		my $rep;

		if ($location) {
			$rep = $location->Representative->Standard_name if $location->Representative;
		}

		my $lab_info = _pack_obj($location);		
		my $rep_info = _pack_obj($location);
		
		push @data_pack,{
			'laboratory' => $lab_info,
			'representative' => $rep_info
		};
	}	
	my $data = {
		'data'=> \@data_pack,
		'description' => 'laboratory source of the antibody'
	};
	return $data;
}

=head2 antigen

<headvar>This method will return a data structure re: the antigen for this antibody

=head3 PERL API

 $data = $model->antigen();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/WBPmat00000001/antigen

=head4 Response example

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

=head2 animal

<headvar>This method will return a data structure re: the animal source of this antibody .

=head3 PERL API

 $data = $model->animal();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/animal

=head4 Response example

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

=head2 clonality

<headvar>This method will return a data structure re: clonality of this antibody .

=head3 PERL API

 $data = $model->clonality();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/clonality

=head4 Response example

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

=head2 remark

This method will return a data structure with a remark re: this antibody.

=head3 PERL API

 $data = $model->remark();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/remark

=head4 Response example

<div class="response-example"></div>

=cut

sub remark {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Remark;

	my $data = {
				'data'=> $data_pack,
				'description' => 'remark re: this antibody'
				};
	return $data;
}

=head2 other_name

This method will return a data structure re: an other_name for this antibody .

=head3 PERL API

 $data = $model->other_name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/other_name

=head4 Response example

<div class="response-example"></div>

=cut

sub other_name {
	my $self = shift;
    my $object = $self->object;
    my $data_pack = $object->Other_name;
	my $data = {
				'data'=> $data_pack,
				'description' => 'the other_name for this antibody'
				};
	return $data;
}

=head2 target

<headvar>This method will return a data structure re: gene target for this antibody.

=head3 PERL API

 $data = $model->target();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/target

=head4 Response example

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

=head2 expression_pattern

<headvar>This method will return a data structure re: expression_pattern test by this antibody .

=head3 PERL API

 $data = $model->expression_pattern();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Antibody ID [cgc2018]:mec-7

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/antibody/[cgc2018]:mec-7/expression_pattern

=head4 Response example

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
