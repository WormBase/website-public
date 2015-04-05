package WormBase::API::Service::ontology_browser;

=head1 PURPOSE: 
To support Ontology display and query: drive Ontology Browser widget on 
each of the ontology pages & the 'expandable tree' under 
Tools->More tools->Ontologies
  
=head1 REFERENCE:
http://wiki.geneontology.org/index.php/AmiGO_Manual:_Installation_2.0
http://wiki.geneontology.org/index.php/GOlr:_Installation
http://wiki.geneontology.org/index.php/Example_Solr_Queries
http://wormbase.caltech.edu:8080/wormbase/manual/wobr/solr-query
  
=head1 DESCRIPTION:
Following the scheme of AmiGO 2.0, WormBase ontologies and annotations 
based on ontologies (in the form of GAFs) were converted to documents 
stored in an Apache Solr server. This package is used to query the Solr 
server and present the results.
=cut
# display expandable tree with index.tt2, children queried for inferred 
# tree with query_children.tt2, list of genes with show_genes.tt2, and 
# term information with run.tt2 .  data is from Raymond's solr server 
# at $base_solr_url .
 
use Moose;
with 'WormBase::API::Role::Object'; 

use namespace::autoclean;
use LWP::Simple;
use JSON;
use GraphViz;

my $json = JSON->new->allow_nonref;
my %paths;      # finalpath => array of all (array of nodes of paths that end)
                # childToParent -> child node -> parent node => relationship

=head2 %transitivityPriority
Relationships that are transitive. When mutiple relationships form a a 
transitive path, relationship of the highest rank takes precedence.
=cut
my %transitivityPriority;	# these relationships are considered transitive.  also when different paths 
				# have different inferred transitivity, highest number takes precedence. 
$transitivityPriority{"is_a"}                 = 1;
$transitivityPriority{"has_part"}             = 2;
$transitivityPriority{"part_of"}              = 3;
$transitivityPriority{"regulates"}            = 4;
$transitivityPriority{"negatively_regulates"} = 5;
$transitivityPriority{"positively_regulates"} = 6;
$transitivityPriority{"occurs_in"}            = 7;
$transitivityPriority{"capable_of"}           = 8;
$transitivityPriority{"has_function_in"}      = 9;

has 'term_type' => (
    is => 'rw',
);

1;

sub error {
  return 0;
}

sub message {
  return { msg=>shift, redirect=>shift};
}

=head2 SUB index
  Usage    - 
  Returns  - treeExpand # pass the expandable tree through catalyst for view
  Args     -
  Function - Display 'expandable trees' (Tools->Ontologies). One tree
             for each ontology.
=cut
  # index.tt2 shows the expandable tree on the ontology_browser url (under tools)
  # expandable tree has the root terms for each category, and 
  # expandable links to toggle display of that term's children, as 
  # well as relationship to direct parent.  because ontology is a dag, 
  # a term may appear at multiple nodes.  if there are too many non-
  # transitive children the expand link will be a ? link because it's 
  # unknown if there are children
  # Due to the way that the solr server is indexed, querying for the 
  # number of transitive children is cheap, whereas querying for the 
  # number of non-transitive children is costly.
sub index {
  my ($self) = @_;
  my @rootTerms = qw( GO:0008150 GO:0005575 GO:0003674 WBbt:0000100 DOID:4 WBls:0000075 WBPhenotype:0000886 );
											# by default have the 7 main roots
  my @ontologyCategories = qw( go anatomy humdis lifestage phenotype );			# each of these map to a different WormBase subdirectory
  my %ontologyCategories = (								# root terms in each category
        "go"         => [ "GO:0008150", "GO:0005575", "GO:0003674" ],
        "anatomy"    => [ "WBbt:0000100" ],
        "humdis"     => [ "DOID:4" ],
        "lifestage"  => [ "WBls:0000075" ],
        "phenotype"  => [ "WBPhenotype:0000886" ],
     );
  my %categoryLabel;									# labels for the category
  $categoryLabel{"go"}        = "Gene Ontology";
  $categoryLabel{"anatomy"}   = "Anatomy Ontology";
  $categoryLabel{"humdis"}    = "Human Disease Ontology";
  $categoryLabel{"lifestage"} = "Life Stage Ontology";
  $categoryLabel{"phenotype"} = "Phenotype Ontology";

  my %names; my %hasChildren;								# for root terms, their name and whether they have children
  foreach my $category (@ontologyCategories) {						# for every category
    foreach my $termId (@{ $ontologyCategories{$category} }) {				# for every root term in that category
      my ($topoHashref, $transHashref) = &getTopoHash($termId);				# given a termId, get the topology_graph_json and regulates_transitivity_graph_json
      my %topo  = %$topoHashref;
      my %trans = %$transHashref;
      my ($childrenHashref, $parentsHashref) = &getTopoChildrenParents($termId, $topoHashref);
											# get children and parent relationships to term from topology_graph_json
      my %children = %$childrenHashref;
      if (scalar keys %children > 0) { $hasChildren{$termId}++; }			# if term has children, track it
      my (@nodes) = @{ $topo{"nodes"} };						# use topology_graph_json nodes to add sibling termId labels to %names
      for my $index (0 .. @nodes) {
        my ($id, $lbl) = ('', '');
        if ($nodes[$index]{'id'})  { $id  = $nodes[$index]{'id'};  }
        if ($nodes[$index]{'lbl'}) { $lbl = $nodes[$index]{'lbl'}; }
        $names{$id} = $lbl; }								# map id to label for names
    } # foreach my $termId (@{ $ontologyCategories{$category} })
  } # foreach my $termId (@rootTerms)

  my $treeExpand = '';									# the html for the expandable tree
  my $highestNodeCount = 0;								# count of nodes in the expandable tree.  each node must have a unique ID because the ontology term may appear several times in the expandable tree. e.g. GO:0008150 is parent to GO:0050789 directly as well as parent to GO:0065007, which is also parent to GO:0050789
  foreach my $category (@ontologyCategories) {						# for each category
    $treeExpand.= qq(<br/><h2>$categoryLabel{$category}</h2>\n);			# add h2 header of the category
    foreach my $rootTerm (@{ $ontologyCategories{$category} }) {			# for each root term under the category
      $highestNodeCount++;								# add one more node
      my $expand_link = qq(<span style="border:solid 1px black; cursor: pointer;" id="toggle_${highestNodeCount}_$rootTerm" onclick="togglePlusMinus('toggle_${highestNodeCount}_$rootTerm'); expandTermId('$rootTerm', '$highestNodeCount');" >&nbsp;+&nbsp;</span>);  
											# span link to expand node with expandTermId, which will call &query_children
      unless ($hasChildren{$rootTerm}) { $expand_link = ''; }				# if there are no children, no expand link
      my ($class) = &getClassFromId($rootTerm);						# get the object class based on the termId
      my ($url)   = '/tools/ontology_browser/run?inline=1&class=' . $class . '&name=' . $rootTerm . '&linkTarget=_blank';
          										# the url to the term display, links to objects should open in new target from ontology browser page
      my $escaped_name = $names{$rootTerm}; $escaped_name =~ s/\'/&rsquo;/g;
      my $load_widget_link = qq(<a href="#o_browser" id="load_$rootTerm" onclick="document.getElementById('o_browser').innerHTML = 'loading $rootTerm $escaped_name'; \$('#o_browser').load('$url');">$escaped_name ($rootTerm)</a>);
#       my $load_widget_link = qq(<a href="#o_browser" id="load_$rootTerm" onclick="document.getElementById('o_browser').innerHTML = 'loading $rootTerm $names{$rootTerm}'; \$('#o_browser').load('$url');">$names{"$rootTerm"} ($rootTerm)</a>);
          										# a link to load node into the o_browser div by doing a jquery load
      $treeExpand .= qq(<ul><li id="$rootTerm">$expand_link $load_widget_link);		# start an unordered list with only element the rootTerm and links to expand and load term info
      $treeExpand .= qq(<ul id="children_${highestNodeCount}_$rootTerm" style="display: none">);
											# add within another unordered list for the children of this rootTerm, hide by default because clicking to query and load its values will toggle its show/hide state
      $treeExpand .= qq(<li><input id="notQueried_${highestNodeCount}_$rootTerm" value="loading"></li></ul>);
											# add a list item to the list and an input element to state that this rootTerm has not been queried before
      $treeExpand .= qq(</li></ul>\n);							# close the root unordered list and list item
    } # foreach my $rootTerm (@{ $ontologyCategories{$category} })
  } # foreach my $category (@ontologyCategories)
  $treeExpand .= qq(<input type="hidden" id="highestNodeCount" value="$highestNodeCount">\n);
											# highest existing node amount, when creating a new node javascript expandTermId will remove this and &query_children will create a replacement element

  return { treeExpand => $treeExpand,							# pass the expandable tree through catalyst for view
  };
} # sub index

=head2 SUB query_children
  Usage    - 
  Returns  -
  Args     -
  Function - Find children of term
=cut
  # query_children.tt2 displays the children of a term in the expandable tree
  # index.tt2 has javascript that when expandTermId, will query for children to load into expandable tree, replacing html element children_${highestNodeCount}_$child stub.  gets topology_graph_json for term to expand, shows alphabetically (case-insensitive) all the children.  If the children are known to have grandchildren through regulates, they also get an expand link.  If fewer than an arbitrary amount are non-regulates, they each get queried to have an expand link or not ; if too many a question-mark link to expand is shown.
sub query_children {
    my ($self,$param) = @_;
    my $termId = $param->{termId};							# get the termId from the URL
    my ($class) = &getClassFromId($termId);						# get the object class based on the termId
    my $highestNodeCount = $param->{highestNodeCount};					# the same termId can exist at multiple nodes in the tree because the data is a dag, so the html id of the node has a node count as well as the termId
    my %hash;                                     					# for a child :  relationship is the termId's relationship to the original termId ; name is the termId's name ; hasChildren is a flag if the child is itself a parent of other termId ; maybeHasChildren is a flag for when a child does not regulate closure, so we don't know whether it has children
   
    my ($topoHashref, $transHashref) = &getTopoHash($termId);				# get the topology_graph_json and regulates_transitivity_graph_json with a solr query
    my %topo = %$topoHashref;								# get the hash data from the topology_graph_json
    my ($childrenHashref, $parentsHashref) = &getTopoChildrenParents($termId, $topoHashref);
											# get children and parent relationships to termId from topology_graph_json
    my %children = %$childrenHashref;
    my (@nodes) = @{ $topo{"nodes"} };							# use topology_graph_json nodes to add sibling termId labels to %hash -> $id -> name
    for my $index (0 .. @nodes) {
      my ($id, $lbl) = ('', '');
      if ($nodes[$index]{'id'})  { $id  = $nodes[$index]{'id'};  }
      if ($nodes[$index]{'lbl'}) { $lbl = $nodes[$index]{'lbl'}; }
      next unless ($children{$id});               					# only get names of ids that are children of main term
      $hash{$id}{name} = $lbl; }							# store label for that id
   
    my $termRegulatesClosure_href = &getFacetCountsHash($termId);			# solr query to get terms that regulate closure.  these are known to have children through regulates_closure, but absence here does not mean lack of children (through daughter_of or preceded_by)
    my %termRegulatesClosure      = %$termRegulatesClosure_href;
    my %mayHaveNonRegulatesChild;							# children terms that do not regulate closure may or may not have children
    foreach my $child (sort keys %children) {						# for each child get their relationship from %children and whether they do/may have children
      if ($termRegulatesClosure{$child}) { $hash{$child}{hasChildren}++; }
        else { $mayHaveNonRegulatesChild{$child}++; }
      $hash{$child}{relationship} = $children{$child}; }
    my $arbitraryAmountOfNonRegulateChildrenToCheckForChildrenForExpandLink = 40;	# if less than this amount of non-regulate children, query them one by one.  arbitrary amount for reasonable loading time, since most terms should have fewer than this amount
    if (scalar keys %mayHaveNonRegulatesChild <= $arbitraryAmountOfNonRegulateChildrenToCheckForChildrenForExpandLink) {
        foreach my $child (sort keys %mayHaveNonRegulatesChild) {     			# for each child get their name from %children and whether they have children from solr
          my ($topoChildHashref, $transChildHashref)       = &getTopoHash($child);	# get topology from solr
          my ($childChildrenHashref, $childParentsHashref) = &getTopoChildrenParents($child, $topoChildHashref);
											# get children and parents of each child from topology_graph_json
          my %grandchildren = %$childChildrenHashref;
          if (scalar keys %grandchildren > 0) { $hash{$child}{hasChildren}++; } } }	# if there are grandchildren, the child itself hasChildren
      else {										# if there are too may children that are not regulates, mark them as maybeHasChildren in %hash -> id
        foreach my $child (sort keys %mayHaveNonRegulatesChild) {
          $hash{$child}{maybeHasChildren}++; } }
   
    my $childElement = '';
    foreach my $child (sort { lc($hash{$a}{name}) cmp lc($hash{$b}{name}) } keys %hash) {         # for each child sorted alphabetically case-insensitive
      $highestNodeCount++;								# add to counter of nodes that exist
         # the html span to expand the children of each term.  no expand link is a literal space, but put in a span so it lines up with others, use inline-block + width to keep uniform.  the html element id is 'toggle_' + nodecounter + '_' + childId
      my $expand_link = qq(<span style="border:solid 1px white; cursor: pointer; width: 18px; display: inline-block;" id="toggle_${highestNodeCount}_$child">&nbsp;</span>);
      if ($hash{$child}{hasChildren}) {							# if the child positively has children, create a togglePlusMinus link to expand and get its children
          $expand_link = qq(<span style="border:solid 1px black; cursor: pointer; width: 18px; display: inline-block;" id="toggle_${highestNodeCount}_$child" onclick="togglePlusMinus('toggle_${highestNodeCount}_$child'); expandTermId('$child', '$highestNodeCount');" >&nbsp;+&nbsp;</span>); }
        elsif ($hash{$child}{maybeHasChildren}) {					# if the child may have children, create a toggleQuestionMinus link to expand and get its children
          $expand_link = qq(<span style="border:solid 1px black; cursor: pointer; width: 18px; display: inline-block;" id="toggle_${highestNodeCount}_$child" onclick="toggleQuestionMinus('toggle_${highestNodeCount}_$child'); expandTermId('$child', '$highestNodeCount');" >&nbsp;<span style="font-size: 8pt">?</span>&nbsp;</span>); }
      $childElement .= qq(<li>$expand_link );						# add to the childElement an html list item with the link to expand
      my ($relationship) = &convertRelationshipToImage($hash{$child}{relationship});	# if the relationship has an image, map to an html img element
      $childElement .= qq($relationship);						# add to the childElement the relationship
      my ($url) = '/tools/ontology_browser/run?inline=1&class=' . $class . '&name=' . $child . '&linkTarget=_blank';
          										# the url to the term display, links to objects should open in new target from ontology browser page
      my $escaped_name = $hash{$child}{name}; $escaped_name =~ s/\'/&rsquo;/g;
      my $load_widget_link = qq(<a href="#o_browser" id="load_$child" onclick="document.getElementById('o_browser').innerHTML = 'loading $child $escaped_name'; \$('#o_browser').load('$url');">$escaped_name ($child)</a>);  
#       my $load_widget_link = qq(<a href="#o_browser" id="load_$child" onclick="document.getElementById('o_browser').innerHTML = 'loading $child $hash{$child}{name}'; \$('#o_browser').load('$url');">$hash{$child}{name} ($child)</a>);  
          										# a link to load node into the o_browser div by doing a jquery load
      $childElement .= qq($load_widget_link);						# add to the childElement links to display the child terms
      $childElement .= qq(<ul id="children_${highestNodeCount}_$child" style="display: none">);
          										# add to the childElement another unordered list to store the child's children and hide it by default.  when expandTermId triggers for this child, this element is replaced by data for this child from its corresponding &query_children
      $childElement .= qq(<li><input id="notQueried_${highestNodeCount}_$child" value="loading"></li></ul></li>);
          										# add to the childElement a list item to the list and an input element to state that this termId has not been queried before.  used by javascript expandTermId to do a query if needed, and just toggle display if not needed
    } # foreach my $child (sort keys %hash)
    unless ($childElement) { $childElement = qq(<li><span style="color: red">$termId has no children</span></li>); }
          										# if there were no children and an expand link was added for all children of a term without checking it had a child (because it would take too long to query so many of them), display that it has no children
    $childElement .= qq(<input type="hidden" id="highestNodeCount" value="$highestNodeCount">\n);
          										# add to the childElement the highestNodeCount, expandTermId will have already removed the previous html element highestNodeCount
    return { childElement => $childElement,						# pass the childElement through catalyst for view
    }
} # sub query_children

=head2 SUB show_genes
  Usage    - 
  Returns  - geneLists     # pass the geneLists through catalyst for view
             focusTermName # pass the focusTermName through catalyst for view
             focusTermId   # pass the focusTermId through catalyst for view
  Args     -
  Function - Find genes associated with term.
=cut
  # show_genes.tt2  shows lists of genes associated with a term
  # inferred tree has counts of gene products, which are a link to show all the genes related to the term in a new tab.  lists C. elegans / non-C. elegans directly annotated to the term, and annotated directly or with any transitive descendant terms
sub show_genes {
    my ($self,$param) = @_;
    my $focusTermId   = $param->{focusTermId};						# get the focusTermId from the URL
    my $focusTermName = $param->{focusTermName};					# get the focusTermName from the URL
    my ($class) = &getClassFromId($focusTermId);					# get the object class based on the termId
    my %url;										# hash of URLs for different solr queries depending on class
    my %returnData;									# gene lists to pass through catalyst stored here
    my ($solr_url) = &getSolrUrl($focusTermId);						# get the solr URL given a termId
   
    if ($class eq 'go_term') {								# go_term gets direct C. elegans, direct non-C. elegans, inferred + direct C. elegans, inferred + direct non-C. elegans
        $url{"direct_cele"}    = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=taxon:NCBITaxon\:6239&fq=annotation_class:%22' . $focusTermId . '%22'; 
        $url{"direct_noncele"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=taxon%20asc&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=-taxon:NCBITaxon\:6239&fq=annotation_class:%22' . $focusTermId . '%22';
        $url{"infDir_cele"}    = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=taxon:NCBITaxon\:6239&fq=regulates_closure:%22' . $focusTermId . '%22';
        $url{"infDir_noncele"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=taxon%20asc&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=-taxon:NCBITaxon\:6239&fq=regulates_closure:%22' . $focusTermId . '%22';
      }
      elsif ($class eq 'phenotype') {			# phenotype gets direct rnai, direct variation, direct + inferred rnai, direct + inferred variation
        $url{"direct_rnai"}      = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=evidence_type:RNAi&fq=annotation_class:%22' . $focusTermId . '%22';
        $url{"direct_variation"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=evidence_type:Variation&fq=annotation_class:%22' . $focusTermId . '%22';
        $url{"infDir_rnai"}      = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=evidence_type:RNAi&fq=regulates_closure:%22' . $focusTermId . '%22';
        $url{"infDir_variation"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=evidence_type:Variation&fq=regulates_closure:%22' . $focusTermId . '%22';
      }
      else {						# all other classes get direct, inferred + direct
        $url{"direct"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=annotation_class:%22' . $focusTermId . '%22';
        $url{"infDir"} = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=bioentity,bioentity_label&start=0&rows=10000000&q=document_category:annotation&sort=bioentity%20asc&group=true&group.field=bioentity&group.ngroups=true&group.format=simple&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=regulates_closure:%22' . $focusTermId . '%22';
      }

    foreach my $type (sort keys %url) {			# for each type of URL for the term's class
      my $url = $url{$type};
      my $page = get $url; my @genes;			# get the URL
      my $ngroups = 0; if ($page =~ m/"ngroups":(\d+),/) { $ngroups = $1; }
							# get the ngroups if it exists
      my $gene_list = '';
      my $perl_scalar = $json->decode( $page );		# get the solr data
      my %jsonHash = %$perl_scalar;			# decode the solr page into a hash
      foreach my $hashRef (@{ $jsonHash{"grouped"}{"bioentity"}{"doclist"}{"docs"} }) {
							# look at each element in this JSON structure
        my $id   = $$hashRef{'bioentity'};		# get the gene ID
        my $name = $$hashRef{'bioentity_label'};	# get the gene name
        if ($id =~ m/^WB:/) { $id =~ s/^WB://; }	# strip out the extra leading WB: from the gene ID
        my $url = '/species/c_elegans/gene/' . $name;	# link to the gene with the WormBase URL.  this may not be the correct link, but redirects okay
        $gene_list .= qq(<a href="$url">$name</a><br/>\n);
							# add to the gene list links to the WBGene name
      }

	# depending on the type of data, structure the sentences to describe it
      $returnData{$type} .= qq(List of $ngroups);
      if ( $type =~ m/_cele$/ ) {          $returnData{$type} .= qq( C. elegans); }
        elsif ($type =~ m/_noncele$/)  {   $returnData{$type} .= qq( non C. elegans); }
      $returnData{$type} .= qq( genes that were annotated with $focusTermId $focusTermName); 
      if ($type =~ m/^infDir/) {           $returnData{$type} .= qq( or any of its transitive descendant terms); }
      if ($type =~ m/_rnai$/) {            $returnData{$type} .= qq( via RNAi); }
        elsif ($type =~ m/_variation$/) {  $returnData{$type} .= qq( via Variation); }
      $returnData{$type} .= qq(<br/>\n$gene_list); 	# add the gene list of URL links after the description
    } # foreach my $type (sort keys %url)

    my @sortPriority = qw( direct infDir direct_cele infDir_cele direct_noncele infDir_noncele direct_rnai direct_variation infDir_rnai infDir_variation );
							# lists are sorted by this priority
    my @geneLists = ();
    foreach (@sortPriority) { if ($returnData{$_}) { push @geneLists, $returnData{$_}; } }
							# in order of sort priority, if there is data add to gene list
    return { 
             geneLists     => \@geneLists,		# pass the geneLists through catalyst for view
             focusTermName => $focusTermName,		# pass the focusTermName through catalyst for view
             focusTermId   => $focusTermId,		# pass the focusTermId through catalyst for view
    };
} # sub show_genes
 
=head2 SUB run
  Usage    - 
  Returns  - svg_markup         # pass the svg_markup through catalyst for view
	     svg_legend_markup  # pass the svg_legend_markup through catalyst for view
	     parent_table       # pass the parent_table through catalyst for view
	     inferred_tree_view # pass the inferred_tree_view through catalyst for view
  Args     -
  Function - Display term info
=cut
  # run.tt2 shows the main view for a termId : the inferred tree view, svg markup, svg legend, parent table.  
sub run {
    my ($self,$param) = @_;
    my $class       = lc($param->{class});				# get the class
    my $focusTermId = $param->{name};					# get the focusTermId
    my $linkTarget  = $param->{linkTarget} || '_self';			# get whether clicking a link should open in new tab

    my ($topoHashref, $transHashref) = &getTopoHash($focusTermId);	# get the topology_graph_json and regulates_transitivity_graph_json with a solr query
    my %topo  = %$topoHashref;						# get topology_graph_json
    my %trans = %$transHashref;						# get regulates_transitivity_graph_json
   
    my $gviz        = GraphViz->new(concentrate => 'concentrate');	# generate graphviz for main markup
    my $gviz_legend = GraphViz->new(concentrate => 'concentrate', rankdir  => 'BT');	# generate graphviz for legend
    
    my ($childrenHashref, $parentsHashref) = &getTopoChildrenParents($focusTermId, $topoHashref);
									# get children and parent relationships to focusTermId from topology_graph_json
    my %children = %$childrenHashref;					# children relationships to focusTermId
    my %parents  = %$parentsHashref;					# parent relationships to focusTermId
   
    my %colorMap;							# colours to use for each relationship in graph
    $colorMap{is_a}                              = 'black';
    $colorMap{part_of}                           = 'blue';
    $colorMap{has_part}                          = 'purple';
    $colorMap{preceded_by}                       = 'purple';
    $colorMap{regulates}                         = 'orange';
    $colorMap{positively_regulates}              = 'green';
    $colorMap{negatively_regulates}              = 'red';
    $colorMap{occurs_in}                         = '#006699';
    $colorMap{child_nucleus_of}                  = 'pink';
    $colorMap{child_nucleus_of_in_hermaphrodite} = 'pink';
    $colorMap{child_nucleus_of_in_male}          = 'pink';
    $colorMap{union_of}                          = 'brown';
    $colorMap{develops_from}                     = 'brown';
    $colorMap{exclusive_union_of}                = 'brown';
    my %edgeTypeExists;							# track which relationships exist, to show in legend
   
    my (@edges) = @{ $topo{"edges"} };					# get edges from topology_graph_json
    for my $index (0 .. @edges) {					# for each edge, add to graph
      my ($sub, $obj, $pred) = ('', '', '');				# subject object predicate from topology_graph_json
      if ($edges[$index]{'sub'}) {  $sub  = $edges[$index]{'sub'};  }
      if ($edges[$index]{'obj'}) {  $obj  = $edges[$index]{'obj'};  }
      if ($edges[$index]{'pred'}) { $pred = $edges[$index]{'pred'}; }
      my $direction = 'back'; my $style = 'solid';			# graph arror direction and style
      if ($pred eq 'has_part') { $style = 'dashed'; }			# has_part is dashed
      if ($sub && $obj && $pred) {					# if subject + object + predicate
        if ($children{$sub}) { next; }    				# don't add edge for the children of focusTermId
        if ($pred =~ m/ /) { $pred =~ s/ /_/g; }			# in relationships, replace all spaces with underscores for GO and 'preceded by'
        my $color = 'black'; if ($colorMap{$pred}) { $color = $colorMap{$pred}; $edgeTypeExists{$pred}++; }
									# default colour black, get specific colour to override, add relationship for legend
        $paths{"childToParent"}{"$sub"}{"$obj"} = $pred;		# put all parent nodes under child node
        $sub =~ s/:/_placeholderColon_/g;				# edges won't have proper title text if ids have : in them
        $obj =~ s/:/_placeholderColon_/g;				# edges won't have proper title text if ids have : in them
        $gviz->add_edge("$obj" => "$sub", dir => "$direction", color => "$color", fontcolor => "$color", style => "$style");
									# add edge to graph
      } # if ($sub && $obj && $pred)
    } # for my $index (0 .. @edges)
   
    my %label;                            				# id to name
    my (@nodes) = @{ $topo{"nodes"} };					# get nodes from topology_graph_json
    for my $index (0 .. @nodes) {					# for each node, add to graph
      my ($id, $lbl) = ('', '');					# id and label
      if ($nodes[$index]{'id'}) {  $id  = $nodes[$index]{'id'};  }
      if ($nodes[$index]{'lbl'}) { $lbl = $nodes[$index]{'lbl'}; }
      $label{$id} = $lbl;						# map id to label
      if ($children{$id}) { next; }					# don't add node for the children
      my $url = "/species/all/$class/$id";				# URL to link to wormbase page for object
      if ($class eq 'disease') { $url = "/resources/$class/$id"; }	# URL to link to wormbase page for disease class
      $lbl =~ s/ /\\n/g;						# replace spaces with linebreaks in graph for more-square boxes
      my $label = "$id\n$lbl";						# node label should have full id, not stripped of :, which is required for edge title text
      $id =~ s/:/_placeholderColon_/g;					# edges won't have proper title text if ids have : in them
      if ($id && $lbl) { $gviz->add_node("$id", label => "$label", shape => "box", fontsize => "10", color => "red", URL => "$url"); }
									# add node to graph
    }
   
    foreach my $pred (sort keys %edgeTypeExists) {			# for each relationship that exists in the graph
      my $color = $colorMap{$pred};					# get the colour, add sample nodes and edge to legend
      $gviz_legend->add_node("A_$pred", label => "A", shape => "box", fontsize => "10", color => "red");
      $gviz_legend->add_node("B_$pred", label => "B", shape => "box", fontsize => "10", color => "red");
      $gviz_legend->add_edge("A_$pred" => "B_$pred", label => "$pred", color => "$color", fontsize => "10", fontcolor => "black");
    }
   
    my $svgGenerated = $gviz->as_svg;					# generate graph as svg
    my ($svgMarkup) = $svgGenerated =~ m/(<svg.*<\/svg>)/s;		# capture svg markup
    $svgMarkup =~ s/<title>test<\/title>//g;				# remove automatic title
    $svgMarkup =~ s/_placeholderColon_/:/g;				# ids can't be created with a : in them, so have to add the : after the svg is generated
   
      # make a legend using graphViz, it's kind of bulky
    my $svgLegendGenerated = $gviz_legend->as_svg;			# generate legend as svg
    my ($svgLegendMarkup) = $svgLegendGenerated =~ m/(<svg.*<\/svg>)/s;	# capture svg markup
    $svgLegendMarkup =~ s/<title>test<\/title>//g;			# remove automatic title
   
    my $parentTable = '';						# table of focus term parents, expandable to show focus term sibblings
    if (scalar keys %parents > 0) {					# if focus term has any parents
      $parentTable .= qq(List of Parallel Terms by Branch : \n);	# table description
      foreach my $parent (sort keys %parents) {				# for all parents of the focus term
        my $relationship = $parents{$parent};				# relationship to parent
        my $name = $label{$parent};					# parent term name
        my ($link_parent) = &makeObjectLink($class, $parent, $parent, $linkTarget, '');
									# make html link to WormBase for parent object id
        my ($link_name)   = &makeObjectLink($class, $parent, $name, $linkTarget, '');
									# make html link to WormBase for parent object name
        my $siblingsLink = qq(<span id="span_plusMinus_$parent" style="border:solid 1px black; cursor: pointer;" onclick="togglePlusMinus('span_plusMinus_$parent'); toggleShowHide('table_siblings_$parent');">&nbsp;+&nbsp;</span>);
									# html span with plus/minus toggle to show/hide children terms of parent term
        $parentTable .= qq(<br/>$siblingsLink $link_parent $link_name);	# add expand span, and link to parent id and name
        my ($topoHashref, $transHashref) = &getTopoHash($parent);	# get the topology_graph_json and regulates_transitivity_graph_json with a solr query
        my %topo  = %$topoHashref;
   
        my (@nodes) = @{ $topo{"nodes"} };		                # use nodes from topology_graph_json to add to %label the labels of sibling terms of focusTermId 
        for my $index (0 .. @nodes) {
          my ($id, $lbl) = ('', '');
          if ($nodes[$index]{'id'})  { $id  = $nodes[$index]{'id'};  }	# get the id from topology_graph_json
          if ($nodes[$index]{'lbl'}) { $lbl = $nodes[$index]{'lbl'}; }	# get the lbl from topology_graph_json
          $label{$id} = $lbl; }						# add mapping of id to lbl to %label
   
        my ($siblingsHashref, $grandparentsHashref) = &getTopoChildrenParents($parent, $topoHashref);
									# get children and parent relationships to parent term from topology_graph_json
        my %siblings = %$siblingsHashref;
        my @siblingRows = ();
        foreach my $sibling (sort keys %siblings) {			# for all children of this parent (including focus term)
#           next if ($sibling eq $focusTermId);				# raymond wants the focus term to show among sibblings now 2014 01 10
          my $sib_rel = $siblings{$sibling};				# get relationship to sibling term
          my $name    = $label{$sibling};				# get name of sibling term
          my ($link_sibling) = &makeObjectLink($class, $sibling, $sibling, $linkTarget, '');
									# make html link to WormBase sibling object id
          my ($link_name)    = &makeObjectLink($class, $sibling, $name, $linkTarget, '');	# make html link to WormBase sibling object name
          push @siblingRows, qq(<tr><td width="30"></td><td>$sib_rel</td><td>$link_sibling</td><td>$link_name</tr>);
									# add to table a row for sibling relationship, term id, term name
        }
        if (scalar @siblingRows > 0) {					# if there were any sibling terms, put in a table that is hidden by default
          $parentTable .= qq(<table id="table_siblings_$parent" style="display: none">);
          foreach my $siblingRow (@siblingRows) { $parentTable .= $siblingRow; }
          $parentTable .= qq(</table>); }
      } # foreach my $parent (sort keys %parents)
    }

#     my $childTable = ''; 						# a table of all children of focusTerm, removed because already in expandable tree
#       $childTable .= "children : <br/>\n";
#       $childTable .= qq(<table border="1"><tr><th>relationship</th><th>id</th><th>name</th></tr>\n);
#       foreach my $child (sort keys %children) {
#         my $relationship = $children{$child};
#         my ($link_child) = &makeObjectLink($class, $child, $child, $linkTarget, '');
# 									# make html link to WormBase child object id
#         my $child_name = $label{$child};
#         my ($link_childname) = &makeObjectLink($class, $child, $child_name, $linkTarget, '');
# 									# make html link to WormBase child object name
#         $childTable .= qq(<tr><td>$relationship</td><td>$link_child</td><td>$link_childname</td></tr>\n);
#       } # foreach my $child (sort keys %children)
#       $childTable .= qq(</table>\n);
# #   to display children table, return $childTable

=head2 Transitivity
Inferred tree view includes, top-down, transitive ancestors (including 
transitive parents), focus term, and children (may be of any direct 
relationship to the focus term). Nodes in 
regulates_transitivity_graph_json are the same terms as those in 
"regulates_closure", ie, transitive ancestors and the focus term. 
Children terms are not included here.
=cut
    my %ancestors;                        				# ancestors are nodes in regulates_transitivity_graph_json that are neither the focus term nor its children
    my (@tnodes) = @{ $trans{"nodes"} };  				# for inferred tree view, use nodes from transitivity instead of topology
    for my $index (0 .. @tnodes) {
      my ($id, $lbl) = ('', '');
      if ($tnodes[$index]{'id'}) { $id = $tnodes[$index]{'id'}; }	# get the id field from the node -- RAYMOND, I'm not clear on how this works, what's on regulates_transitivity_graph_json that makes it that the ID field gives us ancestors ?  It's just the ancestor to focus terms in there ?
      next unless $id;							# skip if no id
      unless ($id eq $focusTermId) { $ancestors{$id}++; }		# ancestors are nodes that are neither the GOID nor its children
    }

    my %inferredTree;             					# sort nodes by depth of steps (longest path)
    my $max_indent = 0;           					# how many steps is the longest path, will indent that much
#     my $ancestorTable = '';						# ancestor table not needed because data in inferred tree
#     $ancestorTable .= "ancestors : <br/>\n";
#     $ancestorTable .= qq(<table border="1"><tr><th>steps</th><th>relationship</th><th>id</th><th>name</th></tr>\n);
    foreach my $ancestor (sort keys %ancestors) {
      my $ancestor_name = $label{$ancestor};				# get label of ancestor term
      my ($link_ancestor)     = &makeObjectLink($class, $ancestor, $ancestor, $linkTarget, '');
									# make html link to WormBase ancestor object id
      my ($link_ancestorname) = &makeObjectLink($class, $ancestor, $ancestor_name, $linkTarget, '');
									# make html link to WormBase ancestor object name
      my ($max_steps, $relationship) = &getLongestPathAndTransitivity( $ancestor, $focusTermId );
									# given focusTermId and ancestor, get the longest path and dominant inferred transitivity
      next unless $relationship;					# skip if there is no relationship based on transitivity rules
      my $indentation = $max_steps - 1; 				# indentation is one less than the maximum steps (to make 1 step have no indentation)
      if ($indentation > $max_indent) { $max_indent = $indentation; }	# if current indentation is greater than maximum, update maximum indentation
      ($relationship) = &convertRelationshipToImage($relationship);	# if the relationship has an image, map to an html img element
      $inferredTree{$indentation}{qq($relationship : $link_ancestor $link_ancestorname)}++;
									# add to inferred tree hash sorting by indentation
#       $ancestorTable .= qq(<tr><td>$max_steps</td><td>$relationship</td><td>$link_ancestor</td><td>$link_ancestorname</td></tr>\n);
    } # foreach my $ancestor (sort keys %ancestors)
   
#     $ancestorTable .= qq(</table>\n);
# to display ancestor table, return $ancestorTable

    my $inferredTreeView = '';						# html for the inferred tree view
    my $spacer = '&nbsp;&nbsp;&nbsp;';					# amount of html non-breaking spaces that make up one level of indentation
    foreach my $depth (reverse sort {$a<=>$b} keys %inferredTree) {	# sort data for inferred tree by ascending depth of indentation
      foreach my $row (sort keys %{ $inferredTree{$depth} }) {		# for all rows of data at that depth level
        my $indentation = $max_indent - $depth;				# indentation is max indent minux depth
        for (1 .. $indentation) { $inferredTreeView .= $spacer; }	# for each indentation print a spacer
        $inferredTreeView .= qq($row<br/>\n); } }			# print the data row
    for (1 .. $max_indent) { $inferredTreeView .= $spacer; }		# add indentation for main term
    my %inferredGenesCount; my %directGenesCount;			# count of inferred genes and count of direct genes
    my ($inferredGenesCountHashref, $directGenesCountHashref) = &getGenesCountHash($focusTermId);       
									# for a focusTermId, get mapping of it + children terms to count of genes, direct and inferred
    %inferredGenesCount = %$inferredGenesCountHashref;
    %directGenesCount   = %$directGenesCountHashref;
   
    my $inferredLink       = &makeGenesLink($focusTermId, $label{$focusTermId}, $inferredGenesCount{$focusTermId}, $directGenesCount{$focusTermId});
		           						# if there's at least one inferred gene, create a link to show the genes
    my $link_focusTerm     = &makeObjectLink($class, $focusTermId, $focusTermId, $linkTarget, 'green');
									# make html link to WormBase focus term object id, green colour
    my $link_focusTermName = &makeObjectLink($class, $focusTermId, $label{$focusTermId}, $linkTarget, 'green');
									# make html link to WormBase focus term object name, green colour
    $inferredTreeView .= qq($spacer<span style="color:green">$link_focusTermName ($link_focusTerm)</span> [${inferredLink}]<br/>\n);
									# add data for main term

    my $tooManyNonTransitiveChildrenCutoff = 20; 			# how many non-transitive children are too many to query individually
    my $amountNonTransitiveChildren        = 0;				# amount of non-transitive children
    my $checkNonTransitiveFlag             = 0; 			# if amount of non-transitive children is below threshold, set this flag
    foreach my $child (sort keys %children) {				# for each child, check how many are non-transitive
      my $relationship = $children{$child};				# get relationship to child
      unless ($transitivityPriority{$relationship}) {			# if relationship is not in transitive whitelist
        $amountNonTransitiveChildren++; } }				# add to count of non-transitive children
    if ($amountNonTransitiveChildren <= $tooManyNonTransitiveChildrenCutoff) { 
      $checkNonTransitiveFlag = 1; }					# less non-transitive children than threshold, it is okay to check each of them for counts
      
   
    foreach my $child (sort { lc($label{$a}) cmp lc($label{$b}) } keys %children) {
									# for each child, sort by alphabetical name from %label
      my $directGenesCount = 0; my $inferredGenesCount = 0;		# initialize direct and inferred counts to zero
      my $link_to_show_genes = '';					# the html to link to the list of genes for the term
      my $relationship = $children{$child};				# child relationship to main term
      my ($relationshipImg) = &convertRelationshipToImage($relationship);	
									# if the relationship has an image, map to an html img element
      if ($transitivityPriority{$relationship}) { 			# relationship is transitive, get direct and inferred counts from hash
          $inferredGenesCount = $inferredGenesCount{$child};	
          $directGenesCount   = $directGenesCount{$child};   }
        elsif ($checkNonTransitiveFlag) {				# if there are few enough non-transitive relationships, get their counts with solr query
          $inferredGenesCount = &getDirectInferredGenesCount($child, 'inferred');
          $directGenesCount   = &getDirectInferredGenesCount($child, 'direct'); }
        else { 								# too many non-transitive terms, show ? link
          ($link_to_show_genes) = &makeObjectLink($class, $child, '[? gene products]', $linkTarget, ''); }
									# make html link to WormBase child object id with unknown amount of gene products
      my $inferredLink = &makeGenesLink($child, $label{$child}, $inferredGenesCount, $directGenesCount);
									# if there's at least one inferred gene, create a link to show the genes
      my ($link_child)     = &makeObjectLink($class, $child, $child, $linkTarget, '');
									# make link to WormBase child object id
      my $child_name       = $label{$child};				# get name of child term
      my ($link_childname) = &makeObjectLink($class, $child, $child_name, $linkTarget, '');
									# make html link to WormBase child object name
      unless ($link_to_show_genes) {					# either transitive term, or few enough non-transitive children, make link
        $link_to_show_genes = qq(($link_child) [${inferredLink}]); }
      for (1 .. $max_indent) { $inferredTreeView .= $spacer; }		# add indentation for children term
      $inferredTreeView .= $spacer . $spacer . qq($relationshipImg $link_childname $link_to_show_genes<br/>\n);
									# add data for child term
    } # foreach my $child (sort keys %children)
   
    return {
	     svg_markup         => $svgMarkup,				# pass the svg_markup through catalyst for view
	     svg_legend_markup  => $svgLegendMarkup,			# pass the svg_legend_markup through catalyst for view
	     parent_table       => $parentTable,			# pass the parent_table through catalyst for view
	     inferred_tree_view => $inferredTreeView,			# pass the inferred_tree_view through catalyst for view
    };
} # sub run

=head2 SUB convertRelationshipToImage
  Usage    - 
  Returns  - $relationship
  Args     -
  Function - Map relationship to an html img element.
=cut
sub convertRelationshipToImage {	# if the relationship has an image, map to an html img element
  my ($relationship) = @_;
  my %relationshipToImage;
  my $img_path = "/img/ontology_browser/";
  my @haveImages = qw( is_a part_of regulates positively_regulates negatively_regulates develops_from occurs_in has_part preceded_by );
  foreach my $relationship (@haveImages) { 
    my $imgUrl = $img_path . $relationship . '.svg';
    $relationshipToImage{$relationship} = qq(<img src="$imgUrl" alt="$relationship" title="$relationship" width="16" height="16">); }
  if ($relationshipToImage{$relationship}) { $relationship = $relationshipToImage{$relationship}; }
    else { $relationship = qq(<span style="background-color: black; color: white">$relationship</span> : ); }
  return $relationship;
} # sub convertRelationshipToImage

=head2 SUB getDirectInferredGenesCount
  Usage    - 
  Returns  - $jsonHash{'grouped'}{'bioentity'}{'ngroups'} 
              # get the gene count from grouped -> bioentity -> ngroups
  Args     -
  Function - Get annotation counts through ngroups.
=cut
# to query by individual annotations, it's too slow, so we can't
sub getDirectInferredGenesCount {					# given a focusTermId, and direct or inferred flag, get count of genes from solr ngroups
  my ($focusTermId, $directOrInferred) = @_;
  my ($solr_url) = &getSolrUrl($focusTermId);				# get the solr URL given a termId
  my $url = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&rows=0&q=document_category:annotation&group=true&group.field=bioentity&group.ngroups=true&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=annotation_class:%22' . $focusTermId . '%22';
									# direct gene count query by default
  if ($directOrInferred eq 'inferred') {				# if inferred, change the solr URL
    $url = $solr_url .  'select?qt=standard&indent=on&wt=json&version=2.2&rows=0&q=document_category:annotation&group=true&group.field=bioentity&group.ngroups=true&fq=-qualifier:%22not%22&fq=source:%22WB%22&fq=regulates_closure:%22' . $focusTermId . '%22'; }
  my $page_data   = get $url;						# get the URL
  my $perl_scalar = $json->decode( $page_data );			# get the solr data
  my %jsonHash    = %$perl_scalar;
  return $jsonHash{'grouped'}{'bioentity'}{'ngroups'};			# get the gene count from grouped -> bioentity -> ngroups
} # getDirectInferredGenesCount

=head2 SUB getGenesCountHash
  Usage    - 
  Returns  - %inferredGenesCount, %directGenesCount
  Args     -
  Function - Get annotation counts.
=cut
sub getGenesCountHash {                         			# for a given focusTermId, get the genes count of itself and its direct children, option direct or inferred genes ;  uses bioentities. WORKS NOW AFTER PREFILTERING NOTS FROM ASSOCIATION FILE{but doesn't work for phenotype because of NOT -- RAYMOND does this still not work for phenotype, or remove that part of the comment ?}
#   direct gene counts come from json pairs under facet_counts -> facet_fields -> annotation_class_list
# inferred gene counts come from json pairs under facet_counts -> facet_fields -> regulates_closure
  my ($focusTermId) = @_;
  my %directGenesCount; my %inferredGenesCount;				# mapping of children terms to count of genes, direct and inferred
  my ($solr_url) = &getSolrUrl($focusTermId);				# get the solr URL given a termId
  my $url = $solr_url . 'select?qt=standard&indent=on&wt=json&version=2.2&fl=id&start=0&rows=0&q=document_category:bioentity&facet=true&facet.field=regulates_closure&facet.field=annotation_class_list&facet.limit=-1&facet.mincount=1&facet.sort=count&fq=source:"WB"&fq=regulates_closure:%22' . $focusTermId . '%22';
  my $page_data = get $url;						# get the URL
  my $perl_scalar = $json->decode( $page_data );			# get the solr data
  my %jsonHash = %$perl_scalar;
  while (scalar @{ $jsonHash{'facet_counts'}{'facet_fields'}{'annotation_class_list'} } > 0) {
									# get all pairs of genes/count in the JSON array
    my $termId = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'annotation_class_list'} };		# get the termId
    my $count  = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'annotation_class_list'} };		# get the count
    $directGenesCount{$termId} = $count;				# map termId to count for direct genes
  } # while (scalar @{ $jsonHash{'facet_counts'}{'facet_fields'}{'annotation_class_list'} } > 0)
  while (scalar @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} } > 0) {
									# get all pairs of genes/count in the JSON array
    my $termId = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} };		# get the termId
    my $count  = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} };		# get the count
    $inferredGenesCount{$termId} = $count;				# map termId to count for inferred genes
  } # while (scalar @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} } > 0)
  return (\%inferredGenesCount, \%directGenesCount);
} # sub getGenesCountHash

=head2 SUB makeGenesLink
  Usage    - 
  Returns  - $link
  Args     -
  Function - Hyperlinking counts to annotation lists
=cut
sub makeGenesLink {							# give a focusTermId, focusTermName, number of inferred genes, number of direct genes ;  if there's at least one inferred gene, create a link to show the genes, showing the count of inferred and direct genes
  my ($focusTermId, $focusTermName, $numFoundInferred, $numFoundDirect) = @_;
  unless ($numFoundDirect)   { $numFoundDirect   = 0; }			# initialize number of direct genes
  unless ($numFoundInferred) { $numFoundInferred = 0; }			# initialize number of inferred genes
  my $link = "0 gene products";						# by default there are zero of the given direct vs inferred
  if ($numFoundInferred > 0) {						# if there's at least one inferred gene, make a link show its genes
    $link = qq(<a target="new" href="/tools/ontology_browser/show_genes?focusTermName=$focusTermName&focusTermId=$focusTermId">$numFoundInferred gene products ($numFoundDirect direct)</a>); }
  return $link;
} # makeGenesLink

=head2 SUB makeUrl
  Usage    - 
  Returns  - $url
  Args     -
  Function - Term URL construct.
=cut
sub makeUrl {								# generate URL to WormBase object given a class and focus term id
  my ($class, $focusTermId) = @_;
  my $url = "/species/all/$class/$focusTermId";				# standard URL
  if ($class eq 'disease') { $url = "/resources/$class/$focusTermId"; }	# disease class has a special URL
  return $url;
} # sub makeUrl

=head2 SUB makeObjectLink
  Usage    - 
  Returns  - $link
  Args     -
  Function - Annotation entity URL construct
=cut
sub makeObjectLink {							# make html link to WormBase object, given a class, focus term id, link text, link target, link colour
  my ($class, $focusTermId, $text, $linkTarget, $color) = @_;
  my ($url) = &makeUrl($class, $focusTermId);				# generate URL to WormBase object
  if ($color) { $text = qq(<span style="color:$color">) . $text . '</span>'; }
									# if a special colour is wanted, put link text in an html span
  my $link = qq(<a href="$url" target="$linkTarget">$text</a>);		# generate html link from URL and link text
  return $link;
} # sub makeObjectLink

=head2 SUB getLongestPathAndTransitivity
  Usage    - 
  Returns  - ($max_steps, $dominant_inferred_transitivity)
              # return the maximum number of steps and dominant inferred transitivity
  Args     -
  Function - Choose path of transitivity
=cut
sub getLongestPathAndTransitivity {                     		# given two nodes, get the longest path and dominant inferred transitivity, by recursively finding all paths that connect both nodes, then counting the steps in the longest, and finding the dominant inferred transitivity based on %transitivityPriority
  my ($ancestor, $focusTermId) = @_;                                    # the ancestor and focusTermId from which to find the longest path
  &recurseLongestPath($focusTermId, $focusTermId, $ancestor, $focusTermId);
									# recurse to find longest path given current, start, end, and list of current path
  my $max_nodes = 0;                                                    # the most nodes found among all paths travelled
  my %relationshipsBetweenNodes;					# all the relationships that exist between two nodes
  foreach my $finpath (@{ $paths{"finalpath"} }) {                      # for each of the paths that reached the end node during &recurseLongestPath
    my $nodes = scalar @$finpath;                                       # amount of nodes in the path
    if ($nodes > $max_nodes) { $max_nodes = $nodes; }                   # if more nodes than max, set new max
    my $parent = shift @$finpath; my $child;				# get first node (child) set to parent since loop will make it be child
    while (scalar @$finpath > 0) {                                      # while there are steps in the path
      $child = $parent;                                                 # the child in the new step is the previous parent
      $parent = shift @$finpath;                                        # the new parent is the next node in the path
      my $relationship = $paths{"childToParent"}{$child}{$parent};	# the relationship between this pair
      $relationshipsBetweenNodes{$relationship}++; }	 		# add relationship of this pair to list of all relationships that exist between original two nodes
  } # foreach my $finpath (@finalpath)
  delete $paths{"finalpath"};                                           # reset finalpath for other ancestors
  my $max_steps = $max_nodes - 1;                                       # amount of steps is one less than amount of nodes
  my @all_inferred_paths_transitivity = sort { $transitivityPriority{$b} <=> $transitivityPriority{$a} } keys %relationshipsBetweenNodes ;
									# sort all relationships by highest precedence
  my $dominant_inferred_transitivity = shift @all_inferred_paths_transitivity;
									# dominant is the one with highest precedence
  return ($max_steps, $dominant_inferred_transitivity);                 # return the maximum number of steps and dominant inferred transitivity
} # sub getLongestPathAndTransitivity

=head2 SUB recurseLongestPath
  Usage    - 
  Returns  -
  Args     -
  Function - 
=cut
sub recurseLongestPath {
									# recurse to find longest path given current, start, end, and list of current path
  my ($current, $start, $end, $curpath) = @_;                           # current node, starting node, end node, path travelled so far
  foreach my $parent (sort keys %{ $paths{"childToParent"}{$current} }) {
									# for each parent of the current node
    next if ($curpath =~ m/$parent/);					# sometimes two terms can be each others's parents, so skip if already in path
    next unless ($transitivityPriority{$paths{"childToParent"}{$current}{$parent}}); 
									# skip non-transitive edges
    my @curpath = split/\t/, $curpath;                                  # convert current path to array
    push @curpath, $parent;                                             # add the current parent
    if ($parent eq $end) {                                              # if current parent is the end node
        my @tmpWay = @curpath;                                          # make a copy of the array
        push @{ $paths{"finalpath"} }, \@tmpWay; }                      # put a reference to the array copy into the finalpath
      else {                                                            # not the end node yet
        my $curpath = join"\t", @curpath;                               # pass literal current path instead of reference
        &recurseLongestPath($parent, $start, $end, $curpath); }         # recurse to keep looking for the final node
  } # foreach $parent (sort keys %{ $paths{"childToParent"}{$current} })
} # sub recurseLongestPath

=head2 SUB getClassFromId
  Usage    - 
  Returns  - $class
  Args     -
  Function - Using ID to figure out the Class it belongs.
=cut
sub getClassFromId {							# from a term ID, match for identifier prefix to get the class used in the solr URL path
  my ($rootTerm) = @_;
  my $class = 'go_term';						# initialize to arbitrary default class
  if ($rootTerm =~ m/GO:/)               { $class = 'go_term';      }
    elsif ($rootTerm =~ m/WBPhenotype:/) { $class = 'phenotype';    }
    elsif ($rootTerm =~ m/WBbt:/)        { $class = 'anatomy_term'; }
    elsif ($rootTerm =~ m/DOID:/)        { $class = 'disease';      }
    elsif ($rootTerm =~ m/WBls:/)        { $class = 'life_stage';   }
  return $class;
} # sub getClassFromId

=head2 SUB getTopoChildrenParents
  Usage    - 
  Returns  - %children, %parents
  Args     -
  Function - 
=cut
sub getTopoChildrenParents {						# for a termId, from the topology_graph_json edges get the children and parents as key and relationship as value
  my ($termId, $topoHref) = @_;
  my %topo = %$topoHref;
  my %children;								# children of the wanted termId, value is relationship type (predicate) ; are the corresponding nodes on an edge where the object is the termId
  my %parents;								# direct parents of the wanted termId, value is relationship type (predicate) ; are the corresponding nodes on an edge where the subject is the termId
  my (@edges) = @{ $topo{"edges"} };					# get edges from topology_graph_json
  for my $index (0 .. @edges) {
    my ($sub, $obj, $pred) = ('', '', '');
    if ($edges[$index]{'sub'})  { $sub  = $edges[$index]{'sub'};  }
    if ($edges[$index]{'obj'})  { $obj  = $edges[$index]{'obj'};  }
    if ($edges[$index]{'pred'}) { $pred = $edges[$index]{'pred'}; }
    if ($pred =~ m/ /) { $pred =~ s/ /_/g; }				# replace all spaces with underscores for GO and 'preceded by'
    if ($obj eq $termId) { $children{$sub} = $pred; }             	# track children here
    if ($sub eq $termId) { $parents{$obj}  = $pred; }             	# track parents here
  }
  return (\%children, \%parents);
} # sub getTopoChildrenParents

=head2 SUB getFacetCountsHash
  Usage    - 
  Returns  - %termRegulatesClosure
  Args     -
  Function - 
=cut
sub getFacetCountsHash {						# solr query to get terms that regulate closure.  these are known to have children through regulates_closure, but absence here does not mean lack of children (through daughter_of or preceded_by)
  my ($focusTermId) = @_;
  my ($solr_url) = &getSolrUrl($focusTermId);				# get the solr URL given a termId
  my $url = $solr_url . "select?qt=standard&fl=*&version=2.2&wt=json&indent=on&rows=0&q=document_category:ontology_class&fq=regulates_closure:%22" . $focusTermId . "%22&facet=true&facet.field=regulates_closure&facet.limit=-1&facet.mincount=2&facet.sort=count";
  my $page_data = get $url;						# get the URL
  my $perl_scalar = $json->decode( $page_data );			# get the solr data
  my %jsonHash = %$perl_scalar;

  my %termRegulatesClosure;
  while (scalar @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} } > 0) {	# while there are pairs of genes/count in the JSON array
    my $termId = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} };	# get the focusTermId
    my $count  = shift @{ $jsonHash{'facet_counts'}{'facet_fields'}{'regulates_closure'} };	# get the count
    $termRegulatesClosure{$termId} = $count; }

  return \%termRegulatesClosure;
} # sub getFacetCountsHash

=head2 SUB getTopoHash
  Usage    - 
  Returns  - $topoHashref, $transHashref
  Args     -
  Function - 
=cut
sub getTopoHash {							# given a termId, get the topology_graph_json and regulates_transitivity_graph_json
  my ($focusTermId) = @_;
  my ($solr_url) = &getSolrUrl($focusTermId);				# get the solr URL given a termId
  my $url = $solr_url . "select?qt=standard&fl=*&version=2.2&wt=json&indent=on&rows=1&q=id:%22" . $focusTermId . "%22&fq=document_category:%22ontology_class%22";
  my $page_data = get $url;						# get the URL
  my $perl_scalar = $json->decode( $page_data );			# get the solr data
  my %jsonHash = %$perl_scalar;
  my $topoHashref  = $json->decode( $jsonHash{"response"}{"docs"}[0]{"topology_graph_json"} );
									# mostly use topology_graph_json
  my $transHashref = $json->decode( $jsonHash{"response"}{"docs"}[0]{"regulates_transitivity_graph_json"} );
									# need this for inferred Tree View
  return ($topoHashref, $transHashref);
} # sub getTopoHash

=head2 SUB getSolrUrl
  Usage    - 
  Returns  - $solr_url
  Args     -
  Function - 
=cut
sub getSolrUrl {							# given a termId, get the solr URL based on the prefix of the termId
  my ($focusTermId) = @_;
  my ($identifierType) = $focusTermId =~ m/^(\w+):/;
  my %idToSolrSubdirectory;						# different classes map to a different Solr subdirectory
  $idToSolrSubdirectory{"WBbt"}        = "anatomy";
  $idToSolrSubdirectory{"DOID"}        = "disease";
  $idToSolrSubdirectory{"GO"}          = "go";
  $idToSolrSubdirectory{"WBls"}        = "lifestage";
  $idToSolrSubdirectory{"WBPhenotype"} = "phenotype";
#   my $base_solr_url = 'http://131.215.12.207:8080/solr/';		# raymond URL for testing 2014 10 22 
#   my $base_solr_url = 'http://131.215.12.220:8080/solr/';		# raymond URL 2013 08 06
  my $base_solr_url = 'http://wobr.caltech.edu/solr/';			# raymond URL for WB live 2014 10 22
  my $solr_url = $base_solr_url . $idToSolrSubdirectory{$identifierType} . '/';
  return $solr_url;
} # sub getSolrUrl

