package WormBase::API::Role::Interaction;

use Moose::Role;
use Data::Dumper;

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
	my $data;
    return $self->_get_interactions($data, 0);
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

An object ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[class]/[object]/interactions

B<Response example>

=cut

sub interactions  {
    my $self   = shift;
    my $results = $self->_interactions;
	my $show_nearby = $results->{showall};
	$results = $self->_get_interactions($results, 1) if $show_nearby;

    @{$results->{edges}} = (values %{$results->{edgeVals}});
    return {
        description => 'genetic and predicted interactions',
        data        => $results,
    };
}

=head3 interaction_details

This method takes the interaction network built on first load and
searches for additional interactions for the same set of nodes.
Returns a data structure in the same format as the one taken in.

=over

=item PERL API

 $data = $model->interaction_details();

=item REST API

B<Request Method>

GET

B<Requires Authentication>

No

B<Parameters>

An object ID (WBGene00006763)

B<Returns>

=over 4

=item *

200 OK and JSON, HTML, or XML

=item *

404 Not Found

=back

B<Request example>

curl -H content-type:application/json http://api.wormbase.org/rest/field/[class]/[object]/interaction_details

B<Response example>

=cut

sub interaction_details {
    my $self = shift;
    my $results = $self->_interactions;
    $results = $self->_get_interactions($results, 1);

    @{$results->{edges}} = (values %{$results->{edgesVals}});
	warn("Results:\n", Dumper($results));
    return {
		description	=> 'addtional nearby interactions',
		data		=> $results,
    };
}

############################################################
#
# Private Methods
#
############################################################

sub _get_interactions {
    my ($self, $data, $nearby) = @_;
	my $object = $self->object;
	my @objects;
	if ($data->{nodes_obj}){ @objects = map {$_->Interaction} grep {$_->class =~ /gene/i} values %{$data->{nodes_obj}} }
	elsif ($object->class =~ /gene/i) { @objects = $object->Interaction }
	elsif ($object->class =~ /interaction/i ) { @objects = ($object) }
	warn("size: ", scalar @objects);
	foreach my $interaction ( @objects ) {
	    next if($data->{ids}{"$interaction"});
		if ($nearby) { next if scalar grep {!defined $data->{nodes_obj}->{$_}} map {$_->col} $interaction->Interactor; }		
		my $edgeList = $self->_get_interaction_info($interaction);
		foreach my $key (keys %{$edgeList}) {
			my ($type, $effector, $effected, $direction, $phenotype)= @{$edgeList->{$key}};
			warn("effector: $effector, effected: $effected");
			next unless($effector);
			$data->{nodes}{"$effector"} ||= $self->_pack_obj($effector, eval {$effector->Public_name} || undef);
			$data->{nodes}{"$effected"} ||= $self->_pack_obj($effected, eval {$effected->Public_name} || undef);
			$data->{nodes_obj}{"$effector"} = $effector;
			$data->{nodes_obj}{"$effected"} = $effected;
			$data->{ids}{"$interaction"}=1;
			$data->{types}{"$type"}=1;
			
			my $phenObj = $self->_pack_obj($phenotype);
			my $key = "$effector $effected $type";

			if ($phenotype) {
				$data->{phenotypes}{"$phenotype"} ||= $phenObj;
				$key .= " $phenotype" if $phenotype;
			}
			
			my $packInteraction = $self->_pack_obj($interaction);
			my @papers = map { $self->_pack_obj($_) } $interaction->Paper;
			
			if (exists $data->{edgeVals}{$key}){
				push @{$data->{edgeVals}{$key}{interactions}}, $packInteraction;
				push @{$data->{edgeVals}{$key}{citations}}, @papers;
			} else {
				my @interacArr = ($packInteraction);
				$data->{edgeVals}{$key} = {
					interactions=> @interacArr ? \@interacArr : undef,
					citations	=> @papers ? \@papers : undef,
					type		=> "$type",
					effector	=> $data->{nodes}{"$effector"},
					effected	=> $data->{nodes}{"$effected"},
					direction	=> $direction,
					phenotype	=> $phenObj,
					nearby		=> $nearby,
				};
			}
		}
	}
	$data->{showall} = scalar keys %{$data->{edgeVals}} < 100;
    return $data;
}

sub _get_interaction_info {
    my ($self, $interaction) = @_;
	my $type = $interaction->Interaction_type;
	$type = $type->right ? $type->right . '' : "$type";
	$type =~ s/_/ /g;
	if ($type eq 'Regulatory') {
		my $reg_result = $interaction->Regulation_result;
		if ("$reg_result" =~ /^(.*tive)_regulate$/) { $type = $1 . "ly Regulates" }
		elsif ("$reg_result" eq 'Does_not_regulate') { $type = "Does Not Regulate" }
	}
    # Filter low confidence predicted interactions.
	# what happens when no data?
	return undef if ($interaction->Log_likelihood_score || 1000) <= 1.5 && $type =~ m/predicted/i;
 
	my $phenotype = $interaction->Interaction_phenotype;
	my ( @effectors, @effected, @others, $direction );

	foreach my $intertype ($interaction->Interactor) {
		my $count = 0;
		foreach my $interactor ($intertype->col) {
			my @tags = eval { $intertype->right->down($count++)->col };
			if ( @tags ) {
				foreach my $tag (@tags) {
					if ($tag eq 'Interactor_type') {
						my $val = $tag->at;
						if ($val =~ /Effector|.*regulator/) { push @effectors, $interactor }
						elsif ($val =~ /Effected|.*regulated/)  { push @effected, $interactor }
						else { push @others, $interactor }
					}
				}
			} else { push @others, $interactor }
		}
    }
	
	my %results;
	if (@effectors || @effected) {
		foreach my $obj (@effectors, @others) {
			foreach my $obj2 (@effected) {
				next if $obj == $obj2;
				@{$results{"$obj $obj2"}} = ($type, $obj, $obj2, 'Effector->Effected', $phenotype);
			}
		}
	} else {
		foreach my $obj (@others) {
			foreach my $obj2 (@others) {
				next if $obj == $obj2;
				my @objs = ("$obj", "$obj2");
				my $str = join(' ', sort @objs); 
				@{$results{"$str"}} = ($type, $obj, $obj2, 'non-directional', $phenotype);
			}
		}
	}
    return \%results;
}

1;