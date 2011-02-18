package WormBase::API::Object::Interaction;
use Moose;

with 'WormBase::API::Role::Object';
extends 'WormBase::API::Object';



has 'effector' => (    
	is  => 'ro',
    lazy => 1,
    default => sub {
    	
    	my $self = shift;
    	my @effectors;
    	eval {@effectors = $self->interaction_type->Effector->col;};
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

#
# sub phenotype
# sub rnai
#

	######################
### Interactors
######################

# sub interactors



1;
