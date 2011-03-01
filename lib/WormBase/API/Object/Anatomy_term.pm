package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

=pod 

=head1 NAME

WormBase::API::Object::Anatomy_term

=head1 SYNPOSIS

Model for the Ace ?Gene class.

=head1 URL

http://wormbase.org/species/gene

=head1 METHODS/URIs

=cut

################
## subroutines
################

=head2 name

This method will return a data structure re: definition of this name.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/name

=head4 Response example

<div class="response-example"></div>

=cut


# sub name { }
# Supplied by Role; POD will automatically be inserted here.
# << include name >>


=head2 definition

This method will return a data structure re: definition of this anatomy_term.

=head3 PERL API

 $data = $model->definition();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/definition

=head4 Response example

<div class="response-example"></div>

=cut

sub definition {
	my $self = shift;
    my $object = $self->object;
	my $data_pack = $object->Definition;
	my $data = {
				'data'=> $data_pack,
				'description' => 'definition of the anatomy term'
				};
	return $data;
}

=head2 synonyms

This method will return a data structure re: synonyms this anatomy_term.

=head3 PERL API

 $data = $model->synonyms();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/synonyms

=head4 Response example

<div class="response-example"></div>

=cut

sub synonyms {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @tag_objects = $object->Synonym;

	foreach my $tag_object (@tag_objects) {
		my $synonym = $tag_object->Primary_name->right if $tag_object->Primary_name;
		my $tag_info = $self->_pack_obj($synonym);
		push, @data_pack, $tag_info;
	}
	my $data = {
				'data'=> \@data_pack,
				'description' => 'description of the'
				};
	return $data;
}

=head2 remarks

This method will return a data structure with remarks re: this term.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/remarks

=head4 Response example

<div class="response-example"></div>

=cut


# sub remarks {}
# Supplied by Role; POD will automatically be inserted here.
# << include remarks >>

## sub anatomy {}  figure out image displaying functions

## sub worm_atlas {} put under external resources


=head2 transgenes

This method will return a data structure re: transgenes annotated with this anatomy_term.

=head3 PERL API

 $data = $model->transgenes();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/transgenes

=head4 Response example

<div class="response-example"></div>

=cut

sub transgenes {
	my $self = shift;
    my $object = $self->object;
	my @transgenes;
	my @data_pack;
	eval{@transgenes = map{$_->Transgene} grep {/marker/i&& defined $_->Transgene} $term->Expr_pattern;};

	foreach $transgene (@transgenes) {
		my $transgene_data = {
			'id' =>"$transgene",
			'label' =>"$transgene",
			'class' => 'Transgene'
		}
		push @data_pack, $transgene_data;
	}
	my $data = {
		'data'=> \@data_pack,
		'description' => 'transgenes annotated with this anatomy_term'
		};
	return $data;		
	
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

=head2 expr_patterns

This method will return a data structure re: expr_patterns annotated with this anatomy_term.

=head3 PERL API

 $data = $model->expr_patterns();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/expr_patterns

=head4 Response example

<div class="response-example"></div>

=cut

sub expr_patterns{
	my $self = shift;
    my $object = $self->object;
	my $desc = 'notes';
	my @data_pack;
	my @expr_patterns = $object->Expr_pattern;
	
	foreach my $expr_pattern (@expr_patterns) {
		my $ep_data = {
			'id' =>"$expr_pattern",
			'label' =>"$expr_pattern",
			'Class' => 'Expr_pattern'				
		};
		my $ep_gene;
		my $ep_pattern;
		my $ep_xgene;
		
		eval {$ep_gene= $expr_pattern->Gene};
		eval {$ep_pattern= $expr_pattern->Pattern};
		eval {$ep_xgene = $expr_pattern->Transgene};		
		
		my $gene_data = $self->_pack_obj($ep_gene) if $ep_gene;
		my $ep_pattern_data = $self->_pack_obj($ep_pattern) if $ep_pattern;
		my $ep_transgene_data = $self->_pack_obj($ep_xgene) if $ep_xgene;
		
		push @data_pack, {
			'ep_data' => $ep_data,
			'gene' => $gene_data,
			'pattern' => ep_pattern_data,
			'trans_gene' => $ep_transgene_data		
			};
	}
	
	my $data = {
		'data'=> \@data_pack,
		'description' => 'expr_patterns annotated with this anatomy_term'
		};
	return $data;
}

=head2 go_terms

<headvar>This method will return a data structure re: go_terms annotated to this anatomy_term.

=head3 PERL API

 $data = $model->go_terms();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/go_terms

=head4 Response example

<div class="response-example"></div>

=cut

sub go_terms{
	my $self = shift;
    my $object = $self->object;
	my $desc = 'notes';
	my @data_pack;
	my @go_terms = $object->GO_term;
	foreach my $go_term (@go_terms) {
		my $term = $go_term->Term;
		my $ao_code = $go_term->right;
		my $gt_data = {
			'id' =>"$go_term",
			'label' =>"$term",
			'Class' => 'GO_term'			
		};
		push @data_pack, {
				'term' => $gt_data,
				'ao_code' => "$ao_code"
			};
	}
	
	my $data = {
		'data'=> \@data_pack,
		'description' => 'go_terms associated with this anatomy_term'
		};
	return $data;
}

=head2 anatomy_function 

<headvar>This method will return a data structure re: anatomy_function associated with this anatomy_term.

=head3 PERL API

 $data = $model->anatomy_function();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/anatomy_function

=head4 Response example

<div class="response-example"></div>

=cut

sub anatomy_functions {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @anatomy_functions = $object->Anatomy_function;
	
	foreach my $anatomy_function (@anatomy_functions) {
		my $phenotype = $anatomy_function->Phenotype;
		my $phenotype_name = $phenotype->Primary_name;
		my $gene = eval{$af->Gene;};
		my $gene_data = $self->_pack_obj($gene) if $gene;

		push @data_pack, {
			'af_data' => {
				'id' =>"$anatomy_function",
				'label' =>"$anatomy_function",
				'Class' => 'Anatomy_function'			
			},						
			'phenotype' => {
				'id' => $phenotype,
				'label' => $phenotype_name,
				'class' => 'phenotype'
			},
			'gene' => $gene_data
		};	
	}
	
	my $data = {
		'data'=> \@data_pack,
		'description' => 'anatomy_functions associatated with this anatomy_term'
		};
	return $data;
}

=head2 anatomy_function_nots

<headvar>This method will return a data structure re:anatomy_function_nots associated with this anatomy_term.

=head3 PERL API

 $data = $model->anatomy_function_nots();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/anatomy_function_nots

=head4 Response example

<div class="response-example"></div>

=cut

sub anatomy_function_nots {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	my @anatomy_functions = $object->Anatomy_function_not;
	
	foreach my $anatomy_function (@anatomy_functions) {
		my $phenotype = $anatomy_function->Phenotype;
		my $phenotype_name = $phenotype->Primary_name;
		my $gene = eval{$af->Gene;};
		my $gene_data = $self->_pack_obj($gene) if $gene;

		push @data_pack, {
			'af_data' => {
				'id' =>"$anatomy_function",
				'label' =>"$anatomy_function",
				'Class' => 'Anatomy_function'			
			},						
			'phenotype' => {
				'id' => $phenotype,
				'label' => $phenotype_name,
				'class' => 'phenotype'
			},
			'gene' => $gene_data
		};	
	}
	
	my $data = {
		'data'=> \@data_pack,
		'description' => 'anatomy_functions not associated with this anatomy_term'
		};
	return $data;
}
=head2 expression_clusters

<headvar>This method will return a data structure re: expression_clusters associated with this anatomy_term.

=head3 PERL API

 $data = $model->expression_clusters();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Anatomy_term ID WBbt:0005175

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/anatomy_term/WBbt:0005175/expression_clusters

=head4 Response example

<div class="response-example"></div>

=cut

sub expression_clusters {
	my $self = shift;
    my $object = $self->object;
	my $desc = 'notes';
	my @data_pack;
	my @expression_clusters = $object->Expression_cluster;
	foreach my $expression_cluster (@expression_clusters) {
		my $ec_description = $expression_cluster->Description;
		my $ec_data = {
			'id' =>"$expression_cluster",
			'label' =>"$expression_cluster",
			'Class' => 'Expression_cluster'			
		};
		push @data_pack, {
			'ec_data' => $ec_data,
			'description' => $ec_description
		};
	}
	my $data = {
		'data'=> \@data_pack,
		'description' => 'expression_clusters associated with this anatomy_term'
		};
	return $data;
}


1;



