package WormBase::API::Object::GO_Term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::GO_term

=head1 SYNPOSIS

Model for the Ace ?GO_Term class.

=head1 URL

http://wormbase.org/species/go_term

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

=head2 term

<headvar>This method will return a data structure with the term for this GO_Term.

=head3 PERL API

 $data = $model->term();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/term

=head4 Response example

<div class="response-example"></div>

=cut

sub term {
	my $self = shift;
    my $object = $self->object;
	my $tag_object = $object->Term;
	my $data_pack = $self->_pack_obj($object, $tag_object);
	return {
		'data'=> $data_pack,
		'description' => 'GO term'
		};
}

=head2 definition

This method will return a data structure definition for this GO_Term.

=head3 PERL API

 $data = $model->definition();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/definition
=head4 Response example

<div class="response-example"></div>

=cut

sub definition {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Definition; 
	return {
		'data'=> $data_pack,
		'description' => 'term definition'
	};
}

=head2 type

This method will return a data structure with the type of this GO_Term.

=head3 PERL API

 $data = $model->type();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/type

=head4 Response example

<div class="response-example"></div>

=cut

sub type {	
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Type;
	$data_pack =~ s/\_/\ /;
	return {
		'data'=> $data_pack,
		'description' => 'type for this term'
	};
}

=head2 genes

This method will return a data structure with genes annotated to this GO_Term.

=head3 PERL API

 $data = $model->genes();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/genes

=head4 Response example

<div class="response-example"></div>

=cut

sub genes {
  	my $self = shift;
    my $object = $self->object;
    my @data_pack;
	my @genes = eval{$object->Genes};
	
	if (@genes) {
		foreach my $gene (@genes) {
		
			my ($evidence_code, $evidence_details) = $self->_get_GO_evidence($object,$gene);
			my $gene_info = $self->_pack_object($gene);
			my $gene_data = {
				'gene' => $gene_info,
				'evidence_code' => $evidence_code,
				'evidence_details' => $evidence_details
				};
			push @data_pack, $gene_data;				
		}
	}
	return {
		'data'=> \@data_pack,
		'description' => 'genes annotated with this term'
	};  
}

=head2 cds

This method will return a data structure cds annotated with this GO_Term.

=head3 PERL API

 $data = $model->cds();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/cds

=head4 Response example

<div class="response-example"></div>

=cut

sub cds {
  	my $self = shift;
    my $object = $self->object;
    my @data_pack;
	my @genes = eval{$object->CDS};
	
	if (@genes) {
		foreach my $gene (@genes) {
		
			my ($evidence_code, $evidence_details) = $self->_get_GO_evidence($object,$gene);
			my $gene_info = $self->_pack_object($gene);
			my $gene_data = {
				'gene' => $gene_info,
				'evidence_code' => $evidence_code,
				'evidence_details' => $evidence_details
				};
			push @data_pack, $gene_data;				
		}
	}	
	return {
		'data'=> \@data_pack,
		'description' => 'CDS annotated with this term'
	};  
}

=head2 genes_n_cds

This method will return a data structure with genes and cds annotated with this GO_Term.

=head3 PERL API

 $data = $model->genes_n_cds();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/genes_n_cds

=head4 Response example

<div class="response-example"></div>

=cut

sub genes_n_cds {
  	my $self = shift;
  	my $term = $self->object;
  	my %mol;
  	my %cgc;
  	my @data_pack;
	my $DB = $self->ace_dsn();
	my @objs;
	
  	push (@objs,$term->Gene,$term->CDS) unless @objs;

  	foreach my $obj (@objs) {
    	my ($gene,$key);
	  	if ($obj->class eq 'CDS') {
	    	$gene = $obj->Gene;
	      	$key  = $obj;
	  	} else {
	      	$gene = $obj;
	      	$key  = $gene;
	  	}
      	next unless $gene;
      	next if (defined $cgc{$key} || defined $mol{$key});

     	if ($gene->CGC_name) {
	  		$cgc{$key} = [$obj,$gene,$gene->CGC_name];
      	} else {
	  		$mol{$key} = [$obj,$gene,$gene->Sequence_name];
      	}
  	}

  	my @sorted = keys %cgc;
  	push @sorted, keys %mol;

  	my @genes;
  
  	foreach (@sorted) {
    	my ($obj,$gene,$junk) = eval { @{$cgc{$_}} };
      	($obj,$gene,$junk) = eval { @{$mol{$_}} } unless $gene;
      # UGH!  Return a list of CDSs instead.
	  	push @genes,$obj;
	  	push @genes,$DB->fetch(Gene=>$gene);
	}
	
	foreach my $gene (@genes) {
	
			my $cgc_name = $gene->CGC_name;
			my $seq = $gene->Sequence_name;
			my $desc = $gene->Concise_description || $gene->Provisional_description;		
			my ($evidence_code, $evidence_details) = $self->_get_GO_evidence($term,$gene);
			my $gene_info = $self->_pack_obj($gene);
			
			my $gene_data = {
								'gene_info' => $gene_info,
								'cgc_name' => $cgc_name,
								'seq' => $seq,
								'description' => $desc,
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
							};
			push @data_pack, $gene_data;		
	}
	return {
		'data'=> \@data_pack,
		'description' => 'genes and cds annoted with this term'
	};
}

=head2 phenotype

This method will return a data structure phenotypes annotated with this GO_Term.

=head3 PERL API

 $data = $model->phenotype();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/phenotype

=head4 Response example

<div class="response-example"></div>

=cut

sub phenotype {
  	my $self = shift;
  	my $term = $self->object;
  	my @data_pack;
	my @phenotypes= $term->Phenotype;
	foreach my $phenotype (@phenotypes) {
		my $phenotype_desc = $phenotype->Description;
		my ($evidence_code, $evidence_details) = $self->_get_GO_evidence($term,$phenotype);
		my $phenotype_info = $self->_pack_obj($phenotype);

		my $pheno_data = {
							'phenotype_info' => $phenotype_info,
							'description' => $phenotype_desc,
							'evidence_code' => $evidence_code,
							'evidence_details' => $evidence_details									
						 };
		push @data_pack, $pheno_data;			 
	}
	return {
		'data'=> \@data_pack,
		'description' => 'phenotypes annotated with this term'
	};
}

=head2 motif

This method will return a data structure motifs annotated with this GO_Term.

=head3 PERL API

 $data = $model->motif();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/motif

=head4 Response example

<div class="response-example"></div>

=cut

sub motif {
	my $self = shift;
  	my $term = $self->object;
  	my @data_pack;

	my @motifs;
	eval {@motifs = $term->Motif;};
	
	foreach my $motif (@motifs) {
		my $motif_desc = $motif->Description;
		my ($evidence_code, $evidence_details) = get_GO_evidence($term,$motif);
		my $motif_info = $self->_pack_obj($motif);
		my $motif_data = {
			'motif_info' => $motif_info,
			'description' => $motif_desc,
			'evidence_code' => $evidence_code,
			'evidence_details' => $evidence_details
		};						
		push @data_pack, $motif_data;
	}
	return {
		'data'=> \@data_pack,
		'description' => 'motifs annotated with this term'
	};	
}

=head2 get_tag_data

This method will return a data structure with the tag_object annoted with this GO_Term.

=head3 PERL API

 $data = $model->get_tag_data();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a GO_Term ID GO:0016311

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/GO:0016311/get_tag_data

=head4 Response example

<div class="response-example"></div>

=cut

sub get_tag_data {
	my $self = shift;
  	my $tag = shift;
  	my $term = $self->object;
  	my @data_pack;
	my @motifs;
	my @tag_data = $term->$tag;
	
	foreach my $tag_datum (@tag_data) {
		my $tag_datum_desc = $tag_datum->Description;
		my ($evidence_code, $evidence_details) = get_evidence($term,$tag_datum);
		
		push @data_pack, {
			'term' =>"$tag_datum",
			'description' => "$tag_datum_desc",
			'class' => $tag,
			'evidence_code' => $evidence_code,
			'evidence_details' => $evidence_details
		};
	}
	return {
		'data'=> \@data_pack,
		'description' => 'Objects annotated with this term'
	};
}
  
sub _get_GO_evidence {

	my ($term,$gene) = @_;
	my @go_terms;
	eval{@go_terms = $gene->GO_Term;};
	my $evidence_code;
	my $evidence_detail;
	
	
	foreach my $go_term (@go_terms) {
	
		if ($go_term eq $term) {
			eval{$evidence_code = $go_term->right;};
			eval{$go_term->right->right->right;};$evidence_detail = 
			last;
		}
	}
	return ($evidence_code, $evidence_detail);
}

1;



