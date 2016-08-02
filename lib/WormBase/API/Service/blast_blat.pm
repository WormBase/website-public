package WormBase::API::Service::blast_blat;

use Carp;
use File::Temp;
use Bio::SearchIO;
use Bio::Tools::Blat;
use Bio::Graphics;
use Bio::SeqFeature::Generic;
use Bio::SeqIO;
#use File::Slurp;
use File::Slurp qw(slurp read_dir);
use File::Spec::Functions qw(catfile);
use GD::Simple;
use namespace::autoclean -except => 'meta';
use JSON::Parse qw(json_file_to_perl);

use Moose;
with 'WormBase::API::Role::Object';

has 'file_dir' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return shift->tmp_dir('blast_blat');
    }
);

has 'image_dir' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return shift->tmp_image_dir('blast_blat');
    }
);

# A discoverable list of blast databases.
has 'blast_databases' => (
    is  => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $data;
        my $base_dir = catfile($self->pre_compile->{base});
        my $assemblies_info = WormBase::Web->path_to('/conf/species/', 'species_ASSEMBLIES.json');
        unless (-e $assemblies_info) {
            error("Misconfigured set-up. Cannot find metadata file that describes assemblies.");
        }
        my $assemblies = json_file_to_perl($assemblies_info);
        my $bioproject_metadata = {};
                $bioproject_metadata->{"sdfsdfsdf"} = "";

        foreach my $species (keys $assemblies) {
            foreach my $bioprojects ($assemblies->{$species}->{assemblies}) {
                foreach my $bioproject (@$bioprojects) {
                    $bioproject_metadata->{$bioproject->{bioproject}} = $bioproject;
                }
            }
        }

        # Discover available BLAST databases
        my @versions = grep { /^WS/ } grep { -d "$base_dir/$_" } read_dir($base_dir);
        foreach my $version (@versions) {
            my @species = grep { -d "$base_dir/$version/blast/$_" } read_dir("$base_dir/$version/blast") if (-e "$base_dir/$version/blast");
            foreach my $species (@species) {
                my ($g,$s)   = split('_',$species);
                my $symbolic = uc($g) . ". $s";

                my @bioprojects = grep { -d "$base_dir/$version/blast/$species/$_" } read_dir("$base_dir/$version/blast/$species");
                push @bioprojects, ''; # Also consider old WormBase releases that did not have Bioproject IDs associated with them.
                foreach my $bioproject (@bioprojects) {
                    my $blast_dir = catfile($self->pre_compile->{base},
                        $version,
                        $self->pre_compile->{blast},
                        $species,
                        $bioproject);

                    my $filename_prefix;
                    if ($bioproject ne '') {
                        $filename_prefix = join('_',$version,$species,$bioproject);
                    } else {
                        $bioproject = 'not applicable';
                    $filename_prefix = join('_',$version,$species);
                    }

                    my $species_entry;
                    if (-e "$blast_dir/genomic.fa") {
                        $species_entry = $data->{"$version"}{Genome}{"$species"} || {};
                        $species_entry->{"name"} = join('_',$filename_prefix,'genomic.fa');
                        $species_entry->{"symbolic"} = "$symbolic";
                        $species_entry->{$bioproject} = {
                            symbolic    => "$bioproject",
                            description => $bioproject_metadata->{$bioproject}->{bioproject_description},
                            name        => join('_',$filename_prefix,'genomic.fa'),
                            location    => catfile($blast_dir, $species, 'genomic.fa'),
                        };
                        $data->{"$version"}{Genome}{"$species"} = $species_entry;
                    }
                    if (-e "$blast_dir/peptide.fa") {
                        $species_entry = $data->{"$version"}{Protein}{"$species"} || {};
                        $species_entry->{"name"} = join('_',$filename_prefix,'peptide.fa');
                        $species_entry->{"symbolic"} = "$symbolic";
                        $species_entry->{$bioproject} = {
                            symbolic    => "$bioproject",
                            description => $bioproject_metadata->{$bioproject}->{bioproject_description},
                            name        => join('_',$filename_prefix,'peptide.fa'),
                            location    => catfile($blast_dir, $species, 'peptide.fa'),
                        };
                        $data->{"$version"}{Protein}{"$species"} = $species_entry;
                    }
                    if (-e "$blast_dir/ests.fa") {
                        $species_entry = $data->{"$version"}{ESTs}{"$species"} || {};
                        $species_entry->{"name"} = join('_',$filename_prefix,'ests.fa');
                        $species_entry->{"symbolic"} = "$symbolic";
                        $species_entry->{$bioproject} = {
                            symbolic    => "$bioproject",
                            description => $bioproject_metadata->{$bioproject}->{bioproject_description},
                            name        => join('_',$filename_prefix,'ests.fa'),
                            location    => catfile($blast_dir, $species, 'ests.fa'),
                        };
                        $data->{"$version"}{ESTs}{"$species"} = $species_entry;
                    }
                }
            }
        }
        return $data;
    }
);

our %BLAST_APPLICATIONS = (
    blastn  => {query_type => "nucl", database_type => "nucl"},
    blastp  => {query_type => "prot", database_type => "prot"},
    blastx  => {query_type => "nucl", database_type => "prot"},
    tblastn => {query_type => "prot", database_type => "nucl"},
);

our %BLAST_FILTERS = ("filter" => "-F T",);

# Belongs as part of the controller?
sub run {
    my ($self,$param) = @_;

    my $bioprojects = $param->{'bioproject'};
    $bioprojects = [ $bioprojects ] unless ref($bioprojects) eq 'ARRAY';

    if (length(@{$bioprojects}) == 1 && @{$bioprojects}[0] == undef) {
        error("A BioProject must be selected!");
    }

    my @results = ();
    foreach my $bioproject (@{$bioprojects}) {
      my ($query_file, $query_type, $result_file) = $self->process_input($param, $bioproject);
      my $data = $self->display_results($param, $query_file, $query_type, $result_file)->{'data'};

      # Add BioProject identifier for display purposes.
      my @filename_segments = split('_', $bioproject);
      foreach my $result (@{$data}) {
          $result->{'bioproject'} = $filename_segments[3];
      }

      push(@results, $data);
    }

    return {
        description => 'Alignment results of one or more BLAST/BLAT runs.',
        data        => \@results
    };
}

sub about_blat {
  return undef;
}

sub error {
  return 0;

}
sub message {
  return 0;

}


sub _get_database_type {
    my ($self,$database) = @_;
    return 'nucl' if $database =~ /.*_genome/;
    return 'prot' if $database =~ /.*_protein/;
    return 'nucl' if $database =~ /.*_gene/;
    return 'nucl' if $database =~ /.*_est/;
}




sub process_input {
    my ($self, $cgi, $database) = @_;

    my $query_sequence = $cgi->{"query_sequence"};
    my $query_type     = $cgi->{"query_type"};

    if (!$database || $database eq '') {
        error("A BioProject must be selected!");
    }

    if (!$query_sequence) {
        error("A query sequence is required!");
    }

    my $query_file = $self->process_query_sequence($query_sequence);

    my $temp_file = File::Temp->new(
        TEMPLATE => "out_XXXXX",
        DIR      => $self->file_dir,
        SUFFIX   => ".out",
        UNLINK   => 0,
    );

#    my $address = $ENV{REMOTE_ADDR};
#    my $out_file = ($address eq "127.0.0.1") ? 'localhost-debug' : $temp_file->filename;
    my $out_file = $temp_file->filename;

    my $search_type = $cgi->{"search_type"};
    my $command_line;

    my @path_parts    = split('_',$database);
    my $species = $path_parts[1] . '_' . $path_parts[2];
    my $version = $path_parts[0];

    my $database_location;
    my $bioproject = $path_parts[3];
    $database_location = catfile($self->pre_compile->{base}, $version, 'blast', $species, $bioproject, $path_parts[4]);
    $database_location = $1 if ($database_location =~ /(.*)\/$/); # Remove trailing slash, which is present when no BioProject ID was provided.

    if ($search_type eq "blast") {
        my $blast_app = $cgi->{"blast_app"};
        if (!$BLAST_APPLICATIONS{$blast_app}) {
            error("Invalid BLAST application ($blast_app)!");
        }

        my $blast_e_value = $cgi->{"blast_e_value"};
        if ($blast_e_value =~ /[^\dE+\-]/) {
            error("Invalid BLAST e-value ($blast_e_value)!");
        }

	my $database_type = $self->_get_database_type($database);

	# database option encodes its location as WSXXX_g_species_file.suffix

	$self->log->error($database_location);

        my $expected_query_type = $BLAST_APPLICATIONS{$blast_app}{query_type};
        my $expected_database_type =
          $BLAST_APPLICATIONS{$blast_app}{database_type};

        if (   $query_type ne $expected_query_type
            or $database_type ne $expected_database_type) {
            error("Incompatible query($query_type)/database($database_type)");
        }

        my $blast_filter = "-F F";
        if ($cgi->{"process_query"}) {
            my $process_query_type =
              $cgi->{"process_query_type"};    # filter, mask

            my $blast_filter_identifier = join(":", $process_query_type);

            $blast_filter = $BLAST_FILTERS{$blast_filter_identifier};

            if (!$blast_filter) {
                error(
                    "Invalid BLAST filter selection ($blast_filter_identifier)!"
                );
            }
        }

        $command_line = catfile($self->pre_compile->{BLAST_EXEC_DIR}, '/bin/blastall')
                      . qq[ -p $blast_app -d $database_location -i $query_file -e $blast_e_value $blast_filter -o $out_file 2> $out_file.err];
    }

    elsif ($search_type eq "blat") {
        my $db_info;

        my $database_type = $self->_get_database_type($database);

        my $blat_client = $self->pre_compile->{BLAT_CLIENT};
        $blat_client = "/usr/local/wormbase/services/blat/bin/blat";

        # Only supporting matching query and database types:
        if ($query_type ne $database_type) {
            error("Incompatible query($query_type)/database($database_type)");
        }

        my $query_and_database_type;
        if ($query_type eq 'nucl') {
            $query_and_database_type = '-t=dna -q=dna';
        } elsif ($query_type eq 'prot') {
            $query_and_database_type = '-prot';
        }

        $command_line = "$blat_client -out=blast $query_and_database_type $database_location $query_file $out_file 2> $out_file.err ";
        #            $blat_client . qq[ -out=blast -t=dna -q=dna localhost $database_port $database_location $query_file $out_file >& $out_file.err];

    }

    else {
        error("Unknown search type ($search_type)!");
    }

    # Run search
    my $result = system($command_line);
    if ($result) {
        warn "$out_file.err";
        my $err = slurp("$out_file.err");

        my %seen;
        my @err = split(/\n+/, $err);
        my @nr_err;

        foreach (@err) {
            warn($_, "\n");
            push @nr_err, $_ unless $seen{$_};
            $seen{$_}++;
        }

        my $nr_err = join('<br/>', @nr_err);

        $self->log->debug( "$command_line\n" );
        error("<b>BLAST/BLAT search failed!</b><br/><br/>$!<br/>$nr_err");
    }

    return ($query_file, $query_type, $out_file);
}

sub process_query_sequence {
    my ($self,$query_sequence) = @_;

    # Check query sequence
    check_query_sequence($query_sequence);

    # Clean query sequence of extra white space
    $query_sequence =~ s/^\s+//;
    $query_sequence =~ s/\s+$//;

#     if ($query_sequence =~ /^>/ && $query_sequence !~ /^>[^\n]*\n+[^\n]+/) {
#         message("Empty sequence!");
#     }

    # Add a header line if not available
    if ($query_sequence !~ />/) {
        $query_sequence = ">Query Sequence\n" . $query_sequence;
    }

    # Write query sequence to a temp file
    my $temp_file = File::Temp->new(
        TEMPLATE => "query_XXXXX",
        DIR      => $self->file_dir,
        SUFFIX   => ".seq",
        UNLINK   => 0,
    );
    my $file_name = $temp_file->filename;

    open(SEQ, ">$file_name")
      or error("Cannot write temp query sequence file ($file_name)!");
    print SEQ $query_sequence;
    close SEQ;

    return $file_name;
}

sub check_query_sequence {
    my ($query_sequence) = @_;

    $query_sequence =~ s/^>[^\n\r]*[\n\r]+//;
    $query_sequence =~ s/[\n\r]//g;
    $query_sequence =~ s/\s+//g;
    $query_sequence = lc($query_sequence);

    if (length($query_sequence) < 10) {
        error("At least 10 residues are required!");
    }

    return 1;
}

sub display_results {
    my ($self,$cgi, $query_file, $query_type, $result_file) = @_;

    my $search_type = $cgi->{"search_type"};
    my $blast_app   = $cgi->{"blast_app"} || '';

    my $database   = $cgi->{"database"};
    my @path_parts = split('_',$database);
    my $species    = $path_parts[1] . '_' . $path_parts[2];

    # Generate (i)Alignment Image URL and (ii)Karyotype Viewer URL
#     my ($alignment_image,  $kviewer_adds_ref, $genome_links_ref,
#         $expand_links_ref, $image_map_pieces_ref
#       )
    my $data = $self->process_result_file(
        $query_file,  $query_type, $result_file,
        $search_type, $blast_app,
        $species,
    );


    my $pattern;
    my @result_file_array;
#    warn "$address done slurping" if DEBUG;
    my $stream = slurp($result_file);
#note!!!!!!! this will not work currently if the format of the output change.
    $blast_app=uc($blast_app);
    foreach my $file (split /$blast_app/, $stream) {
        next unless($file);
        push @result_file_array, $blast_app.$file;
    }
    my @final;

    foreach (@$data) {
        my ($query_name, $alignment_image,  $score_key_image, $kviewer_adds_ref, $genome_links_ref,
            $expand_links_ref, $image_map_pieces_ref) = @$_;
        my ($alignment_image_file_name) = $alignment_image =~ /([^\/]+)$/;
        my ($score_key_image_file_name) = $score_key_image =~ /([^\/]+)$/;

        my $alignment_image_url =
            $self->tmp_image_uri(catfile($self->image_dir, $alignment_image_file_name));
        my $score_key_image_url =
            $self->tmp_image_uri(catfile($self->image_dir, $score_key_image_file_name));

        # Retrieve kviewer image and imagemap

        my $kviewer_image_content;
        my $kviewer_imagemap;
        my $address = $ENV{REMOTE_ADDR};
        # Slurp result file
        my $result_file_content =
            $self->result2html(shift @result_file_array, $genome_links_ref, $expand_links_ref, $species);

        $self->log->debug( "$address: processing results file: done" );

        my $vars = {
            query_name 	       => $query_name,
            kviewer_image_content      => $kviewer_image_content,
            kviewer_imagemap           => $kviewer_imagemap,
            score_key_image_url        => $score_key_image_url,
            alignment_image_url        => $alignment_image_url,
            image_map_pieces           => $image_map_pieces_ref,
            result_file_content        => $result_file_content,
            hsp_genome_link_part_limit => $self->pre_compile->{HSP_GENOME_LINK_PART_LIMIT},
            hsp_alignment_image_limit  => $self->pre_compile->{HSP_ALIGNMENT_IMAGE_LIMIT},
        };
        push @final, $vars;
    }

    return {data=>\@final};
}

sub result2html {
    my ($self,$result, $genome_links_ref, $expand_links_ref, $species) = @_;

    my $address = $ENV{REMOTE_ADDR};
 #   warn "$address: the result file is: $result_file" if DEBUG;


#    warn "$address done slurping" if DEBUG;

    # BLAST outformat of BLAT contains hard-coded sequece/bp count
    if ($result =~ /BLAT - The BLAST-like alignment tool/) {
        $result =~ s/23 sequences; 3,000,000,000 total letters//;
    }

    $result =~ s/\n{3,}/\n\n/g;
    $result =~ s/\n/<br\/>\n/g;
    $result =~ s/ /&nbsp;/g;

    my @content;

    my $current_idx      = 0;
    my $current_hit      = "";
    my $current_type     = "header";
    my $current_sub_type = "";

    my $end_header_parsing = 0;
    my $end_parsing        = 0;

    my $anchor_counter      = 0;
    my $expand_area_counter = 0;


    # WARNING!  THIS IS INCREDIBLY BRITTLE.
    # IF THE FORMAT OF OUR FASTA HEADERS CHANGES
    # THIS PARSING CODE WILL LIKELY BREAK.
    # CHECK BELOW FOR "FASTA WARNING"

    # Reformat the summary table of the BLAST report
    my ($hash);
    foreach my $line (split("<br/>\n", $result)) {
	my $link;
	#print STDERR "\n\nPROCESSING $line\n" if DEBUG;
        if ($current_type eq 'header' && $current_sub_type eq 'summary') {
            if ($line =~ /^WARNING/) {
                $end_header_parsing = 1;
            }

	    # FASTA WARNING!
#            if (!$end_header_parsing && $line =~ /^([^&>]+?)\#/) {
            if (!$end_header_parsing && $line =~ /^([^&>]+?)[\#&]+?/) {
                my $hit = $1;
#		print STDERR "HERE: hit is $hit\n" if DEBUG;

		# Try and fasta headers that contain re-unfriendly characters.
		$hit =~ s/[\[\]]/--/g;

                $expand_area_counter++;

                my ($sequence_link, $gene_link, $protein_link,
                    $corr_gene_link) = $self->make_links($hit);

                my $expand_link    = $expand_links_ref->{$hit};
                my $alignment_link = "#hit_anchor_${hit}";
		my $genome_link;
                $genome_link = {class=>'genomic_location', id=>$genome_links_ref->{$hit} , label=>'[Genome View]', taxonomy=>$species} if $genome_links_ref->{$hit};

		# Replace the Gene name in the report with a link to the sequence.
		$line =~ s/^$hit//;
		$line =~ s/\#/ /g;

		# Highlight the hit.
=pod
		$line = qq[<font class="bold">] . $line . qq[</font>];

		$line .= qq[<br/>\n];
 		$line .=
		    qq[<img class="expand_button" expand_area_count="$expand_area_counter" src="/blast_blat/blank.png"/>]
		    if $expand_link;
		$line .= qq[$alignment_link];
		$line .= qq[$genome_link] if $genome_links_ref->{$hit};
		$line .= qq[$gene_link] if $gene_link;
		$line .= qq[$protein_link] if $protein_link;
		$line .= qq[$corr_gene_link] if $corr_gene_link;
		$line .= qq[<br/>\n];
		$line .=
		    qq[<div class="expand_area"  expand_area_count="$expand_area_counter" expand_link="$expand_link"></div>\n]
		    if $expand_link;
=cut
		$link= $hash->{$hit} = {
							     expand_area_counter=>$expand_area_counter,
								sequence_link=> $sequence_link,
								expand_link=>$expand_link,
								alignment_link=>$alignment_link,
								genome_link=>$genome_link,
								gene_link=>$gene_link,
								protein_link=>$protein_link,
								corr_gene_link=>$corr_gene_link
							  };
            }
        }

#	print STDERR "TYPE: $current_type; SUBTYPE: $current_sub_type\n" if DEBUG;

        if ($current_type eq 'hit' && $line !~ /^>/) {
            $line =~ s!/([^&=]+)=!<font class="red">$1</font>=!g;
        }

        if ($end_parsing) {

            # Do nothing
        } elsif ($line =~ /^Sequences&nbsp;producing&nbsp;/) {    # Do not create a new type/section
            $current_sub_type = "summary";

	    # FASTA WARNING!
#         } elsif ($line =~ /^>([^&>].+?)\#/) {
#         } elsif ($line =~ /^>([^&>]+?)[\#&]?/) {  --this one doesn't work...
         } elsif ($line =~ /^>([^&>]+?)([\#&]|$)/) {
            $current_hit = $1;
#	    print STDERR "CURRENT HIT: $current_hit\n" if DEBUG;

            $line =~ s!/([^&=]+)=!<font class="red">$1</font>=!g;

#             my ($sequence_link, $gene_link, $protein_link, $corr_gene_link) =
# 		$self->make_links($current_hit);

	    $current_hit =~ s/[\[\]]/--/g;

            $line =~ s/^>$current_hit//;
	    $line =~ s/\#/ /g;
	    $line =~ s/\n/ /g;
	    $line =~ s/<br\/>/ /g;
            $current_sub_type = "";    # Close summary sub_type
            $current_idx++;
            $current_type = "hit";
#             push @{$content[$current_idx]->{html}},
	     $link= {hit_sequence_link=> $hash->{$current_hit}->{sequence_link},current_hit=>$current_hit };
# 	    qq[<a name="hit_anchor_${current_hit}"></a>\n];
        } elsif ($line =~ /Length\&nbsp;=/) {
# 	   $line .= qq[<br/>\n];

=pod
            my ($sequence_link, $gene_link, $protein_link, $corr_gene_link) =
		$self->make_links($current_hit);

            $expand_area_counter++;

            my $expand_link = $expand_links_ref->{$current_hit};
            my $genome_link = a(
				 $genome_links_ref->{$current_hit} ,
				'[Genome View]'
				);

            $line .= qq[<br/>\n];
            $line .=
		qq[<img class="expand_button" expand_area_count="$expand_area_counter" src="/blast_blat/blank.png"/>]
		if $expand_link;
            $line .= qq[$genome_link]    if $genome_links_ref->{$current_hit};
            $line .= qq[$gene_link]      if $gene_link;
            $line .= qq[$protein_link]   if $protein_link;
            $line .= qq[$corr_gene_link] if $corr_gene_link;
            $line .= qq[<br/>\n];
            $line .=
		qq[<div class="expand_area"  expand_area_count="$expand_area_counter" expand_link="$expand_link"></div>\n]
		if $expand_link;
=cut

	   $link= $hash->{$current_hit};

        } elsif ($line =~ /Strand\&nbsp;HSPs:/) {

            # $current_idx++;
            # $current_type = "info";
            next;
        } elsif ($line =~ /^\&nbsp;Score/) {

            # $current_idx++;
            $current_type = "hit";
            $anchor_counter++;
            push @{$content[$current_idx]->{html}},
	    qq[<a name="anchor${anchor_counter}"></a>\n];
        } elsif ($line =~ /^Parameters:/ or $line =~ /&nbsp;&nbsp;Database:/) {
            $current_idx++;
            $current_type = "footer";
            $end_parsing  = 1;
        }

        $content[$current_idx]->{type} = $current_type;

	$line={ line=>$line,link=>$link} if($link) ;

        push @{$content[$current_idx]->{html}}, $line;
    }

#    warn "$address: done parsing blast report" if DEBUG;
    return \@content;
}

sub make_links {
    my ($self,$hit) = @_;
    my $object;
    my ($id1,$id2,$id3,$discard) = split /\#/, $hit;
    # $id1 = 0;
    if ($id1){
        $hit = $id1;
    } elsif ($id2){
        $hit = $id2;
    } else {
        $hit = $id3;
    }


    # check_output($hit);

    my $sequence_link;
    my $gene_link;
    my $protein_link;
    my $corr_gene_link;

    # elegans
    if ($hit =~ /^(CHROMOSOME_|)([IVX]+|MtDNA)/) {
        $sequence_link = { class=>"sequence", id=>"CHROMOSOME_$2", label=>$hit};
    }

    # cb3
    elsif ($hit =~ /^chr/) {
        $sequence_link = $hit;
    }

    # pb2801
    elsif ($hit =~ /^contig/i) {
        $sequence_link = $hit;
    }

    # cb25
    elsif ($hit =~ /^cb25/) {
        $sequence_link = $hit;
    }

    # briggpep
    elsif ($hit =~ /^BP:/i) {
        $sequence_link =  { class=>"sequence", id=>$hit, label=>$hit};
        $gene_link =  { class=>"gene", id=>$hit, label=>'[Gene Summary]'};
        $protein_link = { class=>"protein", id=>$hit, label=>'[Protein Summary]'};
    }

    # remanei
    elsif ($hit =~ /sctg/i) {
        $sequence_link = "$hit";
        $gene_link     = '';
        $protein_link  = '';
    }

    # wormpep
    elsif ($object = $self->dsn->{acedb}->fetch('Transcript' => $hit) || $self->dsn->{acedb}->fetch('CDS' => $hit)) {
        my $protein = $object->Corresponding_CDS ? $object->Corresponding_CDS->Corresponding_protein : $object->Corresponding_protein;
        my $gene = $object->Corresponding_CDS ? $object->Corresponding_CDS->Gene : $object->Gene;
        $sequence_link = $self->_pack_obj($object);
        $gene_link = $self->_pack_obj($gene || undef, '[Gene Summary]');
        $protein_link = $self->_pack_obj($protein || undef, '[Protein Summary]');
    }

    # est
    elsif($object = $self->dsn->{acedb}->fetch('Sequence' => $hit)){
        $sequence_link = $self->_pack_obj($object);
        my ($gene) = $object->Gene ? $object->Gene : $object->Matching_cds && $object->Matching_cds->Gene;
        my $corr_gene_name = $gene && $self->_make_common_name($gene);
        $corr_gene_link = $self->_pack_obj($gene || undef, $corr_gene_name && "[Corr. Gene: $corr_gene_name]");
    }

    elsif($object = $self->dsn->{acedb}->fetch('Protein' => $hit)){
        $sequence_link = $self->_pack_obj($object);
    }

    else {
        $sequence_link = {label => $hit} if !$sequence_link;
    }
    return ($sequence_link, $gene_link, $protein_link, $corr_gene_link);
}




sub process_result_file {
    my ($self,$query_file, $query_type, $result_file, $search_type, $blast_app, $species) =
	@_;
    my @data;

    my $searchio;
    if ($search_type eq "blast" or $search_type eq "blat") {
        $searchio = new Bio::SearchIO(
					 -format => "blast",
					 -file   => $result_file
					 );
    }

    else {
        error("Unreconized search type ($search_type)!");
    }
    # Determine query length
    my $in = Bio::SeqIO->new(-file => $query_file, -format => "Fasta");
    for (my $count=1;my $query_seq = $in->next_seq;$count++) {

	my $query_length = $query_seq->length;
	my $query_name   = $query_seq->id;

	# Generate score key colors
	my @score_key_colors;
	for my $i (0 .. 4) {
	    my $h_value = 251 * (255 / 360);
	    my $s_value = $i * 25 * (255 / 100);
	    my $v_value = 100 * (255 / 100);

	    my @rgb_values = GD::Simple->HSVtoRGB($h_value, $s_value, $v_value);

	    push @score_key_colors, sprintf("#%.2x%.2x%.2x", @rgb_values);
	}

	# Store hits
	my @piece_refs;

	# Store genome links/positions during processing
	my %genome_links;
	my %expand_links;

	# Create image panels
	my $panel = Bio::Graphics::Panel->new(
					      -length     => $query_length,
					      -width      => 500,
					      -pad_left   => 10,
					      -pad_right  => 10,
					      -pad_top    => 10,
					      -pad_bottom => 10,
					      -key_style  => "left",
					      );

	my $score_key = Bio::Graphics::Panel->new(
						  -length     => $query_length,
						  -width      => 532,
						  -pad_left   => 1,
						  -pad_right  => 1,
						  -pad_top    => 1,
						  -pad_bottom => 1,
						  -key_style  => "left",
						  );

	# Score key
	my @score_key;

	for my $i (0 .. 19) {
	    my $display_name = ' ';
	    $display_name = '0 bits'    if $i == 0;
	    $display_name = '800+ bits' if $i == 18;
	    my $feature = Bio::SeqFeature::Generic->new(
							-score => $i * (800 / 19),
							-start => $i ? ($query_length / 20) * $i : 1,
							-end => ($query_length / 20) * $i + ($query_length / 20),
							-display_name => $display_name,
							);
	    push @score_key, $feature;
	}

	my $track = $score_key->add_track(
					  -glyph      => 'graded_segments',
					  -key        => '    SCORE KEY: ',
					  -fgcolor    => 'gray',
					  -max_score  => 800,
					  -min_score  => 0,
					  -sort_order => 'high_score',
					  -bgcolor    => 'blue',
					  -label      => 1,
					  -height     => 16,
					  -bump       => 0,
					  );
	$track->add_feature(@score_key);

	# Query sequence
	my $query = Bio::SeqFeature::Generic->new(
						  -start        => 1,
						  -end          => $query_length,
						  -display_name => "QUERY: $query_name",
						  );
	$panel->add_track(
			  $query,
			  -glyph   => "arrow",
			  -tick    => 2,
			  -fgcolor => "black",
			  -double  => 1,
			  -label   => 1,
			  );

	# Process BLAST/BLAT output - both are provided in blast format

	    my $result = $searchio->next_result;

	    if (!$result){    # Blat does not provide output when no hits
		error("No hits were found!");
	    } else {
		my $hsp_counter = 0;

		$result->rewind;

		while (my $hit = $result->next_hit) {

		    next
			if $hit->num_hsps < 1;  # Work-around, BLAT producing blank hits

		    my @hsps_in_track;
		    my $clustered_plus_strand_hsps  = Bio::SeqFeature::Generic->new;
		    my $clustered_minus_strand_hsps = Bio::SeqFeature::Generic->new;

		    my $name = $hit->name;
		    my ($formatted_name) = $name =~ /([^\/]+)$/;

		    if (length($formatted_name) > 20) {
			$formatted_name =~ s/^(.{16})(.*)/$1 .../;
		    }
		    $formatted_name = sprintf("%20s", $formatted_name);

		    my $description = $hit->description;
		    $description =~ s!^/!!;

		    my @formatted_parts;
		    foreach my $part (split(" /", $description)) {
			my ($key, $value) = split("=", $part);
			if ($key eq "id" or $key eq "tentative_id") {
			    push @formatted_parts, "/$key=$value";
			}
		    }
		    my $formatted_parts = join " ", @formatted_parts;
		    my $formatted_description =
		      length($formatted_parts) < 96
		      ? $formatted_parts
		      : substr($formatted_parts, 0, 92) . " ...";

		    # my $start = $hit->start;
		    # my $end = $hit->end;

		    my ($piece_refs_ref, $hit_genome_link, $hit_expand_link) =
		      $self->extract_hit_info($hit, $query_name, $query_type,$species);
		    push @piece_refs, @{$piece_refs_ref} if @{$piece_refs_ref};

		    $genome_links{$hit->name} = $hit_genome_link;
		    $expand_links{$hit->name} = $hit_expand_link;

		    $self->sort_hits($hit, $blast_app);    # Sort hits and add a cluster tag

		    my $hsp_count_per_hit = 0;

		    $hit->rewind;
		    while (my $hsp = $hit->next_hsp) {
			$hsp_counter++;

			next if $hsp_count_per_hit > $self->pre_compile->{HSP_ALIGNMENT_IMAGE_LIMIT};
			$hsp_count_per_hit++;

			my $hsp_strand =
			  $hsp->strand('hit') ne $hsp->strand('query') ? -1 : 1;

			$hsp_strand = $hsp->strand('hit')
			  if $blast_app =~ /^tblastn/;    # Exception
			$hsp_strand = $hsp->strand('query')
			  if $blast_app =~ /^blastx/;     # Exception

			my ($hsp_cluster) = $hsp->get_tag_values('cluster');

			my $feature = Bio::SeqFeature::Generic->new(
			    -display_name => $hsp->hit->start . '..'
			      . $hsp->hit->end,           # . '(' . $hsp->score . ')',
			    -score  => $hsp->bits,                      # $hsp->score,
			    -start  => $hsp->start,
			    -end    => $hsp->end,
			    -strand => $hsp_strand,
			    -tag    => {anchor => "anchor$hsp_counter"},
			);

			if ($hsp_cluster && $hsp_strand eq '1') {
			    $clustered_plus_strand_hsps->add_sub_SeqFeature(
				$feature,
				'EXPAND'
			    );
			    $clustered_plus_strand_hsps->score(
				$clustered_plus_strand_hsps->score + $feature->score);
			}
			elsif ($hsp_cluster && $hsp_strand eq '-1') {
			    $clustered_minus_strand_hsps->add_sub_SeqFeature(
				$feature,
				'EXPAND'
			    );
			    $clustered_minus_strand_hsps->score(
				$clustered_minus_strand_hsps->score +
				  $feature->score);
			}
			else {
			    push @hsps_in_track, $feature;
			}
		    }

		    my $track = $panel->add_track(
			-glyph        => 'graded_segments',
			-connector    => 'dashed',
			-max_score    => 800,
			-min_score    => 0,
			-sort_order   => 'high_score',
			-key          => "$formatted_name ",
			-bgcolor      => 'blue',
			-strand_arrow => 1,
			-height       => 7,
			-label        => 0,
			-pad_bottom   => 3,
		    );

		    $track->add_feature($clustered_plus_strand_hsps)
		      if $clustered_plus_strand_hsps->start;
		    $track->add_feature($clustered_minus_strand_hsps)
		      if $clustered_minus_strand_hsps->start;
		    $track->add_feature(@hsps_in_track) if @hsps_in_track;
		}
	    }

        # Write image to a temp file
        my $temp_file = File::Temp->new(
            TEMPLATE => "alignment_XXXXX",
            DIR      => $self->image_dir,
            SUFFIX   => ".png",
            UNLINK   => 0,
        );

        my $alignment_image = $temp_file->filename;

        $temp_file = File::Temp->new(
            TEMPLATE => "score_key_XXXXX",
            DIR      => $self->image_dir,
            SUFFIX   => ".png",
            UNLINK   => 0,
        );

        my $score_key_image = $temp_file->filename;
          # Print out images
        open(IMAGE, ">$alignment_image")
          or error("Cannot write file ($alignment_image): $!");
        print IMAGE $panel->png;
        $panel->finished;
        close IMAGE;

        open(IMAGE, ">$score_key_image")
          or error("Cannot write file ($score_key_image): $!");
        print IMAGE $score_key->png;
        $score_key->finished;
        close IMAGE;

        # Generate image map
        my @image_map_pieces;

        #     my @boxes = $panel->boxes;
        #     foreach my $map_component (@boxes) {
        #         my ($feature, $x1, $y1, $x2, $y2, $track) = @{$map_component};
        #
        #         my ($anchor) = $feature->get_tag_values('anchor');
        #         $x1 += 142;
        #         $x2 += 142;
        #         push @image_map_pieces, { coords => qq[$x1, $y1, $x2, $y2], href => qq[#$anchor] } if $anchor; # Padding (temporary)
        #     }

        # kviewer_string
        my %kviewer_adds;
        my $kviewer_adds = 0;
        foreach (@piece_refs) {
            next unless $_->{pos};

            $kviewer_adds++;

            my $kviewer_add;

            my $chr  = $_->{chr};
            my $name = $_->{name};
            my $type = $_->{type};
            my $pos  = $_->{pos};
            my $link = CGI::escape($_->{genome_link});    # ***

            my $name_string = join(",", @{$name});

            $kviewer_add =
              qq[$type ${name_string}-$kviewer_adds ${pos}]
              ;    # Zero-length markers do not work

            push @{$kviewer_adds{$chr}}, $kviewer_add;
        }

        push @data, [$query_name, $alignment_image, $score_key_image,
                     \%kviewer_adds, \%genome_links, \%expand_links,
                     \@image_map_pieces];
    }

    return \@data;
}

sub extract_hit_info {
    my ($self,$hit, $query_name, $query_type, $species) = @_;

    #my $piece_ref;
    my @piece_refs;
    my $hit_genome_link;
    my $hit_expand_link;

    my $hit_description = $hit->description;
    my $hit_name        = $hit->name;

    my $gbrowse_root_id = $species;

    my $gbrowse_root = "$gbrowse_root_id/"
      if $gbrowse_root_id;
    my $expand_root =
      qq[$gbrowse_root_id/]
      if $gbrowse_root_id;

    # Scenario 1 - decription contains chromosome location; C. elegans
    if ($hit_description =~ /\/map=(CHROMOSOME_|)([^\/]+)\/(\d+),(\d+)/) {
        my ($chr, $start, $end) = ($2, $3, $4);

        my $counter;

        $hit->rewind;

        my $on_reverse_strand = '';
        my @hsp_genome_link_parts;
        while (my $hsp = $hit->next_hsp) {
            $counter++;

            next if $query_type eq 'P';    # No HSPs for protein hits

            my $hsp_start  = $hsp->start('hit');
            my $hsp_end    = $hsp->end('hit');
            my $hsp_strand =
              $hsp->strand('hit') ne $hsp->strand('query') ? -1 : 1;

            my $hsp_genome_link_part = qq[$hsp_start-$hsp_end];

            # If the feature is on the reverse strand, then flip the coordinates in GBrowse:
            if ($hsp_strand == -1) {
                # $on_reverse_strand = 'flip=1;';
            }

            push @hsp_genome_link_parts, $hsp_genome_link_part
              if @hsp_genome_link_parts < $self->pre_compile->{HSP_GENOME_LINK_PART_LIMIT};
        }

        my $hit_ranges = qq[${on_reverse_strand}add=${hit_name}+Hits+Hits+] . join(',', @hsp_genome_link_parts);

        $hit_genome_link = qq[${hit_name};$hit_ranges];
        $hit_expand_link = $expand_root . qq[?] . join(";", 'width=450', qq[name=${hit_name};$hit_ranges]) if $expand_root;

        my $piece_ref = {
            chr         => $chr,
            name        => [$hit_name],
            type        => 'hit',
            pos         => "$start..$end",
            genome_link => undef,
            expand_link => undef,
        };
        push @piece_refs, $piece_ref;

    }

    # Scenario 2 - map to chromosome; C. elegans
    elsif ($hit_name =~ /CHROMOSOME_([^\/]+)/
        || $hit_name =~ /^([IVX]+|MtDNA)/) {
        my ($chr) = ($1);

        my $counter;
        my $top_hsp_start;
        my $top_hsp_end;
        my $top_hsp_strand;

        $hit->rewind;
        my $on_reverse_strand = '';
        my @hsp_genome_link_parts;
        while (my $hsp = $hit->next_hsp) {
            $counter++;

            next if $query_type eq 'P';    # No HSPs for protein hits

            my $hsp_start  = $hsp->start('hit');
            my $hsp_end    = $hsp->end('hit');
            my $hsp_strand =
              $hsp->strand('hit') ne $hsp->strand('query') ? -1 : 1;

            my $hsp_genome_link_part = qq[$hsp_start-$hsp_end];

            # If the feature is on the reverse strand, then flip the coordinates in GBrowse:
            if ($hsp_strand == -1) {
                # $on_reverse_strand = 'flip=1;';
            }

            push @hsp_genome_link_parts, $hsp_genome_link_part
              if @hsp_genome_link_parts < $self->pre_compile->{HSP_GENOME_LINK_PART_LIMIT};

            if ($counter == 1) {
                $top_hsp_start  = $hsp_start;
                $top_hsp_end    = $hsp_end;
                $top_hsp_strand = $hsp_strand;
            }

            my $piece_ref = {
                chr         => $chr,
                name        => [$hit_name],
                type        => 'hsp',
                pos         => "$hsp_start..$hsp_end",
                genome_link => undef,
                expand_link => undef,
            };
            push @piece_refs, $piece_ref;

        }

	my $hit_ranges = qq[${on_reverse_strand}add=${chr}+Hits+Hits+] . join(',', @hsp_genome_link_parts);

        my $view_start;
        my $view_end;

        if ($top_hsp_end > $top_hsp_start) {
            $view_start = $top_hsp_start - 3000;
            $view_end   = $top_hsp_end + 3000;
        }

        else {
            $view_start = $top_hsp_start + 3000;
            $view_end   = $top_hsp_end - 3000;
        }

        $hit_genome_link = qq[${chr}:${view_start}..${view_end};$hit_ranges];
        $hit_expand_link = $expand_root . qq[?] . join( ";", 'width=450', qq[name=${hit_name}:${view_start}..${view_end};$hit_ranges]) if $expand_root;

    }

    # Scenario 3 - neither
    else {
        my $counter;
        my $top_hsp_start;
        my $top_hsp_end;
        my $top_hsp_strand;

        $hit->rewind;
        my $on_reverse_strand = '';
        my @hsp_genome_link_parts;
        while (my $hsp = $hit->next_hsp) {
            $counter++;

            next if $query_type eq 'P';    # No HSPs for protein hits

            my $hsp_start  = $hsp->start('hit');
            my $hsp_end    = $hsp->end('hit');
            my $hsp_strand =
              $hsp->strand('hit') ne $hsp->strand('query') ? -1 : 1;

            my $hsp_genome_link_part = qq[$hsp_start-$hsp_end];

            # If the feature is on the reverse strand, then flip the coordinates in GBrowse:
            if ($hsp_strand == -1) {
                # $on_reverse_strand = 'flip=1;';
            }

            push @hsp_genome_link_parts, $hsp_genome_link_part
              if @hsp_genome_link_parts < $self->pre_compile->{HSP_GENOME_LINK_PART_LIMIT};

            if ($counter == 1) {
                $top_hsp_start  = $hsp_start;
                $top_hsp_end    = $hsp_end;
                $top_hsp_strand = $hsp_strand;
            }

            my $piece_ref = {
                chr         => undef,
                name        => undef,
                type        => undef,
                pos         => undef,
                genome_link => undef,
                expand_link => undef,
            };
            push @piece_refs, $piece_ref;

        }

        my $hit_ranges = qq[${on_reverse_strand}add=${hit_name}+Hits+Hits+] . join(',', @hsp_genome_link_parts);

        my $view_start;
        my $view_end;

        if ($top_hsp_end > $top_hsp_start) {
            $view_start = $top_hsp_start - 3000;
            $view_end   = $top_hsp_end + 3000;
        }

        else {
            $view_start = $top_hsp_start + 3000;
            $view_end   = $top_hsp_end - 3000;
        }

        $hit_genome_link = qq[${hit_name}:${view_start}..${view_end};$hit_ranges];
        $hit_expand_link = $expand_root . qq[?] . join(";", 'width=450', qq[name=${hit_name};$hit_ranges]) if $expand_root;

    }
    return (\@piece_refs, $hit_genome_link, $hit_expand_link);
}
sub sort_hits {
    my ($self,$hit, $blast_app) = @_;

    my @all_hsps;

    # Mark with unique identifiers and copy into a new array as refs
    $hit->rewind;
    my $hsp_counter = -1;
    while (my $hsp = $hit->next_hsp) {
        next if $hsp_counter > $self->pre_compile->{HSP_ALIGNMENT_IMAGE_LIMIT};
        $hsp_counter++;

        $hsp->add_tag_value('id',      $hsp_counter);
        $hsp->add_tag_value('cluster', 1);

        $all_hsps[$hsp_counter] = $hsp;
    }

    # Mark ones to be clustered
    foreach my $i (0 .. $#all_hsps) {
        my ($ith_cluster) = $all_hsps[$i]->get_tag_values('cluster');

        my $ith_score  = $all_hsps[$i]->bits;
        my $ith_start  = $all_hsps[$i]->start('query');
        my $ith_end    = $all_hsps[$i]->end('query');
        my $ith_strand =
          $all_hsps[$i]->strand('hit') ne $all_hsps[$i]->strand('query')
          ? -1
          : 1;

        $ith_strand = $all_hsps[$i]->strand('hit')
          if $blast_app =~ /^tblastn/;    # Exception
        $ith_strand = $all_hsps[$i]->strand('query')
          if $blast_app =~ /^blastx/;     # Exception

        foreach my $j (0 .. $#all_hsps) {
            next if $i == $j;

            my ($jth_cluster) = $all_hsps[$j]->get_tag_values('cluster');

            my $jth_score  = $all_hsps[$j]->bits;
            my $jth_start  = $all_hsps[$j]->start('query');
            my $jth_end    = $all_hsps[$j]->end('query');
            my $jth_strand =
              $all_hsps[$j]->strand('hit') ne $all_hsps[$j]->strand('query')
              ? -1
              : 1;

            $jth_strand = $all_hsps[$j]->strand('hit')
              if $blast_app =~ /^tblastn/;    # Exception
            $jth_strand = $all_hsps[$j]->strand('query')
              if $blast_app =~ /^blastx/;     # Exception

            next if $ith_strand ne $jth_strand;

            # Remove overlaps
            if (
                (      ($ith_start >= $jth_start)
                    && ($ith_start <= $jth_end)
                    && ((($jth_end - $ith_start) / ($ith_end - $ith_start)) >
                        0.8)
                )

                # (($ith_start >= $jth_start) && ($ith_start <= $jth_end) && (((2 * $ith_end - $ith_start - $jth_end) / ($ith_end - $ith_start)) > 0.8))
                || (   ($ith_end >= $jth_start)
                    && ($ith_end <= $jth_end)
                    && ($ith_end >= $jth_end)
                    && (
                        (   (2 * $jth_end - $jth_start - $ith_end) /
                            ($jth_end - $jth_start)
                        ) > 0.8
                    )
                )
              ) {
                if ($ith_score > $jth_score) {
                    $all_hsps[$j]->remove_tag('cluster');
                    $all_hsps[$j]->add_tag_value('cluster', 0);
                }
                else {
                    $all_hsps[$i]->remove_tag('cluster');
                    $all_hsps[$i]->add_tag_value('cluster', 0);
                }
            }
        }
    }

    return 1;
}

sub autoload {
    my ($self,$param) = @_;

    my $object = $param->{'autoload'};

    my ($id, $species, $db) = $object =~ /^Blast (\S+) against (\S+) (\S+)/;

    $self->log->debug("[API::Service::blast_blat::autoload()]",
                      " \$id=$id, \$species=$species, \$db=$db");

    return unless $id && $db && $species;

    my $obj = WormBase::Web->model('WormBaseAPI')->fetch({
        class  => 'Sequence',
        name   => $id,
        nowrap => 1
    });

    unless ($obj) {
        $self->log->warn("[API::Service::blast_blat::autoload()]",
                         " object $object not found");
        return;
    }

    $param->{'search_type'} = 'blast';

    if ($db =~ /protein/) {
        $param->{'blast_app'} = 'blastp';
        $param->{'query_sequence'} = $obj->asPeptide;
        $param->{'query_type'} = 'prot';
        $param->{'database'} = lc($species.'_'.$db);
    }
    else {
        $param->{'blast_app'} = 'blastn';
        $param->{'query_sequence'} = $obj->asDNA;
        $param->{'query_type'} = 'nucl';
        $param->{'database'} = lc($species.'_'.$db);
    }
}

1;
