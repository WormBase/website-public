package WormBase::API::Object::Motif;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

###################
## Identification
###################

sub title {
	my $self 	= shift;
	my $object 	= $self->object;
	my $data_pack = $object->Title;

	my $data = {
				'data'=> $data_pack,
				'description' => 'title for the motif'
				};
	return $data;
}

sub remarks {
	my $self 	= shift;
    my $object 	= $self->object;
	my $data_pack = $object->Remark;

	my $data = {
				'data'=> $data_pack,
				'description' => 'remarks regarding motif'
				};
	return $data;	
}

sub database  {
	my $self = shift;
    my $object = $self->object;
	my ($database,$accession1,$accession2) = $object->Database('@')->row;
	my $accession = $accession2 || $accession1;
	
	my $data_pack = {'database' 	=> "$database",
					'accession' => "$accession"
	             };

	my $data = {
				'data'=> $data_pack,
				'description' => 'database which contained info on motif, along with its accession number'
				};
	return $data;
}

####################
## homology
####################

sub homologies {
	my $self = shift;
    my $object = $self->object;
	my @data_pack;
	
    foreach (qw/DNA_homol Pep_homol Motif_homol Homol_homol/) {
		if (my @homol = $motif->$_) {
			foreach (@homol) {
				my $id;
				my $label;
				my $class;
				my $homolog_data;
				if ($_ =~ /.*RepeatMasker/g) {
					$_ =~ /(.*):.*/;
					my $clone = $1;
					$id = "$clone";
					$label = "$clone";
					$class = 'Clone';
					
					$homolog_data = {	
						'id'	=> "$id",
						'label'	=> "$label",
						'class' => $class
					};
				} else
					$homolog_data = _pack_obj($_);	
				}
				push @data_pack, $homolog_data;
			}
		}       
	my $data = {
				'data'=> \@data_pack,
				'description' => 'homology data for this motif'
				};
	return $data;	
}

###################
## gene ontology
###################

sub go  {
	my $self = shift;
    my $motif = $self->object;
	my @go_terms;
	@go_terms = $motif->GO_term;
	
	foreach my $go_term (@go_terms) {	
		my $definition = $go_term->Definition;
		my ($evidence) = $go_term->right;
		my $term = $go_term->GO_term;
		my $go_data;

		$go_data = (		
					'term_data' => {
						'id'=> "$go_term",
						'label' => "$term",
						'class'=>'GO_term'
					},	
				'definition'=>$definition,
				'evidence'=>$evidence
				);
				
		push @data_pack, $go_data;		

	my $data = {
				'data'=> \@data_pack,
				'description' => 'go terms to with which motif is annotated'
				};
	return $data;	
}

1;