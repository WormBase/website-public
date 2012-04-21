package WormBase::API::Role::Interaction;

use Moose::Role;

#######################################################
#
# Attributes
#
#######################################################

has '_interactions' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build__interactions',
);

sub _build__interactions {
    my $self = shift;
    my $object = $self->object;
	my @interactions;
	if ($object->class =~ /gene/i) { @interactions = $object->Interaction }
	elsif ($object->class =~ /interaction/i) { @interactions = ($object) }
    my ($nodes,$edges,$phenotypes,$types,$nodes_obj); #save packed objects improves the speed
    my %data;
    my $show_local = 0;
    # find interacted genes with this $object
    foreach my $interaction ( @interactions ) {

	my ($type, $effector, $effected, $direction, $phenotype)= _get_interation_info($interaction);
	next unless($effector);

	$nodes->{"$effector"}= $self->_pack_obj($effector);
	$nodes->{"$effected"}= $self->_pack_obj($effected);
	$nodes_obj->{"$effector"}=$effector;
	$nodes_obj->{"$effected"}=$effected;

	$edges->{"$interaction"}=1;  
	$types->{"$type"}=1;
	if($phenotype) {
	      $phenotypes->{"$phenotype"}= $self->_pack_obj($phenotype) unless(exists $phenotypes->{"$phenotype"});
	      $phenotype= $phenotypes->{"$phenotype"};
	}
	my $phenString = $phenotype ? $phenotype : "";
	my $key = join(' ', "$effector", "$effected", "$type", $direction, $phenString);
	my $altkey = join(' ', "$effected", "$effector", "$type", $direction, $phenString);

	my $packInteraction = $self->_pack_obj($interaction);
	my @papers = map { $self->_pack_obj($_) } $interaction->Paper;
	if (exists $data{$key}){
		push @{$data{$key}{interactions}}, $packInteraction;
		push @{$data{$key}{citations}}, @papers;
	} elsif($direction ne 'Effector->Effected' && exists $data{$altkey}){
		push @{$data{$altkey}{interactions}}, $packInteraction;
		push @{$data{$altkey}{citations}}, @papers;
	} else {
	    my @interacArr = ($packInteraction);
	    $data{$key} = {
		interactions=> @interacArr ? \@interacArr : undef,
		citations   => @papers ? \@papers : undef,
		type        => "$type",
		effector    => $nodes->{"$effector"},
		effected    => $nodes->{"$effected"},
		direction   => $direction,
		phenotype   => $phenotype,
		nearby	    => 0,
	    };
	}
    }

    if(scalar keys %data < 100){
	$show_local = 1;
    }

    my @results = (\%data,$nodes,$edges,$phenotypes,$types,$nodes_obj);
    my %result = (
	showall => $show_local,
	results => \@results,
    );
    return \%result;
}

#######################################
#
# The Interactions Widget
#   template: classes/gene/interactions.tt2
#
#######################################

=head2 Interactions

=cut

=head3 interactions

This method returns a data structure containing the 
a data table of gene and protein interactions. Ask us
to increase the granularity of this method!

=over

=item PERL API

 $data = $model->interactions();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

A gene ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/gene/WBGene000066763/interactions

B<Response example>

=cut

sub interactions  {
    my $self   = shift;
    my ($data,$nodes,$edges,$phenotypes,$types,$nodes_obj) = @{$self->_interactions->{results}};
    if($self->_interactions->{showall}){
	$self->nearby_interactions($data, 1);
    }
    my @dataRet = (values %{$data});
    return {
        description => 'genetic and predicted interactions',
        data        => {edges=>\@dataRet,nodes=>$nodes,types=>$types,showall=>$self->_interactions->{showall}},
    };
}

sub nearby_interactions {
    #this method loads nearby interactions (i.e. interactions between nodes that interact with the current gene)
    my ($self, $data, $show_local) = @_;
    my ($old_data,$nodes,$edges,$phenotypes,$types,$nodes_obj) = @{$self->_interactions->{results}};
    #find the interactions between all other genes
    for my $key (sort keys %$nodes){
	my $node = $nodes_obj->{$key};
	foreach my $interaction ( $node->Interaction ) {
	    next if(exists $edges->{"$interaction"});
	    my $flag=0;
	    foreach ($interaction->Interactor){
	      next if($_ eq $node);
	      unless ( exists $nodes->{$_}) { $flag=0; last;}
	      $flag=1; 
	    }
	    next unless($flag == 1);
	
	    my ($type, $effector, $effected, $direction, $phenotype)= _get_interation_info($interaction);
	    next unless($effector);

	    $edges->{"$interaction"}=1;
	    $types->{"$type"}=1;
	    if( $phenotype) {
	      $phenotypes->{"$phenotype"}= $self->_pack_obj($phenotype) unless(exists $phenotypes->{"$phenotype"});
	      $phenotype= $phenotypes->{"$phenotype"};
	    }

	    my $phenString = $phenotype ? $phenotype : "";
	    my $key = join(' ', "$effector", "$effected", "$type", $direction, "$phenString");
	    my $altkey = join(' ', "$effected", "$effector", "$type", $direction, "$phenString");

	    my $packInteraction = $self->_pack_obj($interaction);
	    my @papers = map { $self->_pack_obj($_) } $interaction->Paper;
	    if (exists $data->{$key}){
		my $interacArr = $data->{$key}{interactions};
		push @$interacArr, $packInteraction;
		if($show_local){
		    my $paperArr = $data->{$key}{citations};
		    push @$paperArr, @papers;
		}
	    } elsif($direction ne 'Effector->Effected' && exists $data->{$altkey}){
		my $interacArr = $data->{$altkey}{interactions};
		push @$interacArr, $packInteraction;
		if($show_local){
		    my $paperArr = $data->{$altkey}{citations};
		    push @$paperArr, @papers;
		}
	    } else {
		my @interacArr;
		push @interacArr, $packInteraction;
		$data->{$key} = {
		    interactions=> @interacArr ? \@interacArr : undef,
		    citations	=> @papers && $show_local ? \@papers : undef,
		    type        => "$type",
		    effector    => $nodes->{"$effector"},
		    effected    => $nodes->{"$effected"},
		    direction   => $direction,
		    phenotype   => $phenotype,
		    nearby	=> 1,
		};
	    }
	 }
    }
}

sub interaction_details {
    my $self = shift;
    my ($data,$nodes,$edges,$phenotypes,$types,$nodes_obj) = @{$self->_interactions->{results}};

    $self->nearby_interactions($data, 0);

    my @edges = (values %{$data});
    return {
	description	=> 'addtional nearby interactions',
	data		=> {edges=>\@edges, nodes => $nodes, types => $types},
    };
}

############################################################
#
# Private Methods
#
############################################################

sub _get_interation_info {
    my ($interaction) = @_;
    # Filter low confidence predicted interactions.
	my $type = $interaction->Interaction_type;
	return undef
	    if ($interaction->Log_likelihood_score || 1000) <= 1.5
                && $type =~ m/predicted/i; # what happens when no data?

	 
	my $phenotype = eval {$type->Interaction_phenotype->right};

        my ( $effector, $effected, $direction );

        my @non_directional = eval { $type->Non_directional->col };
        if (@non_directional) {
            ( $effector, $effected ) = @non_directional;    # WBGenes
            $direction = 'non-directional';
        }
        else {
            $effector  = eval{$type->Effector->right} if $type->Effector;
            $effected  = eval{$type->Effected->right};
	    return undef unless(defined $effector && defined $effected);
            $direction = 'Effector->Effected';
        }    

    return ($type, $effector, $effected, $direction, $phenotype);
}

1;
