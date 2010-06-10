package WormBase::API::Object::Anatomy_term;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';


#### subroutines

sub details {

  my $self = shift;
  my $term = $self->object;
  my %data;
  my $desc = 'notes';
  my $data_pack;

  #### data pull and packaging
  
  my $ao_term = $term->Term;
  my $definition = $term->Definition;
  my $synonym = $term->Synonym;
  my $remark = $term->Remark;
  my $url = $term->URL;

  $data_pack = {
  				'ace_id' =>$term,
  				'term' => $ao_term,
  				'definition' => $definition,
  				'synonym' => $synonym,
  				'remark' => $remark,
  				'url' => $url,
  				};
  ####

  $data{'data'} = $data_pack;
  $data{'description'} = $desc;
  return \%data;
}


##NB create transgene method:

#sub make_link {
#  my ($object) = shift;
#  if ($object->class eq 'Expr_pattern') {
#    my $gene = eval { $object->Gene};
#    my $bestname = Bestname($gene) if $gene;
#    my $pattern = substr($object->Pattern,0,75);
#    $pattern .= '...' if length($object->Pattern) > 75;
#    my $evidence;
#    return (ObjectLink($object),ObjectLink($gene,$bestname),$pattern,$evidence);
#  } elsif ($object->class eq 'GO_term') {
#    my $term = $object->Term;
#    my $type = $object->Type;
#    my $ao_code = $object->right;
#    my (@evidence) = GetEvidence(-obj=>$ao_code,-dont_link=>1);
#    my $evidence = join(';',@evidence);
#    return (ObjectLink($object),$CODES{$type},$term,$evidence);
#  }
##### new code for function
#	elsif ($object->class eq 'Anatomy_function'){
#		my $phenotype = $object->Phenotype;
#		my $phenotype_name = $phenotype->Primary_name;
#		my $gene = eval{$object->Gene;};
#		if ($gene) {
#		
#			my $gene_name = $gene->CGC_name;  ## $gene_name = eval {}; ;
#			
#			if(!($gene_name)){
#				
#				$gene_name = $gene->Sequence_name;
#			}
#			my $gene_url = "../gene/gene?Class=Gene;name=" . $gene;
#			my $gene_link = a({-href=>$gene_url},$gene_name);
#			
#			$phenotype_name =~ s/_/ /g;
#			my $gene = $object->Gene;
#			return (b("Gene\: ") . $gene_link,b("Phenotype\: ") . $phenotype_name, b("via Anatomy function\: ") . ObjectLink($object), "");
#		}
#		
#		
#	}
#	elsif ($object->class eq 'Expression_cluster'){
#		my $description = substr($object->Description,0,65);
#		$description .= '...' if length($object->Description) > 65;
#		return (ObjectLink($object),$description,"","");
#	}
#}


#	SubSection('Transgene' ,Tableize([map{$_->Transgene} grep {/marker/i&& defined $_->Transgene} $term->Expr_pattern],0,10)) if ($term->Expr_pattern) ;
#  EndSection;


##### tags
### Expr_pattern GO_term Reference Anatomy_function Anatomy_function_not Expression_cluster

#sub expr_patterns{

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



#sub go_term {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



#sub reference {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



#sub anatomy_fn {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



#sub anatomy_fn_not {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}



#sub expr_cluster {

#  my $self = shift;
#  my $object = $self->object;
#  my %data;
#  my $desc = 'notes';
#  my %data_pack;

#  #### data pull and packaging

#  ####

#  $data{'data'} = \%data_pack;
#  $data{'description'} = $desc;
#  return \%data;
#}


1;



