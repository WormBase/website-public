package WormBase::API::Object::Interaction;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



has 'effector' => (    
    is       => 'ro',
    lazy    => 1,
    default => sub {
    	
    	my $self = shift;
    	my @effectors;
    	eval { @effectors = $self->interaction_type->Effector->col;};
    	return \@effectors;
  	}
);

has 'effected' => (
	is  => 'ro',
    lazy => 1,
    default => sub {
   
    	my $self = shift;
    	my @effecteds;
    	eval{@effecteds = $self->interaction_type->Effected->col;};
    	return \@effecteds;   
    }
);

has 'non_directional_interactors' => (
	is  => 'ro',
    lazy => 1,
    default => sub {
    
    	my $self = shift;
    	my @non_directional_interactors; 
    	eval {
    	
    		@non_directional_interactors = $self->interaction_type->Non_directional->col;	
    	}; 
    	return \@non_directional_interactors;   
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

sub paper {
    my $self = shift;
    my $object = $self->object;

    my $data = { description => 'The paper for this interactions',
                 data        => $self->_pack_obj($object->Paper, $object->Paper->Brief_citation),
    };
    return $data;
}

######################
## more summary items
######################

sub phenotype {
                                                                # No space
	my $self = shift;
    my $object = $self->object;                                 # Weird indentation?
	my %data;                                               # Why defined here?
	my $desc = 'notes';                                     # Why defined here?
	my $data_pack;                                          # Why defined here?

	#### data pull and packaging                            # Obvious. Omit.
	 
    my $it = $object->Interaction_type;                         # Weird indentation
	
	my $phenotype;                                          # Why?
	my $phenotype_name;                                     # Why?
	my $phenotype = $it->Internation_phenotype->right if $it->Internation_phenotype;
	eval{$phenotype = $it->Interaction_phenotype->right;};  # Why is this an eval?
	eval{$phenotype_name = $phenotype->Primary_name;};      # Why is this an eval?


	$data_pack = {
	                                                # TH. No space!
		'id' => "$phenotype",                   
		'label' => "$phenotype_name",           # TH. Not needed!
		'Class' => 'Phenotype'
	};

	####                                            # TH. No!

	$data{'data'} = $data_pack;                     # TH. No! Why do this?	
	$data{'description'} = $desc;                   # TH. No! Why do this?
	return \%data;
                                                        # Do this instead
                                                  	my $data = { data => 'my data',
                                              		             description => 'my description' };
	
}

sub rnai {

	my $self = shift;
    my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my $data_pack;

	#### data pull and packaging

    my $it = $object->Interaction_type;
	my $rnai;

	eval{$rnai = $it->Interaction_RNAi->right;}; ## $it_data->{'Interaction_RNAi'}
	

	$data_pack = {
	
		'id' =>"$rnai",
		'label' =>"$rnai",
		'Class' => 'RNAi'
	};
	
	####
	
	$data{'data'} = $data_pack;
	$data{'description'} = $desc;
	return \%data;

}


######################
### Interactors
######################

sub interactor_data {

	my $self = shift;
	my $interactor_type; ## efffector, effected, non_directional
   	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;

	#### data pull and packaging

	my $interactor_ar;
	
	if ($interactor_type =~ /effector/) {
	
		$interactor_ar = $self->effector;
	}
	
	elsif ($interactor_type =~ /effected/) {
	
		$interactor_ar = $self->effected;
	}
	
	else {
	
		$interactor_ar = $self->non_directional_interactors;
	}

	foreach my $interactor (@$interactor_ar) {
	

		my @cds = $gene_obj->Corresponding_CDS;
  		my @proteins  = map {$_->Corresponding_protein(-fill=>1)} @cds if (@cds);
  		my @interactions = $gene_obj->Interaction;
  		
  		my $gene_data = _pack_obj($interactor);
  		my @protein_data_set;
  		my $interaction_count = @interactions;
  		
  		
  		foreach my $protein (@proteins) {
  			
  			my $protein_data = _pack_obj($protein);
  			push @protein_data_set, $protein_data
  		}
  	
  		
		$interactor_data => {
				
				'gene' => $gene_data,
				'protein' => \@protein_data_set,
				'inteactions' => "$interaction_count"	
		}
		
		push @data_pack, $interactor_data;
	}

	####
	
	$data{'data'} = \@data_pack;
	$data{'description'} = $desc;
	return \%data;
}

1;
