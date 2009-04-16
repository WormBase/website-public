package WormBase::Model::Gene_ontology;

use strict;
use warnings;
use base 'WormBase::Model';

=head1 NAME

WormBase::Model::Gene_ontology - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Norie  de la Cruz

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

###################################
### template
#####################################

=pod

NB:
Takes ($self,<object>) and returns a <data type> containing.

=cut

# sub <sub_name> {
#     my ($self,$c,$go_term) = @_;
#     my $data = $go_term-><tag>;
#     return <type>data;  ## returns text
# }


#### end template #####

#####################################

=pod

NB: details of term, abstract for all ontologies(?)
Takes ($self,GO_Term) object and returns details of the term in a hash reference with the Methods (Term Definition Type) as keys.
=cut

sub go_details {
    my ($self,$go_term) = @_;
	my @details = qw(Term Definition Type);
    my %data;
	
	foreach my $detail (@details){
		my $go_detail = $go_term->$detail if ($go_term->$detail);
		$data{$detail} = $go_detail;
	}
	
     return \%data;  ## returns hash reference
}


#####################################

=pod

NB: This stuff might be abstracted for other ontologies; the question is are the other associations in the other ontologies sufficiently straightforward?

Takes ($self,GO_Term) and returns a hash of arrays reference containing associated genes and CDSs; Keys:Gene,CDS.

Caution:  SLOWWWWWWW!

=cut


sub go_genes_n_cdss {
	my ($self,$go_term) = @_;
	my @genes = $go_term->Gene;
	my @cdss = $go_term->CDS;
	my @unique_cdss;
	my %data;
	my @cdss_with_genes;
	
	foreach my $cds (@cdss){
		if ($cds->Gene){
			my $cds_gene = $cds->Gene;
			my $in_array = grep {$_ eq $cds_gene} @genes;
			if($in_array){
				next;
			}
			else{
				push @genes,$cds_gene;	
			}		
		}
		else {
					push @unique_cdss, $cds;
				}
	}	
	%data = ('Genes' => \@genes,
			'CDS' => \@unique_cdss);
	return \%data;
}

#################################################

=pod

NB: This stuff might be abstracted for other ontologies; the question is are the other associations in the other ontologies sufficiently straightforward?

Takes ($self,GO_Term) and returns a hash of arrays reference containing associated  objects; Keys:Sequence Transcript Pseudogene Motif Homology_group Expr_pattern Cell Reference

=cut

sub go_associations {
	my ($self,$go_term) = @_;
	my @associations = qw(Sequence Transcript Pseudogene Motif Homology_group Expr_pattern Cell Reference);
	my %data;			
	foreach my $association (@associations){
		if($go_term->$association){
			my @associated_objects = $go_term->$association;
			$data{$association} = \@associated_objects;
		}
	}
	return \%data;
}

######################################################

=pod

Takes ($self,GO_Term) and returns a hash of arrays reference containing associated  terms from other ontologies; Keys:Anatomy_term Phenotype

=cut

sub cross_ontology {
	my ($self,$go_term) = @_;
	my @other_ontologies = qw(Anatomy_term Phenotype);
	my %data;
	foreach my $other_ontology (@other_ontologies){
		if($go_term->$other_ontology){
			my @other_ontology_terms = $go_term->$other_ontology; 
			$data{$other_ontology} = \@other_ontology_terms;
		}
	}
	return \%data;
}


1;
