package WormBase::API::Service::ontology_browser;



use Moose;
with 'WormBase::API::Role::Object';

has 'term_type' => (
    is => 'rw',
);

has 'association_count_file' => (
    is => 'ro',
    lazy => 1,
    default => sub {
	 my ($self) =@_;
	 (my $type = $self->term_type) =~ s/_term//;
	  $type = 'gene' if($type eq 'go');
	 my $file = sprintf($self->pre_compile->{association_count_file},
		    $self->ace_dsn->version,$type,$self->ace_dsn->version);
         return $file; # just a blessed scalar ref
    },
);

sub index {
   my ($self) = @_;
   my $data = {};
   return $data;
}




sub run {
    my ($self,$param) = @_;
    my $class = lc($param->{class});
    $self->term_type($class);
    my $name= $param->{name};
    my $object;

    if ($class && $name ) {

      unless($name =~ m/WBbt:|GO:|WBPhenotype:/i){
	# this is a hack for search exact match in xapian,need to index the term or find other way around -xq
 	$name =~ s/ /:/g ;
	my $match = $self->_api->xapian->fetch({ query => $name, class => $class});

	if ($match ){
	    $name = $match->{id};
	}
	else {
	    return { msg=>"multiple terms are found",
		     redirect => 'Ontology Browser',
		     class => $class,
		     name => $name,
		    };
	}
      }
     ($object) = $self->ace_dsn->fetch(-class => $class,
			       -name  => $name,
			      )   ;

    }else{
	return message("A query term is required!");
    }
    return message("Can't find your term in our database.") unless $object;

    my @parents;
    my $path_count = $self->_get_parent($object,\@parents);
    my $childrens=$self->_get_child($object);

    foreach my $list (@parents){
		my $parent = pop @$list;
		$parent->{siblings} = $self->_get_child($parent->{obj});
		push @$list, $parent;
	}
    return { parents => \@parents,
	     childrens=>$childrens,
	     path_count=>$path_count,
	     term => $self->_pack_obj($object),
	     term_type => $self->term_type,
    };
}

sub error {
  return 0;
}

sub message {
  return { msg=>shift, redirect=>shift};
}



sub _get_child {
  my ($self,$obj)=@_;
  my @c;
  if($self->term_type eq 'phenotype') {
	 @c = grep {/Generalisation_of/} eval {$obj->Related_phenotypes};
  }else {
     @c = eval {$obj->Child};
  }
  my @childrens;
  map {map { push @childrens, $self->_pack_obj($_); } $_->col } @c;

  return \@childrens;

}

# recursive function always work!
sub _get_parent {
    my ($self,$obj,$array)= @_;
	my @p;
	if($self->term_type eq 'phenotype'){
		@p = grep{/Specialisation_of/} eval {$obj->Related_phenotypes};
	}else{
    	@p = eval {$obj->Parent};
	}
    if(@p) {
	my $number = 0;
	foreach my $pre (@p){
	    my $type =$pre;
	    if($self->term_type eq 'anatomy_term'){
 	    	$type = lc($type) unless ( $type =~ m/DESCENDENT/i );
	    	$type =~ s/_p$//g;
	    }else{
			$type = 'is_a';
	    }
	    foreach my $node ($pre->col){
		  my $node_number= $self->_get_parent($node,$array);
		  $number += $node_number;
		  my $total = scalar(@$array);
		  for(my $i=0;$i<$node_number;$i++){
		      my $list = $array->[$total-$i-1];

		      my $association_count = $self->_association_count($node);
# 		      my $association_count_total = $association_count + $self->_association_count($node,1);

		      push @$list,$self->_pack_obj($node,undef,(
					  "type"=>"$type",
					  "obj"=>$node,
# 					  "association_count_total"=>$association_count_total,
					  "association_count"=>$association_count,)) ;
		  }
	    }
	}
	return $number;
    }
   push @$array, [];
   return 1;
}



sub _association_count {
  my ($self,$obj,$total)=@_;
  my $count=0;
  my @childrens;
=pod
  if($total){
    @childrens = $self->_get_child($obj);

    foreach (@childrens) {
	$count+=$self->_association_count($_,1);
    }
  }
  unless(@childrens){
=cut
     my $file = $self->association_count_file;
     $count = `grep -c \'$obj\' $file`;
     chomp($count);
#   }
  return $count;
}
1;
