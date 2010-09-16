package WormBase::API::Object::Interaction;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



has 'effector' => (    
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my $effector = $self->interaction_type->Effector->right;
    	return $effector;
  	}
);

has 'effected' => (
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
   
    	my $self = shift;
    	my $effector = $self->interaction_type->Effector->right;
    	return $effector;   
    }
);

has 'non_directional_interactors' => (
	is  => 'ro',
    isa => 'Ace::Object',
    lazy => 1,
    default => sub {
    
    	my $self = shift;
    	my @non_directional_interactors; 
    	eval {
    	
    		@non_directional_interactors = $self->interaction_type->Non_directional->col;	
    	}; 
    	return @non_directional_interactors;   
    }
);



########


### I added methods cause I needed them -AC ###
sub name {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The name of the interaction',
         data        => $self->_pack_obj($object),
    };
    return $data;
}

sub interactor {
    my $self = shift;
    my $object = $self->object;
    my @genes = $object->Interactor;
    @genes = map{$self->_pack_obj($_, $_->Public_name)} @genes;
    my $data = { description => 'The genes in this interaction',
         data        =>  \@genes, 
    };
    return $data;
}

sub remark {
    my $self = shift;
    my $object = $self->object;
    my $data = { description => 'The remark on this interaction',
         data        => $object->Remark,
    };
    return $data;
}

sub interaction_type {
    my $self = shift;
    my $object = $self->object;
    my $type = $object->Interaction_type;

    my %interaction_info;
    $interaction_info{'effector'} = $self->_pack_obj($type->Effector) if $type->Effector;
    $interaction_info{'effected'} = $self->_pack_obj($type->Effected) if $type->Effected;
    if ($type->Non_directional){
      my @genes = map{$self->_pack_obj($_)} $type->Non_directional;
      $interaction_info{'non_directional'} = \@genes;
    }

    my $data = { description => 'The remark on this interaction',
                 data        => { type  =>  "$type",
                                  interaction_info  =>  \%interaction_info,
                                },
    };
    return $data;
}
### END METHODS ADDED BY AC ###




sub description {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';

	my %data_pack;

	#### data pull and packaging
	
	my $it = $self->interaction_type;  ##$object->Interaction_type
	$data_pack{'type'} = $it;
	$data_pack{'rnai'} = $it->RNAi;
	
	#$data_pack{'phenotype'} = $it->Interaction_phenotype;
	
	my @non_directional_interactors;
	eval {
		@non_directional_interactors = $self->non_directional_interactors;
	};
	
	if ( @non_directional_interactors ) {
		$data_pack{'nd1'} = shift @non_directional_interactors; 
		$data_pack{'nd2'} = shift @non_directional_interactors;
	}
	
	else {
		$data_pack{'effector'} = $self->effector;
		$data_pack{'effected'} = $self->effected;
	}
	
	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}



sub interactor_details {

	my $self = shift;
    my $object = shift;
	my %data;
	my $desc = 'notes ;
				data structure = data{"data"} = {
				}';

	my %data_pack;

	#### data pull and packaging

	my	$gene_name = $object->CGC_name;
	
	$data_pack{'gene_name'} = $gene_name;
	
	my 	@interactions = $object->Interaction;
	$data_pack{'interactions'} = $self->basic_package(\@interactions);

	eval {
	
		$data_pack{'phenotype'} = $object->Phenotype;
	};
		
	my @go_terms = $object->GO_term;

	$data_pack{'go_terms'} = $self->basic_package(\@go_terms);
	my @cds = $object->Corresponding_CDS;
  	my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds if (@cds);
	$data_pack{'proteins'} = $self->basic_package(\@proteins);

	####

	$data{'data'} = \%data_pack;
	$data{'description'} = $desc;
	return \%data;
}




#####

#####


sub interactor_template {

	my $self = shift;
	my $gene_aceo = shift;
	my $gene_name = $gene_aceo->name;
    my $wormbase = WormBase::API->new({conf_dir => "./conf"});
    my $gene = $wormbase->fetch({class=>'Gene',name=>$gene_name});
    
	#	my $return = $gene->METHOD();
	#	return $return;
	
	### OR ###
	
	#	my %data;
	#	my $desc = 'notes';
	#	my %data_pack;
	
		#### data pull and packaging
	
		#### data pull
	
	#	$data{'data'} = \%data_pack;
	#	$data{'description'} = $desc;
	#	return \%data;
}


sub interactor_ids {

	my $self = shift;
	my $gene_aceo = shift;
	my $gene_name = $gene_aceo->name;
    my $wormbase = WormBase::API->new({conf_dir => "./conf"});
    my $gene = $wormbase->fetch({class=>'Gene',name=>$gene_name}); 
	my $return = $gene->ids();
	return $return;
	
}


sub interactor_info {


	my $self = shift;
	my $gene_aceo = shift;
	my $method = shift;
	my $gene_name = $gene_aceo->name;
    my $wormbase = WormBase::API->new({conf_dir => "./conf"});
    my $gene = $wormbase->fetch({class=>'Gene',name=>$gene_name}); 
	my $return = $gene->$method();
	return $return;


}


#####



sub interactor_go_terms {

	my $self = shift;
	my $gene_aceo = shift;
	my $gene_name = $gene_aceo->name;
    my $wormbase = WormBase::API->new({conf_dir => "./conf"});
    my $gene = $wormbase->fetch({class=>'Gene',name=>$gene_name}); 
	my $return = $gene->gene_ontology();
	
	return $return;

}


### for Object.pm

sub basic_package {

	my ($self,$data_ar) = @_;
	my %package;
	
	foreach my $object (@$data_ar) {
				
				
				my $class;
				eval{$class = $object->class;};

				my $common_name = $object;  ## public_name(,$class)
				$package{$object} = {
										'class' => $class,
										'common_name' => $common_name
										}	
	}

	return \%package;
}


1;
