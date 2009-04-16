package WormBase::Model::Operon;

use strict;
use warnings;
use base qw/WormBase::Model/;

sub contains_genes {
  my $self = shift;
  my $object = $self->current_object;
  my @genes = $object->Contains_gene;
  
  my @data;
  foreach my $gene (@genes) {
    next unless $gene; #??
    my %this_gene;
    $this_gene{gene} = $gene;
    
    my (%notes,@splice_leaders);
    for my $sl ($gene->col) {
      my @evidence = $sl->col;      
      $notes{$sl} = \@evidence;
      @splice_leaders = keys %notes
    }
    
    
    foreach ($gene->Corresponding_CDS) {
      my @associated_features = $_->Associated_feature;
      push @splice_leaders,map {$_->Method } @associated_features;
    }
    
    foreach my $sl (@splice_leaders) {
      push @{$this_gene{splice_leaders}},{
					  splice_leader => $sl,
					  evidence      => $notes{$sl},
					 };
    }
    push @data,\%this_gene;
  }
  return \@data;
}
  
sub genomic_position {
  my $self = shift;
  my $object   = $self->current_object;
  my $dbh_gff = $self->dbh_gff;
  my $segment = $dbh_gff->segment('Operon' => $object);
  $segment->absolute(1);
  my $data    = $self->SUPER::genomic_position($segment);
  return $data;
}


sub genomic_environs {
  my $self   = shift;
  my $object = $self->current_object;
  
  my $dbh_gff = $self->dbh_gff;
  my $segment = $dbh_gff->segment('Operon' => $object);
  
  $segment->absolute(1);  
  my $tracks = $self->{image_tracks};   # Specified in the wormbase.yml

  my $data = $self->build_gbrowse_img($segment,$tracks);
  return $data;
}

sub object_history {
  my $self = shift;
  my $object = $self->current_object;
  my (@history) = $self->History;
  my $stash;
  foreach my $history (@history) {
    next unless $history;  # ??
    my ($target_object,$evidence_type,$evidence_object,$evidence_remark,$remark);
    if ($history eq 'Deprecated') {
      ($remark,$evidence_type,$evidence_object,$evidence_remark) = $history->row;
    } else {
      ($history,$target_object,$evidence_object,$evidence_remark) = $history->row;
    }
    $history =~ s/_ / /g;
    
    push @{$stash}, {
		     type            => $history,
		     target_object   => $target_object,
		     remark          => $remark,
		     evidence        => $evidence_type,
		     evidence_object => $evidence_object,
		     evidence_remark => $evidence_remark,
		    };
  }

  return $stash;
}


=head1 NAME

WormBase::Model::Operon - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Original uses old structure, not Section/Subsection.
Model can benefit from generic evidence parsing/formatting

Need to fetch segments and features from Bio::DB::GFF

#--  # References will be handled generically
#--  my $reference = $operon->Reference ? 
#--    ObjectLink($operon->Reference,$operon->Reference->Title) 
#--      : "Blumenthal et al, Nature 417: 851-854 (2002) (cgc5303)";

#    # Evidence will be handled generically
#--  my %notes;  
#--  for my $gene (@genes) {
#--    for my $sl ($gene->col) {
#--      my @evidence = $sl->col;
#--      $notes{$gene}{$sl} = \@evidence;
#--    }
#--  }
    
#++  print h3('Operon Structure');
#++  print start_table;
#++  print TR({-class=>'datatitle'},th('CDS'),th('Spliced Leader'),th('SL Evidence'));
#++   for my $gene (@genes) {
#++    print start_TR({-class=>'databody'});
#++    my @evidence;
#      # PROPER DISPLAY NAME TO BE HANDLED BY VIEW, NOT MODEL
#--    print th(a({-href=>Object2URL($gene)},$gene->Sequence_name . 
#--		($gene->CGC_name ? " (" . $gene->CGC_name . ")" : '')
#--	));
#++ 
#++     my @sl = keys %{$notes{$gene}};
#++     @sl = '&nbsp;' unless @sl;
#++ 
#++     foreach ($gene->Corresponding_CDS) {
#++       my @associated_features = $_->Associated_feature;
#++       push @sl,map {$_->Method } @associated_features;
#++     }
#++     print td(join(br,@sl));
#++     print start_td();
#++     for my $sl (@sl) {
#++       @evidence = @{$notes{$gene}{$sl}} if $notes{$gene}{$sl};
#++       print (shift @evidence || '&nbsp;');
#++       print br if @sl > 1;
#++     }
#++     print end_td;
#++     print end_TR;
#++     while (@evidence) { # more evidence!
#++       print TR({-class=>'databody'},td('&nbsp;')x2,td(shift @evidence));
#++     }
#++   }
#++   print end_table;
#++   
#++   print h3('Other Information');
#++   print start_table;
#--   PrintOne('Genomic Position',$browser_url || '&nbsp;');
#--   PrintOne('Reference: ',$reference);
#++   print end_table;
#++ }

=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
