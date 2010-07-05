package WormBase::API::Object::Phenotype;

use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';
 

sub name {
    my $self = shift;
    my $ace  = $self->object;
    my $data = { description => 'The internal WormBase referential ID of the protein',
		 data        =>  { id    => "$ace",
				   label => $ace->name,
				   class => $ace->class
		 },
    };
    return $data;
}

sub common_name {
    my $self = shift;
    my $ace  = $self->object;
    my $data = { description => 'The internal WormBase referential ID of the protein',
		 data        =>  { id    => "$ace",
				   label => $ace->name,
				   class => $ace->class
		 },
    };
    return $data;
}

############################################################
#
# The Details widget
#
############################################################
sub primary_name {
   my $object = shift->object;
   my $clean_name = ($object  =~ /WBPheno.*/) ? $object->Primary_name : $object ;
   $clean_name =~ s/_/ /g;
   
   my $data = { description => 'The primary name of the phenotype ',
		 	data        => $clean_name  ,
    };
   return $data;
}

sub short_name {
    
   my $data = { description => 'The primary name of the phenotype ',
		 	data        => shift ~~ 'Short_name'  ,
    };
   return $data;
}

sub synonym  {
    
   my $data = { description => 'The synonym name of the phenotype ',
		 	data        => shift ~~ '@Synonym'  ,
    };
   return $data;
}

sub description {
   my $self=shift;
   my $des= $self ~~ 'Description';
 
   my $data = { description => 'The description of the phenotype ',
		 	data        => {      des=>$des ,
					      evidence=>$self->_get_evidence($des) ,
				      },
    };
   return $data;
}

sub assay {
    
   my $data = { description => 'The Assay of the phenotype ',
		 	data        => shift ~~ 'Assay'  ,
    };
   return $data;
}

sub remark {
    
   my $data = { description => 'The Remark of the phenotype ',
		 	data        => shift ~~ 'Remark'  ,
    };
   return $data;
}

sub wb_id {
   my $object = shift->object;
    
   my $data = { description => 'The WormBase ID of the phenotype ',
		 	data        => {
					     id => $object,
					     label => $object,
					     class => 'phenotype',
					  } , 
    };
   return $data;
}


sub is_dead {
   my $object = shift->object;
   my $alternate;
   if ($object ->Dead(0)) {
	  $alternate = eval  {$object ->Dead->right };
   } 
   my $data = { description => "The Note of the phenotype when it's retired and replaced by another  ",
		 	data        => {
					     id => $alternate,
					     label => $alternate,
					     class => 'phenotype',
					  } , 
    };
   return $data;
}

 
############################################################
#
# The Ontology Browser widget
# 
############################################################



############################################################
#
# The Related Information widget
#
############################################################
 
sub related_phenotypes {
   my $self = shift;
   my $phenotype = $self->object;
   my $result;
   if ($phenotype->Related_phenotypes(0)) {
	foreach my $tag (qw/Specialisation_of Generalisation_of/) {
	    (my $type = $tag) =~ s/_/ /g;
           my @entries;
	    foreach my $ph ($phenotype->$tag){
	    	push @entries, {id=>$ph, label=>$self->best_phenotype_name($ph), class=>"phenotype"};
	    }
	    $result->{$type}=\@entries;
	}
   }
   my $data = { description => "The related phenotypes ",
		 	data        => $result , 
    };
   return $data;
}

 
sub rnai {

   my $data = { description => "The related phenotypes of the phenotype",
		 	data        => shift->_format_objects('RNAi') , 
    };
   return $data;
}

sub variation {

   my $data = { description => "The related variation of the phenotype",
		 	data        => shift->_format_objects('Variation') , 
    };
   return $data;
}

sub go_term {

   my $data = { description => "The related Go term of the phenotype",
		 	data        => shift->_format_objects('GO_term') , 
    };
   return $data;
}

sub transgene {
  
   my $data = { description => "The related transgene of the phenotype ",
		 	data        => shift->_format_objects('Transgene') , 
    };
   return $data;
}

sub anatomy_ontology {
    
    my $anatomy_fn = shift ~~ 'Anatomy_function';
    my $anatomy_fn_name = $anatomy_fn->Involved if $anatomy_fn;
    my $anatomy_term = $anatomy_fn_name->Term if $anatomy_fn_name;
    my $anatomy_term_id = $anatomy_term->Name_for_anatomy_term if $anatomy_term;
    my $anatomy_term_name = $anatomy_term_id->Term if $anatomy_term_id;
    return unless $anatomy_term_name;
     
    my $data = { description => "The Anatomy Ontology of the phenotype ",
		 	data        =>  {     id=>$anatomy_term_id,
					      label=>$anatomy_term_id , 
					      class => $anatomy_term_id->class,
					 }
    };
    return $data;
}  
 
############################################################
#
# The Private Methods
#
############################################################
sub _format_objects {
    my ($self,$tag) = @_;
    my $phenotype = $self->object;
    my %result;
    foreach ($phenotype->$tag){
	my $is_not;
	my $str=$_;
	if ($tag eq 'RNAi') {
	    my $cds  = $_->Predicted_gene;
	    my $gene = $_->Gene;    
	    my $cgc  = eval{$gene->CGC_name};
	    $str  = $cgc ? "$cds ($cgc)" : $cds;
	    $str.="[$_]";
	    $is_not = _is_not($_,$phenotype);
	}elsif ($tag eq 'GO_term') {

	    my $joined_evidence;
=pod	need an exmple!!
	    my @evidence = go_evidence_code($_);
	    foreach (@evidence) {
		my ($ty,$evi) = @$_;
		my $tyy = a({-href=>'http://www.geneontology.org/GO.evidence.html',-target=>'_blank'},$ty);
		
		my $evidence = ($ty) ? "($tyy) $evi" : '';
		$joined_evidence = ($joined_evidence) ? ($joined_evidence . br . $evidence) : $evidence;
	    }
=cut
	    my $desc = $_->Term || $_->Definition;
	    $str .= (($desc) ? ": $desc" : '')
		. (($joined_evidence) ? "; $joined_evidence" : '');
	     
	} elsif ($tag eq 'Variation') {
		 $is_not = _is_not($_,$phenotype);
	} 
	my $hash = {    label=> $str,
			class => $tag,
			id => $_, };
	if(defined $is_not) { $result{$is_not}{$str} = $hash;}
	else { $result{$str} = $hash;}
    }
    return \%result;
}


sub _is_not {
    my ($obj,$phene) = @_;
    my @phenes = $obj->Phenotype;
    foreach (@phenes)  {
	next unless $_ eq $phene;
	my %keys = map { $_ => 1 } $_->col;
	return 1 if $keys{Not};
	return 0;
    }
}

1;
