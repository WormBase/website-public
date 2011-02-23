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

############
## SUMMARY
############

sub summary {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Summary;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub source {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	foreach my $location (sort {$a cmp $b } $antibody->Location) {
	
		my $rep;
		my $rep_name;
		
		if ($location) {
			
			$rep = eval { $location->Representative->Standard_name};
			$rep_name = eval { $rep->Standard_name};
		}
		
		#my $add      = $location->Mail;
		
		push @data_pack, {
		
						'laboratory' => {
						
							'id' => "$location",
 							'label' => "$location",
 							'class' => 'Laboratory'
							},
					
						'representative' => {
						
							'id' => "$rep",
 							'label' => "$rep_name",
 							'class' => 'Person'
							}
						};
	}
	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub antigen {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	my ($type,$comment) = eval { $antibody->Antigen->row };
  	$type =~ s/_/ /g;
  	$data_pack = $type . (($comment) ? " ($comment)" : '') if ($type);
	
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}
	
sub details {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $summary = $antibody->Summary;
	my $other_name = $antibody->Other_name;
	my $gene = $antibody->Gene;
	my $clonality = $antibody->Clonality;
	my $remark = $antibody->Remark;
	
	%data_pack = (
					'ace_id' => $antibody,
					'class' => 'Antibody',
					'summary' => $summary,
					'other_name' => $other_name,
					'gene' => $gene, ## TODO: fill hash with details!
					'clonality' => $clonality,
					'remark' => $remark
				);
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub animal {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $animal = $antibody->Animal;
	$data_pack = $animal;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub clonality {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Clonality;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub remark {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Remark;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub other_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Other_name;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub target {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $gene =	$object->Gene;
	my $gene_name = $gene->Public_name;
	
	$data_pack = {
	
		'id' => "$gene",
		'label' => "$gene_name",
		'Class' => 'Gene'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}



####
## EXPRESSION PATTERN
####

sub expression_pattern {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @expr_patterns = $antibody->Expr_pattern;

	foreach my $expr_pattern (@expr_patterns) {
	
		my $date = $expr_pattern->Date || '';
		my $author = $expr_pattern->Author || ''; ## data for link to be added(?)
		my $pattern = $expr_pattern->Pattern || $expr_pattern->Subcellular_localization || $expr_pattern->Remark;
	
		$data_pack{$expr_pattern} = {
									'ep_info' => {
										'id' => "$expr_pattern",
										'class' => 'Expr_pattern',
										'label' =>"$expr_pattern"
										},
 									
									'date' => $date,
									'author' => $author,
									'pattern' => $pattern
									};
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


#####
## REFERENCES
####

sub references {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @references = $antibody->Reference;
	
	foreach my $reference (@references) {
	
		$data_pack{$reference} = {
								'ace_id' => $reference,
								'class' => 'Reference' 
								### add details from format_references
								};
	}
	
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

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
