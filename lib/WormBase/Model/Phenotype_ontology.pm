package WormBase::Model::Phenotype_ontology;

use strict;
use warnings;
use base 'WormBase::Model';

=head1 NAME

WormBase::Model::Phenotype_ontology - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Norie  de la Cruz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

I didn't model the search function yet; coordinate with TH as to plans re: searches

=cut

=pod

NB:

=cut


###################################
### template
#####################################

=pod

NB:
Takes ($self,<object>) and returns a <data type> containing.

=cut

# sub <sub_name> {
#     my ($self,$object) = @_;
#     my $data = $object-><tag>;
#     return <type>data;  ## returns text
# }


#### end template #####

#####################################

#####################################

=pod

NB:
Takes ($self,<object>) and returns a hash reference of arrays. Keys: generalisation, specialisation

=cut

sub relations {
    my ($self,$object) = @_;
    my %data;
 	my @generalisations  = $object->Generalisation_of;
	my @specialisations = $object->Specialisation_of;
	$data{'generalisations'} = \@generalisations;
	$data{'specialisations'} = \@specialisations;
    return \%data;  ## returns hash of arrays
}


#####################################

=pod

NB:
Takes ($self,<object>) and returns a <data type> containing.

=cut

sub description {
    my ($self,$object) = @_;
    my $data = $object->Description;
    return $data;  ## returns text
}

#####################################
=pod

NB:
Takes ($self,<object>) and returns text

=cut

sub assay {
    my ($self,$object) = @_;
    my $data = $object->Assay;
    return $data;  ## returns text
}

#####################################

=pod

NB: There is a complex link to AO terms via anatomy function;  This model returns all the steps as a hash reference
Takes ($self,<object>) and returns a hash reference. Keys : 'anatomy_fn' 'anatomy_fn_name' 'anatomy_term' 'anatomy_term_id' 'anatomy_term_name'

=cut

sub ao_associations {
    my ($self,$phenotype) = @_;
	my $anatomy_fn;
	my $anatomy_fn_name;
	my $anatomy_term;
	my $anatomy_term_id;
	my $anatomy_term_name;

	eval{
		$anatomy_fn = $phenotype->Anatomy_function;
		$anatomy_fn_name = $anatomy_fn->Involved;
		$anatomy_term = $anatomy_fn_name->Term;
		$anatomy_term_id = $anatomy_term->Name_for_anatomy_term;
		$anatomy_term_name = $anatomy_term_id->Term;
	};
    my %data = ('anatomy_fn' => $anatomy_fn,
				'anatomy_fn_name' => $anatomy_fn_name,
				'anatomy_term' => $anatomy_term,
				'anatomy_term_id' => $anatomy_term_id,
				'anatomy_term_name' => $anatomy_term_name
				);

    return \%data;  ## returns hash reference
}

#####################################

=pod

NB:
Takes ($self,<object>) and returns a <data type> containing.

=cut

sub go_term {
    my ($self,$object) = @_;
    my @data = $object->GO_Term;
    return \@data;  ## returns objects
}

#####################################

=pod

NB: Remarks
Takes ($self,<object>) and returns a text.

=cut

sub remark {
    my ($self,$object) = @_;
    my $data = $object->Remark;
    return $data;  ## returns text
}

#####################################

=pod

NB:for set up purposes
Takes ($self,<object>) and returns a <data type> containing.

=cut

sub primary_name {
    my ($self,$object) = @_;
    my $data = $object->Primary_name;
    return $data;  ## returns text
}
#####################################

=pod

NB:synonyms
Takes ($self,<object>) and returns text containing synonyms.

=cut

sub synonym {
	my ($self,$object) = @_;
	my $data = $object->Synonym;
	return $data;  ## returns text
}

#################################################

=pod

NB: This stuff might be abstracted for other ontologies; the question is are the other associations in the other ontologies sufficiently straightforward?

Takes ($self,Phenotype) and returns a hash of arrays reference containing associated  objects; Keys:RNAi Transgene Interaction Variation
=cut

sub po_associations {
	my ($self,$po_term) = @_;
	my @associations = qw(RNAi Transgene Interaction Variation);
	my %data;			
	foreach my $association (@associations){
		if($po_term->$association){
			my @associated_objects = $po_term->$association;
			$data{$association} = \@associated_objects;
		}
	}
	return \%data;
}


1;
