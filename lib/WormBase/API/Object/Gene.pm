package WormBase::API::Object::Gene;
use Moose;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::Position';


#####################

### configuration items

# my $version = 'WS213';  

# our $gene_pheno_datadir = "/usr/local/wormbase/databases/$version/gene";
# our $rnai_details_file = "rnai_data.txt";
# our $gene_rnai_phene_file = "gene_rnai_pheno.txt";
# our $gene_variation_phene_file = "variation_data.txt";
# our $phenotype_name_file = "phenotype_id2name.txt";
# our $gene_xgene_phene_file = "gene_xgene_pheno.txt";

=pod 

=head1 NAME

WormBase::API::Object::Gene

=head1 SYNPOSIS

Model for the Ace ?Gene class.

=head1 URL

http://wormbase.org/species/*/gene

=head1 METHODS/URIs

=cut


has 'gene_pheno_datadir' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $version = $self->ace_dsn->version;
	return $self->pre_compile->{base}.$version.$self->pre_compile->{gene};
    }
);

 
has 'orthology_datadir' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $version = $self->ace_dsn->version;
	return $self->pre_compile->{base} . $version . "/orthology/";
    }
);

 
has 'all_proteins' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my $cds = $self ~~ '@Corresponding_CDS';
	return undef unless $cds;
	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @$cds  ;
	return \@proteins;
    }
);
 
has 'sequences' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
	my $self=shift;
	my @seq = $self->_fetch_sequences;
	return \@seq;
    }
);

has 'tracks' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return {
            description => 'tracks displayed in GBrowse',
            data        => $self->_parsed_species =~ /elegans/ ?
                           [qw(CG CANONICAL Allele RNAi)] : [qw/CG/],
        },
    }
);



has 'phen_data' => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
      my $self=shift;
      my $ret = $self->_build_phen_data;
      return $ret;
    }
);

sub _build_phen_data {
    my $self = shift;
    my $GENE = $self->object;

    my ($details,$phenotype_data) = $self->_get_phenotype_data(1);  
    my ($variation_data, $variation_name_hr) = $self->_get_variation_data(1); 
    my ($details_not,$phenotype_data_not) = $self->_get_phenotype_data(); 
    my ($variation_data_not, $variation_name_hr_not) = $self->_get_variation_data();
    my $xgene_data = $self->_get_xgene_data(1);
    my $xgene_data_not = $self->_get_xgene_data();

    my $phenotype_names_hr  = $self->_get_phenotype_names($phenotype_data,$variation_data);
    my $phenotype_names_not_hr  = $self->_get_phenotype_names($phenotype_data_not,$variation_data_not);

    my $pheno_table = $self->_print_phenotype_table($phenotype_data,
                        $variation_data,
                        $phenotype_names_hr,
                        $xgene_data,
                        $variation_name_hr);
    my $pheno_table_not = $self->_print_phenotype_table($phenotype_data_not,
                        $variation_data_not,
                        $phenotype_names_not_hr,
                        $xgene_data_not,
                        $variation_name_hr_not);
    my $rnai_details_table = $self->_print_rnai_details_table($details, $phenotype_names_hr);
    my $rnai_not_details_table = $self->_print_rnai_details_table($details_not,$phenotype_names_not_hr);

    my $ret = { pheno_table => $pheno_table,
                pheno_table_not => $pheno_table_not,
                rnai_details_table => $rnai_details_table,
                rnai_not_details_table => $rnai_not_details_table,
    };
}



has 'phenotype_id2name' => (
	is =>'rw',
);

has 'gene_rnai_pheno_data' => (
	is =>'rw',
);

has 'phenotype_data' => (
	is => 'ro',	
	lazy => 1,
	default => sub {
		my $self = shift;
		my $gene_rnai_pheno_data = $self->_gene_rnai_pheno_data_compile();
		my $gene_rnai_pheno_not_data = $self->_gene_rnai_pheno_not_data_compile();
		my ($gene_xgene_data,$gene_xgene_data_not) = $self->_gene_xgene_pheno_data_compile();		
		my ($gene_variation_data,$gene_variation_data_not) = $self->_variation_data_compile();
		$self->gene_rnai_pheno_data($gene_rnai_pheno_data . "\n" . $gene_rnai_pheno_not_data); 
		my $rnai_data = $self->_rnai_data_compile();
		my $p2n = $self->phenotype_id2name;
		
		my $return = {
						gene_rnai_pheno_data => $gene_rnai_pheno_data,
						gene_rnai_pheno_not_data => $gene_rnai_pheno_not_data,
						gene_xgene_data => $gene_xgene_data,
						gene_xgene_data_not => $gene_xgene_data_not,
						gene_variation_data => $gene_variation_data,
						gene_variation_data_not => $gene_variation_data_not,
						rnai_data => $rnai_data,
						p2n => $p2n
		
		};
		return $return;
	}
);





#######################################
#
# The Overview Widget
#   template: classes/gene/overview.tt2
#
#######################################

=head2 Overview

=cut

=head3 also_refers_to

This method will return a data structure containing
other names that have also been used to refer to the
gene.

=over

=item PERL API

 $data = $model->also_refers_to();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/also_refers_to

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub also_refers_to {
    my $self   = shift;
    my $object = $self->object;
    my $locus  = $object->CGC_name;
    
    # Save other names that don't correspond to the current object.
    my @other_names_for = $locus ? map { $self->_pack_obj($_) } grep { ! /$object/ } $locus->Other_name_for : ();
    
    return {
	description => 'other genes that this locus name may refer to',
	data        => @other_names_for ? \@other_names_for : undef,
    };
}


=head3 classification

This method will return a data structure containing
the general classification of the gene.

=over

=item PERL API

 $data = $model->classification();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/classification

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub classification {
    my $self   = shift;
    my $object = $self->object;
   
    my $data = {};
    
    # Is this a CGC-approved locus? Is it defined mutationally?
    my $locus = $object->CGC_name;   
    $data->{defined_by_mutation} = $object->Allele ? 1 : 0;

    # General type: coding gene, pseudogene, or RNA
    if ($object->Corresponding_pseudogene) {
	$data->{type} = 'pseudogene';
    }

    # Protein coding?
    my @cds = $object->Corresponding_CDS;
    if (@cds) {
	my $status = $cds[0]->Prediction_status ? 'confirmed' : 'unconfirmed';
	$data->{type}  = "protein coding ($status)" 
    }
    
    # Is this a non-coding RNA?
    my @transcripts = $object->Corresponding_transcript;
    foreach (@transcripts) {
	$data->{type} = $_->Transcript;
	last;
    }
    
    $data->{associated_sequence} = @cds ? 1 : 0;
    
    # Confirmed?
    $data->{confirmed}   = @cds ? $cds[0]->Prediction_status : 0;
    my $matching_cdna    = @cds ? $cds[0]->Matching_cDNA     : '';
    
    # Create a prose description; possibly better in a template.
    my @prose;
    if ($data->{locus}
	&&
	$data->{associated_sequence}) {
	push @prose,"This gene has been defined mutationally and associated with a sequence.";
    } elsif ($data->{associated_sequence}) {
	push @prose,"This gene is known only by sequence.";
    } elsif ($data->{locus}) {
	push @prose,"This gene is known only by mutation.";
    } else { }
    
    # Is the locus name approved?
    if ($data->{locus} && $data->{approved_name}) {
	push @prose,"The gene name has been approved by the CGC.";
    } elsif ($data->{locus} && !$data->{approved_name}) {
	push @prose,"The gene name has not been approved by the CGC.";
    }
    
    # Confirmed or not?
    if ($data->{confirmed} eq 'Confirmed'){
	push @prose,"Gene structures have been confirmed by a curator.";
    } elsif ($matching_cdna) {
	push @prose,"Gene structures have been partially confirmed by matching cDNA.";
    } else {
	push @prose,"Gene structures have not been confirmed."; 
    }
    
    $data->{prose_description} = join(" ",@prose);
    
    return { description => 'gene type and status',
	     data        => $data };
}


=head3 cloned_by

This method will return a data structure containing
the person or laboratory who cloned the gene.

=over

=item PERL API

 $data = $model->cloned_by();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/cloned_by

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub cloned_by {    
    my $self   = shift;
    my $object    = $self->object;
    my $cloned_by = $object->Cloned_by;   

    # This is an evidence hash. We're assuming scalar context.
    my ($tag,$source) = $cloned_by->row  if $cloned_by;   

    return unless $cloned_by;
    return { description => 'the person or laboratory who cloned this gene',
	     data        => {
		 'cloned_by' => "$cloned_by",
		 'tag'       => "$tag",
		 'source'    => $self->_pack_obj($source),
	     },
    };
}


=head3 concise_desciption

This method will return a data structure containing
the prose concise description of the gene, if one exists.

=over

=item PERL API

 $data = $model->concise_description();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/concise_description

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub concise_description {
    my $self   = shift;
    my $object = $self->object;  
    
    my $description = 
	$object->Concise_description
	|| eval {$object->Corresponding_CDS->Concise_description}
        || eval { $object->Gene_class->Description }
        || $self->name->{data}->{label} . ' gene';
    
    return {
	description => "A manually curated description of the gene's function",
	data        => "$description" };
}


=head3 legacy_information

This method will return a data structure containing
legacy information from the original Cold Spring Harbor
C. elegans I & II texts.

=over

=item PERL API

 $data = $model->legacy_information();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/legacy_information

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub legacy_information {
  my $self   = shift;
  my $object = $self->object;
  my @description = map {"$_"} $object->Legacy_information;
  return { description => 'legacy information from the CSHL Press C. elegans I/II books',
	   data        => @description ? \@description : undef };
}

=head3 locus_name

This method will return a data structure containing
the name of the genetic locus.

=over

=item PERL API

 $data = $model->locus_name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/locus_name

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub locus_name { 
    my $self   = shift;
    my $object = $self->object;
    my $locus  = $object->CGC_name;
    return { description => 'the locus name (also known as the CGC name) of the gene',
	     data        => $locus ? $self->_pack_obj($locus->CGC_name_for, "$locus") : undef }
}


# sub name {}
# Supplied by Role; POD will automatically be inserted here.
# << include name >>

# sub other_names {}
# Supplied by Role; POD will automatically be inserted here.
# << include other_names >>


=head3 sequence_name

This method will return a data structure containing
the primary sequence name of the gene.

=over

=item PERL API

 $data = $model->sequence_name();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/sequence_name

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sequence_name {
    my $self     = shift;
    my $object   = $self->object;
    my $sequence = $object->Sequence_name;
    return { description => 'the primary corresponding sequence name of the gene, if known',
	     data        => $sequence ? $self->_pack_obj($sequence->Sequence_name_for, "$sequence") : undef };
}


# sub status {}
# Supplied by Role; POD will automatically be inserted here.
# << include status >>

=head3 version

This method will return a data structure containing
various structured descriptions of gene's function.

=over

=item PERL API

 $data = $model->structured_description();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/structured_description

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub structured_description {
   my $self = shift;
   my %ret;
   my @types = qw(Provisional_description 
                  Other_description
                  Sequence_features
                  Functional_pathway 
                  Functional_physical_interaction 
                  Molecular_function
                  Sequence_features
                  Biological_process
                  Expression
                  Detailed_description);
   foreach my $type (@types){
      my $node = $self->object->$type or next;
      my @nodes = $self->object->$type;
      my $index=-1;
      @nodes = map {$index++; {text=>"$_", evidence=> {tag => $type,index=>$index, check => $self->check_empty($_)}}} @nodes;
      $ret{$type} = \@nodes if (@nodes > 0);
   }
   return { description => "structured descriptions of gene function",
	    data        =>  \%ret };
}

# sub taxonomy {}
# Supplied by Role; POD will automatically be inserted here.
# << include taxonomy >>


=head3 version

This method will return a data structure containing
the current WormBase version of the gene.

=over

=item PERL API

 $data = $model->version();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/version

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub version { 
    return { description => 'the current WormBase version of the gene',
	     data        => shift->object->Version };
}



#######################################
#
# The Expression Widget
#   template: classes/gene/expression.tt2
#
#   TH: Several of the methods in this widget
#       need to be rewritten and clarified.
#
#######################################

=head2 Expression

=cut

=head3 fourd_expression_movies

This method will return a data structure containing
links to four-dimensional expression movies.

=over

=item PERL API

 $data = $model->fourd_expression_movies();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/fourd_expression_movies

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub fourd_expression_movies {
    my $self   = shift;
    my $object = $self->object;
    
    my @expression = grep { ($_->Author =~ /Mohler/ && $_->MovieURL) } $object->Expr_pattern;
    
    my %data;
    foreach (@expression) {
	my $details = $_->Pattern;	
	my $url     = $_->MovieURL;
        $data{$_} = { movie   => "$url",
		      details => "$details",
		      object  => $self->_pack_obj($_),
	};
    }
    return { description => 'interactive 4D expression movies',
	     data        => \%data };
}


=head3 anatomic_expression_patterns

This method will return a complex data structure 
containing expression patterns described at the
anatomic level. Includes links to images.

=over

=item PERL API

 $data = $model->anatomic_expression_patterns();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomic_expression_patterns

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub anatomic_expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my %data_pack;
    # All expression patterns except Mohlers, presented elsewhere.
    my @eps = grep { !($_->Author =~ /Mohler/ && $_->MovieURL) } $object->Expr_pattern;
    
    my $file = $self->pre_compile->{gene_expr}."/".$object.".jpg";
    $data_pack{"image"}="jpg?class=gene_expr&id=". $object   if (-e $file && ! -z $file);
    
    foreach my $ep (@eps) {
	my $file = $self->pre_compile->{expr_object}."/".$ep.".jpg";
	$data_pack{"expr"}{"$ep"}{image}="jpg?class=expr_object&id=". $ep   if (-e $file && ! -z $file);
	# $data_pack{"image"}{"$ep"}{image} = $self->_pattern_thumbnail($ep);
        my $pattern =  join '', ($ep->Pattern(-filled=>1), $ep->Subcellular_localization(-filled=>1));
        $pattern    =~ s/(.{384}).+/$1\.\.\. /;
        $data_pack{"expr"}{"$ep"}{details} = $pattern;
        $data_pack{"expr"}{"$ep"}{object} = $self->_pack_obj($ep);
    }
    
    return { description => 'expression patterns for the gene',
	     data        => \%data_pack };
}

=head3 microarray_expression_data
    
This method will return a data structure containing
microarray expression data.
    
=over

=item PERL API

 $data = $model->microarray_expression_data();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_expression_data

B<Response example>

<div class="response-example"></div>

=back

=cut 


sub microarray_expression_data {
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my @microarray_results = $object->Microarray_results;	
    return { data        => $self->_pack_objects(\@microarray_results),
	     description => 'gene expression determined via microarray analysis'};
}

=head3 microrarray_topology_map_position

This method will return a data structure containing
the microarray "topology" map position.

=over

=item PERL API

 $data = $model->microarray_topology_map_position();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_topology_map_position

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub microarray_topology_map_position {
    my $self = shift;
    my $object = $self->object;

    # I don't think this will work; have sequences been statshed in the object?
    my $sequences = $self->sequences;
    return unless @$sequences;
    my @segments = @{$self->_segments} if $self->_segments;
    my $seg = $segments[0] or return;
    my @p = map {$_->info} $seg->features('experimental_result_region:Expr_profile');
    return unless @p;
    my %data;
    map {$data{"$_"} = $self->_pack_obj($_,eval{'Mountain '.$_->Expr_map->Mountain}||$_)} @p;
    
    my $data = {description =>"microarray topology map",
                data => \%data
    };
    return $data;
}

=head3 expression_cluster

This method will return a data structure containing
microarray expression clusters.

=over

=item PERL API

 $data = $model->expression_cluster();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/expression_cluster

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub expression_cluster {
    my $self   = shift;
    my $object = $self->object;
    my @expr_clusters = $object->Expression_cluster;  
    return { data        => $self->_pack_objects(\@expr_clusters),
	     description => 'expression cluster data' };
}


=head3 anatomy_function

This method will return a data structure containing
the anatomy function of the gene.

=over

=item PERL API

 $data = $model->anatomy_function();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomy_function

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub anatomy_function {
    my $self   = shift;
    my $object = $self->object;

    my @data;
    my @anatomy_fns = $object->Anatomy_function;
    foreach my $anatomy_fn (@anatomy_fns){
      my %anatomy_fn_data;
      my $afn_bodypart_set = $anatomy_fn->Body_part;
      if($afn_bodypart_set =~ m/Not_involved/){
          next;
      }
      else{
          my $afn_phenotype = $anatomy_fn->Phenotype;
          $anatomy_fn_data{'anatomy_fn'} = $self->_pack_obj($anatomy_fn);
          $anatomy_fn_data{'phenotype'} = $self->_pack_obj($afn_phenotype, $afn_phenotype->Primary_name); #$phenotype_prime_name;
          my @afn_bodyparts = $afn_bodypart_set->col if $afn_bodypart_set;
          my @ao_terms;
          foreach my $afn_bodypart (@afn_bodyparts){
            my $ao_term_details;
            my @afn_bp_row = $afn_bodypart->row;
            my ($ao_id,$sufficiency,$description) = @afn_bp_row;
            if( ($sufficiency=~ m/Insufficient/)){
                next;
            }
            else{
                my $term = $ao_id->Term;
                $ao_term_details = $self->_pack_obj($term);
            }
            push @ao_terms,$ao_term_details;
          }
          $anatomy_fn_data{'terms'} = \@ao_terms;
      }
      push @data, \%anatomy_fn_data;
    }


    my %data;

    $data{'data'} = \@data;
    $data{'description'} = "anatomy function";
    return \%data;
}




#######################################
#
# The External Links widget
#   template: shared/widgets/xrefs.tt2
#
#######################################

=head2 External Links

=cut

# sub xrefs {}
# Supplied by Role; POD will automatically be inserted here.
# << include xrefs >>


#######################################
#
# The Genetics Widget
#   template: classes/gene/genetics.tt2
#
#######################################

=head2 Genetics

=cut

=head3 alleles

This method will return a complex data structure 
containing alleles of the gene (but not including
polymorphisms or other natural variations.

=over

=item PERL API

 $data = $model->alleles();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/alleles

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub alleles {
    my $self   = shift;
    my $object = $self->object;
    my @alleles = $object->Allele;
    
    my @data;
    foreach my $allele (@alleles) {
	next if ($allele->Variation_type =~ /SNP/ || $allele->Variation_type =~ /RFLP/);
	push @data,$self->_process_variation($allele);       
    }
    
    return { description => 'alleles found within this gene',
	     data        => \@data };
}

=head3 polymorphisms

This method will return a complex data structure 
containing polymorphisms and natural variations
but not alleles.

=over

=item PERL API

 $data = $model->polymorphisms();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/polymorphisms

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub polymorphisms {
    my $self    = shift;
    my $object  = $self->object;
    my @alleles = $object->Allele;
    
    my @data;
    foreach my $allele (@alleles) {
	next unless ($allele->Variation_type =~ /SNP/ || $allele->Variation_type =~ /RFLP/);
	push @data,$self->_process_variation($allele);
    }
    
    return { description => 'polymorphisms and natural variations found within this gene',
	     data        => \@data };
}

# Private method: glean some information about a variation.
sub _process_variation {
    my ($self,$variation) = @_;

    my $type = lc($variation->Variation_type) || 'unknown';
        
    my $molecular_change  = lc($variation->Type_of_mutation || "other");
    my $sequence_known    = $variation->Flanking_sequences ? 'yes' : 'no';
    
    my $affects;
    foreach my $type_affected ($variation->Affects) {
	foreach my $item_affected ($type_affected->col) { # is a subtree
	    ($affects) = $item_affected->col;
	}
    }

    $type = "transposon insertion" if $variation->Transposon_insertion;
    my %data = ( variation => $self->_pack_obj($variation),
		 type              => "$type",
		 molecular_change  => "$molecular_change",
		 sequence_known    => $sequence_known,
		 affects           => lc("$affects") );
    return \%data;
}

=head3 reference_allele

This method will return a complex data structure 
containing the reference allele of the gene, if
one exists.

=over

=item PERL API

 $data = $model->reference_allele();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/reference_allele

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub reference_allele {
    my $self = shift;
    my $ref_alleles = $self ~~ '@Reference_allele' ;
    
    my @array = map { $self->_pack_obj($_) } @$ref_alleles;
    return { description => 'the reference allele of the gene',
	     data        => \@array };
}

=head3 strains

This method will return a complex data structure 
containing strains carrying the gene.

=over

=item PERL API

 $data = $model->strains();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/strains

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub strains {
    my $self   = shift;
    my $object = $self->object;    
    my @data;
    my %count;
    foreach ($object->Strain) {
	my @genes = $_->Gene;
	my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;

	my $packed = $self->_pack_obj($_);

	# All of the counts can go away if
	# we discard the venn diagram.
	push @{$count{total}},$packed;
	push @{$count{available_from_cgc}},$packed if $cgc;

	if (@genes == 1 && !$_->Transgene){
	    push @{$count{carrying_gene_alone}},$packed;
	    if ($cgc) {
		push @{$count{carrying_gene_alone_and_cgc}},$packed;
	    }	    
	} else {
	    push @{$count{others}},$packed;
	}       
	
	my $genotype = $_->Genotype;
	push @data, { strain   => $packed,
		      cgc      => $cgc ? 'yes' : 'no',
		      genotype => "$genotype",
	};
    }
    
    return { description => 'strains carrying this gene',
	     data        => @data ? \@data : undef,
	     count       => \%count };
}

=head3 rearrangements
    
This method will return a data structure 
containing rearrangements affecting the gene.

=over

=item PERL API

 $data = $model->rearrangements();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/rearrangements

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub rearrangements {
    my $self    = shift;     
    my $object  = $self->object;
    my @positive = map { $self->_pack_obj($_) } $object->Inside_rearr;
    my @negative = map { $self->_pack_obj($_) } $object->Outside_rearr;

    return { description => 'rearrangements involving this gene',
	     data        => { positive => \@positive,
			      negative => \@negative
	     }
    };
}


#######################################
#
# The Gene Ontology widget
#   template: classes/gene/gene_ontology.tt2
#
#######################################

=head2 Gene Ontology

=cut

=head3 gene ontology

This method will return a data structure containing
curated and electronically assigned gene ontology
associations.

=over

=item PERL API

 $data = $model->gene_ontology();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/gene_ontology

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gene_ontology {
    my $self   = shift;
    my $object = $self->object;

    # TH: This is really opaque. What is the value used for?
    # Is it a display kludge?
    my %annotation_bases  = (
        'EXP' , 'p',
        'IDA' , 'p',
        'IPI' , 'p',
        'IMP' , 'p',
        'IGI' , 'p',
        'IEP' , 'p',
        'ND'  , 'p',
        
        'IEA' , 'x',
        'ISS' , 'x',
        'ISO' , 'x',
        'ISA' , 'x',
        'ISM' , 'x',
        'IGC' , 'x',
        'RCA' , 'x',
        'IC'  , 'x'
    );

    my %data;
    foreach my $go_term ($object->GO_term) {
	foreach my $code ($go_term->col){
	    my @row = $code->row;
	    my ($evidence_code,$method,$detail) = @row;
	    my $display_method   = $self->_go_method_detail($method,$detail);
	    my $term             = $go_term->Term;
	    
	    my $facet            = $go_term->Type;
	    $facet =~ s/_/ /g;

	    my $annotation_basis =  $annotation_bases{$evidence_code};
	    $display_method =~ m/.*_(.*)/;  # Strip off the spam-dexer.
	    	    
	    push @{$data{$facet}},
	    {
		method         => $1,
		evidence_code  => "$evidence_code",
		term           => $self->_pack_obj($go_term,$term),
	    };
	}
    }
    
    return { description => 'gene ontology assocations',
	     data        => \%data }; 
}


#######################################
#
# The History Widget
#    template: shared/widgets/history.tt2
#
#######################################

=head2 History

=cut

=head3 history

This method returns a data structure containing the 
curatorial history of the gene.

=over

=item PERL API

 $data = $model->history();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/history

B<Response example>

=cut

sub history {
    my $self = shift;
    my $object = $self->object;
    my @data;
    
    foreach my $history ($object->History) {
	my $type = $history;
	$type =~ s/_ / /g;  
	
	my @versions = $history->col;
        foreach my $version (@versions) {
	    #  next unless $history eq 'Version_change';    # View Logic
            my ($vers,$date,$curator,$event,$action,$remark,$gene,$person);     
            if ($history eq 'Version_change') {
		($vers,$date,$curator,$event,$action,$remark) = $version->row; 
		
                # For some cases, the remark is actually a gene object
                if ($action eq 'Merged_into'
		    || $action eq 'Acquires_merge'
                    || $action eq 'Split_from'
		    || $action eq 'Split_into') {
		    $gene = $remark;
		    $remark = undef;
                }
            } else {
		($gene) = $version->row;
            }    
	    
	    push @data,{ history => "$history",
			 version => "$version",
			 type    => "$type",
			 date    => "$date",
			 action  => "$action",
			 remark  => "$remark",
			 gene    => $gene    ? $self->_pack_obj($gene,$gene->Public_name)         : undef,
			 curator => $curator ? $self->_pack_obj($curator,$curator->Standard_name) : undef,
	    };
	}
    }
    
    return { description => 'the curatorial history of the gene',
	     data        => @data ? \@data : undef };
}



#######################################
#
# The Homology Widget
#   template: classes/gene/homology.tt2
#
#######################################

=head2 Homology

=cut

# sub best_blastp_matches {}
# Supplied by Role; POD will automatically be inserted here.
# << include best_blastp_matches >>

=head3 nematode_orthologs

This method returns a data structure containing the 
orthologs of this gene to other nematodes housed
at WormBase.

=over

=item PERL API

 $data = $model->nematode_orthologs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/nematode_orthologs

B<Response example>

=cut

sub nematode_orthologs {
    my $self   = shift;
    my $object = $self->object;

    my @data;
    foreach ($object->Ortholog) {
	my $methods  = join('; ',map { "$_" } $_->right(2)->col);
	push @data, { ortholog => $self->_pack_obj($_),
		      method   => $methods,
		      species  => $self->_split_genus_species($_->Species)
	};
    }
    
    return { description => 'precalculated ortholog assignments for this gene',
	     data        =>  @data ? \@data : undef };

}

=head3 human_orthologs

This method returns a data structure containing the 
human orthologs of this gene.

=over

=item PERL API

 $data = $model->human_orthologs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/human_orthologs

B<Response example>

=cut

# I sure do wish we had some descriptions for human genes.
sub human_orthologs {    
    my $self = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Ortholog_other) {
	next unless $_->name =~ /ENSEMBL:ENSP\d{1}.*/;	
	push @data, $self->_parse_ortholog_other($_);
    }
    return { description => 'human orthologs of this gene',
	     data        => @data ? \@data : undef};    
}


=head3 other_orthologs

This method returns a data structure containing the 
orthologs of this gene to species outside of the core
nematodes housed at WormBase. See also nematode_orthologs()
and human_orthologs();

=over

=item PERL API

 $data = $model->other_orthologs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/other_orthologs

B<Response example>

=cut

sub other_orthologs {    
    my $self = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Ortholog_other) {
	push @data, $self->_parse_ortholog_other($_);
    }
    return { description => 'orthologs of this gene to other species outside of core nematodes at WormBase',
	     data        => @data ? \@data : undef };    
}

# Private helper method to standardize structure of other orthologs.
sub _parse_ortholog_other {
    my ($self,$ortholog) = @_;
    my $methods  = $ortholog->right ? join('; ',map { "$_" } $ortholog->right->col): undef;
    return { ortholog => $self->_pack_obj($ortholog),
	     method   => $methods,
	     species  => $self->_split_genus_species($ortholog->Species)
    };
}

=head3 paralogs

This method returns a data structure containing the 
paralogs of this gene.

=over

=item PERL API

 $data = $model->paralogs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/paralogs

B<Response example>

=cut

sub paralogs {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Paralog) {
	my $methods  = join('; ',map { "$_" } $_->right(2)->col);
	push @data, { ortholog => $self->_pack_obj($_),
		      method   => $methods,
		      species  => $self->_split_genus_species($_->Species)
	};
    }
    
    return { description => 'precalculated paralog assignments',
	     data        =>  @data ? \@data : undef};
}


=head3 human_diseases

This method returns a data structure containing disease
processes that human orthologs of this gene are thought
to participate in.

=over

=item PERL API

 $data = $model->human_diseases();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/human_diseases

B<Response example>

=cut

# THIS SERIOUSLY NEEDS TO BE FIXED.
sub human_diseases {
    my $self = shift;
    my $object = $self->object;
	my %gene_id2omim_ids = build_hash($self->orthology_datadir . 'gene_id2omim_ids.txt');
	my %omim_id2disease_desc = build_hash($self->orthology_datadir . 'omim_id2disease_desc.txt');
	my %omim_id2disease_name = build_hash($self->orthology_datadir . 'omim_id2disease_name.txt');
	my $disease_list = $gene_id2omim_ids{$object};                                                                                                            
	my @diseases = split /%/,$disease_list;     
	my @data_pack;
	foreach my $disease_id (@diseases) {
		push @data_pack, {
					omim_id 	=> $disease_id,
					disease 	=> $omim_id2disease_name{$disease_id},
					description => $omim_id2disease_desc{$disease_id},
					};	
	}
	return {
		'data'=> @data_pack ? \@data_pack : undef,
		'description' => 'Diseases related to the gene'
	};
}


=head3 protein_domains

This method returns a data structure containing the 
protein domains contained in this gene.

=over

=item PERL API

 $data = $model->protein_domains();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/protein_domains

B<Response example>

=cut

sub protein_domains {
    my $self   = shift;
    my $object = $self->object;
    
    my %unique_motifs;
    for my $protein (@{$self->all_proteins}) {
    	my @motifs;
    	@motifs	= $protein->Motif_homol;
	foreach my $motif (@motifs) {
	    $unique_motifs{$motif->Title} 
	    = $self->_pack_obj($motif, $motif->Title) unless $unique_motifs{$motif->Title};
	}
    }
    return { description => "protein domains of the gene",
	     data        => %unique_motifs ? \%unique_motifs : undef,
    };
}


=head3 treefam

This method returns a data structure containing the 
link outs to the Treefam resource.

=over

=item PERL API

 $data = $model->treefam();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/treefam

B<Response example>

=cut

sub treefam {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;
    foreach (@{$self->all_proteins}) {
	my $treefam = $self->_fetch_protein_ids($_,'treefam');
	# Ignore proteins that lack a Treefam ID
	next unless $treefam;
	push @data, "$treefam";
    }			
    
    return { description => 'data and IDs related to rendering Treefam trees',
	     data        => \@data,
    };
}




#######################################
#
# The Interactions Widget
#   template: classes/gene/interactions.tt2
#
#######################################

=head2 Interactions

=cut

=head3 interactions

This method returns a data structure containing the 
a data table of gene and protein interactions. Ask us
to increase the granularity of this method!

=over

=item PERL API

 $data = $model->interactions();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/interactions

B<Response example>

=cut

sub interactions {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;
    foreach ($object->Interaction) {
	my $type = $_->Interaction_type;
	# Filter low confidence predicted interactions.
	next if ($_->Log_likelihood_score >= 1.5 && $type =~ /predicted/);
	
	my ($effector,$effected,$direction);
	
	my @non_directional = eval { $type->Non_directional->col };
	if (@non_directional) {
	    ($effector,$effected) = @non_directional;  # WBGenes
	    $direction = 'non-directional';
	} else { 
	    $effector  = $type->Effector->right;
	    $effected  = $type->Effected->right;
	    $direction = 'Effector->Effected';
	}
	
	my $phenotype = $type->Interaction_phenotype;
	push @data, { interaction => $self->_pack_obj($_),
		      type        => "$type",
		      effector    => $self->_pack_obj($effector),
		      effected    => $self->_pack_obj($effected),
		      direction   => $direction,
		      phenotype   => $self->_pack_obj($phenotype) };
    }
    return { description => 'genetic and predicted interactions',
	     data        => \@data };
}



#######################################
#
# The Location Widget
#
#######################################

=head2 Location

=cut

# sub genomic_position { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_position >>

sub _build_genomic_position {
    my ($self) = @_;
    my @pos = $self->_genomic_position([ $self->_longest_segment || () ]);
    return {
        description => 'The genomic location of the sequence',
        data        => @pos ? \@pos : undef,
    };
}

# sub genetic_position { }
# Supplied by Role; POD will automatically be inserted here.
# << include genetic_position >>

# sub genomic_image { }
# Supplied by Role; POD will automatically be inserted here.
# << include genomic_image >>


#######################################
#
# The Phenotype Widget
#
#######################################

=head2 Phenotype

=cut

sub phenotype {
    my $self = shift;
    my $data = { description => 'The Phenotype summary of the gene',
		 data        => { pheno=>$self->phen_data->{pheno_table},	
				  pheno_not=>$self->phen_data->{pheno_table_not},
				},
	};

    return $data;    
}


sub rnai {
    my $self = shift;
    my $data = { description => 'The RNAi summary of the gene',
         data        => { rnai=>$self->phen_data->{rnai_details_table},
                  rnai_not=>$self->phen_data->{rnai_not_details_table},
                },
    };

    return $data;    
}
# TH: THIS IS A VIEW TASK.
sub _print_rnai_details_table {
	my ($self, $rnai_details_ar, $phene_id2name_hr) = @_;
	my @array;
	foreach my $rnai_detail (@$rnai_details_ar) {

		my ($rnaix,$phenes,$genotype,$ref) = split /\|/,$rnai_detail;
		my @phenes = split /\&/, $phenes;
		my $ref_obj = $self->ace_dsn->fetch(-class=>'Paper', -name=>$ref);
		my $paper = $self->_wrap($ref_obj);
		my $citation_hash = $paper->intext_citation->{data};
		my $formatted_ref = $citation_hash ? substr $citation_hash->{citation}, 1, -1 : undef ;

		my @phenotype_set = map {
			class => 'phenotype',
			id => $_,
			label => $$phene_id2name_hr{$_},
		}, @phenes;

		push @array, {
			rnai	  => {
				class => 'RNAi',
				id	  => $rnaix,
				label => $rnaix,
			},
			phenotype => \@phenotype_set,
			genotype  => $genotype,
			cite	  => $self->_pack_obj($ref_obj,$formatted_ref),
		};
	}

	return \@array;
}

sub _print_phenotype_table {

    ## get data

    my ($self,$rnai_data_ar, $var_data_ar, $phenotype_id2name_hr, $xgene_data_ar, $var_id2name_hr) = @_;

    ## build data structures

    my %rnai_data;
    foreach my $rnai_data_line (@$rnai_data_ar) {

	    my ($phenotype_id,$experiment_count) = split /\|/,$rnai_data_line;
	    $rnai_data{$phenotype_id} = $experiment_count;

    }

    my %var_data;
    foreach my $var_data_line (@$var_data_ar) {

	    my ($phenotype_id,$var_list) = split /\|/,$var_data_line;
	    $var_data{$phenotype_id} = $var_list;

    }

    my %xgene_data;
    foreach my $xgene_data_line (@$xgene_data_ar) {

	    my ($phenotype_id,$xgene_list) = split /\|/,$xgene_data_line;
	    $xgene_data{$phenotype_id} = $xgene_list;

    }
    my @data;
    ## consolidate phenotype list and get phenotype names
    foreach my $phenotype_id (keys %$phenotype_id2name_hr ){ 

	    my $phenotype_link = {  class=>'phenotype',
				    id=>$phenotype_id,
				    label=>$$phenotype_id2name_hr{$phenotype_id},
				};
	    my $supporting_evidence;
	    ## variation evidence
	  
	    my @allele_links;
	    if ($var_data{$phenotype_id}) {
		    my @allele_set = split /\&/, $var_data{$phenotype_id};
		    foreach my $allele_data (@allele_set) {
			    my ($allele, $seq_status) = split /\+/,$allele_data;
			    my $var_name = $var_id2name_hr->{$allele};
			    my $boldface = ($seq_status =~ m/sequenced/i) ;
			    push @allele_links, {  class=>'variation',
				    id=>$allele,
				    label=>$var_name,boldface=>$boldface
				}; 
		    }
	    }
		    
	    $supporting_evidence->{allele} = \@allele_links;;
	    
	    ### xgene evidence
	    my @xgene_links;
	    if ($xgene_data{$phenotype_id}) { ###
		    my @xgene_set = split /\&/, $xgene_data{$phenotype_id};
		    my @xgene_links;
		    foreach my $xgene_data (@xgene_set) {
			    my ($xgene, $seq_status) = split /\+/,$xgene_data;	
			    push @xgene_links,  {id=>$xgene, label=>$xgene, class=>'gene'};#$self->_pack_obj($xgene);    
		    }
	    }

	    $supporting_evidence->{transgene} = \@xgene_links;; 
	    if ($rnai_data{$phenotype_id}) {
		    $supporting_evidence->{rnai} = $rnai_data{$phenotype_id} ;
	    }
	    push @data, {	id => $phenotype_link,
				evidence => $supporting_evidence,
			  }
    }

    return \@data;
} 



#######################################
#
# The Reagents Widget
#
#######################################

=head2 Reagents

=cut

=head3 antibodies

This method will return a data structure containing
antibodies generated against products of the gene.

=over

=item PERL API

 $data = $model->antibodies();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/antibodies

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub antibodies {
  my $self   = shift;
  my $object = $self->object;

  my @data;
  foreach ($object->Antibody) {
      my $summary = $_->Summary;
      push @data, { antibody   => $self->_pack_obj($_),
		    summary    => "$summary",
		    laboratory => $_->Location ? $self->_pack_obj($_->Location) : "" };
  }

  return {  description =>  "antibodies generated against protein products or gene fusions",
	    data        =>  \@data };
}



=head3 matching_cdnas

This method will return a data structure containing
a list of cDNAs mapped to the gene.

=over

=item PERL API

 $data = $model->matching_cdnas();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/matching_cdnas

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %unique;
    my @mcdnas = map {$self->_pack_obj($_)} grep {!$unique{$_}++} map {$_->Matching_cDNA} $object->Corresponding_CDS;
    return { description => 'cDNAs matching this gene',
	     data        => \@mcdnas };
}



=head3 microarray_probes

This method will return a data structure containing
microarray probes that map to the gene.

=over

=item PERL API

 $data = $model->microarray_probes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_probes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub microarray_probes {
    my $self   = shift;
    my $object = $self->object;

    my %seen;

    my @oligos =  
	grep {!$seen{$_}++}
    grep {$_->Type =~ /microarray_probe/}
    map {$_->Corresponding_oligo_set} $object->Corresponding_CDS if ($object->Corresponding_CDS);
    my @stash;
    foreach (@oligos) {
	my $comment = ($_->Type =~ /GSC/) ? 'GSC' : 
	    ($_->Type =~ /Agilent/ ? 'Agilent' : 'Affymetrix');
	push @stash,$self->_pack_obj($_,"$_ [$comment]");
    }
    
    return { description => "microarray probes",
	     data => \@stash,
    };
}

=head3 orfeome_primers

This method will return a data structure containing
ORFeome primers flanking the gene.

=over

=item PERL API

 $data = $model->orfeome_primers();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/orfeome_primers

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub orfeome_primers {
    my $self   = shift;
    my $object = $self->object;
    my @segments = $self->_segments ? @{$self->_segments} : undef ;
    my @ost = map { $self->_pack_obj($_)} map {$_->info} map { $_->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome') } @segments if ($object->Corresponding_CDS || $object->Corresponding_Pseudogene);
    
    return { description =>  "ORFeome Project primers and sequences",
	     data        =>  \@ost };
}


=head3 primer_pairs

This method will return a data structure containing
other names that have also been used to refer to the
gene.

=over

=item PERL API

 $data = $model->primer_pairs();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/primer_pairs

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub primer_pairs {
    my $self   = shift;
    my $object = $self->object;
    
    return unless @{$self->sequences};
    
    my @segments = @{$self->_segments};
    my @primer_pairs =  
	map {$self->_pack_obj($_)} 
    map {$_->info} 
    map { $_->features('PCR_product:GenePair_STS','structural:PCR_product') } @segments;
    
    return { description =>  "Primer pairs",
	     data        =>  \@primer_pairs };
}

=head3 sage_tags

This method will return a data structure containing
Serial Analysis of Gene Expresion (SAGE) tags
that map to the gene.

=over

=item PERL API

 $data = $model->sage_tags();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/sage_tags

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;
    
    my @sage_tags = map {$self->_pack_obj($_)} $object->Sage_tag;
    
    return {  description =>  "SAGE tags identified",
	      data        =>  \@sage_tags
    };
}


=head3 transgenes

This method will return a data structure containing
trasngenes driven by the gene.

=over

=item PERL API

 $data = $model->transgenes();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/transgenes

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transgenes {
    my $self   = shift;
    my $object = $self->object;
    
    my @data; 
    foreach ($object->Drives_transgene) {
	my $summary = $_->Summary;
	push @data, { transgene  => $self->_pack_obj($_),
		      laboratory => eval {$_->Location} ? $self->_pack_obj($_->Location) : '',
		      summary    => "$summary",
	};
    }
    
    return {
	description => 'transgenes expressed by this gene',
	data        => \@data };    
}

=head3 transgene_products

This method will return a data structure containing
trasngenes that express this gene.

=over

=item PERL API

 $data = $model->transgene_products();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID (eg WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/transgene_products

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub transgene_products {
    my $self   = shift;
    my $object = $self->object;

    my @data; 
    foreach ($object->Transgene_product) {
	my $summary = $_->Summary;
	push @data, { transgene  => $self->_pack_obj($_),
		      laboratory => eval {$_->Location} ? $self->_pack_obj($_->Location) : '',
		      summary    => "$summary",
	};
    }
    
    return {
	description => 'transgenes that express this gene',
	data        => \@data };    
}

#######################################
#
# The Regulation Widget
#   template: classes/gene/regulation.tt2
#
#######################################

=head2 Regulation

=cut

=head3 regulation_on_expression_level

This method returns a data structure containing the 
a data table describing the regulation on expression
level.

=over

=item PERL API

 $data = $model->regulation_on_expression_level();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/regulation_on_expression_level

B<Response example>

=cut

sub regulation_on_expression_level {
    my $self   = shift;
    my $object = $self->object;
    return unless ($object->Gene_regulation);
    
    my @stash;

    # Explore the relationship in both directions.
    foreach my $tag (qw/Trans_regulator Trans_target/) {
	my $join = ($tag eq 'Trans_regulator') ? 'regulated by' : 'regulates';
	if (my @gene_reg = $object->$tag(-filled=>1)) {
	    foreach my $gene_reg (@gene_reg) {
		my ($string,$target);
		if ($tag eq 'Trans_regulator') {
		    $target = $gene_reg->Trans_regulated_gene(-filled=>1)
			|| $gene_reg->Trans_regulated_seq(-filled=>1)
			|| $gene_reg->Other_regulated(-filled=>1);
		} else {
		    $target = $gene_reg->Trans_regulator_gene(-filled=>1)
			|| $gene_reg->Trans_regulator_seq(-filled=>1)
			|| $gene_reg->Other_regulator(-filled=>1);
		}
		# What is the nature of the regulation?
		# If Positive_regulate and Negative_regulate are present
		# in the same gene object, then it means the localization is changed.  Go figure.
		if ($gene_reg->Positive_regulate && $gene_reg->Negative_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Changes localization of '
			: 'Localization changed by ';
		} elsif ($gene_reg->Result eq 'Does_not_regulate') {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Does not regulate '
			: 'Not regulated by ';
		} elsif ($gene_reg->Positive_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Positively regulates '
			: 'Positively regulated by ';
		} elsif ($gene_reg->Negative_regulate) {
		    $string .= ($tag eq 'Trans_regulator')
			? 'Negatively regulates '
			: 'Negatively regulated by ';
		}
	
		my $common_name     = $self->_public_name($target);
		push @stash,{ string => $string,
			      target => $self->_pack_obj($target, $common_name),
			      gene_regulation => $self->_pack_obj($gene_reg)};
	    }
	}
    }
    return { description => 'Regulation on expression level',
	     data        => \@stash };
}







#######################################
#
# The References Widget
#
#######################################

=head2 References

=cut

# sub references {}
# Supplied by Role; POD will automatically be inserted here.
# << include references >>


#######################################
#
# The Sequences Widget
#
#######################################

=head2 Sequences

=cut

=head3 gene_models

This method will return an extensive data structure containing
gene models for the gene.

=over

=item PERL API

 $data = $model->gene_models();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

a WBGene ID

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/gene_models

B<Response example>

<div class="response-example"></div>

=back

=cut 

sub gene_models {
  my $self = shift;
  my $object = $self->object;
  my $seqs = $self->sequences;

  my @rows;

  # $sequence could potentially be a Transcript, CDS, Pseudogene - but
  # I still need to fetch some details from sequence
  # Fetch a variety of information about all transcripts / CDS prior to printing
  # These will be stored using the following keys (which correspond to column headers)

  foreach my $sequence (sort { $a cmp $b } @$seqs) {
    my %data = ();
    my $model = $self->_pack_obj($sequence);
    my $gff = $self->fetch_gff_gene($sequence) or next;
    my $cds = ($sequence->class eq 'CDS') ? $sequence : eval { $sequence->Corresponding_CDS };

    my ($confirm,$remark,$protein,@matching_cdna);
    if ($cds) {
      $confirm = $cds->Prediction_status; # with or without being confirmed
      @matching_cdna = $cds->Matching_cDNA; # with or without matching_cdna
      $protein = $cds->Corresponding_protein(-fill=>1);
    }

    # Fetch all the notes for this given sequence / CDS
    my @notes = (eval {$cds->DB_remark},$sequence->DB_remark,eval {$cds->Remark},$sequence->Remark);

    # Save all the remarks for each gene model.
    # We will create unique list of footnotes in the view.
    $data{remarks} = \@notes;
    
    if ($confirm eq 'Confirmed') {
	$data{status} = "confirmed by cDNA(s)";
    } elsif (@matching_cdna && $confirm eq 'Partially_confirmed') {
	$data{status} = "partially confirmed by cDNA(s)";
    } elsif ($confirm eq 'Partially_confirmed') {
	$data{status} = "partially confirmed";
    } elsif ($cds && $cds->Method eq 'history') {
	$data{status} = 'historical';
    } else {
	$data{status} = "predicted";
    }
    
    my $len_unspliced  = $gff->length;
    my $len_spliced = 0;

    for ($gff->features('coding_exon')) {

    if ($object->Species =~ /elegans/) {
        next unless $_->source eq 'Coding_transcript';
    } else {        
        next unless $_->method =~ /coding_exon/ && $_->source eq 'Coding_transcript';
    }
    next unless $_->name eq $sequence;
    $len_spliced += $_->length;
    }
#     Try calculating the spliced length for pseudogenes
    if (!$len_spliced) {
      my $flag = eval { $object->Corresponding_Pseudogene } || $cds;
      for ($gff->features('exon:Pseudogene')) {
        next unless ($_->name eq $flag);
        $len_spliced += $_->length;
      }
    }
    $len_spliced ||= '-';

    $data{length_spliced}   = $len_spliced;
    $data{length_unspliced} = $len_unspliced;

    if ($protein) {
      my $peplen = $protein->Peptide(2);
      my $aa   = "$peplen aa";
      $data{length_protein} = $aa if $aa;
    }
    my $protein_desc = $self->_pack_obj($protein);
    $data{model}   = $model    if $model;
    $data{protein} = $protein_desc if $protein_desc;

    push @rows,\%data;
  }

   my $data = { description => 'gene models for this gene',
                data        =>  @rows ? \@rows : undef};
   return $data;
}



# TH: Retired 2011.08.17; safe to delete or transmogrify to some other function.
# should we return entire sequence obj or just linking/description info? -AC
sub other_sequences {
    my $self   = shift;
    my $object = $self->object;
    my @data;
    foreach ($object->Other_sequence) {
	my $title = $_->Title;
	push @data, {sequence    => $self->_pack_obj($_),
		     description => "$title" };
    }

    return { 
	description => 'Other sequences associated with gene',
	data        => \@data,
    };
}





#########################################
#
#   INTERNAL METHODS
#
#########################################
sub fetch_gff_gene {
 my ($self,$transcript) = @_;

  my $trans;
  my $GFF = $self->gff_dsn() || return $trans;
  eval {$GFF->fetch_group()}; return $trans if $@;

  if ($self->object->Species =~ /briggsae/) {
      ($trans)      = grep {$_->method eq 'wormbase_cds'} $GFF->fetch_group(Transcript => $transcript);
  }
  ($trans)      = grep {$_->method eq 'full_transcript'} $GFF->fetch_group(Transcript => $transcript) unless $trans;

  # Now pseudogenes
  ($trans) = grep {$_->method eq 'pseudo'} $GFF->fetch_group(Pseudogene => $transcript) unless ($trans);

  # RNA transcripts - this is getting out of hand
  ($trans) = $GFF->segment(Transcript => $transcript) unless ($trans);
  return $trans;
}






# This is for GO processing
# TH: I don't understand the significance of the nomenclature.
# Oh wait, I see, it's used to force an order in the view.
# This should probably be an attribute or view configuration.
sub _go_method_detail {
    my ($self,$method,$detail) = @_;
    if ($method =~ m/Paper/){
        return 'a_Curated';
    } elsif ($detail =~ m/phenotype/i) {
        return 'b_Phenotype to GO Mapping';
    } elsif ($detail =~ m/interpro/i) {
        return 'c_Interpro to GO Mapping';
    } elsif ($detail =~ m/tmhmm/i) {
        return 'd_TMHMM to GO Mapping';
    } else {
        return 'z_No Method';
    }
}

 
# Fetch unique transcripts (Transcripts or Pseudogenes) for the gene
sub _fetch_transcripts {  
    my $self = shift;
    my $object = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $object->Corresponding_transcript;
    my @cds  = $object->Corresponding_CDS;
    foreach (@cds) {
	next if defined $seen{$_};
	my @transcripts = grep {!$seen{$_}++} $_->Corresponding_transcript;
	push (@seqs,(@transcripts) ? @transcripts : $_);
    }
    @seqs = $object->Corresponding_Pseudogene unless @seqs;
    return \@seqs;
}

sub _build__segments {
    my ($self) = @_;
    my $sequences = $self->sequences;
    my @segments;
    my $dbh = $self->gff_dsn() || return \@segments;

    my $object = $self->object;
    my $species = $object->Species;

    eval {$dbh->segment()}; return \@segments if $@;

    # Yuck. Still have some species specific stuff here.

    if (@$sequences and $species =~ /briggsae/) {
        if (@segments = map {$dbh->segment(CDS => "$_")} @$sequences
            or @segments = map {$dbh->segment(Pseudogene => "$_")} @$sequences) {
            return \@segments;
        }
    }

    if (@segments = $dbh->segment(Gene => $object)
        or @segments = map {$dbh->segment(CDS => $_)} @$sequences
        or @segments = map { $dbh->segment(Pseudogene => $_) } $object->Corresponding_Pseudogene # Pseudogenes (B0399.t10)
        or @segments = map { $dbh->segment(Transcript => $_) } $object->Corresponding_Transcript # RNA transcripts (lin-4, sup-5)
    ) {
        return \@segments;
    }

    return;
}

# TODO: Logically this might reside in Model::GFF although I don't know if it is used elsewhere
# Find the longest GFF segment
sub _longest_segment {
    my ($self) = @_;
    # Not all genes are cloned and will have segments associated with them.
    my ($longest)
	= sort { $b->abs_end - $b->abs_start <=> $a->abs_end - $a->_abs_start}
    @{$self->_segments} if $self->_segments;
    return $longest;
}

sub _select_protein_description {
    my ($self,$seq,$protein) = @_;
    my %labels = (Pseudogene => 'Pseudogene; not attached to protein',
		  history     => 'historical prediction',
		  RNA         => 'non-coding RNA transcript',
		  Transcript  => 'non-coding RNA transcript',
	);
    my $error = $labels{eval{$seq->Method}};
    $error ||= eval { ($seq->Remark =~ /dead/i) ? 'dead/retired gene' : ''};
    my $msg = $protein ? $protein : $error;
    return $msg;
}


# I need to retain this in order to link to Treefam.
sub _fetch_protein_ids {
    my ($self,$s,$tag) = @_;
    my @dbs = $s->Database;
    foreach (@dbs) {
	return $_->right(2) if (/$tag/i);
    }
    return;
}

# TODO: This could logically be moved into a template
sub _other_notes {
    my ($self,$object) = @_;
    
    my @notes;
    if ($object->Corresponding_Pseudogene) {
	push (@notes,'This gene is thought to be a pseudogene');
    }
    
    if ($object->CGC_name || $object->Other_name) {
	if (my @contained_in = $object->In_cluster) {
#####      my $cluster = join ' ',map{a({-href=>Url('gene'=>"name=$_")},$_)} @contained_in;
	    my $cluster = join(' ',@contained_in);
	    push @notes,"This gene is contained in gene cluster $cluster.\n";
	}
	
#####    push @notes,map { GetEvidence(-obj=>$_,-dont_link=>1) } $object->Remark if $object->Remark;
	push @notes,$object->Remark if $object->Remark;
    }
    
    # Add a brief remark for Transposon CDS entries
    push @notes,
    'This gene is believed to represent the remnant of a transposon which is no longer functional'
	if (eval {$object->Corresponding_CDS->Method eq 'Transposon_CDS'});
    
    foreach (@notes) {
	$_ = ucfirst($_);
	$_ .= '.' unless /\.$/;
    }
    return \@notes;
}




sub parse_year {
    my $date = shift;
    $date =~ /.*(\d\d\d\d).*/;
    my $year = $1 || $date;
    return $year;
}


sub _pattern_thumbnail {
    my ($self,$ep) = @_;
    return '' unless $self->_is_cached($ep->name);
    my $terms = join ', ', map {$_->Term} $ep->Anatomy_term;
    $terms ||= "No adult terms in the database";
    return ([$ep,$terms]);
}

# Meh. This is a view component and doesn't belong here.
sub _is_cached {
    my ($self,$ep) = @_;
    my $WORMVIEW_IMG = '/usr/local/wormbase/html/images/expression/assembled/';
    return -e $WORMVIEW_IMG . "$ep.png";
}



sub _y2h_data {
    my ($self,$object,$limit,$c) = @_;
    my %tags = ('YH_bait'   => 'Target_overlapping_CDS',
		'YH_target' => 'Bait_overlapping_CDS');
    
    my %results;
    foreach my $tag (keys %tags) {
	if (my @data = $object->$tag) {
	    
# Map baits/targets to CDSs
	    my $subtag = $tags{$tag};
	    my %seen = ();
	    foreach (@data) {
		my @cds = $_->$subtag;
		
		unless (@cds) {
		    my $try_again = ($subtag eq 'Bait_overlapping_CDS') ? 'Target_overlapping_CDS' : 'Bait_overlapping_CDS';
		    @cds = $_->$try_again;
		}
		
		unless (@cds) {
		    my $try_again = ($subtag eq 'Bait_overlapping_CDS') ? 'Bait_overlapping_gene' : 'Target_overlapping_gene';
		    my $new_gene = $_->$try_again;
		    @cds = $new_gene->Corresponding_CDS if $new_gene;
		}
		
		foreach my $cds (@cds) {
		    push @{$seen{$cds}},$_;
		}    
	    }
	    
	    my $count = 0;
	    for my $cds (keys %seen){
		my ($y2h_ref,$count);
		my $str = "See: ";
		for my $y2h (@{$seen{$cds}}) {
		    $count++;
		    # If we are limiting for the main page, append a link to "more"
		    last if ($limit && $count > $limit);
#	  $str    .= " " . $c->object2link($y2h);
		    $str    .= " " . $y2h;
		    $y2h_ref  = $y2h->Reference;
		}
		if ($limit && $count > $limit) {
#	  my $link = DisplayMoreLink(\@data,'y2h',undef,'more',1);
#	  $link =~ s/[\[\]]//g;
#	  $str .= " $link";
		}
		my $dbh = $self->service('acedb');
		my $k_cds = $dbh->fetch(CDS => $cds);
		#	push @{$results{$tag}}, [$c->object2link($k_cds) . " [" . $str ."]", $y2h_ref];
		push @{$results{$tag}}, [$k_cds . " [" . $str ."]", $y2h_ref];
	    }
	}
    }
    return (\@{$results{'YH_bait'}},\@{$results{'YH_target'}});
}



# This is one big ugly hack job
sub _go_evidence_code {
    my ($self,$term) = @_;
    my @type      = $term->col;
    my @evidence  = $term->right->col if $term->right;
    my @results;
    foreach my $type (@type) {
	my $evidence = '';
	
	for my $ev (@evidence) {
	    my $desc;
	    my (@supporting_data) = $ev->col;
	    
	    # For IMP, this is semi-formatted text remark
	    if ($type eq 'IMP' && $type->right eq 'Inferred_automatically') {
		my (%phenes,%rnai);
		foreach (@supporting_data) {
		    my @row;
		    $_ =~ /(.*) \(WBPhenotype(.*)\|WBRNAi(.*)\)/;
		    my ($phene,$wb_phene,$wb_rnai) = ($1,$2,$3);
		    $rnai{$wb_rnai}++ if $wb_rnai;
		    $phenes{$wb_phene}++ if $wb_phene;
		}
#	$evidence .= 'via Phenotype: '
#	  #		  . join(', ',map { a({-href=>ObjectLink('phenotype',"WBPhenotype$_")},$_) }
#	  . join(', ',map { a({-href=>Object2URL("WBPhenotype$_",'phenotype')},$_) }
#		 
#		 keys %phenes) if keys %phenes > 0;
		
		$evidence .= 'via Phenotype: '
		    . join(', ',		 keys %phenes) if keys %phenes > 0;
		
		$evidence .= '; ' if $evidence && keys %rnai > 0;
		
#	$evidence .= 'via RNAi: '
#	  . join(', ',map { a({-href=>Object2URL("WBRNAi$_",'rnai')},$_) } 
#		 keys %rnai) if keys %rnai > 0;
		$evidence .= 'via RNAi: '
		    . join(', ', keys %rnai) if keys %rnai > 0;
		
		next;
	    }
	    
	    my @seen;
	    
	    foreach (@supporting_data) {
		if ($_->class eq 'Paper') {  # a paper
#	  push @seen,ObjectLink($_,build_citation(-paper=>$_,-format=>'short'));
		    
		    push @seen,$_;
		} elsif ($_->class eq 'Person') {
		    #		  push @seen,ObjectLink($_,$_->Standard_name);
		    next;
		} elsif ($_->class eq 'Text' && $ev =~ /Protein/) {  # a protein
#	  push @seen,a({-href=>sprintf(Configuration->Protein_links->{NCBI},$_),-target=>'_blank'},$_);
		} else {
#	  push @seen,ObjectLink($_);
		    push @seen,$_;
		}
	    }
	    if (@seen) {
		$evidence .= ($evidence ? ' and ' : '') . "via $desc ";
		$evidence .= join('; ',@seen); 
	    }
	}
	
	
	# Return an array of arrays, containing the go evidence code (IMP, IEA) and its source (RNAi, paper, curator, etc)
	push @results,[$type,($type eq 'IEA') ? 'via InterPro' : $evidence];
    }
    #my @proteins = $term->at('Protein_id_evidence');
    return @results;
}

sub _fetch_sequences {

	my $self = shift;
	my $GENE = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $GENE->Corresponding_transcript;
    my @cds = $GENE->Corresponding_CDS;
    foreach (@cds) {
	next if defined $seen{$_};
	my @transcripts = grep {!$seen{$_}++} $_->Corresponding_transcript;
	push (@seqs,(@transcripts)? @transcripts : $_);
    }
    @seqs = $GENE->Corresponding_Pseudogene unless @seqs;
	return @seqs;
    
}



### get phenotype ids from outputs of get_phenotype_data() and get_variation_data() and provides corresponding phenotype names
### syntax: $phene_id2name_hr = get_phenotype_names(rnai_ar,var_ar)

sub _get_phenotype_names {

	my ($self, $rnai_ar, $var_ar) = @_;
	my %phene_master;
	
	foreach my $rnai_phene_line (@$rnai_ar) {
	
		my ($phene_id, $disc) = split /\|/,$rnai_phene_line;
		$phene_master{$phene_id} = 1;
	}
	
	foreach my $var_phene_line (@$var_ar) {
	
		my ($phene_id, $disc) = split /\|/,$var_phene_line;	
		$phene_master{$phene_id} = 1;
	}
	
	my %phene_id2name;
	my %fullset_phene_id2name = build_hash($self->gene_pheno_datadir.$self->pre_compile->{phenotype_name_file});
	foreach my $phene_id (keys %phene_master) {
				
		$phene_id2name{$phene_id} = $fullset_phene_id2name{$phene_id};  ## $phene_primary_name
	}
	
	return \%phene_id2name;
}



sub _get_xgene_data {

	my ($self, $positive_results) = @_; ## , $phenotype_ar
	
	my $gene_xgene_data; 
	if($positive_results) {
	
		$gene_xgene_data = $self->phenotype_data->{'gene_xgene_data'}; # `grep $gene  $gene_xgene_phene_file | grep -v Not `;
	
	} else {
	
		$gene_xgene_data = $self->phenotype_data->{'gene_xgene_data_not'};#`grep $gene $gene_xgene_phene_file | grep Not `;
	
	}
	
	#print "$gene_variation_data\n";
	
	my @gene_xgene_data = split /\n/, $gene_xgene_data;
	
	my %phenotype_xgene;
	
	foreach my $xgene_data_line (@gene_xgene_data) {
	
		my ($gene,$xgene,$phenotype,$not,$seq_stat)  = split /\|/, $xgene_data_line;
		$xgene = $xgene . "+" . $seq_stat;
		$phenotype_xgene{$phenotype}{$xgene} = 1;
		
	}
	
	my @return_data;

	foreach my $phene (keys %phenotype_xgene) {
	
		my $xgenes_hr = $phenotype_xgene{$phene};
		my @xgenes = keys %$xgenes_hr;
		my $xgenes_line = join "&", @xgenes;
		push @return_data, "$phene\|$xgenes_line";
	}

	return \@return_data;	
}


sub _get_phenotype_data {

	my ($self, $positive_results) = @_;
	
	my %rnai_phenotypes;
	my %rnai_genotype;
	my %rnai_ref;

	my $rnai_data = $self->phenotype_data->{'rnai_data'};
	my @rnai_data_lines = split "\n", $rnai_data;
	
	foreach my $rnai_data_line (@rnai_data_lines) {
	
		chomp $rnai_data_line;
		my ($rnai,$genotype,$ref) = split /\|/,$rnai_data_line;
		# print "$rnai_data_line\n";
		
		$rnai_genotype{$rnai} = $genotype;
		$rnai_ref{$rnai} = $ref;
		
	}
	
	my $gene_phenotype_data;
	
	if($positive_results) {
	
		$gene_phenotype_data =  $self->phenotype_data->{gene_rnai_pheno_data}; #`grep $gene $gene_rnai_phene_file | grep -v Not `;
	
	} else {
	
		$gene_phenotype_data = $self->phenotype_data->{gene_rnai_pheno_not_data}; # = `grep $gene $gene_rnai_phene_file | grep Not `;
	}
	

	#print "$gene_phenotype_data\n";
	my @gene_phenotype_data = split /\n/,$gene_phenotype_data;
	my %rnai_pheno_data;
	my %pheno_rnai_data;
	foreach my $gene_phenotype_data_line (@gene_phenotype_data) {
	
		#print "\=\>$gene_phenotype_data_line\n";
		
		my ($gene_id,$rnai_id,$pheno_id) = split /\|/,$gene_phenotype_data_line;
		
		$rnai_pheno_data{$rnai_id}{$pheno_id} = 1;
		$pheno_rnai_data{$pheno_id}{$rnai_id} = 1;
	
	}

	my @rnais  = keys %rnai_pheno_data;
	my @details;
	my @phenotype_return;
	
	foreach my $rnai (@rnais) {
	
		my $pheno_ids_hr =  $rnai_pheno_data{$rnai};
		my $pheno_ids = join "&", keys %$pheno_ids_hr;
	
		push @details, "$rnai\|$pheno_ids\|$rnai_genotype{$rnai}\|$rnai_ref{$rnai}";
	}
	
	foreach my $phenotype (keys %pheno_rnai_data) {
	
		my $rnai_ids_hr = $pheno_rnai_data{$phenotype};
		my @rnai_ids = keys %$rnai_ids_hr;
		my $rnai_id_count = @rnai_ids;
		push @phenotype_return, "$phenotype\|$rnai_id_count";
	}
	
	return \@details, \@phenotype_return;

}




### pulls variation data from file for inputed gene
### syntax: $variation_data_ar = get_variation_data('gene_id');
### array_ref for lines: phenotype_id|var1&var2&var3


sub _get_variation_data {

	my ($self,$positive_results) = @_; ## , $phenotype_ar
	my $gene_variation_data;
    
	if($positive_results) {
	
		$gene_variation_data = $self->phenotype_data->{'gene_variation_data'}; # `grep $gene $gene_variation_phene_file | grep -v Not `;
	
	} else {
	
		$gene_variation_data = $self->phenotype_data->{'gene_variation_data_not'}; #`grep $gene $gene_variation_phene_file | grep Not `;
	
	}
	
	my @gene_variation_data = split /\n/, $gene_variation_data;
	my %phenotype_variation;
	my %variation_id2name;

	foreach my $var_data_line (@gene_variation_data) {
		my ($gene,$var,$phenotype,$not,$seq_stat,$var_name)  = split /\|/, $var_data_line;
		$variation_id2name{$var} = $var_name;
		$var = $var . "+" . $seq_stat;
		$phenotype_variation{$phenotype}{$var} = 1;	
	}

	my @return_data;
	
	foreach my $phene (keys %phenotype_variation) {
		my $vars_hr = $phenotype_variation{$phene};
		my @vars = keys %$vars_hr;
		my $vars_line = join "&", @vars;
		push @return_data, "$phene\|$vars_line";
	}
	return \@return_data, \%variation_id2name;
}



sub _gene_rnai_pheno_data_compile { ## on going
    my ($self) = @_;
   	my $object = $self->object;
    my $na = '';
	my $output = "";
	my $p2n = "";
	my %uniq; 
	my %phenotype2name;	
	    
	foreach my $rnai ($object->RNAi_result) {
	    
	    my @phenotypes = $rnai->Phenotype;
		
	    foreach my $interaction ($rnai->Interaction) {
		my @types = $interaction->Interaction_type;
			foreach (@types) {		    
				push @phenotypes,map { $_->right } grep { $_ eq 'Interaction_phenotype' } $_->col;		    
			}
	    }
	    next unless @phenotypes > 0;
	    
	    foreach my $phenotype (@phenotypes) {
	    	my $phenotype_name = $phenotype->Primary_name;
	    	$uniq{"$object\|$rnai\|$phenotype\|$na"} = 1;
	    	$phenotype2name{"$phenotype\=\>$phenotype_name"} = 1;
	    }
	}

	$output = $output . join("\n",keys %uniq);
	$p2n = $p2n . join("\n",keys %phenotype2name);	
	my $phenotype_id2name = $self->phenotype_id2name;
	$phenotype_id2name = $phenotype_id2name . "\n" . $p2n;
	$self->phenotype_id2name("$phenotype_id2name");
	return $output;
}

sub _gene_rnai_pheno_not_data_compile {
    my ($self) = @_;
	my $object = $self->object;
    my $output = "";
	my $p2n = "";
    
    my $na = 'Not';
	my @rnai = $object->RNAi_result;    
	my %uniq; 
	my %phenotype2name;
	
	foreach my $rnai (@rnai) {
	    my @phenotypes = $rnai->Phenotype_not_observed;
	    
	    foreach my $phenotype (@phenotypes) {		
	    	my $phenotype_name = $phenotype->Primary_name;
			$uniq{"$object\|$rnai\|$phenotype\|$na"} = 1;
	    	$phenotype2name{"$phenotype\=\>$phenotype_name"} = 1;
	    }
	}
	$output = $output . join("\n",keys %uniq);
	$p2n = $p2n . join("\n",keys %phenotype2name);
	
	my $phenotype_id2name = $self->phenotype_id2name;
	$phenotype_id2name = $phenotype_id2name . "\n" . $p2n;
	$self->phenotype_id2name("$phenotype_id2name");
	return $output;
}

sub _gene_xgene_pheno_data_compile{

	my $self = shift @_;		
	my $object = $self->object;
	my %lines;
	my %lines_not;
	my $p2n = "";
		
	my @xgenes = $object->Drives_Transgene;
	my @xgene_product = $object->Transgene_product;
	my @xgene_rescue = eval{ $object->Rescued_by_transgene };
	
	push @xgenes,@xgene_product;
	push @xgenes,@xgene_rescue;
	
	my %phenotype2name;
	
	foreach my $xgene (@xgenes) {

		my @phenotypes = $xgene->Phenotype;
	
		foreach my $phenotype (@phenotypes) {
			my $phenotype_name = $phenotype->Primary_name;
			my $na = "";
			$lines{"$object\|$xgene\|$phenotype\|$na"} = 1;
			$phenotype2name{"$phenotype\=\>$phenotype_name"} = 1;
		}	
		
		my @phenotype_nots = $xgene->Phenotype_not_observed;
		
		foreach my $phenotype_not (@phenotype_nots) {
			my $phenotype_name = $phenotype_not->Primary_name;
			my $na = "Not";
			$lines_not{"$object\|$xgene\|$phenotype_not\|$na"} = 1;
			$phenotype2name{"$phenotype_not\=\>$phenotype_name"} = 1;
		}		
	}
	$p2n = $p2n . join("\n",keys %phenotype2name);
	my $phenotype_id2name = $self->phenotype_id2name;
	$phenotype_id2name = $phenotype_id2name . "\n" . $p2n;
	$self->phenotype_id2name("$phenotype_id2name");
	my $output = join ("\n" , keys %lines);
	my $output_not = join ("\n" , keys %lines_not);
	return $output,$output_not ;
}
 
sub _variation_data_compile{
	
	my $self = shift @_;						
	my $object = $self->object;
	my %lines;
	my %lines_not;
	my $p2n = "";
	my %phenotype2name;
	
	my @variations = $object->Allele;
	
	foreach my $variation (@variations) {

		my $seq_status = $variation->SeqStatus;
		my $variation_name = $variation->Public_name;
		my @phenotypes = $variation->Phenotype;
		my @phenotype_nots = $variation->Phenotype_not_observed;
		
		foreach my $phenotype (@phenotypes) {
			my $phenotype_name = $phenotype->Primary_name;
			my $na = "";
			$lines{"$object\|$variation\|$phenotype\|$na\|$seq_status\|$variation_name"} = 1;
			$phenotype2name{"$phenotype\=\>$phenotype_name"} = 1;
		}
		foreach my $phenotype (@phenotype_nots) {	
			my $na = "Not";			
			my $phenotype_name = $phenotype->Primary_name;
			$lines_not{"$object\|$variation\|$phenotype\|$na\|$seq_status\|$variation_name"} = 1;
			$phenotype2name{"$phenotype\=\>$phenotype_name"} = 1;
			
		}
	}
	
	$p2n = $p2n . join("\n",keys %phenotype2name);
	my $phenotype_id2name = $self->phenotype_id2name;
	$phenotype_id2name = $phenotype_id2name . "\n" . $p2n;
	$self->phenotype_id2name("$phenotype_id2name");
	my $output = join ("\n" , keys %lines);
	my $output_not = join ("\n" , keys %lines_not);
	return $output, $output_not;
}


sub _rnai_data_compile{

	my $self = shift;
	my $class = 'RNAi';
	my %lines;
	my $gene_rnai_data = $self->gene_rnai_pheno_data;
	my %rnais;
	my @rnai_datalines = split "\n",$gene_rnai_data;
	my $DB = $self->ace_dsn;
	
	foreach my $dataline (@rnai_datalines) {
		chomp $dataline;
		my ($gene,$rnai,$pheno,$not) = split /\|/,$dataline;
		$rnais{$rnai} = 1;
	}
	
	foreach my $unique_rnai (keys %rnais) {
		my $rnai_object = $DB->fetch(-class => $class, -name =>$unique_rnai); #, , -count => 20, -offset=>6800	
		my $ref;
		
		eval { $ref = $rnai_object->Reference;}; 
		
		my $genotype;
		my @experimental_details; # = $rnai_object->Experiment;
	
		eval {@experimental_details = $rnai_object->Experiment;};
	
		foreach my $experimental_detail (@experimental_details) {
				
			if($experimental_detail =~ m/Genotype/) {
			
				$genotype = $experimental_detail->right;
				$lines{"$rnai_object\|$genotype\|$ref"} = 1;
			}
			
			if($experimental_detail =~ m/Strain/) {
			
				my $strain = $experimental_detail->right;
				$genotype = $strain->Genotype;
				$lines{"$rnai_object\|$genotype\|$ref"} = 1;
			}	
		} 
	
		if(!($genotype)) {
			$lines{"$rnai_object\|$genotype\|$ref"} = 1;
		} else {
			next;
		}
	}

	my $output = join("\n",keys %lines);
	return $output;
}


sub build_hash{

	my ($file_name) = @_;
	open FILE, "< $file_name" or die "Cannot open the file: $file_name\n";

	my %hash;
	foreach my $line (<FILE>) {
		chomp ($line);
		my ($key, $value) = split '=>',$line;
		$hash{$key} = $value;
	}
	return %hash;
}



# helper method, retrieve public name from objects
sub _public_name {
    
    my ($self,$object) = @_;
    my $common_name;    
    my $class = eval{$object->class} || "";
   
    if ($class =~ /gene/i) {
        $common_name = 
        $object->Public_name
        || $object->CGC_name
        || $object->Molecular_name
        || eval { $object->Corresponding_CDS->Corresponding_protein }
        || $object;
    }
    elsif ($class =~ /protein/i) { 
        $common_name = 
        $object->Gene_name
        || eval { $object->Corresponding_CDS->Corresponding_protein }
        ||$object;
    }
    else {
        $common_name = $object;
    }
    
    my $data = $common_name;
    return "$data";


}






#######################################
#
# OBSOLETE METHODS?
#
#######################################

# Fetch all proteins associated with a gene.
## NB: figure out the naming convention for proteins

# NOTE: this method is not used
sub proteins {
    my $self   = shift;
    my $object = $self->object;   
    my $desc = 'proteins related to gene';   
        
    my @cds    = $object->Corresponding_CDS;
    my @proteins  = map { $_->Corresponding_protein } @cds;
    @proteins = map {$self->_pack_obj($_, $self->public_name($_, $_->class))} @proteins;
		
    return { description => 'proteins encoded by this gene',
	     data        => \@proteins };
}


# Fetch all CDSs associated with a gene.
## figure out naming convention for CDs

# NOTE: this method is not used
sub cds {
    my $self   = shift;
    my $object = $self->object;    
    my @cds    = $object->Corresponding_CDS;
    my $data_pack = $self->basic_package(\@cds);
    
    return { description => 'CDSs encoded by this gene',
	     data        => $data_pack };
}



# Fetch Homology Group Objects for this gene.
# Each is associated with a protein and we should probably
# retain that relationship

# NOTE: this method is not used
# TH: NOT YET CLEANED UP
sub kogs {
    my $self   = shift;
    my $object = $self->object;
    my @cds    = $object->Corresponding_CDS;
    my %data;
    my %data_pack;
    
    if (@cds) {
	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds;
	if (@proteins) {
	    my %seen;
	    my @kogs = grep {$_->Group_type ne 'InParanoid_group' } grep {!$seen{$_}++} 
	         map {$_->Homology_group} @proteins;
	    if (@kogs) {
	    	
	    	$data_pack{$object} = \@kogs;
			$data{'data'} = \%data_pack;

	    } else { 
	    
	    	$data_pack{$object} = 1;
	    
	    }
	}
    } else {
		$data_pack{$object} = 1;	
    }
    
    $data{'description'} = "KOGs related to gene";
 	return \%data;
}









__PACKAGE__->meta->make_immutable;

1;

