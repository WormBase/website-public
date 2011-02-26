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

=head2 interactor

<headvar>This method will return a data structure re: set of interactors for this interaction.

=head3 PERL API

 $data = $model->interactor();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interactor

=head4 Response example

<div class="response-example"></div>

=cut

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

=head2 interaction_type

This method will return a data structure re: interaction_type of this interaction.

=head3 PERL API

 $data = $model->interaction_type();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/<headvar>

=head4 Response example

<div class="response-example"></div>

=cut

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

=head2 paper

<headvar>This method will return a data structure re: papers describing this interaction.

=head3 PERL API

 $data = $model->paper();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/paper

=head4 Response example

<div class="response-example"></div>

=cut

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


=head2 phenotype

This method will return a data structure re: phenotype associated with this interaction.

=head3 PERL API

 $data = $model-><headvar>();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/<headvar>

=head4 Response example

<div class="response-example"></div>

=cut

sub phenotype {
	
	my $self = shift;
    my $object = $self->object;

	### data pull ####
	
	my $it = $object->Interaction_type;                                                         
	my $phenotype = $it->Internation_phenotype->right if $it->Internation_phenotype;  
	my $phenotype_name = $phenotype->Primary_name if $phenotype;      

	my $data_pack = {
		'id' =>"$phenotype",
		'label' =>"$phenotype_name",
		'Class' => 'Phenotype'
	};

	my $data = {
		'data'=> $data_pack,
		'description' => 'description of the phenotype associated with this interaction'
		};
	return $data;
}

=head2 rnai

This method will return a data structure re: rnais related to this interaction.

=head3 PERL API

 $data = $model->rnai();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/rnai

=head4 Response example

<div class="response-example"></div>

=cut

sub rnai {
	my $self = shift;
    my $object = $self->object;
	my $it = $object->Interaction_type;
	my $rnai = $it->Interaction_RNAi->right if $it->Interaction_RNAi;
	
	my $data_pack = $self->_pack_obj($rnai);
	my $data = {
				'data'=> $data_pack,
				'description' => 'description of the rnai involved with this interaction'
				};
	return $data;
}

######################
### Interactors
######################

=head2 interactor_data

This method will return a data structure re: interactor_data for this interaction.

=head3 PERL API

 $data = $model->interactor_data();

=head3 REST API

=head4 Request Method

GET

=head4 Requires Authentication

No

=head4 Parameters

a Interaction ID WBInteraction0000779

=head4 Returns

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

=head4 Request example

curl -H content-type:application/json http://api.wormbase.org/rest/field/interaction/WBInteraction0000779/interactor_data

=head4 Response example

<div class="response-example"></div>

=cut

sub interactor_data {
	my $self = shift;
	my $interactor_type; ## efffector, effected, non_directional
   	my $object = $self->object;
	my %data;
	my $desc = 'notes';
	my @data_pack;
	my $interactor_ar;
		
	if ($interactor_type =~ /effector/) {
		$interactor_ar = $self->effector;
	} elsif ($interactor_type =~ /effected/) {
		$interactor_ar = $self->effected;
	} else {
		$interactor_ar = $self->non_directional_interactors;
	}

	foreach my $interactor (@$interactor_ar) {
		my @cds = $interactor->Corresponding_CDS;
  		my @proteins  = map {$interactor->Corresponding_protein(-fill=>1)} @cds if (@cds);
  		my @interactions = $interactor->Interaction;
  		my $gene_data = _pack_obj($interactor);
  		my @protein_data_set;
  		my $interaction_count = @interactions;
  	
  		foreach my $protein (@proteins) {		
  			my $protein_data = _pack_obj($protein);
  			push @protein_data_set, $protein_data
  		}
  	
		my $interactor_data => {
				'gene' => $gene_data,
				'protein' => \@protein_data_set,
				'inteactions' => "$interaction_count"	
		};
	 	
		push @data_pack, $interactor_data;
	}
	my $data = {
		'data'=> \@data_pack,
		'description' => 'interactor data for this interaction broken down by type'
	};
	return $data;
}

1;
