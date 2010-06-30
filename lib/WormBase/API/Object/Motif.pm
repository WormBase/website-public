package WormBase::API::Object::Motif;
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

sub identification {

	my $self = shift;
    my $motif = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my $accession;
	my $title;
	my $database;
	my $remarks;
	my $a1;
	my $a2;
	my $associated_transp_fam;
	my $match_seq;
	my $num_mismatch;
	
	$database = $motif->Database;
	if ($database) {
	
		($database,$a1,$a2) = $motif->Database('@')->row;
		$accession = $a1 || $a2;
	}
	

	$title = $motif->Title;
	$remarks = $motif->Remark;
	
	$associated_transp_fam = $motif->Associated_transposon_family;
	$match_seq = $motif->Match_sequence;
	$num_mismatch = $motif->Num_mismatch;

	%data_pack = (
					'ace_id'=>$motif
					,'database'=>$database
					,'accession'=>$accession
					,'associated_transp_fam'=>$associated_transp_fam
					,'match_seq'=>$match_seq
					,'num_mismatch'=>$num_mismatch
					);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub homologies {

	my $self = shift;
    my $motif = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
	
	my @dnas;
	my @peptides;
	my @motifs;
	my @homologies;
	
	@dnas = $motif->DNA_homol;
	@peptides= $motif->Pep_homol;
	@motifs= $motif->Motif_homol;
	@homologies= $motif->Homol_homol;


	%data_pack = (
					'dnas'=>\@dnas
					,'peptides'=>\@peptides
					,'motifs'=>\@motifs
					,'homologies'=>\@homologies
					);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub go  {

	my $self = shift;
    my $motif = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	

	#### data pull and packaging

	my @go_terms;
	
	@go_terms = $motif->GO_term;
	
	foreach my $go_term (@go_terms) {
	
		my $definition = $go_term->Definition;
		my ($evidence) = $go_term->right;
	
	
	
		$data_pack{$go_term} = (
								'ace_id'=>$go_term
								,'class'=>'GO_term'
								,'definition'=>$definition
								,'evidence'=>$evidence
								);
	}



	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



#{
#    my $text = start_table({-border=>1}) . TR(th('Term'),th('Description'),th('GO code'),th('Evidence'));
#    
#    # In order to display evidence, I actually need to visit each gene or CDS object,
#    # fetch all GO_terms and find the one which corresponds to the current one
#    my $evidence;
#    foreach my $go ($motif->) {
#	($evidence) = $go->right . 
#	    (($go->right) ?
#	     ': '. join(br,GetEvidenceNew(-object=>$go->right,-format => 'inline'))
#	     : '');
#
#	my $desc = $go->Definition;
#	$text .= TR(
#		    td(ObjectLink($go)),
#		    td($desc),
#		    td($go->right),
#		    td($evidence),
#		    );
#    }
#    $text .= end_table;
#	StartSection('Gene Ontology term associations');
#    SubSection('',
#	       i('This motif has been associated with the following Gene Ontology Terms'),
#	       $text);
#	EndSection();
#}


1;