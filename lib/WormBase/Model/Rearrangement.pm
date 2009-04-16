package WormBase::Model::Rearrangement;

use strict;
use warnings;
use base 'WormBase::Model';

sub map_position {
  my ($self) = @_;
  my ($chrom,$pos,$error) = $self->_get_interpolated_position();
  
  # TEMPLATE?
  $pos   = _format_gmap($pos);
  $error = _format_gmap($error) if $error;
  
  my $text = "$chrom: $pos cM";
  $text .= " +/- $error" if $error;
  return $text;
}
  

sub alleles {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Variation;
}

sub rearrangement_type {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Type;
}

sub chromosome {
  my ($self) = @_;
  my $object = $self->current_object;
  my @chr = $object->Balances;
  return \@chr;
}

# if the relative position is provided (i.e. from_right_end or
# to_left_end), indicate it (careful because if not provided, on
# the right column, the tag name Locus will appear)
sub relative_position {
  my ($self) = @_;
  my $object = $self->current_object;
  my $rel_pos = $object->get('Balances',1)->right;
  unless ($rel_pos =~ /Locus/) {
    return $rel_pos;  # $rearg->get('Balances',1)->right);
  }
}

sub loci {
  my ($self) = @_;
  my $object = $self->current_object;
  
  # link the locus(i) to corresponding genetic map(s)
  my @locus = $object->get('Balances',1)->get('Locus',1);
  
  # necessary view formatting
  # SubSection('Locus/loci' => link_locus_map(@locus1));
  return \@locus;
}

sub experimental_position {
  my ($self) = @_;
  my $object = $self->current_object;
  my @data;
  my @chr = $object->Map;
  foreach my $chr (@chr) {
    my $left = $chr->right->get('Left');
    my $right = $chr->right->get('Right');
    push @data,[$chr,$left,$right];
  }
}

# TODO: This is not sufficient (or necessary?)
sub rearrangement_evidence {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Evidence->right;
}

sub genes_inside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Gene_inside;
}

sub clones_inside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Clone_inside;
}

sub loci_inside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Locus_inside;
}

sub rearrangements_inside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Rearr_inside;
}


sub genes_outside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Gene_outside;
}

sub clones_outside {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->Clone_outside;
}

sub rearrangements_outside {
  my ($self,$object) = @_;
  return $object->Rearr_outside;
}

sub strains_carrying {
  my ($self) = @_;    
  my $object = $self->current_object;
  return $object->Strain;
}


=pod thus begins the Mapping Data widget
  
It was too complicated for me to deal with at 2:30 AM.
Everything from here down to the next =cut needs to be migrated.


    if ($rearg->Mapping_data) {
      StartSection('Mapping Data');
      print_mapping_data();
    }

    if ($rearg->Reference) {
      StartSection('Reference');
      my @references = $rearg->Reference;
      SubSection('',
		 format_references(-references=>\@references,-format=>'long',-pubmed_link=>'image',
				   -curator=>url_param('curator')));
    }


sub print_mapping_data {
  my $locus = $rearg;
  SubSection('Two Point Data',two_pt_data($locus));
  SubSection('Multipoint Data',multi_pt_data($locus));

  my @data = $locus->follow(-tag=>'Pos_neg_data',
			    -filled=>1);

  my (@pos_neg,@other);
  for my $exp (@data){
    my $result = $exp->Results(1);
    if ($result =~ /delete|include|overlap|complement/) {
      push @pos_neg,$exp;
    } else {
      push @other,$exp;
    }
  }
  #  if ($TYPE eq 'Deletion'){
  #    SubSection('Deletions',pos_neg_table(@pos_neg))
  #  } elsif ($TYPE eq 'Duplication') {
  #    SubSection('Duplications',pos_neg_table(@pos_neg));
  #  } elsif ($TYPE eq 'Translocation') {
  #    SubSection('Translocations',pos_neg_table(@pos_neg));
  #  }
  #  SubSection('',other_table(@other));
  
  SubSection('',display_experimental_data(@pos_neg));
  SubSection('',display_experimental_data(@other));
}


sub two_pt_data {
  my $locus = shift;
  local $^W = 0;
  my @data = $locus->follow(-tag=>'2_point',
			    -filled=>1);
  return unless @data;
  my $toprow = th(['Genes','Distance','Author','Genotype','Raw Data','Comment']);
  my @rows;

  for my $exp (sort { $a->Calc_distance(1) <=> $b->Calc_distance(1) } @data) {
    my $mappers = fetch_mappers($exp);
    push @rows,td([
		   join("&nbsp;&lt;&gt;&nbsp;",
			a({-href=>Object2URL(Bestname($exp->Point_1(2)))},Bestname($exp->Point_1(2))),
			a({-href=>Object2URL(Bestname($exp->Point_2(2)))},Bestname($exp->Point_2(2))),
		       ),
		   $exp->Calc_distance(1) || "0.0" . '&nbsp;(' . (0+$exp->Calc_lower_conf(1))
		   . '-' . (0+$exp->Calc_upper_conf(1))
		   . ')',
		   $mappers,
		   # a({-href=>Object2URL($exp->Mapper)},$exp->Mapper),
		   a({-href=>Object2URL($exp)},$exp->Genotype),
		   $exp->Results,
		   cite(join('',$exp->Remark))
		  ]);
  }
  return table({-border=>undef,-width=>'100%'},
	       TR({-class=>'datatitle'},$toprow),
	       TR({-class=>'databody'},\@rows)),p();
}


sub multi_pt_data {
  my $locus = shift;
  my @data = $locus->follow(-tag=>'Multi_point',
			   -filled=>1);
  return unless @data;
  my $toprow = th(['Results','Author','Comment']);
  my @rows;
  for my $exp (@data) {
    next unless $exp->Results(1);
    my @results = $exp->Results(1)->row;
    shift @results;
    my (@loci,$total);
    $total = 0;
    while (@results) {
      my ($label,$locus,$count) = splice(@results,0,3);
      $count ||= 0;
      $total += $count;
      push(@loci,[$locus=>$count]);
    }
    my $genotype = '';
    my $open_paren;
    while (@loci) {
      my $l = shift @loci;
      if (defined $l->[1] && ($l->[1]+0) == 0) {
	$genotype .= "($l->[0]&nbsp;";
	$open_paren++;
      } else {
	$genotype .= $l->[0];
	if ($open_paren) {
	  $genotype .= ")";
	  undef $open_paren;
	}
	$genotype .= "&nbsp;($l->[1]/$total)&nbsp;" if defined($l->[1]);
      }
    }
    my $mappers = fetch_mappers($exp);
    push @rows,td([
		   a({-href=>Object2URL($exp)},$genotype,),
		   $mappers,
		   cite(join('',$exp->Remark))
		  ]
		 );
  }
  return table({-border=>undef,-width=>'100%'},
	       TR({-class=>'datatitle'},$toprow),
	       TR({-class=>'databody'},\@rows)),p();
}


# Formerly the pos_neg_table, I generalized this to become the
# display_experimental_data().
sub display_experimental_data {
  my @data = @_;
  return unless @data;
  my @rows;

  # my $toprow = th([qw/Class Name Position Result Status Remark Author/]);
  # Not displaying the status
  my $toprow = th([qw/Class Name Position Genotype Result Remark Author/]);

  # MTR was using TYPE in the header row.  This isn't really appropriate
  # (ie experimental results are not duplications or deletions in themselves).
  # my $toprow = th(['Class','Name','Position',$TYPE,'Status','Author']);
  
  # Gather all the unqiue loci and objects that have been mapped
  # Multiple experiments that use the same loci will be flattened!
  my $tested = [];
  foreach my $experiment (@data) {
    my (@to_test) = ($experiment->Item_1(2),$experiment->Item_2(2));
    foreach my $marker (@to_test) {

      #  next if (defined $tested->{$marker});
      # Let's not include ourselves either
      next if ($marker eq $rearg);

      # Is this inside or outside of the rearrangement
      # I'm not sure how clear + or - really is. Perhaps this should just read
      # the description in the database
      my $pos_neg = $experiment->Calculation;
      my $results  = $experiment->Results(1);
      $results =~ s/\.//g;
      my $results_flag;
      if ($results =~ /deletes|includes|overlaps|(does not complement)/ || $pos_neg eq 'Positive') {
	$results_flag = '+';
      } elsif ($results =~ /complements|(does not (delete|include|overlap))/ || $pos_neg eq 'Negative') {
	$results_flag = '-';
      }

      # Calculate the map position of each marker
      my ($chrom,$gmap,$error,$position);
      my $class = $marker->class;
      if ($class eq 'Gene') {
	# Is it *really* necessary to fetch each locus here?
	my $locus = $DB->fetch(Gene => $marker);
	($chrom,$gmap,$error) = ($locus->Map(1),$locus->Map(3),$locus->Map(5));
	$position = link_map_position($marker,$chrom,$gmap,$error);
      } elsif ($class eq 'Rearrangement') {
	# The gmap position will be a range...
	my @chrom = $marker->Map;
	$chrom = $chrom[0];
	if ($chrom) {
	  my @left  = $chrom[0]->right->get('Left');
	  my @right = $chrom[0]->right->get('Right');
	  $position = link_rearg_position($marker,$chrom,$left[0],$right[0]);
	  # We will sort rearrangements based on left most end.
	  $gmap = $left[0];
	}
      } elsif ($class eq 'Variation') {
	$chrom = $marker->Map;
	my $allele = $DB->fetch(Variation=>$marker);
	
      } else {  # Final case: clones
      }

      # There may be more than one experiment / marker...
      push (@$tested,
	    {marker => $marker,
	     status => 'tested',        # Experiments will all have a status of 'tested';
	     experiment => $experiment, # Store experiment for later access
	     formatted_result =>
	     a({-href=>ResolveUrl('/db/misc/etree?class=Pos_neg_data',"name=$experiment")},$results_flag),
	     class       => $marker->class,
	     gmap        => $gmap || 0,             # used for sorting
	     position    => $position || UNKNOWN, # position is formatted and linked
	     chrom       => $chrom,
	     error       => $error,
	     genotype    => $experiment->Genotype || '',
	     marker_link => $marker->class eq 'Gene' ? ObjectLink($marker,Bestname($marker)) : ObjectLink($marker),
	     results     => $results,
	    });
      #      $tested->{$marker} = { status => 'tested',        # Experiments will all have a status of 'tested';
      #      			     experiment => $experiment, # Store experiment for later access
      #      			     formatted_result =>
      #      			     a({-href=>ResolveUrl('/db/misc/etree?class=Pos_neg_data',"name=$experiment")},$results_flag),
      #      			     class       => $marker->class,
      #      			     gmap        => $gmap || 0,             # used for sorting
      #      			     position    => $position || UNKNOWN, # position is formatted and linked
      #      			     chrom       => $chrom,
      #      			     error       => $error,
      #      			     marker_link => ObjectLink($marker),
      #      			     results     => $results,
      #      			   };
      
      # There may be more than one experiment / marker...
      # Each experiment will be a unique row...
    }
  }

  my $sorted = sort_markers($tested);
  #  foreach my $marker (@$sorted) {
  foreach my $h (@$sorted) {
    # my $h = $tested->{$marker};
    push @rows,td([
    		   $h->{class},
		   $h->{marker_link},
		   $h->{position},
		   $h->{genotype},
    		   $h->{formatted_result},
#		   $h->{status},
		   $h->{results} || '&nbsp;',
		   fetch_mappers($h->{experiment}),
    		  ]);
  }

  my $table = table({-border=>undef,-width=>'100%'},
		    TR({-class=>'datatitle'},$toprow),
		    TR({-class=>'databody',
			-align=>'center'},\@rows)),p();
  return $table;
}


sub fetch_mappers {
  my $experiment = shift;
  my @mappers = $experiment->Mapper;
  my @linked;
  foreach (sort { $a cmp $b } @mappers) {
    push (@linked,ObjectLink($_));
  }
  my $linked = join(', ',@linked);
  $linked ||= 'Lab: ' . ObjectLink($experiment->Laboratory);
  return $linked;
}


# Two element sort based on chrom then gmap position
# Inefficient. I should be able to do this in a single step.
sub sort_markers {
  my $markers = shift;

  # sort by chromosome and gmap
  my $split = {};
  foreach (@$markers) {
    my $chrom = $_->{chrom};
    push (@{$split->{$chrom}},$_);
  }
  
  # Now sort each chrom based on genetic map position
  my @all_sorted;
  foreach my $chrom (keys %$split) {
    my @markers = @{$split->{$chrom}};
    my @this_chrom = sort {$a->{gmap} <=> $b->{gmap}} @markers;
    push (@all_sorted,@this_chrom);
  }
  return \@all_sorted;
}


sub link_map_position {
  my ($marker,$chrom,$gmap,$error) = @_;
  return (UNKNOWN) if (!$error);
  my $position = a({-href=>ResolveUrl('/db/misc/epic?class=locus',"name=$marker")},$chrom
		   . sprintf(": %2.2f +/- %2.3f",$gmap,$error));
  return $position;
}

sub link_rearg_position {
  my ($marker,$chrom,$left,$right) = @_;
  my $position = a({-href=>ResolveUrl('/db/misc/epic?class=rearrangment',"name=$marker")},$chrom
		   . sprintf(": %2.2f to %2.2f",$left,$right));
  return $position;
}



=cut







# TEMPLATE?
sub _format_gmap {
  my $pos = shift;
  return sprintf("%2.3f",$pos);
}


=pod

link_locus_map belongs in a tempalte
sub link_locus_map {
  my @loci = @_;
  my @results;
  foreach my $locus(@loci) {
    push @results,a({-href=>ResolveUrl('/db/misc/epic?class=locus',"name=$locus")},$locus);
  }
  return @results;
}

=cut



# THis is the original get_object.  It will form the basis of search.

=pod

sub search {
  # Simple search for rearrangements
  my $rearg = $DB->fetch(Rearrangement=>$query);
  return $rearg if ($rearg);

  # Maybe users entered a chromosome
  my @by_chrom = $DB->fetch(-query=>qq{find Rearrangement where Map="$query"});
  return (undef,\@by_chrom) if (@by_chrom);

  # Perhaps users are trying to find rearrangements in relation to a gene
  my @by_gene;

  # Use FetchGene so that users can search via WBGene IDs, too
  # Parse out the gene if needed (queries from the prompt)
  my ($gene,$bestname) = FetchGene($DB,$query,'suppress multiple hits display flag');
  my ($chrom,undef,$gmap,undef,$error) = eval{$gene->Map(1)->row};
  my $low  = $gmap - $error;
  my $high = $gmap + $error;
  my $status = 'experimentally determined';
  unless ($chrom && $gmap) {
    if (my $map = $gene->get('Interpolated_map_position')) {
      ($chrom,$gmap) = $map->right->row;
      $low  = $gmap;
      $high = $gmap;
      $status = 'interpolated';
    }
  }

  # So that I can add a row in the table for the gene
  push (@by_gene,{ status    => $status,
		   gene      => $gene,
		   bestname  => $bestname,
		   gmap      => $gmap,
		   error     => $error,
		   chrom     => $chrom,
		 });

  # We do not need to fetch these if they have specifically
  # asked for those that exclude the rearrangement
  if ((!$position) || ($position eq 'includes')) {
    # Fetch those genes that have positively been shown to contain the rearrangement
    my @contains = $DB->fetch(-query=>qq{find Rearrangement where Gene_inside="$gene"});
    foreach (@contains) {
      push (@by_gene,{ position  => 'includes',
		       status    => 'confirmed',
		       rearrange => $_}
	   );
    }

    # Fetch rearrangements inferred to contain the gene
    if ($chrom && $gmap) {
      my @contains = $DB->fetch(-query=>qq{find Rearrangement Map = "$chrom" \# (LEFT <= $low AND RIGHT >= $high)});
      foreach (@contains) {
	push (@by_gene,{ position  => 'includes',
			 status    => 'inferred',
			 rearrange => $_}
	     );
      }
    }
  }

  # Fetch rearrangements that exclude the rearrangement
  if ((!$position) || ($position eq 'excludes')) {
    my @excludes = $DB->fetch(-query=>qq{find Rearrangement where Gene_outside="$gene"});
    foreach (@excludes) {
      push (@by_gene,{ position  => 'excludes',
		       status    => 'positive',
		       rearrange => $_}
	   );
    }

    # Fetch rearrangements inferred to exclude the gene (this is kind of absurd)
    if ($chrom && $gmap) {
      my @excludes = $DB->fetch(-query=>qq{find Rearrangement Map = "$chrom" \# (LEFT <= $low AND RIGHT <= $high)});
      push(@excludes,$DB->fetch(-query=>qq{find Rearrangement Map = "$chrom" \# (LEFT >= $low AND RIGHT >= $high)}));
      foreach (@excludes) {
	push (@by_gene,{ position  => 'excludes',
			 status    => 'inferred',
			 rearrange => $_}
	     );
      }
    }
  }
  return (undef,undef,\@by_gene,$gene,$bestname) if @by_gene;
}

=cut


=pod

The display_chrom_table, not yet migrated

 sub display_chrom_table {
  my $by_chrom = shift;
  my @rows;
  foreach my $re (@$by_chrom) {
    my $type       = $re->Type;
    my @chr        = $re->Map;
    my $desc      .= join("; ",$re->Remark);
    my $allele     = $re->Variation;
    $type ||= ($re =~ /Dp/) ? 'duplication' : (($type =~ /Df/) ? 'deletion' : '');

    foreach my $chr (@chr) {
      my $left  = eval { $chr->get('Left')->right }  || UNKNOWN;
      my $right = eval { $chr->get('Right')->right } || UNKNOWN;
      $left  = gmap($left) unless $left eq UNKNOWN;
      $right = gmap($right) unless $right eq UNKNOWN;

      push (@rows,[$chr,$re,$desc,$type,$allele,$left,$right]);
    }
    push (@rows,[UNKNOWN,$re,$desc,$type,$allele,UNKNOWN,UNKNOWN]) unless @chr;
  }

  # Corresponds to position in the @rows array
  my %cols = (
	      0 => ['chromosome',     10  ],
	      1 => ['rearrangement',  10  ],
	      2 => ['type',           10  ],
	      3 => ['description',    35  ],
#	      4 => ['allele',         10  ],
	      5 => ['left breakpoint', 10 ],
	      6 => ['right breakpoint',10 ]);

  my $sort_by    = url_param('sort');
  $sort_by = ($sort_by eq '') ? 6 : $sort_by; # Have to do it this way because of 0
  my $sort_order = (param('order') eq 'ascending') ? 'descending' : 'ascending';
  my @sorted;
  if ($sort_by =~ /[0123]/) {   # Alphanumeric sort columns
    if ($sort_order eq 'ascending') {
      @sorted = sort { lc ($a->[$sort_by]) cmp lc ($b->[$sort_by]) } @rows;
    } else {
      @sorted = sort { lc ($b->[$sort_by]) cmp lc ($a->[$sort_by]) } @rows;
    }
  } else {
    if ($sort_order eq 'ascending') {
      @sorted = sort { $a->[$sort_by] <=> $b->[$sort_by] } @rows;
    } else {
      @sorted = sort { $b->[$sort_by] <=> $a->[$sort_by] } @rows;
    }
  }

  # Create column headers linked with the sort options
  print hr;
  print start_table();
  my $url = url(-absolute=>1,query=>1);
  $url .= "?name=" . param('name') . ';sort=';
  print TR(
	   map {
	     my ($header,$width) = @{$cols{$_}};
	     th({-class=>'dataheader',-width=>$width},
		a({-href=>$url . $_ . ";order=$sort_order"},
		  $header
		  . img({-width=>17,-src=>'/images/sort.gif'})
		 ))}
	   sort {$a <=> $b} keys %cols);

  foreach (@sorted) {
    my ($chrom,$re,$desc,$type,$allele,$left,$right) = @$_;
    print TR(td({-class=>'datacell'},($chrom ne UNKNOWN) ? a({-href=>$url . "?name=$chrom"},$chrom) : $chrom),
	     td({-class=>'datacell'},ObjectLink($re)),
	     td({-class=>'datacell'},lc $type),
	     td({-class=>'datacell'},$desc),
	     # td({-class=>'datacell'},ObjectLink($allele)),
	     td({-class=>'datacell'},$left),
	     td({-class=>'datacell'},$right));
  }
  print end_table;
}

=cut

=pod

The display gene table. Not yet migrated.

sub display_gene_table {
  my $by_gene = shift;
  my @rows;
  foreach my $href (@$by_gene) {
    my $status    = $href->{status};
    my $position  = $href->{position};
    my $re        = $href->{rearrange};
    if ($re) {
      my $type      = $re->Type;
      my @chr       = $re->Map;
      my $desc     .= join("; ",$re->Remark);
      my $allele    = $re->Variation;
      $type ||= ($re =~ /Dp/) ? 'duplication' : (($type =~ /Df/) ? 'deletion' : '');

      foreach my $chr (@chr) {
	my $left  = eval { $chr->get('Left')->right }  || UNKNOWN;
	my $right = eval { $chr->get('Right')->right } || UNKNOWN;
	$left  = gmap($left) unless $left eq UNKNOWN;
	$right = gmap($right) unless $right eq UNKNOWN;
	push (@rows,[$chr,$re,$status,$position,$desc,$type,$allele,$left,$right]);
      }
      push (@rows,[UNKNOWN,$re,$status,$position,$desc,$type,$allele,UNKNOWN,UNKNOWN]) unless @chr;
    } else {
      # This is the gene entry
      my $gene = $href->{gene};
      my $gmap = $href->{gmap};
      next unless $gmap;  # Only add a special row for genes that have a gmap
      my $chrom = $href->{chrom};
      my $error = $href->{error};
      my $low   = gmap($gmap - $error);
      my $high  = gmap($gmap + $error);
      my $status = $href->{status};
      push (@rows,[$chrom,a({-href=>Object2URL($gene)},$href->{bestname}),
		   '-',
		   '-',
		   a({href=>Object2URL($gene)},$href->{bestname} . " ($gene)")
		   . "; genetic map position is $status.",
		   '-','',$low,$high,'highlight']);
    }
  }

  # Corresponds to position in the @rows array
  my %cols = (
	      0 => [ 'chrom',         5 ],
	      1 => [ 'rearrangement',10 ],
	      2 => [ 'type',         10 ],
	      3 => [ 'status',       10 ],
	      4 => [ 'position',     10 ],
	      5 => [ 'description', 25 ],
#	      6 => [ 'allele',       10 ],
	      7 => [ 'left brkpt',   15],
	      8 => [ 'right brkpt',  15]);

  my $sort_by    = url_param('sort');
  $sort_by = ($sort_by eq '') ? 7 : $sort_by; # Have to do it this way because of 0
  my $sort_order = (param('order') eq 'ascending') ? 'descending' : 'ascending';
  my @sorted;
  if ($sort_by =~ /[0123]/) {   # Alphanumeric sort columns
    if ($sort_order eq 'ascending') {
      @sorted = sort { lc ($a->[$sort_by]) cmp lc ($b->[$sort_by]) } @rows;
    } else {
      @sorted = sort { lc ($b->[$sort_by]) cmp lc ($a->[$sort_by]) } @rows;
    }
  } else {
    if ($sort_order eq 'ascending') {
      @sorted = sort { $a->[$sort_by] <=> $b->[$sort_by] } @rows;
    } else {
      @sorted = sort { $b->[$sort_by] <=> $a->[$sort_by] } @rows;
    }
  }

  # Create column headers linked with the sort options
  print hr;
  print start_table();
  my $url = url();
  $url .= "?name=" . param('name') . ';sort=';
  print TR(
	   map {
	     my ($header,$width) = @{$cols{$_}};
	     th({-class=>'dataheader',-width=>$width},
		a({-href=>$url . $_ . ";order=$sort_order"},
		  $header
		  . br
		  . img({-width=>17,-src=>'/images/sort.gif'})
		 ))}
	   sort {$a <=> $b} keys %cols);

  foreach (@sorted) {
    my ($chrom,$re,$status,$position,$desc,$type,$allele,$left,$right,$class) = @$_;
    $class ||= 'datacell';
    print TR({-class=>$class},td({-class=>$class},($chrom ne UNKNOWN) ? a({-href=>$url . "?name=$chrom"},$chrom) : $chrom),
	     td({-class=>$class},ObjectLink($re)),
	     td({-class=>$class},lc $type),
	     td({-class=>$class},$status),
	     td({-class=>$class},$position),
	     td({-class=>$class},$desc),
	     td({-class=>$class},$left),
	     td({-class=>$class},$right));
  }
  print end_table;
  display_notes();
}

=cut

=head1 NAME

WormBase::Model::Rearrangement - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Original CGI had a sortable table of rearrangements by chromosome. These have been
pulled but not converted.

link_locus_map should be migrated to the view

There is some seriously batty logic in the original displaying chromosomes and markers.
I couldn't figure it out.

There were conflicting field names between interpolated and experimental map (ie Chromosome).
I prepended chromosome to these in order to distinguish them

Evidence is probably not sufficient

Remark has inline evidence - handle at the template

Lots of formatting for the features inside and outside

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
