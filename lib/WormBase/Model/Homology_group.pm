package WormBase::Model::Homology_group;

use strict;
use warnings;
use base 'WormBase::Model';

sub cog_type {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->COG_type;
}

sub cog_code {
  my ($self) = @_;
  my $object = $self->current_object;
  return $object->COG_code;
}

sub general_cog_expansion {
  my ($self) = @_;
  my $object = $self->current_object;
  
  my $code = $object->COG_code;  
  my %general_cog_codes = (
			   Code_J => 'Information storage and processing',
			   Code_A => 'Information storage and processing',
			   Code_K => 'Information storage and processing',
			   Code_L => 'Information storage and processing',
			   Code_B => 'Information storage and processing',
			   Code_D => 'Cellular processes and signalling',
			   Code_Y => 'Cellular processes and signalling',
			   Code_V => 'Cellular processes and signalling',
			   Code_T => 'Cellular processes and signalling',
			   Code_M => 'Cellular processes and signalling',
			   Code_N => 'Cellular processes and signalling',
			   Code_Z => 'Cellular processes and signalling',
			   Code_W => 'Cellular processes and signalling',
			   Code_U => 'Cellular processes and signalling',
			   Code_O => 'Cellular processes and signalling',
			   Code_C => 'Metabolism',
			   Code_G => 'Metabolism',
			   Code_E => 'Metabolism',
			   Code_F => 'Metabolism',
			   Code_H => 'Metabolism',
			   Code_I => 'Metabolism',
			   Code_P => 'Metabolism',
			   Code_Q => 'Metabolism',
			   Code_R => 'Poorly characterized',
			   Code_S => 'Poorly characterized',
			  );
  return $general_cog_codes{$code}; 
}


sub specific_cog_expansion {
  my ($self) = @_;
  my $object = $self->current_object;
  
  my $code = $object->COG_code;  
  my %specific_cog_codes = (
			    Code_J => 'Translation, ribosomal structure and biogenesis',
			    Code_A => 'RNA processing and modification',
			    Code_K => 'Transcription',
			    Code_L => 'Replication, recombination and repair',
			    Code_B => 'Chromatin structure and dynamics',
			    Code_D => 'Cell cycle control, cell division, chromosome partitioning',
			    Code_Y => 'Nuclear structure',
			    Code_V => 'Defense mechanisms',
			    Code_T => 'Signal transduction mechanisms',
			    Code_M => 'Cell wall/membrane/envelope biogenesis',
			    Code_N => 'Cell motility',
			    Code_Z => 'Cytoskeleton',
			    Code_W => 'Extracellular structures',
			    Code_U => 'Intracellular trafficking, secretion, and vesicular transport',
			    Code_O => 'Posttranslational modification, protein turnover, chaperones',
			    Code_C => 'Energy production and conversion',
			    Code_G => 'Carbohydrate transport and metabolism',
			    Code_E => 'Amino acid transport and metabolism',
			    Code_F => 'Nucleotide transport and metabolism',
			    Code_H => 'Coenzyme transport and metabolism',
			    Code_I => 'Lipid transport and metabolism',
			    Code_P => 'Inorganic ion transport and metabolism',
			    Code_Q => 'Secondary metabolites biosynthesis, transport and catabolism',
			    Code_R => 'General function prediction only',
			    Code_S => 'Function unknown',
			   );
  
  return $specific_cog_codes{$code};
}

sub proteins {
  my ($self) = @_;
  my $object = $self->current_object;
  
  my @proteins = $object->Protein;
  
  # TODO: Protein links are now located in the template (external_urls hash)
  #  my $links = Configuration->Protein_links;
  my $links;

  my @protein_details; # Add protein details

  foreach (@proteins) {    
    # Get gene name (non-WB proteins)
    my $name = $_->Gene_name;
    
    # Get gene name (WB proteins)
    unless ($name) {
      my $cds = $_->Corresponding_CDS;
      my $gene = $cds->Gene if $cds;
      $name = $gene->CGC_name if $gene;
    }
    
    # If we have it as a separate object
    my $species = $_->Species || $self->ID2species($_);
    my $description = $_->Description;
    
    # If this is a wormpep protein, the description will be retrieved from corresponding cds
    unless ($description) {
      my $cds = $_->Corresponding_CDS;
      $description = $cds->DB_remark if $cds;
    }
    
    # Format protein id into a URL
    my $display_name = $name ? "$_ ($name)" : $_;
    
    my $url;
    if ($_ =~ /(\w+):(.+)/ and exists $links->{$1}) {
      my ($prefix, $accession) = ($1, $2);
      
      # hack for converting CG numbers to FBan numbers, this format needs to be confirmed - 25May05, 9Jul04/PC
      if ($prefix =~ /^flybase/i) { 
	$accession =~ s/-[\w\-]+$//; 
	$accession =~ s/^CG//i; 
	$accession = sprintf("%07d", $accession);
      }
      
      my $link_rule = $links->{$prefix};
      # TEMPLATIZE
      # $url = a({-href=>sprintf($link_rule, $accession)}, $display_name);
    } else { 
      # TEMPLATIZE
      # $url = a({-href=>Object2URL($_)},($name) ? "$_ ($name)" : $_);
    }
    
    push (@protein_details, [$species, $url, $description]);
  }
  
  
  #  my $table = start_table({-border=>1});
  #  
  #  $table .= TR(th(['Species','Protein','Description']));
  #  
  #  foreach (@protein_details) {
  #      my ($species, $protein, $description) = @$_;
  #      $table .= TR( td($species), td($protein), td($description) );
  #  }
  #  $table .= end_table;
  #  
  #  StartSection('Protein Details');
  #  SubSection('',$table);
  #  EndSection;
}


=head1 NAME

WormBase::Model::Homology_group - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=head1 MIGRATION NOTES

Type needs to have a link to the wiki appended for INPARANOID entries
  if ($type =~ /InParanoid/) {
      $type .= br .GenerateWikiLink('InParanoid',INPARANOID_URL);

formatting in the proteins(), links, etc

=head1 AUTHOR

Todd Harris (todd@five2three.com)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
