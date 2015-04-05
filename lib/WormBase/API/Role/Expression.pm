package WormBase::API::Role::Expression;

use Moose::Role;
use File::Spec::Functions qw(catfile catdir);

#######################################################
#
# Attributes
#
#######################################################

#######################################################
#
# Generic methods, shared across Gene and Transcript classes
#
#######################################################


############################################################
#
# Private Methods
#
############################################################


has '_gene' => (
    is       => 'ro',
    isa => 'Maybe[Ace::Object]',
    required => 1,
    lazy     => 1,
    builder  => '_build__gene',
);

has 'exp_sequences' => (
    is  => 'ro',
    lazy => 1,
    builder => '_build_sequences',
);

requires '_build__gene'; # no fallback to build segments... yet (or ever?).

# anatomic_expression_patterns { }
# This method will return a complex data structure
# containing expression patterns described at the
# anatomic level. Includes links to images.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomic_expression_patterns

sub anatomic_expression_patterns {
    my $self   = shift;
    my $object = $self->_gene;
    my %data_pack;

    my $file = catfile($self->pre_compile->{image_file_base},$self->pre_compile->{gene_expression_path}, "$object.jpg");
    $data_pack{"image"}=catfile($self->pre_compile->{gene_expression_path}, "$object.jpg") if (-e $file && ! -z $file);

    return {
        description => 'expression patterns for the gene',
        data        => %data_pack ? \%data_pack : undef,
    };
}


# Returns expressions with Microarray and Tiling_array types
sub expression_patterns {
    my $self   = shift;
    my $object = $self->_gene;
    my @data;

    foreach my $expr ($object->Expr_pattern) {
        my $type = $expr->Type;
        next if $type =~ /Microarray|Tiling_array/;
        push @data, $self->_expression_pattern_details($expr, $type);
    }

    return {
        description => "expression patterns associated with the gene:$object",
        data        => @data ? \@data : undef
    };
}

# Returns expressions other than Microarray and Tiling_array types
sub expression_profiling_graphs {
    my $self   = shift;
    my $object = $self->_gene;
    my @data;

    foreach my $expr ($object->Expr_pattern) {
        my $type = $expr->Type;
        next unless $type =~ /Microarray|Tiling_array/;
        push @data, $self->_expression_pattern_details($expr, $type);
    }

    return {
        description => "expression patterns associated with the gene:$object",
        data        => @data ? \@data : undef
    };
}

sub _expression_pattern_details {
    my ($self, $expr, $type) = @_;

    my $author = $expr->Author;
    my @patterns = $expr->Pattern
        || $expr->Subcellular_localization
        || $expr->Remark;
    my $desc = join("<br />", @patterns) if @patterns;
    $type =~ s/_/ /g if $type;
    my $reference = $self->_pack_obj($expr->Reference);

    my @expressed_in = map { $self->_pack_obj($_) } $expr->Anatomy_term;
    my @life_stage = map { $self->_pack_obj($_) } $expr->Life_stage;
    my @go_term = map { $self->_pack_obj($_) } $expr->GO_term;

    my $pack_transgenes = sub {
        my  @trnsgns = @_;
        return map {
            my @cs =map { "$_" } $_->Construction_summary;
            @cs ? {
                text=>$self->_pack_obj($_),
                evidence=>{'Construction summary'=> \@cs }
            } : $self->_pack_obj($_)
        } @trnsgns;
    };
    my @transgene = $expr->Transgene ? &$pack_transgenes($expr->Transgene)
        : &$pack_transgenes($expr->Construct);

    my $expr_packed = $self->_pack_obj($expr, "$expr");


    my $file = catfile($self->pre_compile->{image_file_base},$self->pre_compile->{expression_object_path}, "$expr.jpg");
    $expr_packed->{image}=catfile($self->pre_compile->{expression_object_path}, "$expr.jpg")  if (-e $file && ! -z $file);
    foreach($expr->Picture) {
        next unless($_->class eq 'Picture');
        my $pic = $self->_api->wrap($_);
        if( $pic->image->{data}) {
            $expr_packed->{curated_images} = 1;
            last;
        }
    }
    my $sub = $expr->Subcellular_localization;

    my @dbs;
    foreach my $db ($expr->DB_info) {
        # assuming we don't have any other fields other than id
        foreach my $id (map { $_->col } $db->col) {
            push @dbs, { class => "$db",
                         label => "$db",
                         id    => "$id" };
        }
    }

    return {
        expression_pattern =>  $expr_packed,
        description        => $reference ? { text=> $desc, evidence=> {'Reference' => $reference}} : $desc,
        type             => $type && "$type",
        database         => @dbs ? \@dbs : undef,
        expressed_in    => @expressed_in ? \@expressed_in : undef,
        life_stage    => @life_stage ? \@life_stage : undef,
        go_term => @go_term ? {text => \@go_term, evidence=>{'Subcellular localization' => "$sub"}} : undef,
        transgene => @transgene ? \@transgene : undef

    };
}

# anatomy_terms { }
# This method will return a hash
# containing unique anatomy terms described from the
# expression patterns associated with this gene
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomy_terms

sub anatomy_terms {
    my $self   = shift;
    my $object = $self->_gene;
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

# expression_cluster { }
# This method will return a data structure containing
# microarray expression clusters.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/expression_cluster

sub expression_cluster {
    my $self   = shift;
    my $object = $self->_gene;
    my @data;

    foreach my $expr_cluster ($object->Expression_cluster){
        my $description = $expr_cluster->Description;
        push @data, {
            expression_cluster => $self->_pack_obj($expr_cluster),
            description => $description && "$description"
        }
    }


    return { data        => @data ? \@data : undef,
             description => 'expression cluster data' };
}

# fourd_expression_movies { }
# This method will return a data structure containing
# links to four-dimensional expression movies.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/fourd_expression_movies
sub fourd_expression_movies {
    my $self   = shift;
    my $object = $self->_gene;

    my $author;
    my @expr_patterns = $object->Expr_pattern;
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
    } @expr_patterns;

    return {
        description => 'interactive 4D expression movies',
        data        => %data ? \%data : undef,
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
    my $object = $self->_gene;

    my $datapack = {
        description => 'microarray topography map',
        data        => undef,
    };

    return $datapack unless @{$self->exp_sequences};
    my @segments = $self->_segments && @{$self->_segments};
    return $datapack unless $segments[0];

    my @profiles = $segments[0]->features('experimental_result_region:Expr_profile');
    my @p = map {  $_->info } @profiles or return $datapack;

    my @data = ();
    foreach my $pid (@p){
        my $profile_api_obj = $self->_api->fetch({ class => 'Expr_profile', name => $pid});
        my $mountain = $profile_api_obj->pcr_data()->{'data'}->{'mountain'} if $profile_api_obj;
        my $label = $mountain ? "$pid Mountain: $mountain" : "$pid";
        my $dat = {
            'class' => 'expr_profile',
            'label' => $label,
            'id' => $pid,
        };
        push @data, $dat;
    }

    $datapack->{data} = \@data if @data;
    return $datapack;
}

# anatomy_function { }
# This method will return a data structure containing
# the anatomy function of the gene.
# eg: curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene00006763/anatomy_function

sub anatomy_function {
    my $self   = shift;
    my $object = $self->_gene;
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


sub fpkm_expression_summary_ls {
    my $self = shift;
    return $self->fpkm_expression('summary_ls');
}

# Mapping expresion study accession to a description
# Ugly hack!! This is a temporary solution before WS245/WS246 database build
our $_study2label_str =<<END;
brenneri

PRJNA75295	Hillier_modENCODE
SRP016006	Thomas_Male_Female_comparison

briggsae

PRJNA75295	Hillier_modENCODE
PRJNA104933	Uyar_Briggsae_transcriptome
SRP016006	Thomas_Male_Female_comparison

brugia

PRJEB2709	Choi_Brugia_transcriptome

elegans

PRJEB4208	Engstrom_evaluation_of_alignment_programs
PRJNA128465	Lamm_Multimodal_RNASeq_methods
PRJNA148023	Maxwell_Timecourse_of_recovery_from_L1_arrest
PRJNA151765	Zarse_Impaired_insulin_signaling
PRJNA159607	Nam_Small_RNAs_in_L4_and_Adult
PRJNA168961	Hillier_modENCODE_RNA_profiling
PRJNA170771	Jungkamp_mRNA_GLD-1_targets
PRJNA171306	Ma_Sperm_transcriptome
PRJNA174814	Schwarz_Linker_cell_transcriptome
PRJNA184024	Tamayo_Effect_of_MAB-5
PRJNA221531	Gout_Transcription_errors
PRJNA33023	Hillier_modENCODE_deep_sequencing
PRJNA51225	Mortazavi_Comparison_of_elegans_and_angaria
PRJNA79387	Shin_L1_transcriptome
PRJNA79457	Ramani_Effect_of_NMD
SRP010374	Stadler_Ribosome_profiling
SRP016006	Thomas_Male_Female_comparison
SRP026198	Stadler_Comparison_of_Starved_and_Fed

japonica

PRJNA75295	Hillier_modENCODE
SRP016006	Thomas_Male_Female_comparison

ovolvulus

PRJEB2965	Berriman_Onchocerca_transcriptome

remanei

PRJNA75295	Hillier_modENCODE
SRP016006	Thomas_Male_Female_comparison
END


our sub _extract_study2label {
    my $study2label = {};

    my @lines = split /\n/, $_study2label_str;
    foreach my $line (@lines) {
        my ($id, $label) = $line =~ /^(PRJ[A-Z]{2}\d+|SRP\d+)\s+(\w+)/;
        next unless $id;  #remove empty lines or species name lines
        $study2label->{$id} = $label;
    }
    return $study2label;
}

our $_study2label = _extract_study2label();

sub fpkm_expression {
    my $self = shift;
    my $mode = shift;
    my $object = $self->_gene;
    my $by_study = {};  # tracks regular analysis object
    my $controls_by_life_stage = {};  #tracks analysis object for control statistics

    my $rserve = $self->_api->_tools->{rserve};

    my @fpkm_map = map { # iterating on life stages
        my $life_stage = ''. $_->Public_name;
        my $life_stage_tag = $self->_pack_obj($_);
        my @fpkm_table = $_->col;

        map { # iterating on fpkm_values

            my $value = $_;
            #fpkm_values are hash keys to analysis_objects having same value,
            # totally an artifect of ACe,
            my @ana = map { #iterating on analysis objects
                my $name = $self->_pack_obj($_);
                my $analysis_record = {
                    value => "$value",
                    life_stage => $life_stage_tag,
                    label => $name,
                };

                my $project;
                my $label = $name->{label};
                if ($label =~ /([^\.]+).(control_(mean|median))/){
                    # This analysis object statics for the control
                    $life_stage = $1;
                    (my $stat_type = $2) =~ s/_/ /;
                    $analysis_record->{stat_type} = $stat_type;
                    $project = $self->_pack_obj($_->Project);

                    $controls_by_life_stage->{$life_stage} ||= [];   # ininitalize if not already
                    push @{$controls_by_life_stage->{$life_stage}}, $analysis_record;
                }else{
                    # otherwise, it't an normal analysis object that part of a study/prject

                    # accession of a project, occurs right behind /WBbt:\d+/ in a dot separated list
                    # /PRJ[A-Z]{2}\d+/ matches BioProject accession
                    # everything else treat as NCBI Trace SRA
                    my ($project_acc) = $label =~ /WBbt:\d+\.([A-Z]+\d+)\./;
                    my $source_db = $project_acc =~ /^PRJ[A-Z]{2}\d+/ ? 'BioProject' : 'sra_trace';

                    my $project_label = $_study2label->{$project_acc} || $project_acc;
                    $project_label = join(' ', split('_', $project_label));

                    $project = {
                        id => $project_acc,
                        class => $source_db,
                        label => $project_label
                    };

                    if ($project_acc) {
                        $by_study->{$project_acc} ||= { analyses => []};   # ininitalize if not already
                        push @{$by_study->{$project_acc}->{analyses}}, $analysis_record;
                    }
                }

                $analysis_record->{project_info} = $project;
                $analysis_record->{project} = $project->{id};

                $analysis_record;
            } $value->right() && $value->right()->col() ; #$value->From_analysis;

            @ana;
        } @fpkm_table;
    } $object->RNASeq_FPKM;

    # Return if no expression data is available.
    # Yes, it has to be <= 1, because there will be an undef entry when no data is present.
    if ((scalar @fpkm_map) <= 1) {
        return {
            description => 'Fragments Per Kilobase of transcript per Million mapped reads (FPKM) expression data -- no data returned.',
            data        => undef
        };
    }

    # Sort by project (primary order) and developmental stage (secondary order):
    @fpkm_map = sort {

        # Primary sorting order: project
        # Reverse comparison, so that projects that come first in the alphabet appear at the top of the barchart.
        return $b->{project} cmp $a->{project} if $a->{project} ne $b->{project};

        # Secondary sorting order: developmental stage
        my @sides = ($a, $b);
        my @label_value = (50, 50); # Entries that cannot be matched to the regexps will go to the bottom of the barchart.
        for my $i (0 .. 1) {
            # UNAPPLIED
            # Possible keywords? Not seen in data yet (browsing only).
            #$label_value[$i] =  0 if ($sides[$i]->{label} =~ m/gastrula/i);
            #$label_value[$i] =  1 if ($sides[$i]->{label} =~ m/comma/i);
            #$label_value[$i] =  2 if ($sides[$i]->{label} =~ m/15_fold/i);
            #$label_value[$i] =  3 if ($sides[$i]->{label} =~ m/2_fold/i);
            #$label_value[$i] =  4 if ($sides[$i]->{label} =~ m/3_fold/i);

            # EMBRYO STAGES
            $label_value[$i] = 30 if ($sides[$i]->{label} =~ m/embryo/i); # May be overwritten by the next two rules.
            if ($sides[$i]->{label} =~ m/\.([0-9]+)-cell_embryo/) {
                # Assuming an upper bound of 40 cells (for ordering below).
                $sides[$i]->{label} =~ /\.([0-9]+)-cell_embryo/;
                $label_value[$i] = "$1";
            }
            $label_value[$i] =  0 if ($sides[$i]->{label} =~ m/early_embryo/i);
            $label_value[$i] = 40 if ($sides[$i]->{label} =~ m/late_embryo/i);

            # LARVA STAGES
            $label_value[$i] = 41 if ($sides[$i]->{label} =~ m/L1_(l|L)arva/);
            $label_value[$i] = 43 if ($sides[$i]->{label} =~ m/L2_(l|L)arva/);
            $label_value[$i] = 42 if ($sides[$i]->{label} =~ m/L2d_(l|L)arva/i);
            $label_value[$i] = 43 if ($sides[$i]->{label} =~ m/L3_(l|L)arva/);
            $label_value[$i] = 45 if ($sides[$i]->{label} =~ m/L4_(l|L)arva/);

            # DAUER STAGES
            $label_value[$i] = 43 if ($sides[$i]->{label} =~ m/dauer/i); # May be overwritten by the next two rules.
            $label_value[$i] = 42 if ($sides[$i]->{label} =~ m/dauer_entry/);
            $label_value[$i] = 44 if ($sides[$i]->{label} =~ m/dauer_exit/);
            $label_value[$i] = 42 if ($sides[$i]->{label} =~ m/predauer/i);

            # ADULTHOOD
            $label_value[$i] = 47 if ($sides[$i]->{label} =~ m/adult/); # May be overwritten by the next rule.
            $label_value[$i] = 46 if ($sides[$i]->{label} =~ m/young_adult/);
        }

        # Reversed comparison, so that early stages appear at the top of the barchart.
        return $label_value[1] <=> $label_value[0];
    } @fpkm_map;

    my $plot;
    if ($mode eq 'summary_ls') {
	# This is NOT consistently returning an ID, resulting in fpkm_.png
	# and breaking the expression widget.
	# filename => "fpkm_" . $self->name->{data}{id} . ".png",
	my $obj = $self->object;
        $plot = $rserve->boxplot(\@fpkm_map, {
                                    filename => "fpkm_$object.png",
                                    xlabel   => WormBase::Web->config->{fpkm_expression_chart_xlabel},
                                    ylabel   => WormBase::Web->config->{fpkm_expression_chart_ylabel},
                                    width    => WormBase::Web->config->{fpkm_expression_chart_width},
                                    height   => WormBase::Web->config->{fpkm_expression_chart_height},
                                    rotate   => WormBase::Web->config->{fpkm_expression_chart_rotate},
                                    bw       => WormBase::Web->config->{fpkm_expression_chart_bw},
                                    facets   => WormBase::Web->config->{fpkm_expression_chart_facets},
                                    adjust_height_for_less_than_X_facets => WormBase::Web->config->{fpkm_expression_chart_height_shorter_if_less_than_X_facets}
                                 });
    } else {
        # $plot = $rserve->barchart(\@fpkm_map, {
        #                             filename => "fpkm_$object.png",
        #                             xlabel   => WormBase::Web->config->{fpkm_expression_chart_xlabel},
        #                             ylabel   => WormBase::Web->config->{fpkm_expression_chart_ylabel},
        #                             width    => WormBase::Web->config->{fpkm_expression_chart_width},
        #                             height   => WormBase::Web->config->{fpkm_expression_chart_height},
        #                             rotate   => WormBase::Web->config->{fpkm_expression_chart_rotate},
        #                             bw       => WormBase::Web->config->{fpkm_expression_chart_bw},
        #                             facets   => WormBase::Web->config->{fpkm_expression_chart_facets},
        #                             adjust_height_for_less_than_X_facets => WormBase::Web->config->{fpkm_expression_chart_height_shorter_if_less_than_X_facets}
        #                          });
    }

    foreach my $study (keys %$by_study){
        my $study_name = "RNASeq_Study.$study";
        my $study_obj = $self->_api->fetch({ class => 'Analysis', name => $study_name, nowrap => 1 });
        my $study_label = $study_obj->Title . " [$study]";

        $by_study->{$study}->{title} = '' . $study_obj->Title;
        $by_study->{$study}->{description}  = '' . $study_obj->Description;
        $by_study->{$study}->{indep_variable} = [
            map {"$_"} $study_obj->Independent_variable];
        $by_study->{$study}->{tag} = $self->_pack_obj($study_obj, $study_label);
    }

    return {
        description => 'Fragments Per Kilobase of transcript per Million mapped reads (FPKM) expression data',
        data        => @fpkm_map ? {
            by_study => $by_study,
            controls => $controls_by_life_stage,
            plot => $plot,
            table => { fpkm => { data => \@fpkm_map } }
        } : undef
    };
}

1;
