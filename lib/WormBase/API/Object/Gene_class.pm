package WormBase::API::Object::Gene_class;
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

sub general_info {

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
	      'gene_id' => $gene,
	      'gene_name' => $gene_name,
	      'class' => 'Gene'
	      );
	    
	    $data_pack{$species}{$gene} = \%gene_data;
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
	      'ace_id' => $gene,
	      'gene_name' => $gene_name,
	      'class' => 'Gene'
	      ); 

	   $data_pack{$species}{$gene} = \%gene_data; 
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
	my %data_pack;

	#### data pull and packaging
	
	my @others;
	my @genes = eval {$dbh->fetch(-query=>qq{find Gene where Other_name="$object" . "*"})};

	foreach my $gene (@genes) {

	  my $bestname = $self->bestname($gene);
	  my @onames = $gene->Other_name;
	  my $seq_name = $gene->Sequence_name;
	  my %gene_data = {
	    'ace_id' => $gene,
	    'gene_name' => $bestname,
	    'other_names' => \@onames,
	    'sequence_name' => $seq_name, 
	    'class' => 'Gene'
	    };    

	    $data_pack{$gene} = \%gene_data;
	 }
	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


# 	  foreach my $other (@onames) {
# 	    
# 	    if ($other =~ m/$object/) {
# 	      
# 
# 	    } else {
# 
# 		next;
# 	    }
# 	  }

sub remarks {

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


1;