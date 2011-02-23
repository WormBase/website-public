package WormBase::API::Object::Motif;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';

###################
## Identification
###################

sub title {
<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Motif.pm
	my $self 	= shift;
	my $object 	= $self->object;
	my $data_pack = $object->Title;

	my $data = {
				'data'=> $data_pack,
				'description' => 'title for the motif'
				};
	return $data;
}
=======
    my $self   = shift;
    my $object = $self->object;
    my $title   = $object->Title;

    my $data = { description => 'this is the description',
		 data        => "$title" };
    return $data;
}


# remarks() provided by Object.pm. We retain here for completeness of the API documentation.

=head2 remarks

This method will return a data structure containing
curatorial remarks for the gene class.

=head3 PERL API

 $data = $model->remarks();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

A Gene class (eg unc)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example
>>>>>>> /tmp/Motif.pm~other.glr_jt

<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Motif.pm
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
=======
curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }


>>>>>>> /tmp/Motif.pm~other.glr_jt

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

<<<<<<< /usr/local/wormbase/website/norie/lib/WormBase/API/Object/Motif.pm
1;=======


sub homologies_old {

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





1;
>>>>>>> /tmp/Motif.pm~other.glr_jt
