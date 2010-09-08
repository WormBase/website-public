package WormBase::API::Object::Operon;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

has 'ao_template' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $ao_object = $self->pull;
    	return $ao_object;
  	}
);



#######

sub template {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

### mainly for text data; and single layer hash ###

sub template_simple {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Tag;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


########

##################
# Description
##################

sub description {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my $species = $object->Species;
	my $description = $object->Description;

	%data_pack = (
	    'name' => $object,
	    'class' => 'Operon',
	    'species' => $species,
	    'description' => $description,
	    'reference' => 'TBD'
	);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}


###############
## Structure
###############

sub structure {

	my $self = shift;
	my $operon = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my %genes;
	my @gene_list;
	my @member_gene = $operon->Contains_gene;
 
	foreach my $gene (@member_gene) {

	  my $gene_name = $self->bestname($gene);
	  my %spliced_leader;

	    foreach my $sl ($gene->col) {

	      my @evidence = $sl->col;
	      #@evidence = get_evidence_names(\@evidence);
	      $spliced_leader{$sl} = \@evidence;      # each spliced leader key is linked to an array of evidence 
	    }
    
	    $genes{$gene_name} = \%spliced_leader;      # each gene key is linked to a hash of splioed leaders for the gene
	 } 

	####

	$data{'data'} = \%genes;
	$data{'description'} = $desc;
	return \%data;

}

# sub get_all_struct_data {
#   my %data;
#  
#   # get data on genes in operon 

#   $data{'Genes'} = \%genes;
#   $data{'Gene_List'} = \@gene_list;
#   
#   #get data on associated features
#   $data{'Associated'} = a({-href=>Object2URL($operon->Associated_feature)}, $operon->Associated_feature) if $operon->Associated_feature;
#   
#   if (my $segment = $DBGFF->segment('Operon' => $operon)) {
# 
#     # get genomic position
#     my ($ref,$start,$stop) = ($segment->abs_ref,$segment->abs_start,$segment->abs_stop);
#     my $browser_url = a({-href=>HunterUrl($ref,$start,$stop)},"$ref:$start..$stop");
#     $data{'Genomic_Position'} = $browser_url;
# 
#     # get gbrowse embedded image
#     my $genomic_picture = genomic_picture($segment);
#     $data{'Genomic_Picture'} = $genomic_picture;
#   }
# 
#   return \%data;
#}
# {
#   my $struct_data = get_all_struct_data();
#   StartSection('Structure');
# 
#   # print data in Genes
#   my @gene_list = @{$struct_data->{'Gene_List'}};
#   my $genes_content;
#   if(@gene_list) {
#     my %genes = %{$struct_data->{'Genes'}};
#     $genes_content = start_table({-border=>1}) . TR({-align=>'left'},th('Genes:'), th('Spliced Leader:'), th('Evidence:'));
#     foreach my $gene (@gene_list) {
#         my %spliced_leader = %{$genes{$gene}};                  # get spliced leaders for each gene
#         my $num_rows = keys(%spliced_leader);
#         $num_rows = 1 if $num_rows == 0;
#         $genes_content .= TR().td({-align=>'left',-rowspan=>$num_rows},$gene);
#         foreach my $sl (sort keys %spliced_leader) {
#             my @evidence = @{$spliced_leader{$sl}};             # get evidence for each spliced leader
#             $genes_content .= td($sl).td(join('<br>',@evidence)).TR();    
#         }
#      }
#     $genes_content .= end_table();
#   }
#   SubSection("", $genes_content);
# 
#   # print data in Associated  -- I never see anything 
#   my $associated_content = ${$struct_data}{'Associated'};
#   $associated_content = start_table().TR({-align=>'left'},th('Associated:'), td($associated_content).end_table()) if $associated_content;
#   SubSection("", $associated_content);
#   
#   # print data in Genomic Position
#   my $genomic_position = ${$struct_data}{'Genomic_Position'};
#   SubSection("", start_table().TR(th('Genomic Position:'),td($genomic_position)).end_table()) if $genomic_position;
#   
#   # print data in Genomic Picture
#   my $genomic_picture = ${$struct_data}{'Genomic_Picture'};
#   SubSection("", start_table().TR({-valign=>'top'},th('Genomic Environs:'),td($genomic_picture)).end_table()) if $genomic_picture;
#   
#   EndSection();
#}
#############
## History
#############

sub history {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my  @history_types = $object->History;
	
	foreach my $history_type (@history_types) {
	  my %histories;

	  foreach my $h ($history_type->col) {
	     my @evidence = $h->col;	     
	     @evidence = _get_evidence_names(\@evidence);
	    $histories{$h} = \@evidence;                    #Each history has an array of evidences
	  }
	    
	  $data_pack{$history_type} = \%histories;        #Each history_type is linked to a hash of histories
	}
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

# {
#   my %data;
#   my %history_types;
    
#   $data{'History'} = \%history_types;
# 
#   return \%data;
# 
# }

# {
#   my $history_data = get_all_history_data();
# 
#   # print data in History
#   my %history_types = %{$history_data->{'History'}};
#   my $history_content;
#   if(%history_types) {                                  #Only print section if History items exist
#     StartSection('History');
#     $history_content = start_table() . TR({-align=>'left'},th(''), th(''), th('Evidence:'));
#     foreach my $history_type (sort keys %history_types) {
#         my %operons = %{$history_types{$history_type}};           
#         my $num_rows = keys(%operons);
#         $num_rows = 1 if $num_rows == 0;
#         $history_content .= TR({-valign=>'top'}).td({-align=>'left',-rowspan=>$num_rows},$history_type.': ');
#         foreach my $operon (sort keys %operons) {
#             my @evidence = @{$operons{$operon}};        
#             $history_content .= td($operon).td(join('<br>',@evidence)).TR({-valign=>'top'});    
#         }
#      }
#     $history_content .= end_table();
#     SubSection("", $history_content);
#     EndSection;
#   }
# }
############
## Remark
############


sub remarks {

	my $self = shift;
    my $operon = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @remarks = $operon->Remark;
	my %remark_evidence;
  	
	for my $remark (@remarks) {

	  my @evidence = $remark->col;
	  $data_pack{$remark} = \@evidence;

  	}
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;

}

# sub get_all_remark_data {
#   my %data;
#   # get remarks and remark evidence data
#   
#   $data{'Remark_Evidence'} = \%remark_evidence;
#   return \%data;
# }



############
## Internal
############

sub _get_evidence_names {
  my ($evidences)=shift;
  my @ret;
  
  foreach my $ev (@$evidences) {
    my @names = $ev->col;
    if($ev eq "Person_evidence" || $ev eq "Author_evidence" || $ev eq "Curator_confirmed") {    
      $ev =~ /(.*)_(evidence|confirmed)/;  #find a better way to do this?    
      @names =  map{$1 . ': ' . $_->Full_name || $_} @names;
    }elsif ($ev eq "Paper_evidence"){
      @names = map{'Paper: ' . $_->Brief_citation || $_} @names;
    }elsif ($ev eq "Feature_evidence"){
      @names = map{'Feature: '.  $_->Visible->right || $_} @names;
    }elsif ($ev eq "From_analysis"){
      @names = map{'Analysis: '. $_->Description || $_} @names;
    }else {
      @names = map{$ev . ': ' . $_} @names;
    }
    push(@ret, @names);
  }
  return @ret;
}


1;