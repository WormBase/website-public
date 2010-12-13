package WormBase::API::Object::Gene_class;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


####################
# GENERAL INFO
####################


sub name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	my $name = $object->Main_name;
	
	#### data pull and packaging

	$data_pack = {
	
		'id' => "$object",
		'label' => "$object",
		'class' => "Gene_name"
	};
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub id {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = {
			'id' => "$object",
			'label' => "$object",
			'class' => 'Gene_class'
			};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
	
}

sub other_name {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Other_name;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub description {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Description;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub phenotype {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

	$data_pack = $object->Phenotype;

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}

sub laboratory {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	my $laboratory = $object->Designating_laboratory;

	#### data pull and packaging

	$data_pack = {
	
		'id' => "$laboratory", 
		'label' => "$laboratory",
		'Class' => 'Laboratory'
	};

	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;
}


#sub general_info {
#
#	my $self = shift;
#    my $object = $self->object;
#	my %data;
#	my $desc = 'notes';
#	my %data_pack;
#
#	#### data pull and packaging
#
#	####
#
#	$data{'data'} = \%data_pack;
#	$data{'description'} = $desc;
#	return \%data;
#}


#########
# Gene
#########


sub gene {

	my $self = shift;
	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my @genes = $object->Genes;
	
	foreach my $gene (@genes) {
	    my %gene_data;
	    my $species = $gene->Species;
	    my $gene_name = $self->bestname($gene);
	    %gene_data = (
	      'id' => "$gene",
	      'label' => "$gene_name",
	      'class' => 'Gene'
	      );
	    
	    if ($data_pack{$species}) {
	    
	    	my $gene_data = $data_pack{$species};
	    	push @$gene_data,\%gene_data;
	    	$data_pack{$species} = $gene_data;
	    }
	    
	    else {
	    	
	    	$data_pack{$species} = [\%gene_data];
	    }
	}
  
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub old_members {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging
    
	my @old_genes = $object->Old_member;
	my @genes = map {$_->Other_name_for} @old_genes;

	foreach  my $gene (@genes) {
	   my $gene_name = $self->bestname($gene);
	   my $sequence_name =  $gene->Sequence_name;
	   my $species = $gene->Species;
	   my %gene_data = (
	      'id' => "$gene",
	      'label' => "$gene_name",
	      'class' => 'Gene'
	      ); 
	      
	    if ($data_pack{$species}) {
	    
	    	my $gene_data = $data_pack{$species};
	    	push @$gene_data,\%gene_data;
	    	$data_pack{$species} = $gene_data;
	    }
	    
	    else {
	    	
	    	$data_pack{$species} = [\%gene_data];
	    }
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}

## TODO: figure out the nuisances of @onames if necessary....

sub previous_member {

	my $self = shift;
	my $object = $self->object;
	my $dbh = $self->ace_dsn->dbh;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	my @others;
	my @genes = eval {$dbh->fetch(-query=>qq{find Gene where Other_name="$object" . "*"})};

	foreach my $gene (@genes) {

	  my $bestname = $self->bestname($gene);
	  my @onames = $gene->Other_name;
	  my $seq_name = $gene->Sequence_name;
	  my %gene_data = (
	  
	  #	'info' => {
	  		'ace_id' => "$gene",
	  	  	'gene_name' => "$bestname",
	  	  	'class' => 'Gene'
	  #	},
	
	  #  'other_names' => \@onames,
	  #  'sequence_name' => $seq_name    
	    );    

	    push @data_pack, \%gene_data;
	 }
	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub remarks {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	
	@data_pack = $object->Remark;

	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}


1;
