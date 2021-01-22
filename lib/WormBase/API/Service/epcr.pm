package WormBase::API::Service::epcr;

use Moose;
with 'WormBase::API::Role::Object';

use strict;
#use Ace::Browser::AceSubs qw(:DEFAULT AceAddCookie);
use CGI qw/:standard escapeHTML Sub *table/;
use File::Temp qw(tempfile);
use URI::Escape::XS qw(uri_escape);
#use ElegansSubs;
#use Bio::DB::GFF;

use constant EPCR       => '/usr/local/wormbase/services/e-PCR';
use constant BROWSER    => 'http://www.wormbase.org/tools/genome/gbrowse/c_elegans_PRJNA13758?name=%s;add=%s';
use constant JBROWSE    => '/tools/genome/jbrowse-simple/?data=data%2Fc_elegans_PRJNA13758&tracks=Classical_alleles%2CPolymorphisms%2CCurated_Genes&loc=%s&addFeatures=%s';
use constant GENBANK    => 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=nucleotide&amp;cmd=search&amp;term=%s';
use vars qw/$GFFDB $ACEDB $REF $EPCR_DB $data $format $entry_type $M $N $file_dir/;

use namespace::autoclean -except => 'meta';

sub index {
    my $data = {};
    return $data;
}

sub run {
    my ($self, $param) = @_;
    $data = $param->{'sts'};
    $format = $param->{'format'};
    $entry_type = $param->{'entry_type'} || 'sts';
    $M = $param->{'M'} || 50;
    $N = $param->{'N'} || 0;

    $ACEDB = $self->ace_dsn->dbh;
    my $version = $ACEDB->version;
    $EPCR_DB = "/usr/local/wormbase/databases/$version/blast/c_elegans/PRJNA13758";
    $file_dir = $self->tmp_dir('epcr');
    $GFFDB = $self->gff_dsn('c_elegans');
    $REF = $self;

    my ($results, $links, $msg) = print_results();
    return {
	type => $format,
	results => $results,
	objects => $links,
	msg => $msg,
    };
}

sub print_results {
  if ($entry_type eq 'id') { return print_results_by_id(); }
  elsif ($entry_type eq 'sts') { return print_results_by_sts(); }
  elsif ($entry_type eq 'pos') { return print_results_by_pos(); }
}

sub print_results_by_sts {
  my ($results, $objects, $msg);
  my $TMP = $file_dir;
  my ($fh,$filename) = tempfile("epcr-XXXXXXX",DIR=>$TMP);
  my (@invalid,%names);

  # clean up the entry please
  my @lines = split /\r?\n|\r/,$data;
  foreach (@lines) {
    my ($name,$left,$right,$length) = split /\s+/;
    next unless defined $name;
    next if lc($name) eq 'name';  # in case they followed directions too literally

    $length ||= 1500;
    unless ($left  =~ /^[gatcn]+$/i && $right =~ /^[gatcn]+$/i && $length =~ /^\d+$/) {
      push @invalid,$_;
      next;
    }

    $names{$name}++;
    print $fh join("\t",$name,uc $left,uc $right,$length),"\n";
  }
  close $fh;

  my @options;
  push @options,"M=$M" if $M && $M =~ /^(\d+)$/;
  push @options,"N=$N" if $N && $N =~ /^(\d+)$/ && $N < 5;

  my $command  = join ' ',EPCR,$filename,$EPCR_DB . "/genomic.fa",@options;
  my $opened = open (E,"$command |");
  $msg .= "Couldn't run e-PCR program '$command': $!" unless $opened;

  my $callback = sub {
    my $line = <E>;
    return unless defined $line;
    chomp($line);
    my ($ref,$position,@assay) = split /\s+/,$line;
    my $assay = "@assay";  # in case the assay contains whitespace
    my ($start,$stop) = split /\.\./,$position;
    return ($assay,$ref,$start,$stop);
  };

  if ($format eq 'html') {
    ($results, $objects) = print_html($callback,\%names,\@invalid);
  } else {
    $results = print_text($callback,\%names,\@invalid);
  }
  my $closed = close E;
  $msg .= "Couldn't run e-PCR program '$command': $!" unless $closed;

  return $results, $objects, $msg;
#  unlink $filename;
}

sub print_results_by_id {
  my @ids = split /\s+/,$data;
  my %names         = map {$_=>1} @ids;
  my @invalid       = ();  # none
  my $callback = sub {
    return unless @ids;
    my $id = shift @ids;
    return ($id,PCR_Product=>$id);
  };

  if ($format eq 'html') {
    return print_html($callback,\%names,\@invalid);
  } else {
    return print_text($callback,\%names,\@invalid);
  }

}

sub print_results_by_pos {
  my @lines = split /\r?\n|\r/,$data;
  my %names;
  my @invalid       = ();  # none

  my $callback = sub {
    return unless @lines;
    my $line = shift @lines;
    my ($name,$position ) = split /\s+/,$line;
    $position = $name unless defined $position;
    if ($position =~ /([\w._-]+):(-?[\d,]+)(?:-|\.\.|,)?(-?[\d,]+)$/) {
      return ($name,-name=>$1,-start=>$2,-stop=>$3);
    } else {
      return ($name,$position);
    }
  };

  if ($format eq 'html') {
    return print_html($callback,\%names,\@invalid);
  } else {
    return print_text($callback,\%names,\@invalid);
  }
}

sub print_text {
  my $callback = shift;
  my ($names,$invalid_lines) = @_;
  my $results;
  $results .= header(-type=>'text/plain');
  $results .= "# assay	chromosome	start	end	genbank	start	end	link/cosmid	start	end	gene	exons covered	total exons\n\n";

  while (my($assay,@args) = $callback->()) {
    my ($ref,$start,$stop,$gb,$cosmid,$genes) = resolve_coordinates(@args) or next;
    delete $names->{$assay};
    if (@$genes) {
      foreach (@$genes) {
	$results .= join ("\t",$assay,$ref,$start,$stop,@$gb,@$cosmid,@$_) . "\n";
      }
    } else {
      $results .= join ("\t",$assay,$ref,$start,$stop,@$gb,@$cosmid) . "\n";
    }
  }

  # error reporting
  if (%$names) {
    $results .= "\n# NOT FOUND: ";
    $results .= join(" ",keys %$names) . "\n";
  }
  if (@$invalid_lines) {
    $results .= "\n# INVALID LINES:\n";
    $results .= '# ' . join("\n# ",@$invalid_lines) . "\n";
  }

  return $results;
}

sub print_html {
  my $callback = shift;
  my ($names,$invalid_lines) = @_;
  my (@results, %objects);

  push @results, start_table({-class=>'databody',-width=>'100%'});
  push @results, TR({-class=>'datatitle'}, th({-colspan=>7},'e-PCR Results'));
  push @results, TR({-class=>'datatitle'},
	   th([
	       'Assay',
	       'Chromosomal Pos',
	       'Genbank Pos',
	       'Cosmid/Link Pos',
	       'Genes Covered',
	       'Exons Covered',
	       'Exons in Gene'
	      ]));

  while (my($assay,@args) = $callback->()) {
    my ($ref,$start,$stop,$gb,$canonical,$genes) = resolve_coordinates(@args) or next;
    delete $names->{$assay};

    my $reflink = $ref =~ /CHROMOSOME_([IVX]*)/ ? $1 : $ref;
    my $genome_link    = sprintf(BROWSER,"$reflink:$start..$stop","$reflink+pcr_assay+$assay+$start..$stop");

        #build jbrowse addFeature json
    my $jbrowse_feature_json = uri_escape("[{\"seq_id\":\"$ref\",\"start\":$start,\"end\":$stop,\"name\":\"$assay\"}]");
    my $length = $stop - $start +1;
    my $buf_start = $start-0.05*$length;
    my $buf_stop  = $stop +0.05*$length;
    my $jbrowse_link   = sprintf(JBROWSE,"$reflink:$buf_start..$buf_stop",$jbrowse_feature_json);

    my $gb_link        = sprintf(GENBANK,$gb->[0]);
    my $can_key = $canonical->[0] . "_link";
    my $pcr_key = "$assay" . "_link";
    $objects{$can_key} = objURL($canonical->[0],'Sequence', "$canonical->[0]: $canonical->[1]..$canonical->[2]");
    $objects{$pcr_key} = objURL($assay,'PCR_product', $assay);

    my $first_gene  = shift @$genes;
    my $cds0_key = $first_gene->[0] . "_link";
    $objects{$cds0_key} = objURL($first_gene->[0],'CDS');
    push @results, TR(td([
		 ($entry_type eq 'id') ? a($pcr_key) : $assay,
		 a({-href=>$jbrowse_link,-target=>'_blank'},"JBrowse: $ref: $start..$stop") (a({-href=>$genome_link,-target=>'_blank'},"GBrowse"),
		 @$gb ? a({-href=>$gb_link,-target=>'_blank'},"$gb->[0]: $gb->[1]..$gb->[2]")
		      : '&nbsp;',
		 @$canonical ? a($can_key)
		             : '&nbsp;',
		 a($cds0_key),
		 $first_gene->[1],
		 $first_gene->[2]
		]));
    my $count = 1;
    for my $additional_gene (@$genes) {
      my $key = $additional_gene->[0] . "_link";
      $objects{$key} = objURL($additional_gene->[0],'CDS') unless $objects{$key};
      $count++;
      push @results, TR(td([
		   '&nbsp;',
		   '&nbsp;',
		   '&nbsp;',
		   '&nbsp;',
		   a($key),
		   $additional_gene->[1],
		   $additional_gene->[2]
		]));
    }

  }
  push @results, TR({-class=>'datatitle'},th({-colspan=>7},start_form({-action=>'/tools/epcr/'}),submit('Search Again'),end_form()));
  push @results, end_table;

  # error reporting
  if (%$names) {
    push @results, h2({-class=>'error'},'NOT FOUND:');
    push @results, ul(li([keys %$names]));
  }

  if (@$invalid_lines) {
    push @results, h2({-class=>'error'},'INVALID LINES:');
    push @results, ul(li($invalid_lines));
  }


  return \@results, \%objects;
}

sub resolve_coordinates {
  my @args      = @_;
  my $db        = $GFFDB;
  my ($segment)   = $db->segment(@args);
  if ($segment) {
    $segment->absolute(1);
    my ($ref,$start,$stop) = ($segment->ref,$segment->start,$segment->stop);
    my ($gb,$canonical,$gene) = segment2goodstuff($segment);

    return ($ref,$start,$stop,$gb,$canonical,$gene);
  } elsif (@args == 3) { # i.e. in (ref,start=>stop) format
    return (@args,[],[],[]);
  }
  return;
}

sub segment2goodstuff {
  my $segment = shift;
  my ($ref,$start,$stop) = ($segment->ref,$segment->start,$segment->stop);

  my (@genes,$gb,$c);
  # Not correct for WS126
  my @features = $segment->features('coding_exon:curated','region:Genbank',
				    'region:Genomic_canonical','region:Link');
  my %features;
  foreach (@features) {
    push @{$features{$_->source}},$_;
  }

  # This will need to be changed for WS126
  # Each partial gene is an exon...consolidate these into unique genes
  # This is astoundingly baroque
  my $full_genes = {};
  foreach my $partial_gene (@{$features{curated}}) {
    # fetch the full gene, please
    my ($full_gene) = grep {$_->name eq $partial_gene->name} $partial_gene->features('mRNA:WormBase');
     $segment->ref($full_gene);

    my $full_cds = $GFFDB->segment($full_gene);

    my @exons = $full_cds->features('exon:WormBase');

    $full_genes->{$full_gene->name}->{total} = scalar @exons;

    foreach (@exons) { $_->ref($full_gene);  }
    @exons  = sort {$a && $b ? $a->start<=>$b->start : 0} @exons;
    for (my $e=0; $e < @exons; $e++) {
	# Track partial coverage
	if ((($segment->start > $exons[$e]->stop) && ($segment->stop > $exons[$e]->start))
	    || (($segment->start < $exons[$e]->stop) && ($segment->stop < $exons[$e]->start))) {
	    push(@{ $full_genes->{$full_gene->name}->{partially_covered}},$e+1);
	}

      next if $exons[$e]->stop  < $segment->start;
      next if $exons[$e]->start > $segment->stop;
     # one-based indexing for biologists!
     push(@{ $full_genes->{$full_gene->name}->{covered}},$e+1);
    }

#    my @total_exons = $segment->features('coding_exon:curated');
#    my @total_exons = $full_cds->features('coding_exon:curated');
#    $full_genes->{$full_gene->name}->{total} = scalar @total_exons;
  }

  foreach (keys %{$full_genes}) {
      my $total = $full_genes->{$_}->{total};
      my %seen;
      my @covered = grep {!$seen{$_}++} sort { $a <=> $b } eval { @{$full_genes->{$_}->{covered}} };
      unless (@covered) {
	  my %partial;
	  my @temp = grep {!$partial{$_}++} sort { $a <=> $b } eval { @{$full_genes->{$_}->{partially_covered}} };
	  @covered = map { $_ . ' (partial)'} @temp;
      }
      push @genes,[$_,join(', ',@covered),$total];
  }

  # choose the one genbank entry that we are closest to the center of
  # (ignore case of spanning a genbank entry for now....)
  $gb = [undef,undef,undef];
  if (my @genbank = eval { @{$features{Genbank} } }) {
    my $middle = ($stop+$start)/2;
    my %distance_from_middle = map {$_ => abs(0.5-($middle-$_->stop)/$_->length)} @genbank;
    my ($middle_most) = sort {$distance_from_middle{$a}<=>$distance_from_middle{$b}} @genbank;
    $segment->ref($middle_most);
    $gb = [$middle_most->name,$segment->start,$segment->stop];
  }

  # find either a genomic canonical or a link that covers the region entirely
  my $shortest_canonical;
  for my $c (@{$features{Genomic_canonical}},@{$features{Link}}) {
    next unless $c->contains($segment);  # must contain segment completely
    $shortest_canonical = $c if !defined($shortest_canonical) || $c->length < $shortest_canonical->length;
  }

  $c = [undef,undef,undef];
  if ($shortest_canonical) {
    $segment->ref($shortest_canonical);
    $c = [$shortest_canonical->name,$segment->start,$segment->stop];
  }

  return ($gb,$c,\@genes);
}

sub objURL {
  my ($name, $class) = @_;

  my $object = $ACEDB->fetch(-class => $class, -name  => $name, -fill => 1) if $name && $class;
  return $REF->_pack_obj($object) if $object;
}

sub error {
  return 0;
}

sub message {
  return 0;
}

1;
