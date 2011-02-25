package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


#### subroutines

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


#####################
## identification
#####################

sub term {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging
	
	my $term = $object->Term;

	$data_pack = {
	
		'id' =>"$object",
		'label' =>"$term",
		'Class' => 'AO_term'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}

## TODO: evidence may need to be added in display

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

## TODO: evidence may need to be added in display

sub synonyms {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @data_pack = $object->Synonym;

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub remarks {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @data_pack = $object->Remark;

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

## sub anatomy {}  figure out image displaying functions

sub worm_atlas {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->URL;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub transgenes {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @transgenes;

	eval{@transgenes = map{$_->Transgene} grep {/marker/i&& defined $_->Transgene} $term->Expr_pattern;};

	foreach $transgene (@transgenes) {
	
		my $transgene_data = {
			'id' =>"$transgene",
			'label' =>"$transgene",
			'class' => 'Transgene'
		}
	
		push @data_pack, $transgene_data;
	}
	
	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

#####################
## browser
#####################

#####################
## term diagram
#####################

#####################
## associations
####################

sub expr_patterns{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @expr_patterns = $object->Expr_pattern;
	
	foreach my $expr_pattern (@expr_patterns) {
	
		my $ep_data = {
		
		'id' =>"$expr_pattern",
		'label' =>"$expr_pattern",
		'Class' => 'Expr_pattern'			
		
		};
	}

	push @data_pack, $ep_data;
	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub go_terms{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	my @go_terms = $object->GO_term;
	
	foreach my $go_term (@go_terms) {
	
		my $term = $go_term->Term;
		my $gt_data = {
		
			'id' =>"$go_term",
			'label' =>"$term",
			'Class' => 'GO_term'			
		};
	}

	push @data_pack, $gt_data;

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub anatomy_functions{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @anatomy_functions = $object->Anatomy_function;
	
	foreach my $anatomy_function (@anatomy_functions) {
	
		my $af_data = {
		
			'id' =>"$anatomy_function",
			'label' =>"$anatomy_function",
			'Class' => 'Anatomy_function'			
		};
	}

	push @data_pack, $af_data;

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub anatomy_function_nots {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my @anatomy_functions = $object->Anatomy_function_not;
	
	foreach my $anatomy_function (@anatomy_functions) {
	
		my $af_data = {
		
			'id' =>"$anatomy_function",
			'label' =>"$anatomy_function",
			'Class' => 'Anatomy_function'			
		};
	}

	push @data_pack, $af_data;
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub expression_clusters{

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	my @expression_clusters = $object->Expression_cluster;
	
	foreach my $expression_cluster (@expression_clusters) {
	
		my $ec_data = {
		
		'id' =>"$expression_cluster",
		'label' =>"$expression_cluster",
		'Class' => 'Expression_cluster'			
		
		};
	}

	push @data_pack, $ec_data;

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


####################
## superceded
####################


sub details {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my $data_pack;

  #### data pull and packaging
  
  my $ao_term = $term->Term;
  my $definition = $term->Definition;
  my $synonym = $term->Synonym;
  my $remark = $term->Remark;
  my $url = $term->URL;

  $data_pack = {
  				'ace_id' =>$term,
  				'term' => $ao_term,
  				'definition' => $definition,
  				'synonym' => $synonym,
  				'remark' => $remark,
  				'url' => $url,
  				};
  ####

  $data{'data'} = $data_pack;
  $data{'description'} = $desc;
  return \%data;
}


sub expr_patterns{

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

		  #### data pull and packaging

	my @eps = $object->Expr_pattern;
		
		foreach my $expr_pattern (@eps) {
		
		my $ep_gene;
		my $ep_pattern;
		my $ep_xgene;
		
		eval {$ep_gene= $expr_pattern->Gene};
		eval {$ep_pattern= $expr_pattern->Pattern};
		eval {$ep_xgene= $expr_pattern->Transgene};
		
		
		my $gene_name = public_name($ep_gene,'Gene');
		
		
		$data_pack{$expr_pattern} = (
									'expr_pattern' => $expr_pattern,
									'gene' => {
												'ace_id' => $ep_gene,
												'name' => $gene_name,
												'class' => 'Gene'
												},
									'pattern' => $ep_pattern,
									'transgene' =>{
													'xgene_id' => $ep_xgene,
													'class' => 'Transgene'
													}
									);
	}

  ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}



sub go_terms {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

  #### data pull and packaging

	my @go_terms = $object->GO_term;
	
	foreach my $go_term (@go_terms) {
	
	my $term = $go_term->Term;
	my $type = $go_term->Type;
	my $ao_code = $go_term->right;
	
	$data_pack{$go_term} = {
							'ace_id' => $go_term,
							'term' => $term,
							'ao_code' => $ao_code,
							'class' => 'GO_term'
							}
	};
	
	
  ####

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}



#sub reference {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}


#sub ao_evidences {
#
#	my $evidences_hr;
#	my @tags = /GO_term /;
#	$evidences_hr = _get_evidences(@tags);
#	return $evidences_hr;
#}



sub anatomy_fn {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;

	my @anatomy_funtions = $object->Anatomy_function;
	
	foreach my $af (@anatomy_funtions) {
		
		my $phenotype = $af->Phenotype;
		my $phenotype_name = $phenotype->Primary_name;
		my $gene = eval{$af->Gene;};
		my $gene_name = eval{public_name($gene);};
		my $af_not;
	
		$data_pack{$af} = {
							'ace_id' => $af,
							'phenotype' => {
								 			'phenotype_id' => $phenotype,
								 			'phenotype_name' => $phenotype_name,
								 			'class' => 'phenotype'
											},
							'gene' => {
										'gene_id' => $gene,
										'gene_name' => $gene_name,
										'class' => 'Gene'
										},
							'not' => $af_not
							};
	}

	


  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
}

sub expr_clusters {

  my $self = shift;
  my $object = $self->object;
  my %data;
  my $desc = 'notes';
  my %data_pack;


	my @expr_clusters = $object->Expression_cluster;
	
	foreach my $ec (@expr_clusters) {
	
		my $ec_description = $ec->Description;
	
		$data_pack{$ec} = {
		
						'expr_cluster_id' => $ec,
						'class' => 'Expression_cluster',
						'description' => $ec_description
						}
	}

  $data{'data'} = \%data_pack;
  $data{'description'} = $desc;
  return \%data;
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
										'label' => $common_name,
                                                                                'id' => "$object"
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

#####################
## internal methods
#####################




1;



