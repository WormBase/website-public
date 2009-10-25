package WormBase::Web;

#use Moose;


use strict;
use warnings;
use Catalyst::Runtime '5.80';

# Set flags and add application plugins
#
#         -Debug: activates the debug mode for very useful log messages
# ConfigLoader: 
#             will load the configuration from a Config::General file in the
#             application's home directory
#  Static::Simple:
#             will serve static files from the application's root directory

use parent qw/Catalyst/;
use Catalyst qw/-Debug
		 ConfigLoader
		 Static::Simple
                 Unicode
	       /;

#                 Breadcrumbs
#
#		 StackTrace
#		 Session
#		 Session::State::Cookie
#		 Session::Store::FastMmap

#NOTE: we may want to dynamically set the local config file suffix:
# * $ENV{ MYAPP_CONFIG_LOCAL_SUFFIX }
# * $ENV{ CATALYST_CONFIG_LOCAL_SUFFIX }
# * $c->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix }
# Thus, we could use different configuration files for any server or developer
# See C:Plugin::ConfigLoader for details


use Catalyst::Log::Log4perl; 

# TODO: Move to distinct configuration files
# use Config::Any::Perl;
#		ConfigLoader::Multi

our $VERSION     = '0.01';
our $CODENAME = 'Troncones';

# Configure the application.
# Default application-wide configuration is located in
# wormbase.yml.
# Defaults can be overriden in wormbase_local.yml for
# local or production deployment.


# Create a log4perl instance
__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(
        __PACKAGE__->path_to( 'conf', 'log4perl.conf' )->stringify
    )
    );

# $SIG{__WARN__} = sub { __PACKAGE__->log->fatal(@_); };

__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.conf' } ) or die "$!";

__PACKAGE__->config->{static}->{dirs} = [
    qw|css
       js
       img       
      |]; 

__PACKAGE__->config->{static}->{debug} = 1;


#__PACKAGE__->config(
#    breadcrumbs => {
#	hide_index => 1,
#	hide_home  => 0,
##	labels     => {
##	    '/'       => 'Home label',
##	    '/foobar' => 'FooBar label',
##	    ....
##	},
#    },
#    );



# Are we in production?  If so, select the correct configuration file using the server name
# TODO: This needs to be a flag set during packaging/deployment as we haven't yet read in
# the configuration file. This is a hack for now

__PACKAGE__->config->{deployed} = 'under development';
if (__PACKAGE__->config->{deployed} eq 'production') {
    __PACKAGE__->config->{ 'Plugin::ConfigLoader' }->{ config_local_suffix } = $ENV{SERVER_NAME};
}


# Where will static files be located? This is a path relative to APPLICATION root
__PACKAGE__->config->{static}->{dirs} = ['static'];

# View debugging. On by default if system-wide debug is on, too.
# Toggle View debug messages that provide indication of our CSS nesting
# View debugging messages:
#     browser: in line
#     comment: HTML comments
#     log: logfile

__PACKAGE__->config->{version}  = $VERSION;
__PACKAGE__->config->{codename} = $CODENAME;


###########################################################
# PAGE CONFIGURATION
#
# This is a bit of a misnomer - consider page roughly
# equivalent to class.  Actual pages are able to display
# widgets from any class they wish.
###########################################################
# Structure:
#__PACKAGE__->config->{pages}->{$class_name} =>
#	{ widget_order => [ ],   # order widgets should be loaded
#                             # in the sidebar or tabbed interface, say
#      widgets      => {         # a hash ref of available widgets
#             widget_name => [ ]   # an array ref of available fields
#                      }
#    }

# Generic widgets:
# Every page SHOULD have an "Identification" widget consisting of name and common name.
# These auto-methods can be over-ridden in your model.

# REMEMBER: If you change the name of anything here, you will also need to 
# change the name of the corresponding method in the Model class and the
# name of the template

# TODO: Decide how to handle empty widgets (those without sections, subsections)
# Solution: I'm forcing fields for every widget.  Ie Expression > Expression patterns
# Other examples:
# Remarks becomes Notes > Remarks

# Define some default fields (and in turn some default widgets) for each class.
# Minimally, each class has an "identification"" widget. This really just provides
# the name and common name of the object being displayed.

# Other possible common widgets might include things like location, genetics, etc.

# Some default fields for the identification widget
# Perhaps I should include species in here, too.
# OTOH, there are classes which may not have species
my @identification_widget_fields = qw/
				       name
				       common_name
				     /;

# References occur often
my @reference_widget_fields = qw/
				  published_literature
				  meeting_abstracts
				  gazette_abstracts
				  wormbook_abstracts
				/;



# Alternatively:
# Introspect each model to find a list of meta methods it implements.
# Append to that a list of available object tags or rows as necessary

__PACKAGE__->config->{pages} = {
    antibody => {
	widget_order => [qw/identification expression_patterns notes references/],
	widgets      => {
	    identification => [
		@identification_widget_fields,
		qw/other_name
                   summary
	           location
		   generated_against_locus
		   corresponding_gene
		   clonality	  
		   antigen
		   animal
	          /
		],
		  expression      => [qw/expression_patterns/],
		  notes           => [qw/remarks/], 
		  references      => \@reference_widget_fields,
	},
    },
		  
		  expression_cluster => { 
		      widget_order => [qw/identification
					  clustered_data
					  notes
				          references
				       /],
		      widgets => { identfication => [@identification_widget_fields,
						     qw/description
						        algorithm/],
							 clustered_data => [qw/microarray_results
									       sage_results/],
							 references      => \@reference_widget_fields,
		  },
	      },
							 gene => {
							     browse       => { limits => [qw/Species
									 Gene_class/],
							 },
					 # Fields to return for searches
					 search => [qw/name common_name species description/],
					 widget_order => [
					     qw/overview
overview2
                                                 /],
#							     location
#							     expression
#							     function
#							     gene_ontology
#							     genetics
#							     homology
#							     similarities
#							     reagents
#							     references/
#					 ],
							     widgets => {
					     overview => [
						 qw/
                                                   ids
						   concise_description

     					           gene_models
                                                   history
						   /],
#                                                   species

#						   sequences => [
#						       qw/gene_models
#                                                         /],

#
#                                                          unspliced
#                                                          spliced
#                                                          translated

						     location => [
								  qw/genetic_position
								     interpolated_position
								     genomic_position
								     genomic_environs
								    /
								 ],
						     expression => [
								    qw/fourd_expression_movies
								       anatomic_expression_patterns
								      /
								   ],
						     function => [
								  qw/pre_wormbase_information
								     rnai_phenotypes
								     y1h_and_y2h_interactions
								     interactions
								     microarray_expression_data
								     expression_cluster
								     microarray_topology_map_position
								     regulation_on_expression_level
								     protein_domains
								    /
								 ],
						     gene_ontology => [qw/gene_ontology/],
						     genetics      => [
								       qw/reference_allele
									  alleles
									  polymorphisms
									  strains
									  rearrangements/
								      ],
						     homology => [
								  qw/inparanoid_groups
								     orthologs
								     treefam
								    /
								 ],
						     similarities => [qw/best_blastp_matches/],
						     reagents     => [
								      qw/							
									  transgenes
									  orfeome_project_primers
									  sage_tags
									  primer_pairs
									  microarray_probes
									  matching_cdnas
                                                                          antibodies
									/
								     ],
						     references  => \@reference_widget_fields,
						    },
					},
				
 				gene_class => {
 					       widget_order => [
 								qw/identification
								   genes
								   notes
								   previous_genes/
 							       ],
 					       widgets => {
 							   identification => [
									      @identification_widget_fields,
									      qw/
										  gene_class
										  main_name
										  other_name
										  description
										  phenotype
										  designating_laboratory
										/],
 							   genes          => [],
 							   notes        => [qw/remarks/],
 							   previous_genes => [],
 							  },
					       view_caveats => { title => 'About gene classes in C. elegans',
								 content => 'Please read <a href="http://www.wormbase.org/wiki/index.php/Nomenclature">guidelines</a> for further details on gene nomenclature in nematodes.'},
 					      },
				gene_regulation => {
						    widget_order => [qw/identification method regulator regulates notes references/],
						    widgets      => { identification => [@identification_widget_fields,
											 qw/summary
											   /],
								      method         => [qw/antibody
											    reporter_gene
											    in_situ_hybridization
											    northern
											    western
											    RT_PCR
											    other_method/],
								      regulator      => [qw/genes
											    cis_regulator
											    allele_used
											    rnai_used
											    condition
											   /],
								      regulates      => [qw//],
								      references      => \@reference_widget_fields,
								      notes    => [ qw/remarks/],
								    },
						   },
				homology_group => {
						   widget_order => [qw/identification
								       cog_code_information
								       proteins/],
						   widgets      => { identification => [@identification_widget_fields,
											qw/title
											   group_type/],
								     cog_code_information => [qw/cog_type
												 cog_code
												 general_code_expansion
												 specific_cog_expansion/],
								     proteins            => [qw//],
								   },
						   
						  },
				laboratory => { widget_order => [qw/identification
								    representatives responsible_for members notes/],
						widgets => {identification  => [@identification_widget_fields], 
							    representatives => [qw/principal_investigator
										   other_representatives
										   lab_url/],
							    responsible_for => [qw/responsible_for_genes
										   responsible_for_alleles/],
							    members         => [qw/registered_lab_members
										   past_lab_members/],
							    notes         => [qw/remarks/],
							   },
					      },	
				
				motif => { widget_order => [qw/identification homology associations/],
					   widgets      => { identification => [@identification_widget_fields,
										qw/title 
										   remarks
										   source_database
										   accession_number
										   associated_transposon_family
										   match_sequence
										   num_mismatch
										  /],
							     homology => [qw/dna_homology
									     peptide_homology
									     motif_homology
									     homol_homology/],
							     associations => [qw/gene_ontology/],
							   },
					 },
				operon => {
					   widget_order => [qw/identification
							       operon_structure
							       location
							       history
							       references/],					   
					   widgets      => { identification => [@identification_widget_fields,
										qw/species/
									       ],
							     operon_structure => [qw/contains_genes/],
							     location   => [qw/genomic_position
									       genomic_environs/],
							     history    => [qw/object_history/],
							     references => \@reference_widget_fields,
							   }
					  },
				
				paper         => { widget_order => [qw/identification
								       citation
								       abstract
								       author_locations/],
						   widgets => {
							       identification => [@identification_widget_fields,
										 qw/PMID
										   CGC/],
							       citation       => [qw/authors
										     journal
										     year
										     pages/],
							       asbtract        => [qw//],
							       author_locations => [qw//],
							      },
						 },
				protein => { widget_order => [qw/identification homology sequence
								protein_statistics
								history/],
					     widgets => { identification => [@identification_widget_fields,
									     qw/species
										homology_groups
										genes
										transcripts
										type
										reactome_knowledgebase/],
							  homology => [qw/homology_image
									  motif_homologies
									  best_blastp_matches/],
							  sequence => [qw/protein_sequence/],
							  protein_statistics => [qw/protein_length
										    estimated_molecular_weight
										    estimated_isoelectric_point
										    amino_acid_composition
										   /],
							  history => [qw/protein_history/],
							  
							},
					   },
				rearrangement => { widget_order => [qw/identification
								       isolation
								       type
								       balances
								       map
								       evidence
								       notes
								       positive_markers
								       negative_markers
								      /],
						   widgets => { identification => [@identification_widget_fields,
										   qw/other_name
										      variation/],
								isolation => [qw/author
										 location
										 date
										 mutagen
										/],
								type      => [qw/rearrangement_type
										 duplication
										 compound
										 phenotype
										/],
								
								balances => [qw/chromosome
										relative_position
										loci/],
								
								map => [qw/experimental_position/],
								evidence => [qw/rearrangement_evidence/],
								notes => [qw/remarks/],
								positive_markers => [qw/genes_inside
											loci_inside
											clones_inside
											rearrangements_inside/],
								negative_markers => [qw/genes_outside
											loci_outside
											clones_outside
											rearrangements_outside/],
								display => [qw/hides_under
									       hides/],
								strain => [qw/reference_strain
									      stains_carrying/],
								mapping_data => [qw//],
								references => \@reference_widget_fields,
							      },
						 },
				structure_data => {
						   widget_order => [ qw/identification
									target_details
									homology/],
						   widgets      => { identification => [@identification_widget_fields,
											qw/database
											   target_id
											  /],
								     target_details => [qw/sequence
											   status/],
								     homology       => [],
								   },
						  },
				
				# Fields for transgene aren't correctly separated into widgets
				transgene => {
					      widget_order => [qw/identification
								  driven_by
								  location
								  notes
								  references
								 /],
					      widgets      => { driven_by => [ qw/driven_by_gene/],
#										  summary
#										  driven_by_sequence
#										  reporter_product
#										  author
#										  clone
#										  fragment
#										  injected_into_cgc_strain
#										  injected_into
#										  integrated_by
#										  location
#										  two_point
#										  multi_point
#										  strain
#                                                                                  phenotype
#										  rescue
#										  expression_pattern
#										  species  
#
#										  /],
#								location => [qw/
#										 map_position
#										 /],
#								location => [qw/
#										 genetic_position
#										 /],
								references => \@reference_widget_fields,
								notes      => [qw/remarks/],
							      },
					     },
				
				variation => {
					 widget_order => [
							  qw/identification
							     molecular_details
							     location
							     genetic_information
							     polymorphism_details
							     phenotype
							     isolation_history
							     remarks
							     references/
							 ],
					 widgets => {
						     identification => [@identification_widget_fields,
									qw/other_name
									   variation_type
									  /],
						     molecular_details => [qw/type_of_mutation
									      nucleotide_change      
									      flanking_sequences
									      cgh_flanking_sequences
									      cgh_deleted_probes
									      context
									      deletion_verification
									      affects
									      flanking_pcr_products
									     /],
						     location => [ qw/genetic_position
								      genomic_position
								      genomic_environs
								     /],
						     genetic_information => [qw/
										 corresponding_gene
										 reference_allele
										 alleles
										 polymorphisms
										 strains
										 rescued_by_transgene/],
						     polymorphism_details => [qw/polymoprhism_type
										 status
										 polymorphism_assay
										/],
						     # NEED TO TEMPLATIZE TO THIS POINT (phenotype remark)
						     phenotype => [qw/
								       phenotypes_observed
								       phenotypes_not_observed
								       phenotype_remark
								     /],
						     # TODO: lab of origin. that's it.
						     isolation_history   => [qw/source_database
										author
										person
										laboratory_of_origin
										date_isolated
										mutagen
										isolated_via_forward_genetics
										isolated_via_reverse_genetics
										transposon_excision
										transposon_insertion
									       /],
						     references => \@reference_widget_fields,
						     notes    => [ qw/remarks/ ],
						    }
					     }
			       };


# These fields are handled by generic templates in root/templates/generic/
# This is a kludge until I debug the RenderView problem
# (to circumvent RenderView, I have to specify template and specifically forward to the view)

# Choosing which template to render:
# 1. Common: Is the field/widget listed in the common_* hash? Use it.
# 2. Custom: Is the field/widget listed in the custom_* hash? Use it.
# 3. Fall back to generic field/widget

# BETTER YET:
# 1. Does a common template exist for this field? Use it.
# 2. Does a custom template exist for this field? Use it.
# 3. Otherwise, use a generic template.

# common_fields are used throughout the model and do not
# belong to a specific class but still require custom templates.
# If your model requires one of these fields, all you need to do
# is specify it in your configuration.
__PACKAGE__->config->{common_fields} = { map { $_ => 1 } qw/alleles
							    common_name
							    genetic_position
							    genomic_position
							    genomic_environs
                                                            history
							    interpolated_position
							    name
							    phenotypes_observed
							    phenotypes_not_observed
							    polymorphisms
							    references
							    species
							    strains
							   / };

# generic_fields can use field.tt2 or widget.tt2
# They should be singletons (either string or object hashref),
# simple lists of either plain text or objects, or lists of lists
# that will become a table.
__PACKAGE__->config->{generic_fields} = { map { $_ => 1 } qw/
							      author
							      allele_used
							      antibodies
							      cis_regulator
							      condition
							      corresponding_gene
							      flanking_pcr_products
							      in_situ_hybridization
							      isolated_via_forward_genetics
							      isolated_via_reverse_genetics
							      microarray_expression_data
							      mutagen
							      northern
							      other_method
							      person
							      polymorphism_type
							      reference_allele
							      reporter_gene
							      rescued_by_transgene
							      rnai_used
							      rt_pcr
							      sage_tags
							      status
							      summary
                                                              transgenes
							      transposon_excision
							      transposon_insertion
							      type_of_mutation
							      variation_type
                                                              western							      
							      matching_cdnas
							      orfeome_project_primers
							    /},
  
  
# These widgets can all use a single generic widget template.
# Note that this is still page specific since the field templates
# are included in the widget template.  This should be a variable, too.

# But this is weird. If I request a single field, the template is specified there.
# How can I access this?  Or rather, why override the specified template
# for the field in the widget template?

#####  ----->
# in other words: any widget that mixes generic and specific field templates
# CANNOT use the generic widget.  Annoying.

# As above, common_widgets are used throughout the model
  # but still require custom markup.
__PACKAGE__->config->{common_widgets} =  { map { $_ => 1 } qw/
							       references
							       remarks
							     /};

# We should aspire to make ALL widgets generic
# We will still have some custom fields however
__PACKAGE__->config->{generic_widgets} =  { map { $_ => 1 } qw/
								identification
								expression
								function
								homology
								location
								reagents
								similarities
							      /};


__PACKAGE__->config->{'View::JSON'} = {
    expose_stash => 'data' };



# Start the application
__PACKAGE__->setup;




#use
#   $ CATALYST_DEBUG_CONFIG=1 perl script/extjs_test.pl /
# to check what's in your configuration after loading
#$ENV{CATALYST_DEBUG_CONFIG} && print STDERR 'cat config looks like: '. dump(__PACKAGE__->config) . "\n";# . dump(%INC)."\n";


=pod

Detect if a controller request is via ajax to disable
template wrapping.

=cut

sub is_ajax {
  my $c       = shift;
  my $headers = $c->req->headers;
  return $headers->header('x-dojo-version')
    || ( ( $headers->header('x-requested-with') || '' ) eq 'XMLHttpRequest' );
}



sub get_example_object {
  my ($self,$class) = @_;
  my $api = $self->model('WormBaseAPI');

  my $ace = $api->service('acedb');
  # Fetch the total number of objects
  my $total = $ace->fetch(-class => ucfirst($class),
			  -name  => '*');
  
  my $object_index = 1 + int rand($total-1);

  # Fetch one object starting from the randomly determined one
  my ($object) = $ace->fetch(ucfirst($class),'*',1,$object_index);
  return $object;
}


=head1 NAME

WormBase - Catalyst based application

=head1 SYNOPSIS

    script/wormbase_server.pl

=head1 DESCRIPTION

WormBase - the WormBase web application

=head1 SEE ALSO

L<WormBase::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
