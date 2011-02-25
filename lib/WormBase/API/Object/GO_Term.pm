package WormBase::API::Object::GO_Term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=head3 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head4 PERL API

 $data = $model->name();

=head4 REST API

=head5 Request Method

GET

=head5 Requires Authentication

No

=head5 Parameters

a Transgene ID (gmIs13)

=head5 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head5 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head5 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}

sub id {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	

	$data_pack = {
	
		'id' => "$object",
		'label' => "$object",
		'Class' => 'GO_Term'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub term {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Term;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


sub definition {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Definition;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;


}


sub type {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Type;
	$data_pack =~ s/\_/\ /;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

sub details {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

  #### data pull and packaging
	
	%data_pack = (
					'acedb_id' => $term,
					'term' => $term->Term,
					'definition' =>$term->Definition,
					'type' => $term->Type
					);
  ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}



sub genes {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my @data_pack; ## %data_pack

  #### data pull and packaging
	
	my @genes;
	eval{@genes = $object->Gene;};

	if (@genes) {
	
		foreach my $gene (@genes) {
		
			my ($evidence_code, $evidence_details) = get_GO_evidence($object,$gene);
			my $gene_name = $gene->Public_name;
			my $gene_data = {
								'gene' => {
									'ace_id' => "$gene",
									'common_name' => "$gene_name",
									'class' => 'Gene'
								},
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
								};
			push @data_pack, $gene_data;				
		}
	}
 
	
	#%data_pack = basic_package(\@genes);

  ####

  $data{'data'} = \@data_pack;
  $data{'description'} = $desc;
  return \%data;
}

sub cds {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my @data_pack;

  #### data pull and packaging
	
	my @genes = $object->CDS;
	
	foreach my $gene (@genes) {
	
			my ($evidence_code, $evidence_details) = get_GO_evidence($object,$gene);		
			my $cds_data = {
								'cds_info' => {
									'id' => "$gene",
									'label' => public_name($gene,'CDS'),
									'class' => 'CDS'
								},
							
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
							};
	}
	

  ####

  $data{'data'} = \@data_pack;
  $data{'description'} = $desc;
  return \%data;
  
}

sub genes_n_cds {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my %mol;
  my %cgc;
  my $desc = 'notes';
  my @data_pack;
	my $DB = $self->ace_dsn();

  #### data pull and packaging
	
my @objs;# = $term->$tag if $tag;

  push (@objs,$term->Gene,$term->CDS) unless @objs;

  foreach my $obj (@objs) {
      my ($gene,$key);
      # We need to key searches by CDS in order to display them all
      # The main display creates a hybrid list of genes and CDSs.

	  if ($obj->class eq 'CDS') {
	      $gene = $obj->Gene;
	      $key  = $obj;
	  } else {
	      $gene = $obj;
	      $key  = $gene;
	  }

      # Ignore CDSs without associated genes
      next unless $gene;
      next if (defined $cgc{$key} || defined $mol{$key});

      if ($gene->CGC_name) {
	  $cgc{$key} = [$obj,$gene,$gene->CGC_name];
      } else {
	  $mol{$key} = [$obj,$gene,$gene->Sequence_name];
      }
  }

  my @sorted = sort {$cgc{$a}->[2] cmp $cgc{$b}->[2] } keys %cgc;
  push @sorted,sort {$mol{$a}->[2] cmp $mol{$b}->[2] } keys %mol;

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
			
					
			my ($evidence_code, $evidence_details) = get_GO_evidence($term,$gene);
			
			my $gene_data = {
								'gene_info' => {
									
									'id' => "$gene",
									'label' => public_name($gene,'Gene'),
									'class' => 'Gene'
								},
								
								'cgc_name' => $cgc_name,
								'seq' => $seq,
								'description' => $desc,
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
							};
			push @data_pack, $gene_data;		
	}
	
  ####

  $data{'data'} = \@data_pack;
  $data{'description'} = $desc;
  return \%data;
}


sub phenotype {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my @data_pack;

  #### data pull and packaging
	my @phenotypes;
	eval {@phenotypes = $term->Phenotype;};
	
	foreach my $phenotype (@phenotypes) {
	
		my $phenotype_term = $phenotype->Name->right;
		my $phenotype_desc = $phenotype->Description;
		
		
		
		my ($evidence_code, $evidence_details) = get_GO_evidence($term,$phenotype);
		
		
		my $pheno_data = {
							'phene_info' => {
								'id' => "$phenotype",
								'label' => "$phenotype_term",
								'class' => 'Phenotype'
							},
							'description' => $phenotype_desc,
							'evidence_code' => $evidence_code,
							'evidence_details' => $evidence_details									
						 };
		push @data_pack, $pheno_data;			 
	}
	
 ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}
 
 
sub motif {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my @data_pack;

  #### data pull and packaging
	my @motifs;
	eval {@motifs = $term->Motif;};
	
	foreach my $motif (@motifs) {
	
		my $motif_desc = $motif->Description;
		my ($evidence_code, $evidence_details) = get_GO_evidence($term,$motif);
		
		my $motif_data = {
								'motif_info' => {
									'id' => "$motif",
									'label' => "$motif",
									'class' => 'Motif'
								},
								
								'description' => $motif_desc,
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
								};
								
		push @data_pack, $motif_data;
	}
	

 ####

  $data{'data'} = \@data_pack;
  $data{'description'} = $desc;
  return \%data;
}
  
 sub get_tag_data {

  my $self = shift;
  my $tag = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

  #### data pull and packaging
	my @motifs;
	my @tag_data;
	eval {@tag_data = $term->$tag;};
	
	foreach my $tag_datum (@tag_data) {
	
		my $tag_datum_desc = $tag_datum->Description;
		my ($evidence_code, $evidence_details) = get_evidence($term,$tag_datum);
		$data_pack{$tag_datum} = {
								'term' =>$tag_datum,
								'description' => $tag_datum_desc,
								'class' => $tag,
								'evidence_code' => $evidence_code,
								'evidence_details' => $evidence_details
								};
	}
	

 ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}
  
sub get_GO_evidence {

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



### copied and pasted, need to get to work in Object.pm


sub basic_package {

	my ($self,$data_ar) = @_;
	my %package;
	
	foreach my $object (@$data_ar) {
				
				
				my $class;
				eval{$class = $object->class;};

				my $common_name = public_name($object,$class);  ## 
				$package{$object} = 	{
										'class' => $class,
										'common_name' => $common_name
										}	
	}
	return \%package;
}

sub public_name {
    
	my ($object,$class) = @_;
    my $common_name;    
   
    if ($class =~ /gene/i) {
		$common_name = 
		$object->Public_name
		|| $object->CGC_name
		|| $object->Molecular_name
		|| eval { $object->Corresponding_CDS->Corresponding_protein}
		|| $object;
    }
    elsif ($class =~ /protein/i) {
    	$common_name = 
    	$object->Gene_name
    	|| eval { $object->Corresponding_CDS->Corresponding_protein}
    	||$object;
    }
    else {
    	$common_name = $object;
    }
	
	my $data = $common_name;
    return $data;


}

1;



