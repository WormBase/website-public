package WormBase::API::Object::Gene;

use Moose;
use File::Spec::Functions qw(catfile catdir);
use namespace::autoclean -except => 'meta';
use File::Temp;

extends 'WormBase::API::Object';
with    'WormBase::API::Role::Object';
with    'WormBase::API::Role::Position';
with    'WormBase::API::Role::Interaction';

=pod 

=head1 NAME

WormBase::API::Object::Gene

=head1 SYNPOSIS

Model for the Ace ?Gene class.

=head1 URL

http://wormbase.org/species/*/gene

=head1 METHODS/URIs

=cut

has '_all_proteins' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
        return [
            map { $_->Corresponding_protein(-fill => 1) }
                shift->object->Corresponding_CDS
        ];
    }
);

has 'sequences' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_sequences',
);

sub _build_sequences {
	my $self = shift;
	my $gene = $self->object;
    my %seen;
    my @seqs = grep { !$seen{$_}++} $gene->Corresponding_transcript;

    for my $cds ($gene->Corresponding_CDS) {
        next if defined $seen{$cds};
        my @transcripts = grep {!$seen{$cds}++} $cds->Corresponding_transcript;

        push (@seqs, @transcripts ? @transcripts : $cds);
    }
    return \@seqs if @seqs;
    return [$gene->Corresponding_Pseudogene];
}

has 'tracks' => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        return {
            description => 'tracks displayed in GBrowse',
            data        => [qw/CG Allele/],
        };
    }
);

has '_phenotypes' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__phenotypes',
);

sub _build__phenotypes {
    my ($self) = @_;
    my $object = $self->object;

    my %phenotypes;

    foreach my $type ('Drives_Transgene', 'Transgene_product', 'Allele', 'RNAi_result'){
	my $type_name; #label that shows in the evidence column above each list of that object type
	if ($type =~ /Transgene/) { $type_name = 'Transgene:'; } 
	elsif ($type eq 'RNAi_result') { $type_name = 'RNAi:'; }
	else { $type_name = $type . ':'; }

	foreach my $obj ($object->$type){

	    my $seq_status = eval { $obj->SeqStatus };
	    my $label = $obj =~ /WBRNAi0{0,3}(.*)/ ? $1 : undef;
	    my $packed_obj = $self->_pack_obj($obj, $label, style => ($seq_status ? scalar($seq_status =~ /sequenced/i) : 0) ? 'font-weight:bold': 0,);
	    
	    foreach my $obs ('Phenotype', 'Phenotype_not_observed'){
		foreach ($obj->$obs){
		    $phenotypes{$obs}{$_}{object} //= $self->_pack_obj($_);
		    my $evidence = $self->_get_evidence($_);
		    # add some additional information for RNAis
		    if ($type eq 'RNAi_result') {
			$evidence->{Paper} = [ $self->_pack_obj($obj->Reference) ];
			my $genotype = $obj->Genotype;
			$evidence->{Genotype} = "$genotype" if $genotype;
		    }
		    push @{$phenotypes{$obs}{$_}{evidence}{$type_name}}, { text=>$packed_obj, evidence=>$evidence } if $evidence && %$evidence;
		}
	    }
	}
    }

    return \%phenotypes;
}

#######################################
#
# The Overview Widget
#   template: classes/gene/overview.tt2
#
#######################################

# also_refers_to { }
# This method will return a data structure containing
# other names that have also been used to refer to the
# gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/also_refers_to

sub also_refers_to {
    my $self   = shift;
    my $object = $self->object;
    my $locus  = $object->CGC_name;

    my $pattern = qr/$object/;
    # Save other names that don't correspond to the current object.
    my @other_names_for = !$locus ? () :
        map { $self->_pack_obj($_) } grep { !/$pattern/ } $locus->Other_name_for;

    return {
        description => 'other genes that this locus name may refer to',
        data        => @other_names_for ? \@other_names_for : undef,
    };
}


# named_by { }
# This method will return a data structure containing
# the WB person who named the gene
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/named_by

sub named_by {
    my $self   = shift;
    my $object = $self->object;
    my $name = $self->_get_evidence($object->CGC_name);
    return {
        description => 'the person who named this gene',
        data        => $name ? @{$name->{Person_evidence}}[0] : undef,
    };
}

# classification { }
# This method will return a data structure containing
# the general classification of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/classification

sub classification {
    my $self   = shift;
    
    #optional second parameter: source object
    my $gene_obj = shift;
    my $object = $gene_obj ? $gene_obj : $self->object;

    my $data;

    $data->{defined_by_mutation} = $object->Allele ? 1 : 0;

    # General type: coding gene, pseudogene, or RNA
    $data->{type} = 'pseudogene' if $object->Corresponding_pseudogene;

    # Protein coding?
    my @cds = $object->Corresponding_CDS;
    if (@cds) {
        $data->{type} = "protein coding";
    }

    unless($data->{type}){
      # Is this a non-coding RNA?
      my @transcripts = $object->Corresponding_transcript;
      foreach (@transcripts) {
          $data->{type} = $_->Transcript;
          last;
      }
    }

    $data->{associated_sequence} = @cds ? 1 : 0;

    # Confirmed?
    $data->{confirmed} = @cds ? $cds[0]->Prediction_status->name : 0;
    my @matching_cdna = @cds ? $cds[0]->Matching_cDNA : '';

    # Create a prose description; possibly better in a template.
    my @prose;
    if (   $data->{locus}
        && $data->{associated_sequence} )
    {
        push @prose,
            "This gene has been defined mutationally and associated with a sequence.";
    }
    elsif ( $data->{associated_sequence} ) {
        push @prose, "This gene is known only by sequence.";
    }
    elsif ( $data->{locus} ) {
        push @prose, "This gene is known only by mutation.";
    }
    else { }

    # Is the locus name approved?
    if ( $data->{locus} && $data->{approved_name} ) {
        push @prose, "The gene name has been approved by the CGC.";
    }
    elsif ( $data->{locus} && !$data->{approved_name} ) {
        push @prose, "The gene name has not been approved by the CGC.";
    }

    # Confirmed or not?
    if ( $data->{confirmed} eq 'Confirmed' ) {
        push @prose, "Gene structures have been confirmed by a curator.";
    }
    elsif (@matching_cdna) {
        push @prose,
            "Gene structures have been partially confirmed by matching cDNA.";
    }
    else {
        push @prose, "Gene structures have not been confirmed.";
    }

    $data->{prose_description} = join( " ", @prose );

    return {
        description => 'gene type and status',
        data        => $data,
    };
}


# cloned_by { }
# This method will return a data structure containing
# the person or laboratory who cloned the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/cloned_by

sub cloned_by {
    my $self      = shift;

    my $datapack = {
        description => 'the person or laboratory who cloned this gene',
        data        => undef,
    };

    # This is an evidence hash. We're assuming scalar context.
    if (my $cloned_by = $self->object->Cloned_by) {
        my ($tag,$source) = $cloned_by->row;
        $datapack->{data} = {
            'cloned_by' => $cloned_by && "$cloned_by",
            'tag'       => $tag && "$tag",
            'source'    => $self->_pack_obj($source),
        };
    }

    return $datapack;
}

# clone { }
# This method will return a data structure containing
# the parent clone of the gene
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/clone

sub clone {
    my $self      = shift;
    my $object = $self->object;  
    return {
        description => 'parent clone of this gene',
        data        => $self->_pack_obj($object->Positive_clone),
    };
}


# concise_desciption { }
# This method will return a data structure containing
# the prose concise description of the gene, if one exists.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/concise_description

sub concise_description {
    my $self   = shift;
    my $object = $self->object;  
    
    my $description = 
	$object->Concise_description
	|| eval {$object->Corresponding_CDS->Concise_description}
        || eval { $object->Gene_class->Description }
        || $self->name->{data}->{label} . ' gene';
    
    my @evs = grep { "$_" eq "$description" } $object->Provisional_description;
    my $evidence = $self->_get_evidence($evs[0]);
    
    return {
      description => "A manually curated description of the gene's function",
      data        => { text => $description && "$description", evidence => $evidence }
    };
}


# gene_class { }
# This method will return a data structure containing
# the gene class packed tag of the gene, if one exists.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/gene_class

sub gene_class {
    my $self   = shift;
    my $gene_class = $self->object->Gene_class;  
    
    return {
    description => "The gene class for this gene",
    data        => $gene_class ? { tag => $self->_pack_obj($gene_class),
                     description => $gene_class ? $gene_class->Description : '',
    } : undef };
}



# operon { }
# This method will return a data structure containing
# the operon packed tag of the gene, if one exists.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/operon

sub operon {
    my $self   = shift;
    my $object = $self->object;  
    
    return {
    description => "Operon the gene is contained in",
    data        => $self->_pack_obj($object->Contained_in_operon)};
}


# legacy_information { }
# This method will return a data structure containing
# legacy information from the original Cold Spring Harbor
# C. elegans I & II texts.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/legacy_information

sub legacy_information {
  my $self   = shift;
  my $object = $self->object;
  my @description = map {"$_"} $object->Legacy_information;
  return { description => 'legacy information from the CSHL Press C. elegans I/II books',
	   data        => @description ? \@description : undef };
}

# locus_name { }
# This method will return a data structure containing
# the name of the genetic locus.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/locus_name

sub locus_name {
    my $self   = shift;
    my $object = $self->object;
    my $locus  = $object->CGC_name;   
    # Genes known only by sequence often lack a CGC (locus) name.
    return { description => 'the locus name (also known as the CGC name) of the gene',
	     data        => $locus ? $self->_pack_obj($locus->CGC_name_for, $locus && "$locus") : 'not assigned'}
}


# name {}
# Supplied by Role

# other_names {}
# Supplied by Role

# sequence_name { }
# This method will return a data structure containing
# the primary sequence name of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/sequence_name

sub sequence_name {
    my $self     = shift;
    my $sequence = $self->object->Sequence_name;
    # Not all genes have a sequence name (sch as those known only by mutation.)
    # This check is MOSTLY to handle relatively rare genes that have been killed.
    return { description => 'the primary corresponding sequence name of the gene, if known',
         data        => $sequence ? $sequence && "$sequence" : 'unknown' };
}


# status {}
# Supplied by Role

# structured_description { }
# This method will return a data structure containing
# various structured descriptions of gene's function.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/structured_description

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
      my @objs = $self->object->$type;
      @objs = grep { "$_" ne $self->object->Concise_description } @objs if $type eq "Provisional_description";
      my @array = map { {text=>"$_", evidence=>$self->_get_evidence($_) } } @objs;
      $ret{$type} = \@array if (@array > 0);
   }
   return { description => "structured descriptions of gene function",
	    data        =>  %ret ? \%ret : undef };
}

# human_disease_relevance { }
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/human_disease_relevance

sub human_disease_relevance {
    my $self = shift;
    my @objs = map { {text=>"$_", evidence=>$self->_get_evidence($_) } } $self->object->Human_disease_relevance;

    return {  description => "curated description of human disease relevance",
              data        =>  @objs ? \@objs : undef };
}

# taxonomy {}
# Supplied by Role

# version { }
# This method will return a data structure containing
# the current WormBase version of the gene.
# curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/version

sub version {
    return {
        description => 'the current WormBase version of the gene',
        data        => eval { shift->object->Version->name },
    };
}



#######################################
#
# The Expression Widget
#   template: classes/gene/expression.tt2
#
#######################################

# fourd_expression_movies { }
# This method will return a data structure containing
# links to four-dimensional expression movies.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/fourd_expression_movies

sub fourd_expression_movies {
    my $self   = shift;

    my $author;
    my %data = map {
        my $details = $_->Pattern;
        my $url     = $_->MovieURL;
        $_ => {
            movie   => $url && "$url",
            details => $details && "$details",
            object  => $self->_pack_obj($_),
        };
    } grep {
        (($author = $_->Author) && $author =~ /Mohler/ && $_->MovieURL)
    } @{$self ~~ '@Expr_pattern'};

    return {
        description => 'interactive 4D expression movies',
        data        => %data ? \%data : undef,
    };
}


# anatomic_expression_patterns { }
# This method will return a complex data structure 
# containing expression patterns described at the
# anatomic level. Includes links to images.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomic_expression_patterns

sub anatomic_expression_patterns {
    my $self   = shift;
    my $object = $self->object;
    my %data_pack;
    
    my $file = catfile($self->pre_compile->{image_file_base},$self->pre_compile->{gene_expression_path}, "$object.jpg");
    $data_pack{"image"}=catfile($self->pre_compile->{gene_expression_path}, "$object.jpg") if (-e $file && ! -z $file);

    # All expression patterns except Mohlers, presented elsewhere.
    my @eps = grep { !(($_->Author || '') =~ /Mohler/ && $_->MovieURL) }
                   $object->Expr_pattern;

    foreach my $ep (@eps) {
	my $file = catfile($self->pre_compile->{image_file_base},$self->pre_compile->{expression_object_path}, "$ep.jpg");
        $data_pack{"expr"}{"$ep"}{image}=catfile($self->pre_compile->{expression_object_path}, "$ep.jpg")  if (-e $file && ! -z $file);
        # $data_pack{"image"}{"$ep"}{image} = $self->_pattern_thumbnail($ep);
# <<<<<<< HEAD
#         my $pattern =  ($ep->Pattern || '') . ($ep->Subcellular_localization || '');
#         $pattern    =~ s/(.{384}).+/$1.../;
# =======

        my $pattern =  ($ep->Pattern || '') . ($ep->Subcellular_localization || '');
#         my $pattern =  ($ep->Pattern(-filled=>1) || '') . ($ep->Subcellular_localization(-filled=>1) || '');
#         $pattern    =~ s/(.{384}).+/$1.../;
		foreach($ep->Picture) {
			 next unless($_->class eq 'Picture');
	    	 my $pic = $self->_api->wrap($_);
			 if( $pic->image->{data}) {
        			$data_pack{"expr"}{"$ep"}{curated_images} = 1;
					last;
			 }	
		}
# >>>>>>> master
        $data_pack{"expr"}{"$ep"}{details} = $pattern;
        $data_pack{"expr"}{"$ep"}{object} = $self->_pack_obj($ep);
    }

    return {
        description => 'expression patterns for the gene',
        data        => %data_pack ? \%data_pack : undef,
    };
}



# anatomy_terms { }
# This method will return a hash 
# containing unique anatomy terms described from the
# expression patterns associated with this gene
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomy_terms

sub anatomy_terms {
    my $self   = shift;
    my $object = $self->object;


    my %unique_anatomy_terms;
    for my $ep ( $object->Expr_pattern ) {
        for my $at ($ep->Anatomy_term) {
          $unique_anatomy_terms{"$at"} ||= $self->_pack_obj($at);
        }
    }

    return {
        description => 'anatomy terms from expression patterns for the gene',
        data        => %unique_anatomy_terms ? \%unique_anatomy_terms : undef,
    };
}

# microarray_expression_data { }
# This method will return a data structure containing
# microarray expression data.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_expression_data

sub microarray_expression_data {
    my $self   = shift;
    my $object = $self->object;
    my %data;
    my @microarray_results = $object->Microarray_results;	
    return { data        => @microarray_results ? $self->_pack_objects(\@microarray_results) : undef,
	     description => 'gene expression determined via microarray analysis'};
}

# microrarray_topology_map_position { }
# This method will return a data structure containing
# the microarray "topology" map position.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_topology_map_position

sub microarray_topology_map_position {
    my $self   = shift;
    my $object = $self->object;

    my $datapack = {
        description => 'microarray topology map',
        data        => undef,
    };

    return $datapack unless @{$self->sequences};
    my @segments = $self->_segments && @{$self->_segments} or return $datapack;
    my @p = map { $_->info }
            $segments[0]->features('experimental_result_region:Expr_profile')
        or return $datapack;
    my %data = map {
        $_ => $self->_pack_obj($_, eval { 'Mountain ' . $_->Expr_map->Mountain })
    } @p;

    $datapack->{data} = \%data if %data;
    return $datapack;
}

# expression_cluster { }
# This method will return a data structure containing
# microarray expression clusters.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/expression_cluster

sub expression_cluster {
    my $self   = shift;
    my $object = $self->object;
    my @expr_clusters = $object->Expression_cluster;  
    return { data        => @expr_clusters ? $self->_pack_objects(\@expr_clusters) : undef,
	     description => 'expression cluster data' };
}


# anatomy_function { }
# This method will return a data structure containing
# the anatomy function of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomy_function

sub anatomy_function {
    my ($self) = @_;
    my $object = $self->object;
    my @data_pack;
    foreach ($object->Anatomy_function){
      my @bp_inv = map { if ("$_" eq "$object") {my $term = $_->Term; { text => $term && "$term", evidence => $self->_get_evidence($_)}}
                else { { text => $self->_pack_obj($_), evidence => $self->_get_evidence($_)}}
                } $_->Involved;
      next unless @bp_inv;
      my @assay = map { my $as = $_->right;
                  if ($as) {
                      my @geno = $as->Genotype;                   
                      {evidence => { genotype => join('<br /> ', @geno) },
                      text => "$_",}
                  }
                } $_->Assay;
      my $pev;
      push @data_pack, {
          phenotype => ($pev = $self->_get_evidence($_->Phenotype)) ? 
                            { evidence => $pev,
                            text => $self->_pack_obj(scalar $_->Phenotype)} : $self->_pack_obj(scalar $_->Phenotype),
          assay    => @assay ? \@assay : undef,
          bp_inv    => @bp_inv ? \@bp_inv : undef,
          reference => $self->_pack_obj(scalar $_->Reference),
      };
    } 

    return {
        data        => @data_pack ? \@data_pack : undef,
        description => 'anatomy functions associatated with this gene',
    };
}


#######################################
#
# The External Links widget
#   template: shared/widgets/xrefs.tt2
#
#######################################

# xrefs {}
# Supplied by Role

#######################################
#
# The Genetics Widget
#   template: classes/gene/genetics.tt2
#
#######################################

# alleles { }
# This method will return a complex data structure 
# containing alleles of the gene (but not including
# polymorphisms or other natural variations.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/alleles

sub alleles {
    my $self   = shift;
    my $object = $self->object;
    my @alleles = $object->Allele;

    my @data;
    foreach my $allele (@alleles) {
      next if grep {/SNP|RFLP/} $allele->Variation_type;
      push @data,$self->_process_variation($allele);       
    }
    
    return { description => 'alleles found within this gene',
	     data        => @data ? \@data : undef };
}

# polymorphisms { }
# This method will return a complex data structure 
# containing polymorphisms and natural variations
# but not alleles.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/polymorphisms

sub polymorphisms {
    my $self    = shift;
    my $object  = $self->object;
    my @alleles = $object->Allele;
    
    my @data;
    foreach my $allele (@alleles) {
      next unless grep {/SNP|RFLP/} $allele->Variation_type;
      push @data,$self->_process_variation($allele);
    }
    
    return { description => 'polymorphisms and natural variations found within this gene',
	     data        => @data ? \@data : undef };
}

# Private method: glean some information about a variation.
sub _process_variation {
    my ( $self, $variation ) = @_;

    my $type = lc( join ', ', $variation->Variation_type ) || 'unknown';

    my $molecular_change = lc( $variation->Type_of_mutation || "other" );

    my @phens = $variation->Phenotype;
    my %effects;
    my %locations;
    my ($aa_change,$aa_position);
    foreach my $type_affected ( $variation->Affects ) {
        foreach my $item_affected ( $type_affected->col ) {    # is a subtree
    	    foreach my $val ($item_affected->col){
              if ($val =~ /utr|intron|exon/i) { $locations{$val}++; } 
              else { 
                $effects{$val}++;
                if ($val =~ /missense/i) {
                  # Not specified for every allele.
                  my ($aa_position,$aa_change_string) = eval { $val->right->row };
                  if ($aa_change_string) {
                      $aa_change_string =~ /(.*)\sto\s(.*)/;
                      $aa_change = "$1$aa_position$2";
                  }
                }  elsif ($val =~ /nonsense/i) {
                  # "Position" here really one of Amber, Ochre, etc.
                  ($aa_position,$aa_change) = eval { $val->right->row; };
                }
              }
    	    }
        }
    }

    $type = "transposon insertion" if $variation->Transposon_insertion;
    my @effect = keys %effects;
    my @location = keys %locations;

    my %data = (
        variation        => $self->_pack_obj($variation),
        type             => $type && "$type",
        molecular_change => $molecular_change && "$molecular_change",
        aa_change        => $aa_change ? $aa_change : undef,
        effects          => @effect ? \@effect : undef,
        phen_count       => scalar @phens || 0,
        locations	 => @location ? \@location : undef,
    );
    return \%data;
}

# reference_allele { }
# This method will return a complex data structure 
# containing the reference allele of the gene, if
# one exists.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/reference_allele

sub reference_allele {
    my $self = shift;
    my $ref_alleles = $self ~~ '@Reference_allele' ;
    
    my @array = map { $self->_pack_obj($_) } @$ref_alleles;
    return { description => 'the reference allele of the gene',
	     data        => @array ? \@array : undef };
}

# strains { }
# This method will return a complex data structure 
# containing strains carrying the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/strains

sub strains {
    my $self   = shift;

    my @data;
    my %count;
    foreach ($self->object->Strain) {
        my @genes = $_->Gene;
        my $cgc   = ($_->Location eq 'CGC') ? 1 : 0;

        my $packed = $self->_pack_obj($_);
        my $genotype = $_->Genotype;
        $packed->{genotype} = $genotype && "$genotype";

        if (@genes == 1 && !$_->Transgene) {
          $cgc ? push @{$count{carrying_gene_alone_and_cgc}},$packed : push @{$count{carrying_gene_alone}},$packed;
        }
        else {
          $cgc ? push @{$count{available_from_cgc}},$packed : push @{$count{others}},$packed;
        }

	if (my $transgene = $_->Transgene) {
	    my $label = $transgene->Public_name;
	    $packed->{transgenes} = $self->_pack_obj($transgene,"$label");
	}
    }

    return {
        description => 'strains carrying this gene',
        data       => %count ? \%count : undef,
    };
}

# rearrangements { }    
# This method will return a data structure 
# containing rearrangements affecting the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/rearrangements

sub rearrangements {
    my $self    = shift;     
    my $object  = $self->object;
    my @positive = map { $self->_pack_obj($_) } $object->Inside_rearr;
    my @negative = map { $self->_pack_obj($_) } $object->Outside_rearr;

    return { description => 'rearrangements involving this gene',
	     data        => (@positive || @negative) ? { positive => \@positive,
			      negative => \@negative
	     } : undef
    };
}


#######################################
#
# The Gene Ontology widget
#   template: classes/gene/gene_ontology.tt2
#
#######################################

# gene ontology { }
# This method will return a data structure containing
# curated and electronically assigned gene ontology
# associations.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/gene_ontology

sub gene_ontology {
    my $self   = shift;
    my $object = $self->object;

    my %data;
    foreach my $go_term ( $object->GO_term ) {
        foreach my $code ( $go_term->col ) {
            my $method = join(", ", map {"$_"} (my @methods = $code->col));
            my $display_method = $self->_go_method_detail( $method, join(", ", map { $_->col } @methods) );

            my $facet = $go_term->Type;
            $facet =~ s/_/ /g if $facet;

            $display_method =~ m/.*_(.*)/;    # Strip off the spam-dexer.
	    my $description = $code->Description;

#                evidence_code => {  text=>"$code",
#                                    evidence=> map {					     
#					$_->{'Description'} = "$description";
#                                                $_ } ($self->_get_evidence($code))
#                                  },

            push @{ $data{"$facet"} }, {
                method        => $1,
                evidence_code => {  text=>"$code",
                                    evidence=> map {					     
					$_->{'Description'} = "$description";
                                                $_ } ($self->_get_evidence($code))
                                  },
                term          => $self->_pack_obj($go_term),
            };
        }
    }

    return {
        description => 'gene ontology assocations',
        data        => %data ? \%data : undef,
    };
}



#######################################
#
# The History Widget
#    template: shared/widgets/history.tt2
#
#######################################

# history { }
# This method returns a data structure containing the 
# curatorial history of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/history

sub history {
    my $self   = shift;
    my $object = $self->object;
    my @data;

    foreach my $history ( $object->History ) {
        my $type = $history;
        $type =~ s/_ / /g;

        my @versions = $history->col;
        foreach my $version (@versions) {

            #  next unless $history eq 'Version_change';    # View Logic
            my ($vers,   $date,   $curator, $event,
                $action, $remark, $gene,    $person
            );
            if ( $history eq 'Version_change' ) {
                ( $vers, $date, $curator, $event, $action, $remark )
                    = $version->row;

                next if $action eq 'Imported';
                # For some cases, the remark is actually a gene object
                if (   $action eq 'Merged_into'
                    || $action eq 'Acquires_merge'
                    || $action eq 'Split_from'
                    || $action eq 'Split_into' )
                {
                    $gene   = $remark;
                    $remark = undef;
                }
            }
            else {
                ($gene) = $version->row;
            }

            push @data, {
                history => $history && "$history",
                version => $version && "$version",
                type    => $type && "$type",
                date    => $date && "$date",
                action  => $action && "$action",
                remark  => $remark && "$remark",
                gene    => $self->_pack_obj($gene),
                curator => $self->_pack_obj($curator),
            };
        }
    }

    return {
        description => 'the curatorial history of the gene',
        data        => @data ? \@data : undef
    };
}




#######################################
#
# The Homology Widget
#   template: classes/gene/homology.tt2
#
#######################################

# best_blastp_matches {}
# Supplied by Role

# nematode_orthologs { }
# This method returns a data structure containing the 
# orthologs of this gene to other nematodes housed
# at WormBase.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/nematode_orthologs

sub nematode_orthologs {
    my $self   = shift;

    my $data = $self->_parse_homologs(
        [ $self->object->Ortholog ],
        sub {
            return $_[0]->right(2) ? [map { $self->_pack_obj($_) } $_->right(2)->col] : undef;
        }
    );

    return {
        description => 'precalculated ortholog assignments for this gene',
        data        =>  @$data ? $data : undef,
    };

}

# human_orthologs { }
# This method returns a data structure containing the 
# human orthologs of this gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/human_orthologs

has '_other_orthologs' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__other_orthologs',
);

sub _build__other_orthologs {
    my ($self) = @_;
    return $self->_parse_homologs(
        [ $self->object->Ortholog_other ],
        sub {
            return $_[0]->right ? [map { $self->_pack_obj($_) } $_->right->col] : undef;
        }
    );
}

# I sure do wish we had some descriptions for human genes.
sub human_orthologs {
    my $self = shift;

    my @data = grep { $_->{ortholog}{id} =~ /ENSEMBL:ENSP\d/ } @{$self->_other_orthologs};

    return {
        description => 'human orthologs of this gene',
        data        => @data ? \@data : undef,
    };
}


# other_orthologs { }
# This method returns a data structure containing the 
# orthologs of this gene to species outside of the core
# nematodes housed at WormBase. See also nematode_orthologs()
# and human_orthologs();
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/other_orthologs

sub other_orthologs {
    my ($self) = @_;
    my $data = $self->_other_orthologs;

    return {
        description => 'orthologs of this gene to other species outside of core nematodes at WormBase',
        data        => @$data ? $data : undef,
    };
}

# paralogs { }
# This method returns a data structure containing the 
# paralogs of this gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/paralogs

sub paralogs {
    my $self   = shift;

    my $data = $self->_parse_homologs(
        [ $self->object->Paralog ],
        sub {
            return $_[0]->right(2) ? [map { $self->_pack_obj($_) } $_->right(2)->col] : undef;
        }
    );

    return {
        description => 'precalculated paralog assignments',
        data        =>  @$data ? $data : undef
    };
}

# Private helper method to standardize structure of homologs.
sub _parse_homologs {
    my ($self, $homologs, $method_sub) = @_;

    my @parsed;
    foreach (@$homologs) {
        my $packed_homolog = $self->_pack_obj($_);
        my $species = $packed_homolog->{taxonomy};
        my ($g, $spec) = split /_/, $species;
        push @parsed, {
            ortholog => $packed_homolog,
            method   => $method_sub->($_),
            species  => {
                genus   => ucfirst $g,
                species => $spec,
            },
        };
    }

    return \@parsed;
}

# human_diseases { }
# This method returns a data structure containing disease
# processes that human orthologs of this gene are thought
# to participate in.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/human_diseases

sub human_diseases {
  my $self = shift;
  my $object = $self->object;
  my @data = grep { $_ eq 'OMIM' } $object->DB_info->col if $object->DB_info; 
  my $search = $self->_api->xapian;

  my %data;
  if($data[0]){
    foreach my $type ($data[0]->col) {
      $data{$type} = ();
      foreach my $disease ($type->col){
        push (@{$data{$type}}, $search->_get_tag_info($self->_api, $disease, 'disease') || $disease)
      }
    }
  }

  return {
      description => 'Diseases related to the gene',
      data        => %data ? \%data : undef,
  };
}

# protein_domains { }
# This method returns a data structure containing the 
# protein domains contained in this gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/protein_domains

sub protein_domains {
    my $self = shift;

    my %unique_motifs;
    for my $protein ( @{ $self->_all_proteins } ) {
        for my $motif ($protein->Motif_homol) {
	    if("$motif" =~ /^INTERPRO:/){
		if (my $title = $motif->Title) {
		    $unique_motifs{$title} ||= $self->_pack_obj($motif);
		}
	    }
        }
    }

    return {
        description => "protein domains of the gene",
        data        => %unique_motifs ? \%unique_motifs : undef,
    };
}


# treefam { }
# This method returns a data structure containing the 
# link outs to the Treefam resource.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/treefam

sub treefam {
    my $self   = shift;
    my $object = $self->object;
    
    my @data;
    foreach (@{$self->_all_proteins}) {
	my $treefam = $self->_fetch_protein_ids($_,'treefam');
	# Ignore proteins that lack a Treefam ID
	next unless $treefam;
	push @data, "$treefam";
    }			
    
    return { description => 'data and IDs related to rendering Treefam trees',
	     data        => @data ? \@data : undef,
    };
}


#######################################
#
# The Location Widget
#
#######################################

# genomic_position { }
# Supplied by Role

sub _build_genomic_position {
    my ($self) = @_;
    my @pos = $self->_genomic_position([ $self->_longest_segment || () ]);
    return {
        description => 'The genomic location of the sequence',
        data        => @pos ? \@pos : undef,
    };
}

# genetic_position { }
# Supplied by Role

# sub genomic_image { }
# Supplied by Role

#######################################
#
# The Phenotype Widget
#
#######################################

# phenotype { }
# returns the phenotype(s) associated with the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/phenotype

sub phenotype {
    my $self = shift;

    return {
        description => 'The Phenotype summary of the gene',
        data        => $self->_phenotypes,
	};
}

#######################################
#
# The Reagents Widget
#
#######################################

# antibodies { }
# This method will return a data structure containing
# antibodies generated against products of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/antibodies

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
	    data        =>  @data ? \@data : undef };
}



# matching_cdnas { }
# This method will return a data structure containing
# a list of cDNAs mapped to the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/matching_cdnas

sub matching_cdnas {
    my $self     = shift;
    my $object = $self->object;
    my %unique;
    my @mcdnas = map {$self->_pack_obj($_)} grep {!$unique{$_}++} map {$_->Matching_cDNA} $object->Corresponding_CDS;
    return { description => 'cDNAs matching this gene',
	     data        => \@mcdnas };
}



# microarray_probes { }
# This method will return a data structure containing
# microarray probes that map to the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/microarray_probes

sub microarray_probes {
    my $self   = shift;
    my $object = $self->object;

    my %seen;

    my @oligos = grep { !$seen{$_}++ }
        grep { $_->Type and $_->Type =~ /microarray_probe/ }
        map { $_->Corresponding_oligo_set } $object->Corresponding_CDS;
    my @stash;
    foreach (@oligos) {
        my $comment
            = ( $_->Type =~ /GSC/ )
            ? 'GSC'
            : ( $_->Type =~ /Agilent/ ? 'Agilent' : 'Affymetrix' );
        push @stash, $self->_pack_obj( $_, "$_ [$comment]" );
    }

    return {
        description => "microarray probes",
        data        => @stash ? \@stash : undef,
    };
}

# orfeome_primers { }
# This method will return a data structure containing
# ORFeome primers flanking the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/orfeome_primers

sub orfeome_primers {
    my $self   = shift;
    my $object = $self->object;
    my @segments = $self->_segments ? @{$self->_segments} : undef ;
    my @ost = map { $self->_pack_obj($_)}
              map {$_->info}
              map { $_->features('alignment:BLAT_OST_BEST','PCR_product:Orfeome') }
              @segments
        if ($object->Corresponding_CDS || $object->Corresponding_Pseudogene);
    
    return { description =>  "ORFeome Project primers and sequences",
	     data        =>  @ost ? \@ost : undef };
}


# primer_pairs { }
# This method will return a data structure containing
# other names that have also been used to refer to the
# gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/primer_pairs

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
	     data        =>  @primer_pairs ? \@primer_pairs : undef };
}

# sage_tags { }
# This method will return a data structure containing
# Serial Analysis of Gene Expresion (SAGE) tags
# that map to the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/sage_tags

sub sage_tags {
    my $self   = shift;
    my $object = $self->object;
    
    my @sage_tags = map {$self->_pack_obj($_)} $object->SAGE_tag;
    
    return {  description =>  "SAGE tags identified",
	      data        =>  @sage_tags ? \@sage_tags : undef
    };
}


# transgenes { }
# This method will return a data structure containing
# trasngenes driven by the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/transgenes

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
	data        => @data ? \@data : undef };    
}

# transgene_products { }
# This method will return a data structure containing
# trasngenes that express this gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/transgene_products

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
	data        => @data ? \@data : undef };    
}

#######################################
#
# The Regulation Widget
#   template: classes/gene/regulation.tt2
#
#######################################

# regulation_on_expression_level { }
# This method returns a data structure containing the 
# a data table describing the regulation on expression
# level.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/regulation_on_expression_level

sub regulation_on_expression_level {
    my $self   = shift;
    my $object = $self->object;
    my $datapack = {
        description => 'Regulation on expression level',
        data        => undef,
    };
    return $datapack unless ($object->Gene_regulation);

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
                } elsif ($gene_reg->Result
                         and $gene_reg->Result eq 'Does_not_regulate') {
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

                # _pack_obj may already take care of this:
                my $common_name = $self->_public_name($target);
                push @stash, {
                    string          => $string,
                    target          => $self->_pack_obj($target, $common_name),
                    gene_regulation => $self->_pack_obj($gene_reg)
                };
            }
        }
    }

    $datapack->{data} = \@stash if @stash;
    return $datapack;
}

#######################################
#
# The References Widget
#
#######################################

# references {}
# Supplied by Role

#######################################
#
# The Sequences Widget
#
#######################################

# gene_models { }
# This method will return an extensive data structure containing
# gene models for the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/gene_models

sub gene_models {
    my $self   = shift;
    my $object = $self->object;
    my $seqs   = $self->sequences;
    my %seen;
    my @rows;

    my $coding =  $self->object->Corresponding_CDS ? 1 : 0;

    # $sequence could potentially be a Transcript, CDS, Pseudogene - but
    # I still need to fetch some details from sequence
    # Fetch a variety of information about all transcripts / CDS prior to printing
    # These will be stored using the following keys (which correspond to column headers)

    foreach my $sequence ( sort { $a cmp $b } @$seqs ) {
        my %data  = ();
        my $gff   = $self->_fetch_gff_gene($sequence) or next;
        my $cds
            = ( $sequence->class eq 'CDS' )
            ? $sequence
            : eval { $sequence->Corresponding_CDS };
        next if $seen{$cds}++;

        my $protein = $cds->Corresponding_protein( -fill => 1 ) if $cds;
        my @sequences = $cds ? $cds->Corresponding_transcript : ($sequence);
        my $len_spliced   = 0;

        for ( $gff->features('coding_exon') ) {

            if ( $object->Species =~ /elegans/ ) {
                next unless $_->source eq 'Coding_transcript';
            }
            else {
                next
                    unless $_->method =~ /coding_exon/
                        && $_->source eq 'Coding_transcript';
            }
            next unless $_->name eq $sequence;
            $len_spliced += $_->length;
        }

        #     Try calculating the spliced length for pseudogenes
        if ( !$len_spliced ) {
            my $flag = eval { $object->Corresponding_Pseudogene } || $cds;
            for ( $gff->features('exon:Pseudogene') ) {
                next unless ( $_->name eq $flag );
                $len_spliced += $_->length;
            }
        }
        $len_spliced ||= '-';

        $data{length_spliced}   = $len_spliced if $coding;

        my @lengths = map { $self->_fetch_gff_gene($_)->length . "<br />";} @sequences;
        $data{length_unspliced} = @lengths ? \@lengths : undef;

        if ($protein) {
            my $peplen = $protein->Peptide(2);
            my $aa     = "$peplen";
            $data{length_protein} = $aa if $aa;
        }
        my $type = $sequence->Method;
        $type =~ s/_/ /g;
        @sequences =  map {$self->_pack_obj($_)} @sequences;
        $data{type} = "$type";
        $data{model}   = \@sequences;
        $data{protein} = $self->_pack_obj($protein) if $coding;
        $data{cds} = $cds ? $self->_pack_obj($cds) : '(no CDS)' if $coding;

        push @rows, \%data;
    }

    return {
        description => 'gene models for this gene',
        data        => @rows ? \@rows : undef
    };
}

# TH: Retired 2011.08.17; safe to delete or transmogrify to some other function.
# should we return entire sequence obj or just linking/description info? -AC
sub other_sequences {
    my $self   = shift;

    my @data = map {
        my $title = $_->Title;
        {
            sequence => $self->_pack_obj($_),
            description => $title && "$title",
        }
    } $self->object->Other_sequence;

    return {
        description => 'Other sequences associated with gene',
        data        => @data ? \@data : undef,
    };
}

#########################################
#
#   INTERNAL METHODS
#
#########################################

# This is for GO processing
# TH: I don't understand the significance of the nomenclature.
# Oh wait, I see, it's used to force an order in the view.
# This should probably be an attribute or view configuration.
sub _go_method_detail {
    my ($self,$method,$detail) = @_;
    return 'a_Curated' if $method =~ m/Paper/;
    return 'z_No Method' unless $detail;
    return 'b_Phenotype to GO Mapping' if ($detail =~ m/phenotype/i);
    return 'c_Interpro to GO Mapping' if ($detail =~ m/interpro/i);
    return 'd_TMHMM to GO Mapping' if ($detail =~ m/tmhmm/i);
    return 'z_No Method';
}

# Fetch unique transcripts (Transcripts or Pseudogenes) for the gene
sub _fetch_transcripts { # pending deletion
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
    # Uncloned genes will NOT have segments associated with them.
    my ($longest)
	= sort { $b->abs_end - $b->abs_start <=> $a->abs_end - $a->_abs_start}
    @{$self->_segments} if $self->_segments;
    return $longest;
}

sub _select_protein_description { # pending deletion
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
sub _other_notes { # pending deletion
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

sub parse_year { # pending deletion
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



sub _y2h_data { # pending deletion
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


=pod
# This is one big ugly hack job, evidence is handled by _get_evidence in API/Object.pm
sub _go_evidence_code { # pending deletion
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

=cut 

sub _build_hash {
    open my $fh, '<', $_[0] or die $!;

    return { map { chomp; split /=>/, $_, 2 } <$fh> };
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
# sub proteins {
#     my $self   = shift;
#     my $object = $self->object;
#     my $desc = 'proteins related to gene';

#     my @cds    = $object->Corresponding_CDS;
#     my @proteins  = map { $_->Corresponding_protein } @cds;
#     @proteins = map {$self->_pack_obj($_, $self->public_name($_, $_->class))} @proteins;

#     return { description => 'proteins encoded by this gene',
# 	     data        => \@proteins };
# }


# # Fetch all CDSs associated with a gene.
# ## figure out naming convention for CDs

# # NOTE: this method is not used
# sub cds {
#     my $self   = shift;
#     my $object = $self->object;
#     my @cds    = $object->Corresponding_CDS;
#     my $data_pack = $self->basic_package(\@cds);

#     return { description => 'CDSs encoded by this gene',
# 	     data        => $data_pack };
# }



# # Fetch Homology Group Objects for this gene.
# # Each is associated with a protein and we should probably
# # retain that relationship

# # NOTE: this method is not used
# # TH: NOT YET CLEANED UP
# sub kogs {
#     my $self   = shift;
#     my $object = $self->object;
#     my @cds    = $object->Corresponding_CDS;
#     my %data;
#     my %data_pack;

#     if (@cds) {
# 	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds;
# 	if (@proteins) {
# 	    my %seen;
# 	    my @kogs = grep {$_->Group_type ne 'InParanoid_group' } grep {!$seen{$_}++}
# 	         map {$_->Homology_group} @proteins;
# 	    if (@kogs) {

# 	    	$data_pack{$object} = \@kogs;
# 			$data{'data'} = \%data_pack;

# 	    } else {

# 	    	$data_pack{$object} = 1;

# 	    }
# 	}
#     } else {
# 		$data_pack{$object} = 1;
#     }

#     $data{'description'} = "KOGs related to gene";
#  	return \%data;
# }

__PACKAGE__->meta->make_immutable;

1;
