package WormBase::API::Object::Antibody;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'ao_template' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->pull;
    	return $ao_object;
  	}
);

#######

sub template {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

### mainly for text data; and single layer hash ###

sub template_simple {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Tag;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


########

#####
## SUMMARY
#####

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

sub antigen {

	my $self = shift;
    my $antibody = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my ($antigen_type,$comment) = eval { $antibody->Antigen->row };
	my $animal = $antibody->Animal;
	
	%data_pack = (
				'antigen_type' => $antigen_type,
				'comment' => $comment,
				'animal' => $animal
				);

	####

	$data{'data'} = \%data_pack;
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
		my $author = $expr_pattern->Author || '';
		my $ref    = $author ? "$author $date" : $expr_pattern;
		my $pattern = $expr_pattern->Pattern || $expr_pattern->Subcellular_localization || $expr_pattern->Remark;
	
		$data_pack{$expr_pattern} = {
									'ace_id' => $expr_pattern,
									'class' => 'Expr_pattern',
									'date' => $date,
									'author' => $author,
									'ref' => $ref,
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