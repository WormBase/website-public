package WormBase::API::Object::Motif;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


=head2 name

This method will return a data structure of the 
name and ID of the requested transgene.

=head3 PERL API

 $data = $model->name();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Transgene ID (gmIs13)

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/transgene/gmIs13/name

=head4 Response example

<div class="response-example"></div>

=cut 

# Supplied by Object.pm; retain pod for complete documentation of API
# sub name {}


#######


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

###################
## Identification
###################

sub title {
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

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene_class/unc/remarks

=head4 Response example

<div class="response-example"></div>

=cut 

# sub remarks { }




sub database  {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	my ($database,$accession1,$accession2) = $object->Database('@')->row;
	my $accession = $accession2 || $accession1;
	
	%data_pack = ('database' => "$database",
					'accession' => "$accession"
	             );

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}


sub data {

	my $self = shift;
	my $tag = shift; ## Associated_transposon_family Match_sequence Num_mismatch
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my %data_pack;

	#### data pull and packaging

	$data_pack{'data'} = $object->Title;
	$data_pack{'title'} = $tag;
	$data_pack{'title'} =~ s/_/ /g;

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}




####################
## homology
####################


sub homologies {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging
	
	
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
						
						'id' => "$id",
						'label' => "$label",
						'class' => $class
					};

				} else
				
					$homolog_data = _pack_obj($_);	
				}
				
				push @data_pack, $homolog_data;
			}
		}       
	####

	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

###################
## gene ontology
###################



sub go  {

	my $self = shift;
    my $motif = $self->object;
	my %data;
	my $desc = 'notes';
	my v;

	#### data pull and packaging

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
	}

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



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
