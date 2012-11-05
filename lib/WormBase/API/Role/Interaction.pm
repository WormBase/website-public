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
    my @edges = values %{$self->_interactions->{edgeVals}};

    my $results = $self->_get_interactions($self->_interactions, 1, 1);
    my @edges_all = values %{$results->{edgeVals}};

    return {
        description => 'genetic and predicted interactions',
        data        => $results->{showall} ? {    
                            edges => \@edges,
                            types => $results->{types},
                            ntypes => $results->{ntypes},
                            nodes => $results->{nodes},
                            showall => $results->{showall},
                            edges_all => \@edges_all
                       } : { edges => \@edges },
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
    my $results = $self->_get_interactions($self->_interactions, 1);

    my @edges = values %{$results->{edgeVals}};

    return {
		description	=> 'addtional nearby interactions',
		data		=> {    edges => \@edges,
                            types => $results->{types},
                            ntypes => $results->{ntypes},
                            nodes => $results->{nodes},
                            showall => $results->{showall},
                       },
    };
}

############################################################
#
# Private Methods
#
############################################################

sub _get_interactions {
    my ($self, $data, $nearby, $from_table) = @_;
    my $object = $self->object;
    my @objects;

    #determine object type and extract interactions accordingly
    if ($nearby){ 
      @objects = map {$_->Interaction} grep {$_->class =~ /gene/i} values %{$data->{nodes_obj}} 
    } elsif ($object->class =~ /gene/i) { 
      @objects = $object->Interaction 
    } elsif ($object->class =~ /interaction/i ) { 
      @objects = ($object) 
    }
# $self->log->debug('INTERACTIONS: ' . join(',', @objects));
    if($nearby && $from_table && (scalar @objects > 3000)){
        $data->{showall} = 0;
        return $data;
    } 

    $self->log->debug("nearby: $nearby, size: ", scalar @objects);
    foreach my $interaction ( @objects ) {
      next if($data->{ids}{"$interaction"});
      if ($nearby) { next if scalar grep {!defined $data->{nodes_obj}->{$_}} map {$_->col} $interaction->Interactor; }
#      $self->log->debug("made it");
     my $edgeList = $self->_get_interaction_info($interaction, $nearby);
#      $self->log->debug("made it a");
      foreach my $key (keys %{$edgeList}) {
#      $self->log->debug("edges");
          my ($type, $effector, $effected, $direction, $phenotype)= @{$edgeList->{$key}};
#           $self->log->debug("     effector: $effector, effected: $effected");
          next unless($effector);
#      $self->log->debug("made it b");
          my $effector_name = $effector->class =~ /gene/i ? $effector->Public_name : "$effector";
          my $effected_name = $effected->class =~ /gene/i ? $effected->Public_name : "$effected";
          $effector_name .= ' (' . $effector->class . ')' if "$effector_name" eq "$effected_name";
          $data->{nodes}{"$effector"} ||= $self->_pack_obj($effector, "$effector_name" || undef);
          $data->{nodes}{"$effected"} ||= $self->_pack_obj($effected, "$effected_name" || undef);
          $data->{nodes_obj}{"$effector"} = $effector;
          $data->{nodes_obj}{"$effected"} = $effected;
          $data->{ids}{"$interaction"}=1;
          $data->{types}{"$type"}=1;
          my $ntype1 = $data->{nodes}{"$effector"}->{class};
          my $ntype2 = $data->{nodes}{"$effected"}->{class};
          $data->{ntypes}{"$ntype1"}=1;
          $data->{ntypes}{"$ntype2"}=1;
          
          my $phenObj = $self->_pack_obj($phenotype);
          my $key = "$effector $effected $type";
          my $key2 = "$effected $effector $type";

          if ($phenotype) {
            $data->{phenotypes}{"$phenotype"} ||= $phenObj;
            $key .= " $phenotype" if $phenotype;
            $key2 .= " $phenotype" if $phenotype;
          }
          
          my $packInteraction = $self->_pack_obj($interaction);
          my @papers = map { $self->_pack_obj($_) } $interaction->Paper;
          
          if (exists $data->{edgeVals}{$key}){
            push @{$data->{edgeVals}{$key}{interactions}}, $packInteraction;
            push @{$data->{edgeVals}{$key}{citations}}, @papers;
          } elsif (exists $data->{edgeVals}{$key2}){
            push @{$data->{edgeVals}{$key2}{interactions}}, $packInteraction;
            push @{$data->{edgeVals}{$key2}{citations}}, @papers;
          } else {
            my @interacArr = ($packInteraction);
# $self->log->debug("KEY: $key");
            $data->{edgeVals}{$key} = {
                interactions=> @interacArr ? \@interacArr : undef,
                citations	=> @papers ? \@papers : undef,
                type	=> "$type",
                effector	=> $data->{nodes}{"$effector"},
                effected	=> $data->{nodes}{"$effected"},
                direction	=> $direction,
                phenotype	=> $phenObj,
                nearby	=> $nearby,
            };
          }
      }
    }
    $data->{showall} = scalar keys %{$data->{edgeVals}} < 100 || $nearby;
    return $data;
}

sub _get_interaction_info {
    my ($self, $interaction, $nearby) = @_;
    my %results;
    return \%results if $self->_ignored_interactions($interaction);
    my $object = $self->object;
    my $type = $interaction->Interaction_type;
    $type = $type->right ? $type->right . '' : "$type";
    $type =~ s/_/ /g;
    if ($type eq 'Regulatory') {
	if ( my $reg_result = $interaction->Regulation_result ) {
	    if ("$reg_result" =~ /^(.*tive)_regulate$/) { $type = $1 . "ly Regulates" }
	    elsif ("$reg_result" eq 'Does_not_regulate') { $type = "Does Not Regulate" }
	}
    }
    # Filter low confidence predicted interactions.
    # what happens when no data?
    return undef if ($interaction->Log_likelihood_score || 1000) <= 1.5 && $object->class ne 'Interaction' && $type =~ m/predicted/i;

    my $phenotype = $interaction->Interaction_phenotype;
    my ( @effectors, @effected, @others );
    my %elements;
    foreach my $intertype ($interaction->Interactor) {
      my $count = 0;
      foreach my $interactor ($intertype->col) {
          my @interactors = $intertype->col;
          my @tags = eval { $interactors[$count++]->col };

          my %info;
          $info{obj} = $interactor;
          if ( @tags ) {
            map { $info{"$_"} = $_->at; } @tags;
            if ("$intertype" eq 'Interactor_overlapping_gene') {
                my $role = $info{Interactor_type};
                if ($role && $role =~ /Effector|.*regulator/) {   $self->log->debug("\t\teffector/regulator" );push @effectors, $interactor }
                elsif ($role && $role =~ /Effected|.*regulated/)  { $self->log->debug("\t\teffected/regulated" );push @effected, $interactor }
                else { push @others, $interactor }
            } else {
                my $corresponding_gene = $self->_get_gene($interactor, "$intertype");
                if ($corresponding_gene) { @{$results{"$interactor $corresponding_gene"}} = ('Associated Product', $interactor, $corresponding_gene, 'Other') } 
                else { push @others, $interactor }
            }
          } else { push @others, $interactor }
      }
    }
    if (@effectors || @effected) {
      foreach my $obj (@effectors, @others) {
          foreach my $obj2 (@effected) {
            next if "$obj" eq "$obj2";
            if (!$nearby && $object->class ne 'Interaction') { 
              next unless ("$obj" eq "$object" || "$obj2" eq "$object")
            };
            @{$results{"$obj $obj2"}} = ($type, $obj, $obj2, 'Effector->Effected', $phenotype);
          }
      }
    } else {
      foreach my $obj (@others) {
          foreach my $obj2 (@others) {
            next if "$obj" eq "$obj2";
            if (!$nearby && $object->class ne 'Interaction') { 
              next unless ("$obj" eq "$object" || "$obj2" eq "$object")
            };
            my @objs = ("$obj", "$obj2");
            my $str = join(' ', sort @objs); 
            @{$results{"$str"}} = ($type, $obj, $obj2, 'non-directional', $phenotype);
          }
      }
    }

    return \%results;
}

sub _get_gene {
    my ($self, $obj, $type) = @_;
    if ($type eq 'Interactor_overlapping_CDS') { return $obj->Gene }
    elsif ($type eq 'Interactor_overlapping_protein') { return $obj->Corresponding_CDS->Gene if $obj->Corresponding_CDS }
    elsif ($type eq 'PCR_interactor') {
	my $corr_gene = $obj->Overlaps_CDS->Gene if $obj->Overlaps_CDS;
	$corr_gene ||= $obj->Overlaps_transcript->Gene if $obj->Overlaps_transcript;
	$corr_gene ||= $obj->Overlaps_pseudogene->Gene if $obj->Overlaps_pseudogene;
	return $corr_gene;
    } elsif ($type eq 'Sequence_interactor') {
	my $corr_gene = $obj->Matching_CDS->Gene if $obj->Matching_CDS;
	$corr_gene ||= $obj->Matching_transcript->Gene if $obj->Matching_transcript;
	$corr_gene ||= $obj->Matching_pseudogene->Gene if $obj->Matching_pseudogene;
	return $corr_gene;
    }
}

sub _ignored_interactions {
    my ($self, $interaction) = @_;
    # These are interactions in the WS231 model that were requested to be ignored by Chris Grove.
    # They should be updated/corrected/removed in the next database release so this can be removed then.
    my %bad_interactions = (
    WBInteraction000505886 => 1, WBInteraction000505887 => 1, WBInteraction000505888 => 1, WBInteraction000505889 => 1,
    WBInteraction000505890 => 1, WBInteraction000505891 => 1, WBInteraction000505892 => 1, WBInteraction000505893 => 1,
    WBInteraction000505894 => 1, WBInteraction000505895 => 1, WBInteraction000505896 => 1, WBInteraction000505897 => 1,
    WBInteraction000505898 => 1, WBInteraction000505899 => 1, WBInteraction000505900 => 1, WBInteraction000505901 => 1,
    WBInteraction000505902 => 1, WBInteraction000505903 => 1, WBInteraction000511628 => 1, WBInteraction000511629 => 1,
    WBInteraction000511630 => 1, WBInteraction000511631 => 1, WBInteraction000511632 => 1, WBInteraction000511633 => 1,
    WBInteraction000511634 => 1, WBInteraction000511635 => 1, WBInteraction000511636 => 1, WBInteraction000511637 => 1,
    WBInteraction000511638 => 1, WBInteraction000511639 => 1, WBInteraction000511640 => 1, WBInteraction000511641 => 1,
    WBInteraction000511642 => 1, WBInteraction000511643 => 1, WBInteraction000511644 => 1, WBInteraction000511645 => 1,
    WBInteraction000511646 => 1, WBInteraction000511647 => 1, WBInteraction000511648 => 1, WBInteraction000511649 => 1,
    WBInteraction000511650 => 1, WBInteraction000511651 => 1, WBInteraction000511652 => 1, WBInteraction000511653 => 1,
    WBInteraction000511654 => 1, WBInteraction000511655 => 1, WBInteraction000511656 => 1, WBInteraction000511657 => 1,
    WBInteraction000511658 => 1, WBInteraction000511659 => 1, WBInteraction000511660 => 1, WBInteraction000511661 => 1,
    WBInteraction000511662 => 1, WBInteraction000511663 => 1, WBInteraction000511664 => 1, WBInteraction000511665 => 1,
    WBInteraction000511666 => 1, WBInteraction000511667 => 1, WBInteraction000511668 => 1, WBInteraction000511669 => 1,
    WBInteraction000511670 => 1, WBInteraction000511671 => 1, WBInteraction000511672 => 1, WBInteraction000511673 => 1,
    WBInteraction000511674 => 1, WBInteraction000511675 => 1, WBInteraction000511676 => 1, WBInteraction000511677 => 1,
    WBInteraction000511678 => 1, WBInteraction000511679 => 1, WBInteraction000511680 => 1, WBInteraction000511681 => 1,
    WBInteraction000511682 => 1, WBInteraction000511683 => 1, WBInteraction000511684 => 1, WBInteraction000511685 => 1,
    WBInteraction000511686 => 1, WBInteraction000511687 => 1, WBInteraction000511688 => 1, WBInteraction000511689 => 1,
    WBInteraction000511690 => 1, WBInteraction000511691 => 1, WBInteraction000511692 => 1, WBInteraction000511693 => 1,
    WBInteraction000511694 => 1, WBInteraction000511695 => 1, WBInteraction000511696 => 1, WBInteraction000511697 => 1,
    WBInteraction000511698 => 1, WBInteraction000511719 => 1, WBInteraction000511720 => 1, WBInteraction000512922 => 1,
    WBInteraction000512926 => 1, WBInteraction000512927 => 1, WBInteraction000512928 => 1, WBInteraction000512929 => 1,
    WBInteraction000512930 => 1, WBInteraction000512931 => 1, WBInteraction000512932 => 1, WBInteraction000512933 => 1,
    WBInteraction000512934 => 1, WBInteraction000512935 => 1, WBInteraction000514981 => 1, WBInteraction000514982 => 1,
    WBInteraction000514983 => 1, WBInteraction000514984 => 1, WBInteraction000514985 => 1, WBInteraction000514986 => 1,
    WBInteraction000514987 => 1, WBInteraction000514988 => 1, WBInteraction000514989 => 1, WBInteraction000514990 => 1,
    WBInteraction000514991 => 1, WBInteraction000514992 => 1, WBInteraction000514993 => 1, WBInteraction000514994 => 1,
    WBInteraction000514995 => 1, WBInteraction000514996 => 1, WBInteraction000514997 => 1, WBInteraction000514998 => 1,
    WBInteraction000514999 => 1, WBInteraction000515000 => 1, WBInteraction000515001 => 1, WBInteraction000515002 => 1,
    WBInteraction000515003 => 1, WBInteraction000515004 => 1, WBInteraction000515005 => 1, WBInteraction000515006 => 1,
    WBInteraction000515007 => 1, WBInteraction000515008 => 1, WBInteraction000515009 => 1, WBInteraction000515010 => 1,
    WBInteraction000515011 => 1, WBInteraction000515012 => 1, WBInteraction000515013 => 1, WBInteraction000515014 => 1,
    WBInteraction000515015 => 1, WBInteraction000515016 => 1, WBInteraction000515017 => 1, WBInteraction000515018 => 1,
    WBInteraction000515029 => 1, WBInteraction000515030 => 1, WBInteraction000515031 => 1, WBInteraction000515032 => 1,
    WBInteraction000515033 => 1, WBInteraction000515034 => 1, WBInteraction000515035 => 1, WBInteraction000515036 => 1,
    WBInteraction000515037 => 1, WBInteraction000515038 => 1, WBInteraction000515054 => 1, WBInteraction000515055 => 1,
    WBInteraction000515056 => 1, WBInteraction000515057 => 1, WBInteraction000515058 => 1, WBInteraction000515059 => 1,
    WBInteraction000515060 => 1, WBInteraction000515061 => 1, WBInteraction000515062 => 1, WBInteraction000515063 => 1,
    WBInteraction000515064 => 1, WBInteraction000515065 => 1, WBInteraction000515066 => 1, WBInteraction000515067 => 1,
    WBInteraction000515072 => 1, WBInteraction000515073 => 1, WBInteraction000515074 => 1, WBInteraction000515075 => 1,
    WBInteraction000515076 => 1, WBInteraction000515077 => 1, WBInteraction000515078 => 1, WBInteraction000515079 => 1,
    WBInteraction000515080 => 1, WBInteraction000515081 => 1, WBInteraction000515082 => 1, WBInteraction000515083 => 1,
    WBInteraction000515084 => 1, WBInteraction000515085 => 1, WBInteraction000515086 => 1, WBInteraction000515087 => 1,
    WBInteraction000515088 => 1, WBInteraction000515089 => 1, WBInteraction000515090 => 1, WBInteraction000515091 => 1,
    WBInteraction000515092 => 1, WBInteraction000515093 => 1, WBInteraction000515094 => 1, WBInteraction000515095 => 1,
    WBInteraction000515096 => 1, WBInteraction000515097 => 1, WBInteraction000515098 => 1, WBInteraction000515099 => 1,
    WBInteraction000515100 => 1, WBInteraction000515101 => 1, WBInteraction000515102 => 1, WBInteraction000515103 => 1,
    WBInteraction000515104 => 1, WBInteraction000515105 => 1, WBInteraction000515106 => 1, WBInteraction000515107 => 1,
    WBInteraction000515108 => 1, WBInteraction000515109 => 1, WBInteraction000515110 => 1, WBInteraction000515111 => 1,
    WBInteraction000515112 => 1, WBInteraction000515163 => 1, WBInteraction000515164 => 1, WBInteraction000515540 => 1,
    WBInteraction000515541 => 1, WBInteraction000515542 => 1, WBInteraction000516462 => 1, WBInteraction000516463 => 1,
    WBInteraction000516464 => 1, WBInteraction000516465 => 1, WBInteraction000516466 => 1, WBInteraction000516467 => 1,
    WBInteraction000516468 => 1, WBInteraction000516469 => 1, WBInteraction000516470 => 1, WBInteraction000516471 => 1,
    WBInteraction000516472 => 1, WBInteraction000516473 => 1, WBInteraction000516474 => 1, );

    if ($bad_interactions{$interaction}) { return 1 }
    else { return 0 }
}

1;