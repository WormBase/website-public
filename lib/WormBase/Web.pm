package WormBase::Web;

use strict;
use warnings;
use Catalyst::Runtime '5.70';

# Load Catalyst Plugins and set some flags for the application
#
#         -Debug: activates the debug mode for very useful log messages
# ConfigLoader: 
#             will load the configuration from a YAML file in the
#             application's home directory

#  Static::Simple:
#             will serve static files from the application's root directory

use Catalyst::Log::Log4perl; 
use Catalyst qw/
		 -Debug
		 ConfigLoader
		 Static::Simple
		 StackTrace
		 Session
		 Session::State::Cookie
		 Session::Store::FastMmap
	       /;

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


# ConfigLoader::Multi
# Configuration files include:
#   - wormbase.yml (application base configuration)
#   - wormbase_local.yml (overrider bas configuration)
#__PACKAGE__->config( file => __PACKAGE__->path_to('conf') );


# ConfigLoader
__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.yml' } )
  or die "$!";
#__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'wormbase.pl' } )
#  or die "$!";


# Where will static files be located? This is a path relative to APPLICATION root
__PACKAGE__->config->{static}->{dirs} = ['static'];

# Toggle View debug messages that provide indication of our CSS nesting
__PACKAGE__->config->{name} = 'WormBase';

# Overall debug mode. Controls which index pages are shown, for example.
__PACKAGE__->config->{debug} = 1;

# View debugging. On by default if system-wide debug is on, too.
# Toggle View debug messages that provide indication of our CSS nesting
# View debugging messages:
#     browser: in line
#     comment: HTML comments
#     log: logfile
if (__PACKAGE__->config->{debug}) {
  __PACKAGE__->config->{debug_view} = "comment";
#  __PACKAGE__->config->{debug_view} = "browser";
}

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

__PACKAGE__->config->{pages} = {
 				antibody => {
 					     widget_order => [qw/identification expression_patterns notes references/],
 					     widgets      => {
 							      identification => [
										 @identification_widget_fields,
										 qw/
										     other_name
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
							      notes        => [qw/remarks/], 
							      references      => \@reference_widget_fields,
 							     },
					    },
				expression_cluster => { widget_order => [qw/identification
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
							  qw/identification
							     location
							     expression
							     function
							     gene_ontology
							     genetics
							     homology
							     similarities
							     reagents
							     references/
							 ],
					 widgets => {
						     identification => [
									@identification_widget_fields,
									qw/
									    ids
									    description
									    ncbi_kogs
									    species
									    reactome_knowledgebase
									    other_sequences
									    ncbi
									    gene_models
									    cloned_by
									  /
								       ],
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
							      antibody
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



=pod

__PACKAGE__->{config}->{progress} = { existing_cgis => { 


SR_expression
SiteDefs
anatomy
atlas
autocompleter
autocompleter2
cell
cisortho
curate
das
entry
gene
generic
get
gmod
hunter
id
lib
list
mapview
mass_spec
microarray
misc
nbrowse.dev
ontology
private
rss
searches
seq
strains
style.xml
surveys
sw
util
validate_gff3

./anatomy:
cell
neuron_display

./atlas:
browse
xy

./cell:
Pedigree.pm
cell.cgi
make_pedigree.cgi
mindofworm
neato
neuron
neuron.cgi
palettemap.png
pedigree.gif
pedigree.png
pedigree.works

./cell/neuron:
dot2png.cgi
img
n.png
neato
neuron.cgi
neuron_png.pl
plain2png.pl

./cisortho:
CGIsubs.pm
query
results
site_score

./curate:
base
online_forms
submit

./entry:
edit_gene

./gene:
allele
antibody
expr_map.gd
expr_map.gif
expr_map.png
expr_map_small.gif
expr_map_small.png
expr_profile
expression
expression.vzhou
gene
gene_class
gene_in_profile
geneapplet
genetable
gmap
homology_group
interaction_details
locus
locus_new
mapping_data
motif
mountains_coords.txt
operon
rearrange
regulation
sk_map
strain
structure_data
transgene
variation

./generic:
acetable
report
tree

./lib:
CGI
CSS
CSS.pm
ElegansOligos.pm
ElegansSubs.auto
ElegansSubs.bak
ElegansSubs.pm
ElegansSubs.pm.bak
GBsyn.pm
GBsyn2.pm
MerlynAO.pm
MerlynGO.pm
RSS
SKMAP
Seqview.pm
Splicer.pm
StandardURLDumpers.pm
Util.pm
WormBase
WormBase.pm
jack_get_homol.pl
pICalculator.pm




./lib/CGI:
Explorer.pm

./lib/RSS:
DB
ObjectHistory.pm
README
populate_database.pl
sql
test.pl
update_static_feeds.pl

./lib/RSS/DB:
History
History.pm

./lib/RSS/DB/History:
History.pm
Objects.pm

./lib/RSS/sql:
create_schema.sql

./lib/SKMAP:
Config.pm
Coordinates.pm
Data
Image
Search.pm

./lib/SKMAP/Image:
Figures.pm

./lib/WormBase:
Autocomplete.pm
AutocompleteLoad.pm
FetchData.pm
Formatting.pm
GMapView.pm
Table.pm
Toggle.pm
Util
Util.pm


./lib/WormBase/Util:
Rearrange.pm

./mapview:
dasdraw2
dasdraw2.conflict
geneticmap
sequenceapplet

./mass_spec:
experiment
peptide

./microarray:
cluster
download
expression_cluster
microarray_aff
microarray_smd
results
search

./misc:
2005_survey
acedb
author
author_example
biblio
c2c
database_stats
defaults
defaults.offline
digest
download_features
download_sequence
epic
etree
feedback
format_datamining_example
gbrowse_popup
generate_wiki_content
geo_map_by_paper
glossary
help
inline_feed
internal_server_error
laboratory
life_stage
marc
model
not_found
paper
person
person_name
phenotype
random_pic
redirect
release_stats
reset_cookie
session
site_map
standard_urls
submit_feedback
test
text
toggle
version
wbtoggle
xml
xml_md5


./ontology:
anatomy
anatomy_browser
browse
browse.old
browser
browser_lib
gene
go_dag
goterm
search
search_data.txt

./ontology/browser_lib:
OBrowse.pm
README
browser.initd
launch_ontology_sockets.sh
ontology_server.pl
test_sockets.pl

./private:
gbrowse
manage_newsfeeds
test_urls
update_newsfeed

./searches:
advanced
aql_query
basic
basic_nuke
batch_genes
blast0212
blast_blat
blast_ori
blat
blat.new
blat_debug
blat_jack
browser
class_query
dasview
download_index
dump_laboratories
epcr
expr_search
fast_facts
gotable
graf.cgi
grep
grep.dev
hunter.cgi
info_dump
interval
markers
multi
multi.prototype
multi.search
multi.search.ace
neuron302.cgi
neuron_display
neuron_display_jack
neuron_graf.cgi
pedigree
query
query_nuke
rnai_search
search_index
standard_urls
strains
test
test_escape
text
text302
wb_query

./searches/advanced:
batch_search
debug_script
debug_script2
dumper
dumper.cfg
dumper.methods.txt
dumper_11_05_03
exercise
gfServer.log
jack_dump.gar
tmp

./seq:
PadAlignment.pm
align
aligner
clone
clone_position_table
contig2gff
das
das2
dasdraw
dna
do_align
ebsyn
frend
gbrowse
gbrowse_details
gbrowse_drag
gbrowse_est
gbrowse_gff_autocomplete
gbrowse_img
gbrowse_moby
gbrowse_not
gbrowse_render
gbrowse_run
gbrowse_seqfeature_autocomplete
gbrowse_syn
gbrowse_templates
gbs
gbsyn
interaction
interaction_viewer
moby_server
pcr
promoter
protein
rnai
sage
sequence
show_mult_align
tr_script
transcript
wtp
y2h

./strains:
search

./surveys:
2005_wormbase
2006_topics_meetings
2007_wormbase
2007_wormbook
dynamic_banner_stats.pl

./sw:
browse

./util:
colors
dump_version
wormbase.pm.defaults


validate_gff3_online


=cut


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

#### THESE ARE DEFAULTS WHICH CAN BE PURGED
sub message : Global {
  my ( $self, $c ) = @_;
  $c->stash->{template} = 'message.tt2';
  $c->stash->{message} ||= $c->req->param('message') || 'No message';
}


sub get_example_object {
  my ($self,$class) = @_;
  my $ace_model = $self->model('AceDB');
  my $dbh   = $ace_model->dbh;
  my $total = $dbh->fetch(-class => ucfirst($class),
			  -name  => '*');
  
  my $object_index = 1 + int rand($total-1);

  # Fetch one object starting from the randomly determined one
  my ($object) = $dbh->fetch(ucfirst($class),'*',1,$object_index);
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
